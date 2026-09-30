#!/bin/bash
set -e
umask 077
if [ ! -f "$HOME/openhands/service.env" ]; then
printf 'LOCAL_BACKEND_API_KEY=%s\nOH_SECRET_KEY=%s\nOH_CANVAS_SAFE_BACKEND_PORT=48081\nOH_CANVAS_SAFE_AUTOMATION_PORT=48082\nOH_CANVAS_SAFE_STATE_DIR=%s/openhands/state/agent-canvas\nOPENHANDS_MODE=--backend-only\n' "$(openssl rand -hex 32)" "$(openssl rand -hex 32)" "$HOME" > "$HOME/openhands/service.env"
fi
mkdir -p "$HOME/Library/LaunchAgents" "$HOME/openhands/logs"
cat > "$HOME/Library/LaunchAgents/dev.openhands.satellite.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>Label</key><string>dev.openhands.satellite</string>
<key>ProgramArguments</key><array><string>/bin/bash</string><string>$HOME/openhands/start.sh</string></array>
<key>RunAtLoad</key><true/><key>KeepAlive</key><true/><key>ThrottleInterval</key><integer>30</integer>
<key>StandardOutPath</key><string>$HOME/openhands/logs/service.log</string>
<key>StandardErrorPath</key><string>$HOME/openhands/logs/service.err</string>
</dict></plist>
PLIST
launchctl bootstrap "gui/$(id -u)" "$HOME/Library/LaunchAgents/dev.openhands.satellite.plist"
