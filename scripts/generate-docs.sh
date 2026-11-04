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
