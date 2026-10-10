#!/bin/zsh
set -u
PATH="/opt/homebrew/bin:/usr/local/bin:${HOME}/.local/bin:/usr/bin:/bin"
export PATH HOME
ROOT="${HF2_BRIDGE_ROOT:-${HOME}/Projects/hf2-bridge}"
LOCK="$ROOT/.locks/run"
LOG="$HOME/Library/Logs/hf2bridge.log"
mkdir -p "$ROOT/.locks" "$HOME/Library/Logs"
log() { print -r -- "$(date -u '+%Y-%m-%dT%H:%M:%SZ') $*" >> "$LOG"; }
if mkdir "$LOCK" 2>/dev/null; then
  trap 'rmdir "$LOCK" 2>/dev/null || true' EXIT INT TERM
else
  lock_age=$(( $(date +%s) - $(stat -f %m "$LOCK" 2>/dev/null || date +%s) ))
  if (( lock_age > 1800 )); then rmdir "$LOCK" 2>/dev/null && log "broke stale lock older than 30 minutes" || { log "stale lock could not be broken"; exit 0; }; else exit 0; fi
  mkdir "$LOCK" 2>/dev/null || exit 0
  trap 'rmdir "$LOCK" 2>/dev/null || true' EXIT INT TERM
fi
cd "$ROOT" || { log "cannot enter repository"; exit 1; }
if ! git pull --rebase --autostash >> "$LOG" 2>&1; then log "git pull failed; no task processed"; exit 1; fi
"$ROOT/scripts/refresh-state.sh" >> "$LOG" 2>&1 || log "state refresh failed"
task=""
for candidate in "$ROOT"/INBOX/T-*.md; do
  [[ -f "$candidate" ]] || continue
  n=$(basename "$candidate" .md | sed 's/^T-//')
  [[ -f "$ROOT/OUTBOX/R-${n}.md" ]] && continue
  task="$candidate"
  break
done
if [[ -n "$task" ]]; then log "processing $(basename "$task")"; "$ROOT/scripts/run-task.sh" "$task" >> "$LOG" 2>&1 || log "run-task returned nonzero"; else log "no pending task"; fi
git add -A -- ':!*.log' ':!*.orig'
if ! git diff --cached --quiet; then git commit -m "chore(bridge): record watcher cycle" >> "$LOG" 2>&1 || log "commit failed"; git push >> "$LOG" 2>&1 || log "push failed"; else log "no meaningful repository changes to commit"; fi

