#!/bin/zsh
# Builds assets/AppIcon.icns from assets/icon_1024.png. Re-run whenever the artwork changes.
set -euo pipefail
cd "$(dirname "$0")/.."

TMP="$(mktemp -d)"
ICONSET="$TMP/AppIcon.iconset"
mkdir -p "$ICONSET"

swift scripts/make-icon.swift assets/icon_1024.png "$TMP/icon-1024.png"
for size in 16 32 128 256 512; do
  sips -z $size $size "$TMP/icon-1024.png" --out "$ICONSET/icon_${size}x${size}.png" >/dev/null
  sips -z $((size * 2)) $((size * 2)) "$TMP/icon-1024.png" --out "$ICONSET/icon_${size}x${size}@2x.png" >/dev/null
done
iconutil -c icns "$ICONSET" -o assets/AppIcon.icns
rm -rf "$TMP"
echo "Wrote assets/AppIcon.icns"
