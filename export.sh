#!/usr/bin/env bash
set -euo pipefail

GODOT_BIN=${GODOT_BIN:-godot4}

"$GODOT_BIN" --headless --path . --export-release "Windows Desktop" "dist/ApexGame.exe"
echo "Export complete: dist/ApexGame.exe"
