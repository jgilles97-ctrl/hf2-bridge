#!/bin/zsh
set -u
ROOT="${HF2_BRIDGE_ROOT:-${HOME}/Projects/hf2-bridge}"
PATH="/opt/homebrew/bin:/usr/local/bin:${HOME}/.local/bin:/usr/bin:/bin"
export PATH
"$ROOT/scripts/hf2" status > "$ROOT/STATE/status.md"
player=$(find "$HOME/Library/Application Support/CrossOver/Bottles/HF2-Test/drive_c" -type f -iname 'Player.log' -print 2>/dev/null | head -1)
[[ -f "$player" ]] && tail -200 "$player" > "$ROOT/STATE/logs/Player.log.tail" || print -r -- "Player.log not found" > "$ROOT/STATE/logs/Player.log.tail"
[[ -f "$HOME/Library/Logs/hf2bridge.log" ]] && tail -200 "$HOME/Library/Logs/hf2bridge.log" > "$ROOT/STATE/logs/bridge.log.tail" || print -r -- "bridge log not found" > "$ROOT/STATE/logs/bridge.log.tail"

