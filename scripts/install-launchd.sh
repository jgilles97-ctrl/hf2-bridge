#!/bin/zsh
set -u
ROOT="${HF2_BRIDGE_ROOT:-${HOME}/Projects/hf2-bridge}"
label="com.$USER.hf2bridge"
dir="$HOME/Library/LaunchAgents"
plist="$dir/$label.plist"
mkdir -p "$dir" "$HOME/Library/Logs"
if [[ -f "$plist" ]]; then cp "$plist" "$plist.orig"; fi
python3 - "$plist" "$ROOT" "$label" "$HOME" <<'PY'
import plistlib, sys
path, root, label, home = sys.argv[1:]
data = {"Label": label, "ProgramArguments": [root + "/scripts/watcher.sh"], "StartInterval": 60, "ThrottleInterval": 30, "RunAtLoad": True, "StandardOutPath": home + "/Library/Logs/hf2bridge.log", "StandardErrorPath": home + "/Library/Logs/hf2bridge.log"}
with open(path, "wb") as f:
    plistlib.dump(data, f)
PY
plutil -lint "$plist" >/dev/null || { print -u2 -- "invalid plist"; exit 1; }
launchctl unload "$plist" 2>/dev/null || true
launchctl load "$plist"
print -r -- "installed and loaded: $plist"

