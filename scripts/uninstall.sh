#!/bin/zsh
set -u
label="com.$USER.hf2bridge"
plist="$HOME/Library/LaunchAgents/$label.plist"
launchctl unload "$plist" 2>/dev/null || true
if [[ -f "$plist" ]]; then mv "$plist" "$plist.orig.$(date -u '+%Y%m%dT%H%M%SZ')"; fi
print -r -- "launchd job removed from service; repository and game files were left untouched"

