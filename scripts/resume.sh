#!/bin/zsh
set -u
label="com.$USER.hf2bridge"
plist="$HOME/Library/LaunchAgents/$label.plist"
[[ -f "$plist" ]] || { print -u2 -- "missing $plist"; exit 1; }
launchctl load "$plist"
print -r -- "resumed: $label"

