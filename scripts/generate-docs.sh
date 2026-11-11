#!/usr/bin/env bash
# Generates combined DocC documentation (Livebox + LiveboxAsync) for GitHub Pages into ./docs
set -euo pipefail

cd "$(dirname "$0")/.."

OUTPUT_DIR="docs"
# Project pages are served at https://masorange.github.io/livebox-sdk-swift/
HOSTING_BASE_PATH="${HOSTING_BASE_PATH:-livebox-sdk-swift}"

rm -rf "$OUTPUT_DIR"

swift package --allow-writing-to-directory "$OUTPUT_DIR" \
    generate-documentation \
    --target Livebox \
    --target LiveboxAsync \
    --enable-experimental-combined-documentation \
    --disable-indexing \
    --transform-for-static-hosting \
    --hosting-base-path "$HOSTING_BASE_PATH" \
    --output-path "$OUTPUT_DIR"

# DocC can't use custom content for the combined landing page yet, so render the top of the README
# (up to the docs-landing-end marker) and inject it into the synthesized page, keeping the module cards.
# readme-only blocks are dropped and `<!-- docs-only: ... -->` lines are uncommented.
# shortcut: image assets aren't copied, copy them too if the README top gets images.
LANDING_DIR="$(mktemp -d)"
trap 'rm -rf "$LANDING_DIR"' EXIT
mkdir "$LANDING_DIR/Landing.docc"
sed -e '/<!-- docs-landing-end/,$d' \
    -e '/<!-- readme-only-start/,/<!-- readme-only-end/d' \
    -e 's/^<!-- docs-only: \(.*\) -->$/\1/' README.md > "$LANDING_DIR/Landing.docc/Landing.md"
xcrun docc convert "$LANDING_DIR/Landing.docc" --output-path "$LANDING_DIR/out" >/dev/null
jq --slurpfile readme "$LANDING_DIR/out/data/documentation/landing.json" '
    .metadata.title = $readme[0].metadata.title
    | .abstract = $readme[0].abstract
    | .primaryContentSections = $readme[0].primaryContentSections
    | .references += ($readme[0].references // {})
' "$OUTPUT_DIR/data/documentation.json" > "$LANDING_DIR/documentation.json"
mv "$LANDING_DIR/documentation.json" "$OUTPUT_DIR/data/documentation.json"

# Skip Jekyll processing on GitHub Pages
touch "$OUTPUT_DIR/.nojekyll"

# DocC has no page at the site root, redirect it to the combined landing page
cat > "$OUTPUT_DIR/index.html" <<EOF
<!DOCTYPE html>
<meta charset="utf-8">
<meta http-equiv="refresh" content="0; url=/$HOSTING_BASE_PATH/documentation/">
<link rel="canonical" href="/$HOSTING_BASE_PATH/documentation/">
<a href="/$HOSTING_BASE_PATH/documentation/">Livebox SDK documentation</a>
EOF

echo "Docs generated in $OUTPUT_DIR → https://masorange.github.io/$HOSTING_BASE_PATH/documentation/"
