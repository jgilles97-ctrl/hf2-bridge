#!/bin/zsh
set -u
ROOT="${HF2_BRIDGE_ROOT:-${HOME}/Projects/hf2-bridge}"
PATH="/opt/homebrew/bin:/usr/local/bin:${HOME}/.local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
export PATH
fail=0
pending=0
check() { if "$@" >/dev/null 2>&1; then print -r -- "PASS: $*"; else print -r -- "FAIL: $*"; fail=1; fi }
print -r -- "hf2-bridge read-only acceptance audit"
check test -d "$ROOT/.git"
check git -C "$ROOT" diff --quiet
check git -C "$ROOT" diff --cached --quiet
check git -C "$ROOT" ls-remote --exit-code origin refs/heads/main
check curl -fsSL --max-time 20 https://raw.githubusercontent.com/jgilles97-ctrl/hf2-bridge/main/INBOX/T-0001.md
check "$ROOT/scripts/hf2" public-status
check test -f "$ROOT/HANDOFF.md"
check test -f "$ROOT/RUNBOOK.md"
check test -f "$ROOT/goose/system-prompt.md"
if git -C "$ROOT" grep -n -I -E 'vapi_[A-Za-z0-9]|sk-[A-Za-z0-9]|ghp_[A-Za-z0-9]|github_pat_[A-Za-z0-9]' -- ':!goose/env.example' >/dev/null 2>&1; then
  print -r -- "FAIL: credential-like token found in repository"; fail=1
else
  print -r -- "PASS: no credential-like token found in repository"
fi
public_snapshot=$(mktemp)
trap 'rm -f "$public_snapshot"' EXIT INT TERM
if "$ROOT/scripts/hf2" public-status > "$public_snapshot"; then
  if grep -E '/Users/|/Volumes/|Library/Application Support|josephgilles|ChickenChase|GardenDreams|Sims4|[0-9]+Gi|[0-9]+ bytes' "$public_snapshot" >/dev/null 2>&1; then
    print -r -- "FAIL: public-status exposed a blocked disclosure marker"; fail=1
  else
    print -r -- "PASS: public-status omits blocked disclosure markers"
  fi
else
  print -r -- "FAIL: public-status could not be captured"; fail=1
fi
check git -C "$ROOT" check-ignore -q .private-state/logs/example.log
if grep -F '"$ROOT/scripts/hf2" public-status' "$ROOT/scripts/refresh-state.sh" >/dev/null 2>&1 && ! grep -F '> "$ROOT/STATE/logs/' "$ROOT/scripts/refresh-state.sh" >/dev/null 2>&1; then
  print -r -- "PASS: refresh-state publishes sanitized state and keeps raw logs private"
else
  print -r -- "FAIL: refresh-state public/private routing is unsafe"; fail=1
fi
if [[ -f "$HOME/.config/hf2-bridge/env" ]]; then
  mode=$(stat -f %Lp "$HOME/.config/hf2-bridge/env" 2>/dev/null || print 000)
  [[ "$mode" == 600 ]] && print -r -- "PASS: private env mode is 600" || { print -r -- "FAIL: private env mode is $mode"; fail=1; }
else
  print -r -- "PENDING: private Venice env file is absent"; pending=1
fi
if [[ -f "$ROOT/OUTBOX/R-0001.md" ]]; then
  print -r -- "INFO: R-0001 exists; inspect its status and external raw URL"
else
  print -r -- "PENDING: OUTBOX/R-0001.md is absent"; pending=1
fi
if [[ -f "$HOME/Library/LaunchAgents/com.$USER.hf2bridge.plist" ]]; then print -r -- "PASS: launchd plist exists"; else print -r -- "PENDING: launchd plist is absent"; pending=1; fi
if [[ -d "$ROOT/.locks/run" ]]; then print -r -- "FAIL: bridge lock is present"; fail=1; else print -r -- "PASS: bridge lock is absent"; fi
if (( fail == 0 && pending == 0 )); then print -r -- "Audit result: PASS"; exit 0; else print -r -- "Audit result: INCOMPLETE"; exit 2; fi

