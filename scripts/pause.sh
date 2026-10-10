#!/bin/zsh
set -u
label="com.$USER.hf2bridge"
plist="$HOME/Library/LaunchAgents/$label.plist"
launchctl unload "$plist" 2>/dev/null || true
print -r -- "paused: $label"

