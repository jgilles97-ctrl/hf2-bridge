# Operator runbook

## The normal loop

Write one numbered Markdown task to `INBOX/`. Use the next unused number. The Mac watcher checks once per minute and processes the lowest-numbered task that does not already have a matching result. It writes a sanitized result to `OUTBOX/`, updates the public state snapshot, commits only meaningful changes, and pushes.

The watcher never runs the game. It is plumbing for evidence and handoffs.

Run `scripts/configure-venice.sh` on the Mac to enter the Venice key locally. The helper does not print the key, does not commit it, and writes the file with mode 600. Select a current supported function-calling model during local configuration.

Run `scripts/verify-bridge.sh` for a read-only acceptance audit. `INCOMPLETE` is expected until the private Venice configuration, launchd job, and external `R-0001` fetch have all been proven.

## Public/private boundary

- `hf2 status` is a detailed local-only diagnostic. Never paste or commit its output.
- `hf2 logs` is local-only. Never paste or commit raw logs.
- `hf2 public-status` is categorical and is the only status command allowed in tracked state or public task results.
- `scripts/refresh-state.sh` writes the tracked `STATE/status.md` from `public-status` only.
- Raw log tails are written under ignored `.private-state/logs/` with private permissions.
- Anything written to `STATE/`, `OUTBOX/`, `journal/`, or another tracked file is public. It must not contain user names, absolute local paths, numeric storage or file sizes, installed-app versions, unrelated project names, device serials, environment contents, credentials, or raw logs.

## Task format

```text
Task:
T-0007
  GOAL: one sentence
  MODE: read-only | modify
  STEPS: ...
  EVIDENCE REQUIRED: ...
  REVERT: ...
```

Results mirror the task and add:

```text
WHAT I ACTUALLY VERIFIED: ...
NEXT HIGHEST-LEVERAGE BLOCKER: ...
```

Never invent task numbers. Continue the sequence by inspecting existing `INBOX/T-*.md` and `OUTBOX/R-*.md` files.

## Commands

`$HOME/Projects/hf2-bridge/scripts/hf2 public-status` is read-only and safe for tracked public evidence. `status`, `doctor`, and `logs` are read-only but local-only. `launch`, `steam`, `extract`, `crack`, `revert`, and `uninstall` are explicit operational commands and are not used by the watcher automatically.

## Goose configuration

The worker reads a private mode-600 environment file outside the repository. The expected variables are `VENICE_API_KEY`, `GOOSE_PROVIDER=venice`, and `GOOSE_MODEL`; supported host and base-path overrides may be supplied locally. Confirm current models against Venice's official model endpoint before configuration. Never copy environment contents into a tracked result.

## launchd

The installer creates a per-user launchd job. It runs `scripts/watcher.sh` once per minute, with throttling and run-at-login behavior. Pause and resume use the supplied scripts. Uninstall removes only this job and leaves the repository and game files in place.

## Remote access

After Joey explicitly enables Remote Login and confirms the Mac's private network name, an iPad may invoke `hf2 public-status` over SSH for shareable evidence. Detailed local diagnostics must remain in the authenticated private session.

The iPad GitHub app can create an `INBOX/T-xxxx.md` file directly. The watcher will pick it up when the commit is visible to the Mac.

## Teardown

Run `scripts/uninstall.sh`. It unloads and removes only the bridge's launchd job. It does not delete the repository, the archive, any compatibility environment, or game files.

