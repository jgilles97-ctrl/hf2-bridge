#!/bin/zsh
set -u
PATH="/opt/homebrew/bin:/usr/local/bin:${HOME}/.local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
export PATH
ROOT="${HF2_BRIDGE_ROOT:-${HOME}/Projects/hf2-bridge}"
ENV_FILE="${HOME}/.config/hf2-bridge/env"
TASK="${1:-}"
TIMEOUT_SECONDS="${HF2_TASK_TIMEOUT_SECONDS:-300}"
if [[ -z "$TASK" || ! -f "$TASK" ]]; then print -u2 "usage: run-task.sh INBOX/T-xxxx.md"; exit 64; fi
if [[ "$TASK" != "$ROOT/INBOX/"* ]]; then print -u2 "task must be inside $ROOT/INBOX"; exit 64; fi
base=$(basename "$TASK" .md)
number=${base#T-}
result="$ROOT/OUTBOX/R-${number}.md"
if [[ -f "$result" ]]; then print -u2 "result already exists: $result"; exit 73; fi
tmp=$(mktemp "$ROOT/OUTBOX/.R-${number}.XXXXXX")
cleanup() { rm -f "$tmp"; }
trap cleanup EXIT INT TERM
print -r -- "# Result R-${number}" > "$tmp"
print -r -- "" >> "$tmp"
print -r -- "Task source: ${base}.md" >> "$tmp"
print -r -- "Started: $(date -u '+%Y-%m-%dT%H:%M:%SZ')" >> "$tmp"
print -r -- "" >> "$tmp"
if [[ ! -f "$ENV_FILE" ]]; then
  print -r -- "Status: FAILED" >> "$tmp"
  print -r -- "Reason: missing $ENV_FILE; Venice credentials have not been configured." >> "$tmp"
  print -r -- "WHAT I ACTUALLY VERIFIED: The task file was found, but no Venice worker credentials were available." >> "$tmp"
  print -r -- "NEXT HIGHEST-LEVERAGE BLOCKER: Configure the private Venice env file, then retry this task." >> "$tmp"
  print -r -- "Finished: $(date -u '+%Y-%m-%dT%H:%M:%SZ')" >> "$tmp"
  mv "$tmp" "$result"
  trap - EXIT INT TERM
  exit 0
fi
setopt allexport
source "$ENV_FILE"
setopt noallexport
payload="Read $TASK, HANDOFF.md, and RUNBOOK.md. Perform the task exactly as written. Return a concise plain-English result with the task mirrored, WHAT I ACTUALLY VERIFIED, and NEXT HIGHEST-LEVERAGE BLOCKER. Include command output as evidence. Do not invent evidence."
system_prompt="$(< "$ROOT/goose/system-prompt.md")"
runner=(goose run --no-session --no-profile --max-turns 8 --quiet --with-builtin developer --with-builtin github --with-builtin memory --system "$system_prompt" --text "$payload")
if command -v perl >/dev/null 2>&1; then perl -e 'alarm shift; exec @ARGV' "$TIMEOUT_SECONDS" "${runner[@]}" >> "$tmp" 2>&1; rc=$?; else "${runner[@]}" >> "$tmp" 2>&1; rc=$?; fi
print -r -- "" >> "$tmp"
if (( rc == 0 )); then print -r -- "Status: VERIFIED" >> "$tmp"; else print -r -- "Status: FAILED" >> "$tmp"; print -r -- "Reason: Goose exited with status ${rc}; see the captured output above." >> "$tmp"; fi
print -r -- "Finished: $(date -u '+%Y-%m-%dT%H:%M:%SZ')" >> "$tmp"
mv "$tmp" "$result"
trap - EXIT INT TERM
exit 0

