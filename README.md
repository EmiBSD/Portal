# www.emibsd.org

The public website of EmiBSD: plain Jekyll, built by GitHub Pages itself, one stylesheet of its
own (`assets/css/site.css`), no theme and no framework. Everything the site needs is in this
folder; it does not read `../docs/`, which holds the project's working documents.

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

The navigation is the `nav` list in `_config.yml`; keep it at seven entries. A news entry is a
file `news/_posts/YYYY-MM-DD-slug.md` with a `title` (and an optional `description`) in its
front matter; the home page shows the latest three, `/news/feed.xml` all of them.

`status.md` is written from the repository: the file counts of each crate and directory and the
totals of `cargo xtask unsafe-report`, at the commit it names. Update both together.

## Build locally

```sh
cd site
bundle config set --local path vendor/bundle   # once: gems stay inside site/vendor/
bundle install
bundle exec jekyll build                       # into site/_site/
bundle exec jekyll serve                       # http://127.0.0.1:4000
```

The `Gemfile` uses the `github-pages` gem, so the local Jekyll and plugins are the ones GitHub
Pages runs.

## Publishing

`CNAME` holds `www.emibsd.org` and `_config.yml` sets `url: "https://www.emibsd.org"` and
`baseurl: ""`.

GitHub Pages, when it builds from a branch with its own Jekyll (no Actions), can serve only the
root of a branch or its `/docs` folder: **Settings > Pages > Build and deployment > Source:
Deploy from a branch** offers `/ (root)` and `/docs`, not `/site`. So `site/` cannot be
selected there directly. Without a workflow, the way to publish it is a branch whose root is
this folder:

```sh
git subtree split --prefix site -b gh-pages     # first time
git push origin gh-pages
# later updates:
git subtree push --prefix site origin gh-pages
```

Then, in **Settings > Pages**: Source **Deploy from a branch**, branch **`gh-pages`**, folder
**`/ (root)`**, and custom domain **`www.emibsd.org`**. GitHub Pages runs Jekyll on that branch
as it does today on `main:/docs`.

With a GitHub Actions workflow instead, `site/` could be built straight from `main` (Source:
**GitHub Actions**). This project does not use one.
