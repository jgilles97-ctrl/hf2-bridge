# Operator runbook

## The normal loop

Write one numbered Markdown task to `INBOX/`. Use the next unused number. The Mac watcher checks once per minute and processes the lowest-numbered task that does not already have a matching result. It writes `OUTBOX/`, updates the state snapshot, commits only meaningful changes, and pushes.

The watcher never runs the game. It is plumbing for evidence and handoffs.

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

`$HOME/Projects/hf2-bridge/scripts/hf2 status` is read-only and prints the current machine snapshot. `doctor` checks prerequisites. `logs` prints the latest bridge and Player.log tails. `launch`, `steam`, `extract`, `crack`, `revert`, and `uninstall` are explicit operational commands and are not used by the watcher automatically.

## Goose configuration

The worker reads `$HOME/.config/hf2-bridge/env`, which must be mode 600 and must never be committed. Current Goose documentation and the installed Goose 1.52.0 binary expose a dedicated `venice` provider. The expected variables are `VENICE_API_KEY`, `GOOSE_PROVIDER=venice`, and `GOOSE_MODEL`. `VENICE_HOST=https://api.venice.ai` and `VENICE_BASE_PATH=/api/v1` are supported optional overrides. Confirm the current model with `curl https://api.venice.ai/api/v1/models`; the checked endpoint currently identifies `z-ai-glm-5-3-flash` as function-calling capable and optimized for code.

## launchd

The installer creates `~/Library/LaunchAgents/com.$USER.hf2bridge.plist`. It runs `scripts/watcher.sh` every 60 seconds, with a 30-second throttle and `RunAtLoad`. Pause and resume use the supplied scripts. Uninstall removes only this job and leaves the repository and game files in place.

## Remote access

After Joey explicitly enables Remote Login and confirms the Mac's Tailscale name, an iPad can run:

```text
ssh <mac-user>@<mac-tailscale-name> '$HOME/Projects/hf2-bridge/scripts/hf2 status'
```

The iPad GitHub app can create an `INBOX/T-xxxx.md` file directly. The watcher will pick it up within 60 seconds when the commit is visible to the Mac.

## Teardown

Run `scripts/uninstall.sh`. It unloads and removes only the bridge's launchd job. It does not delete the repository, the archive, any CrossOver bottle, or game files.

