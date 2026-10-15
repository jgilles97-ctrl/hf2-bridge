#!/bin/zsh
set -u
PATH="/opt/homebrew/bin:/usr/local/bin:${HOME}/.local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
export PATH
ROOT="${HF2_BRIDGE_ROOT:-${HOME}/Projects/hf2-bridge}"
ENV_FILE="${HOME}/.config/hf2-bridge/env"
TASK="${1:-}"
TIMEOUT_SECONDS="${HF2_TASK_TIMEOUT_SECONDS:-300}"
if [[ -z "$TASK" || ! -f "$TASK" ]]; then print -u2 "usage: run-task.sh INBOX/T-xxxx.md"; exit 64; fi
if [[ "$TASK" != "$ROOT/INBOX/"* ]]; then print -u2 "task must be inside the configured bridge inbox"; exit 64; fi
base=$(basename "$TASK" .md)
number=${base#T-}
result="$ROOT/OUTBOX/R-${number}.md"
if [[ -f "$result" ]]; then print -u2 "result already exists for task ${base}"; exit 73; fi
umask 077
PRIVATE_TASK_DIR="$ROOT/.private-state/task-output"
mkdir -p "$PRIVATE_TASK_DIR"
tmp=$(mktemp "$PRIVATE_TASK_DIR/.R-${number}.XXXXXX")
public_tmp=$(mktemp "$ROOT/OUTBOX/.R-${number}.XXXXXX")
cleanup() { rm -f "$tmp" "$public_tmp"; }
trap cleanup EXIT INT TERM
print -r -- "# Result R-${number}" > "$tmp"
print -r -- "" >> "$tmp"
print -r -- "Task source: ${base}.md" >> "$tmp"
print -r -- "Started: $(date -u '+%Y-%m-%dT%H:%M:%SZ')" >> "$tmp"
print -r -- "" >> "$tmp"
if [[ ! -f "$ENV_FILE" ]]; then
  print -r -- "Status: FAILED" >> "$tmp"
  print -r -- "Reason: private Venice credentials have not been configured." >> "$tmp"
  print -r -- "WHAT I ACTUALLY VERIFIED: The task file was found, but no private Venice worker credentials were available." >> "$tmp"
  print -r -- "NEXT HIGHEST-LEVERAGE BLOCKER: Configure the private Venice environment, then retry this task." >> "$tmp"
  print -r -- "Finished: $(date -u '+%Y-%m-%dT%H:%M:%SZ')" >> "$tmp"
  mv "$tmp" "$result"
  rm -f "$public_tmp"
  trap - EXIT INT TERM
  exit 0
fi
setopt allexport
source "$ENV_FILE"
setopt noallexport
payload="Read INBOX/${base}.md, HANDOFF.md, and RUNBOOK.md. Perform the task exactly as written. Anything written to OUTBOX is public: use hf2 public-status for shareable machine state and never include user names, absolute local paths, numeric storage or file sizes, software versions, unrelated project names, environment contents, credentials, or raw logs. Never run or paste hf2 status or hf2 logs for a public result. Return a concise plain-English result with the task mirrored, WHAT I ACTUALLY VERIFIED, and NEXT HIGHEST-LEVERAGE BLOCKER. Do not invent evidence."
system_prompt="$(< "$ROOT/goose/system-prompt.md")"
runner=(goose run --no-session --no-profile --max-turns 8 --quiet --with-builtin developer --with-builtin github --with-builtin memory --system "$system_prompt" --text "$payload")
if command -v perl >/dev/null 2>&1; then perl -e 'alarm shift; exec @ARGV' "$TIMEOUT_SECONDS" "${runner[@]}" >> "$tmp" 2>&1; rc=$?; else "${runner[@]}" >> "$tmp" 2>&1; rc=$?; fi
print -r -- "" >> "$tmp"
if (( rc == 0 )); then print -r -- "Status: VERIFIED" >> "$tmp"; else print -r -- "Status: FAILED" >> "$tmp"; print -r -- "Reason: Goose exited with status ${rc}; see the captured output above." >> "$tmp"; fi
print -r -- "Finished: $(date -u '+%Y-%m-%dT%H:%M:%SZ')" >> "$tmp"
if grep -E '/Users/|/Volumes/|Library/Application Support|josephgilles|ChickenChase|GardenDreams|Sims4|[0-9]+Gi|[0-9]+ bytes|vapi_[A-Za-z0-9]|sk-[A-Za-z0-9]|ghp_[A-Za-z0-9]|github_pat_[A-Za-z0-9]' "$tmp" >/dev/null 2>&1; then
  print -r -- "# Result R-${number}" > "$public_tmp"
  print -r -- "" >> "$public_tmp"
  print -r -- "Task source: ${base}.md" >> "$public_tmp"
  print -r -- "Status: FAILED" >> "$public_tmp"
  print -r -- "Reason: worker output failed the public-output safety check; unsafe details were discarded locally." >> "$public_tmp"
  print -r -- "WHAT I ACTUALLY VERIFIED: The worker returned output, but it was not safe to publish." >> "$public_tmp"
  print -r -- "NEXT HIGHEST-LEVERAGE BLOCKER: Rerun with public-status-only evidence and no local-only details." >> "$public_tmp"
  print -r -- "Finished: $(date -u '+%Y-%m-%dT%H:%M:%SZ')" >> "$public_tmp"
  rm -f "$tmp"
  mv "$public_tmp" "$result"
else
  mv "$tmp" "$result"
  rm -f "$public_tmp"
fi
trap - EXIT INT TERM
exit 0

