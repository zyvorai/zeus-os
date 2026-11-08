#!/usr/bin/env bash
# Builds, signs, packages and (optionally) notarizes Zeus.app as a DMG.
#
#   scripts/release.sh                      # build + sign + DMG, no notarization
#   NOTARY_PROFILE=zeus scripts/release.sh  # also notarize, staple and verify
#
# One-time setup for notarization (stores credentials in your keychain, nothing lands in the repo):
#   xcrun notarytool store-credentials zeus --apple-id you@example.com --team-id TEAMID
#
# Environment:
#   SIGN_IDENTITY   "Developer ID Application: ..." (default: the first one in your keychain)
#   TEAM_ID         10-character team id (default: read from the identity)
#   NOTARY_PROFILE  notarytool keychain profile; unset means skip notarization
#   OUT             output directory (default: macos/dist)
set -euo pipefail
cd "$(dirname "$0")/.."

OUT="${OUT:-dist}"
IDENTITY="${SIGN_IDENTITY:-$(security find-identity -v -p codesigning | sed -n 's/.*"\(Developer ID Application:[^"]*\)".*/\1/p' | head -1)}"
[ -n "$IDENTITY" ] || { echo "No 'Developer ID Application' identity found. Set SIGN_IDENTITY." >&2; exit 1; }
TEAM="${TEAM_ID:-$(printf '%s' "$IDENTITY" | sed -n 's/.*(\([A-Z0-9]\{10\}\)).*/\1/p')}"
[ -n "$TEAM" ] || { echo "Couldn't read the team id from the identity. Set TEAM_ID." >&2; exit 1; }

rm -rf "$OUT"; mkdir -p "$OUT"
echo "==> Building Release signed as: $IDENTITY"
xcodebuild -project Zeus.xcodeproj -scheme Zeus -configuration Release -derivedDataPath "$OUT/dd" \
  CODE_SIGN_STYLE=Manual CODE_SIGN_IDENTITY="$IDENTITY" DEVELOPMENT_TEAM="$TEAM" \
  OTHER_CODE_SIGN_FLAGS="--timestamp" build | tail -1
APP="$OUT/dd/Build/Products/Release/Zeus.app"

echo "==> Verifying signature"
codesign --verify --deep --strict --verbose=2 "$APP"
INFO=$(codesign -dv --verbose=2 "$APP" 2>&1)
case "$INFO" in *"(runtime)"*) ;; *) echo "Hardened runtime is off." >&2; exit 1 ;; esac

echo "==> Making DMG"
STAGE="$OUT/dmg"; mkdir -p "$STAGE"; cp -R "$APP" "$STAGE/"; ln -s /Applications "$STAGE/Applications"
DMG="$OUT/Zeus.dmg"
hdiutil create -quiet -volname Zeus -srcfolder "$STAGE" -ov -format UDZO "$DMG"
codesign --force --timestamp --sign "$IDENTITY" "$DMG"

if [ -z "${NOTARY_PROFILE:-}" ]; then
  echo "==> Skipping notarization (NOTARY_PROFILE not set). Gatekeeper will reject this build until it is notarized."
  echo "Done: $DMG"; exit 0
fi

echo "==> Notarizing (this waits for Apple)"
xcrun notarytool submit "$DMG" --keychain-profile "$NOTARY_PROFILE" --wait
echo "==> Stapling"
xcrun stapler staple "$DMG"
xcrun stapler validate "$DMG"
echo "==> Gatekeeper check"
spctl -a -t open --context context:primary-signature -vv "$DMG"
echo "Done: $DMG"
