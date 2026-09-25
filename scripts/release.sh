#!/bin/zsh
# Produces a signed, notarized, stapled dist/PortKill-<version>.dmg.
#
# Requires a paid Apple Developer account and a "Developer ID Application" certificate.
#
#   SIGN_IDENTITY="Developer ID Application: Your Name (TEAMID)" ./scripts/release.sh
#
# Notarization credentials, either:
#   NOTARY_PROFILE   keychain profile (default: portkill-notary), created once with
#                    xcrun notarytool store-credentials portkill-notary --apple-id <id> --team-id <team> --password <app-specific-password>
#   or APPLE_ID + APPLE_TEAM_ID + APPLE_APP_PASSWORD   (used by GitHub Actions)
set -euo pipefail
cd "$(dirname "$0")/.."

: "${SIGN_IDENTITY:?Set SIGN_IDENTITY to your Developer ID Application identity}"
if [[ "$SIGN_IDENTITY" == "-" ]]; then
  echo "Refusing to release with an ad-hoc signature." >&2
  exit 1
fi

VERSION="$(tr -d '[:space:]' < VERSION)"
DMG="dist/PortKill-${VERSION}.dmg"

if [[ -n "${APPLE_ID:-}" ]]; then
  : "${APPLE_TEAM_ID:?}" "${APPLE_APP_PASSWORD:?}"
  NOTARY_ARGS=(--apple-id "$APPLE_ID" --team-id "$APPLE_TEAM_ID" --password "$APPLE_APP_PASSWORD")
else
  NOTARY_ARGS=(--keychain-profile "${NOTARY_PROFILE:-portkill-notary}")
fi

# Build, then re-sign with a secure timestamp, which notarization requires.
./scripts/build-app.sh
codesign --force --options runtime --timestamp --sign "$SIGN_IDENTITY" build/PortKill.app
codesign --verify --strict --verbose=2 build/PortKill.app

./scripts/make-dmg.sh "$DMG"

xcrun notarytool submit "$DMG" "${NOTARY_ARGS[@]}" --wait
xcrun stapler staple "$DMG"
xcrun stapler validate "$DMG"
spctl --assess --type open --context context:primary-signature --verbose=2 "$DMG"

echo "Release ready: $DMG"
shasum -a 256 "$DMG"
