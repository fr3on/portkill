#!/bin/zsh
# Wraps build/PortKill.app in a drag-to-Applications disk image.
#
#   ./scripts/make-dmg.sh [output.dmg]     default: dist/PortKill-<version>.dmg
#   SIGN_IDENTITY   if set (and not "-"), the DMG itself is codesigned
#
# Does not notarize; scripts/release.sh does that on top of this.
set -euo pipefail
cd "$(dirname "$0")/.."

VERSION="$(tr -d '[:space:]' < VERSION)"
DMG="${1:-dist/PortKill-${VERSION}.dmg}"
[[ -d build/PortKill.app ]] || { echo "build/PortKill.app not found; run scripts/build-app.sh first" >&2; exit 1; }

STAGING="$(mktemp -d)"
trap 'rm -rf "$STAGING"' EXIT
cp -R build/PortKill.app "$STAGING/"
ln -s /Applications "$STAGING/Applications"

mkdir -p "$(dirname "$DMG")"
rm -f "$DMG"
hdiutil create -volname "PortKill" -srcfolder "$STAGING" -ov -format UDZO "$DMG" >/dev/null

if [[ -n "${SIGN_IDENTITY:-}" && "$SIGN_IDENTITY" != "-" ]]; then
  codesign --force --sign "$SIGN_IDENTITY" --timestamp "$DMG"
fi
echo "Wrote $DMG"
