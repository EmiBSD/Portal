# www.emibsd.org

The public website of EmiBSD: plain Jekyll, one stylesheet of its own (`assets/css/site.css`),
no theme and no framework. The code lives in [EmiBSD/Kernel](https://github.com/EmiBSD/Kernel)
(the redesigned kernel) and [EmiBSD/LandingZone](https://github.com/EmiBSD/LandingZone) (the
file-by-file port, formerly EmiBSD.LZ); this repository holds only the site and reads nothing
from them at build time.

## Pages

| File | URL | Nav |
|---|---|---|
| `index.md` | `/` | Home |
| `about.md` | `/about/` | About |
| `process.md` | `/process/` | Process |
| `status.md` | `/status/` | Status |
| `news/index.md`, `news/_posts/` | `/news/` | News |
| `docs-site.md` | `/docs/` | Docs |
| `contributing.md` | `/contributing/` | Contributing |
| `support.md` | `/support/` | footer only |

The navigation is the `nav` list in `_config.yml`; keep it at seven entries.

## News

The devlog is `_data/news.json`, one object per line shown on the pages. The home page shows
the latest five, `/news/` all of them, both through `_includes/news-list.html`, which sorts by
`date`, newest first, whatever the order in the file. Fields:

- `date`: ISO 8601 with the offset, as `git log -1 --date=iso-strict` prints it; the pages
  sort by it and show its day. Keep one offset for every entry so the string order is the time
  order.
- `post`: the slug of a file `news/_posts/YYYY-MM-DD-slug.md` (`n4-met` for
  `2026-10-24-n4-met.md`); the line takes that post's `title` and URL. A post has a `title`
  and an optional `description` in its front matter; `/news/feed.xml` carries the posts only.
- `title` and `url`, when there is no post: the line itself and where it links (a milestone's
  tag in Kernel, its closing commit in LandingZone).
- `repo`: `LandingZone` or `Kernel`, shown before the line: a LandingZone milestone or
  sub-milestone (M16a), or a Kernel slice (`N5.0 done: ...`, linking to its merge commit).

Kernel's slices are written here, one line each when it merges; Kernel's milestones are not:
the list adds every met milestone of
`_data/status.json` (its `date`, `url` and optional `post`), labelled `Kernel`, so a milestone
close is recorded once, in that file.

## Status

`status.md` renders `_data/status.json`, which holds what changes at a milestone close, taken
from the Kernel repository at the commit it names:

- `commit`, `date`, `at`: the commit the figures come from, its day, and what it was (`the
  close of N4`).
- `crates`: one object per crate, `name`, `files`, `unsafe` (the totals of `cargo xtask
  unsafe-report`), `note`, and an optional `label` shown after the name.
- `milestones`: one object per `N` milestone, `name`, `title`, `scope`; a met one has `date`
  (the tag's, `git log -1 --date=iso-strict n<N>-<name>`) and `url` (the tag), and `post` when a
  news post tells the story; one under way has `state: "in progress"`; the rest are pending.
- `next`: the milestone under way, `name` and its `slices` (`slice`, `what`, optional `state`
  `done` or `in progress`).

The prose of `status.md` (what works, the next milestone's paragraph) is edited by hand when
a milestone closes, in the same change as the data.

The `site-updater` agent (`.claude/agents/site-updater.md`) makes all of these edits from the
records of the two code repositories, checked out beside this one as `../Kernel` and
`../LandingZone`: launch it with the tag of the close (`n5-vfs`) or the LandingZone commit.
It builds the site, reports every figure with its source, and never pushes.

## Build locally

```sh
bundle config set --local path vendor/bundle   # once: gems stay inside vendor/
bundle install
bundle exec jekyll build                       # into _site/
bundle exec jekyll serve                       # http://127.0.0.1:4000
```

The `Gemfile` pins the Jekyll, Liquid, kramdown and jekyll-feed versions of GitHub Pages'
`github-pages` gem (v232); that gem itself does not install on Ruby 4.

## Publishing

Every push to `main` runs `.github/workflows/jekyll.yml`, which builds the site and deploys it to
GitHub Pages (**Settings > Pages > Source: GitHub Actions**). `CNAME` holds `www.emibsd.org`,
and `_config.yml` sets `url: "https://www.emibsd.org"` and `baseurl: ""`. The DNS for `emibsd.org` points `www` at GitHub Pages (CNAME to
`emibsd.github.io`) and the apex at GitHub's Pages addresses, which redirect to `www`.

## Headers

GitHub Pages sets the response headers and lets a site set none of its own. Cloudflare proxies
`www.emibsd.org` (the DNS of `emibsd.org` is there, every record proxied, SSL/TLS Full (strict)),
and a Response Header Transform Rule on that zone sets the headers GitHub does not:
`Content-Security-Policy` (the policy below plus `frame-ancestors 'none'`), `X-Frame-Options: DENY`,
`X-Content-Type-Options: nosniff`, `Strict-Transport-Security: max-age=31536000` and
`Referrer-Policy`, and removes GitHub's `Access-Control-Allow-Origin: *`. Turning the proxy off
loses them all; what a page can carry itself, it still does:

- `_layouts/default.html` has a `<meta http-equiv="Content-Security-Policy">` that allows the
  site's own stylesheet and images, and one script source besides the site's own: Google Tag
  Manager (`www.googletagmanager.com`, container `GTM-WKQ3JT59`, with Google Analytics' image
  and connect origins). No forms, no `<base>`, nothing inline: the data layer's three lines are
  `assets/js/gtm-init.js`. So no `style=` attribute, no `<style>` element and no `<script>`
  without a `src` may appear in a page; the build fails if one does. The Cloudflare rule's
  header must carry the same `script-src`, `img-src` and `connect-src`, or it blocks the tag. Kramdown's `|---:|` column alignment writes a `style` attribute,
  so a table that needs it takes the `{: .numbers}` class instead (`assets/css/site.css`).
  Browsers ignore `frame-ancestors` in a meta tag, which is why the header exists.
- `404.html` replaces GitHub's own 404 page, whose policy allows inline styles.
- `robots.txt` and `sitemap.xml` (jekyll-sitemap) exist, so a crawler asking for them gets a file
  and not a 404.

A ZAP scan of the site should report only the two informational cache alerts; a Content Security
Policy alert means a page broke the rule above, a header alert means the proxy or its rule is off.
