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
- `repo`: `Kernel` or `LandingZone`, shown before the line when the entry is a milestone of
  that repository.

A milestone close adds its entry here, with the tag's or the commit's date, in the same change
that updates `status.md`.

`status.md` is written from the Kernel repository: the file counts of each crate and directory
and the totals of `cargo xtask unsafe-report`, at the commit it names. Update both together.

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
