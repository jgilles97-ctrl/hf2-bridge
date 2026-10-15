#!/bin/zsh
set -u
umask 077
ROOT="${HF2_BRIDGE_ROOT:-${HOME}/Projects/hf2-bridge}"
PATH="/opt/homebrew/bin:/usr/local/bin:${HOME}/.local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
export PATH
PRIVATE_LOG_DIR="$ROOT/.private-state/logs"
mkdir -p "$PRIVATE_LOG_DIR"
tmp=$(mktemp "$ROOT/STATE/.status.XXXXXX")
"$ROOT/scripts/hf2" public-status > "$tmp"
if [[ -f "$ROOT/STATE/status.md" ]] && diff -q "$ROOT/STATE/status.md" "$tmp" >/dev/null 2>&1; then
  rm -f "$tmp"
else
  mv "$tmp" "$ROOT/STATE/status.md"
fi
player=$(find "$HOME/Library/Application Support/CrossOver/Bottles/HF2-Test/drive_c" -type f -iname 'Player.log' -print 2>/dev/null | head -1)
[[ -f "$player" ]] && tail -200 "$player" > "$PRIVATE_LOG_DIR/Player.log.tail" || print -r -- "Player.log not found" > "$PRIVATE_LOG_DIR/Player.log.tail"
[[ -f "$HOME/Library/Logs/hf2bridge.log" ]] && tail -200 "$HOME/Library/Logs/hf2bridge.log" > "$PRIVATE_LOG_DIR/bridge.log.tail" || print -r -- "bridge log not found" > "$PRIVATE_LOG_DIR/bridge.log.tail"

