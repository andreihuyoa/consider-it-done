#!/usr/bin/env bash
# Standard startup + verification path.
# Run this at the start of every agent session and before marking any
# feature_list.json entry as "passing".
set -euo pipefail

SCHEME="consider it done"
IOS_DEST="platform=iOS Simulator,name=iPhone 17"

echo "==> Building (iOS)"
xcodebuild -scheme "$SCHEME" -destination "$IOS_DEST" build

echo "==> Running unit tests (iOS)"
if rg -q 'PBXNativeTarget.*Tests|productType = "com.apple.product-type.bundle.unit-test"' "consider it done.xcodeproj/project.pbxproj"; then
  xcodebuild -scheme "$SCHEME" -destination "$IOS_DEST" test
else
  echo "==> No unit-test target is configured; skipping test action"
fi

echo "==> init.sh passed: build is green; configured unit-test action checked"
echo "Reminder: unit tests alone are not full feature verification."
echo "Run the specific commands in this feature's feature_list.json entry"
echo "(including any manual Simulator steps) before marking it passing."
