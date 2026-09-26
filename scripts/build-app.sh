#!/bin/zsh
# Builds a universal (arm64 + x86_64) PortKill and wraps it in a menu-bar-only app bundle at build/PortKill.app.
#
#   SIGN_IDENTITY   codesign identity; defaults to "-" (ad-hoc, fine for local use, not for distribution)
#   BUILD_NUMBER    CFBundleVersion; defaults to the git commit count, or 1 outside a repo
set -euo pipefail
cd "$(dirname "$0")/.."

VERSION="$(tr -d '[:space:]' < VERSION)"
BUILD_NUMBER="${BUILD_NUMBER:-$(git rev-list --count HEAD 2>/dev/null || echo 1)}"
SIGN_IDENTITY="${SIGN_IDENTITY:--}"

swift build -c release --arch arm64 --arch x86_64
BIN="$(swift build -c release --arch arm64 --arch x86_64 --show-bin-path)/PortKill"
APP="build/PortKill.app"

rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$BIN" "$APP/Contents/MacOS/PortKill"
cp assets/AppIcon.icns "$APP/Contents/Resources/AppIcon.icns"
cp assets/icon.png "$APP/Contents/Resources/icon.png"
cp assets/logo.png "$APP/Contents/Resources/logo.png"

cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>CFBundleIdentifier</key><string>com.0x200.portkill</string>
  <key>CFBundleName</key><string>PortKill</string>
  <key>CFBundleDisplayName</key><string>PortKill</string>
  <key>CFBundleExecutable</key><string>PortKill</string>
  <key>CFBundleIconFile</key><string>AppIcon</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>${VERSION}</string>
  <key>CFBundleVersion</key><string>${BUILD_NUMBER}</string>
  <key>LSMinimumSystemVersion</key><string>14.0</string>
  <key>LSApplicationCategoryType</key><string>public.app-category.developer-tools</string>
  <key>NSPrincipalClass</key><string>NSApplication</string>
  <key>LSUIElement</key><true/>
</dict></plist>
PLIST
plutil -lint "$APP/Contents/Info.plist" >/dev/null

# Hardened Runtime is required for notarization; PortKill needs no special entitlements.
codesign --force --options runtime --timestamp=none --sign "$SIGN_IDENTITY" "$APP"
codesign --verify --strict "$APP"
echo "Built $APP ($VERSION, build $BUILD_NUMBER) signed as: $SIGN_IDENTITY"
lipo -archs "$APP/Contents/MacOS/PortKill" | sed 's/^/Architectures: /'
