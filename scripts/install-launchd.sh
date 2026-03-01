#!/usr/bin/env bash
set -euo pipefail

PLIST="$HOME/Library/LaunchAgents/ai.mac-openclaw.mission-status.plist"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
NODE_BIN="$(command -v node)"

cat > "$PLIST" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>Label</key><string>ai.mac-openclaw.mission-status</string>
  <key>ProgramArguments</key>
  <array>
    <string>$NODE_BIN</string>
    <string>$ROOT/scripts/update-status.js</string>
  </array>
  <key>StartInterval</key><integer>300</integer>
  <key>RunAtLoad</key><true/>
  <key>WorkingDirectory</key><string>$ROOT</string>
  <key>StandardOutPath</key><string>$ROOT/status-refresh.log</string>
  <key>StandardErrorPath</key><string>$ROOT/status-refresh.log</string>
</dict></plist>
PLIST

launchctl unload "$PLIST" 2>/dev/null || true
launchctl load "$PLIST"
launchctl kickstart -k "gui/$(id -u)/ai.mac-openclaw.mission-status"
echo "installed: $PLIST"
