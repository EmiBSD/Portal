#!/bin/sh
# Render every _diagrams/*.mmd into assets/img/<name>.svg (light) and <name>-dark.svg, with the
# site's palette (_diagrams/theme-*.json). Needs mermaid-cli: `npm install -g @mermaid-js/mermaid-cli`.
# GitHub Pages renders nothing itself and the site's CSP allows no inline styles, so the SVGs are
# made here, committed, and shown with <picture> (see process.md). Run from the repository root.
set -eu
cd "$(dirname "$0")/.."
command -v mmdc >/dev/null || { echo "diagrams: mmdc not found; npm install -g @mermaid-js/mermaid-cli" >&2; exit 1; }
for src in _diagrams/*.mmd; do
    name=$(basename "$src" .mmd)
    mmdc -q -i "$src" -o "assets/img/$name.svg"      -c _diagrams/theme-light.json -b transparent
    mmdc -q -i "$src" -o "assets/img/$name-dark.svg" -c _diagrams/theme-dark.json  -b transparent
    echo "assets/img/$name.svg assets/img/$name-dark.svg"
done
