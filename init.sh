#!/usr/bin/env bash
# Standard startup + verification path.
# Run this at the start of every agent session and before marking any
# feature_list.json entry as "passing".
set -euo pipefail

SCHEME="ConsiderItDone"
IOS_DEST="platform=iOS Simulator,name=iPhone 16"

echo "==> Building (iOS)"
xcodebuild -scheme "$SCHEME" -destination "$IOS_DEST" build

echo "==> Running unit tests (iOS)"
xcodebuild -scheme "$SCHEME" -destination "$IOS_DEST" test

echo "==> init.sh passed: build + unit tests are green"
echo "Reminder: unit tests alone are not full feature verification."
echo "Run the specific commands in this feature's feature_list.json entry"
echo "(including any manual Simulator steps) before marking it passing."
