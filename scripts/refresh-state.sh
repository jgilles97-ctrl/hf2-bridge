#!/bin/zsh
set -u
ROOT="${HF2_BRIDGE_ROOT:-${HOME}/Projects/hf2-bridge}"
PATH="/opt/homebrew/bin:/usr/local/bin:${HOME}/.local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
export PATH
tmp=$(mktemp "$ROOT/STATE/.status.XXXXXX")
"$ROOT/scripts/hf2" status > "$tmp"
print -r -- "Generated at: $(date -u '+%Y-%m-%dT%H:%M:%SZ')" >> "$tmp"
if [[ -f "$ROOT/STATE/status.md" ]] && diff -q <(sed '/^Generated at:/d' "$ROOT/STATE/status.md") <(sed '/^Generated at:/d' "$tmp") >/dev/null 2>&1; then
  age=$(( $(date +%s) - $(stat -f %m "$ROOT/STATE/status.md" 2>/dev/null || date +%s) ))
  (( age >= 1800 )) && mv "$tmp" "$ROOT/STATE/status.md" || rm -f "$tmp"
else
  mv "$tmp" "$ROOT/STATE/status.md"
fi
player=$(find "$HOME/Library/Application Support/CrossOver/Bottles/HF2-Test/drive_c" -type f -iname 'Player.log' -print 2>/dev/null | head -1)
[[ -f "$player" ]] && tail -200 "$player" > "$ROOT/STATE/logs/Player.log.tail" || print -r -- "Player.log not found" > "$ROOT/STATE/logs/Player.log.tail"
[[ -f "$HOME/Library/Logs/hf2bridge.log" ]] && tail -200 "$HOME/Library/Logs/hf2bridge.log" > "$ROOT/STATE/logs/bridge.log.tail" || print -r -- "bridge log not found" > "$ROOT/STATE/logs/bridge.log.tail"

