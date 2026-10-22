source "https://rubygems.org"

# The versions GitHub Pages runs (the github-pages gem, v232), named one by one: the
# github-pages gem itself cannot be installed on Ruby 4 (its commonmarker needs Ruby < 4).
# GitHub Pages ignores this file; it only makes a local build match the published one.
gem "jekyll", "3.10.0"
gem "liquid", "4.0.4"
gem "kramdown", "2.4.0"
gem "kramdown-parser-gfm", "1.1.0"
gem "rouge", "3.30.0"

group :jekyll_plugins do
  gem "jekyll-feed", "0.17.0"
end

# Ruby 3.4+ no longer ships these as default gems; Jekyll 3 still needs them locally.
gem "webrick"
gem "csv"
gem "base64"
gem "bigdecimal"
gem "logger"
