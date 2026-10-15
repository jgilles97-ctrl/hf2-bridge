# HANDOFF

## Goal

Build and verify a boring, robust, observable shared workspace connecting Venice chat, Codex, Goose, GitHub, the reference Mac, and an iPad. The bridge must be proven end to end before any game work begins.

## Hardware

- Reference host: Apple Silicon Mac. Exact operating-system, storage, mount, user, and installed-app details are local-only.
- Target: 8 GB M4 iPad Pro.

## Legal/ownership stance

The planned runtime is a local compatibility runtime for a Windows x86-64 Unity IL2CPP game (House Flipper 2, Steam AppID 1190970). It is not described as a native iOS port. Use only software and files Joey owns or is authorized to use. No credentials, cracked binaries, or game archive contents belong in this repository.

## What we do NOT have

- No Unity source code.
- No iOS project.
- No `.ipa`.
- No verified extracted game executable on the reference Mac at audit time.
- No proven local, non-placeholder copy of the owned archive at audit time.

## Mac reference runtime status

A compatible runtime and a dedicated House Flipper 2 test environment were observed during the initial audit. Detailed paths, versions, storage values, unrelated project inventory, and raw logs stay local. Other project environments are out of scope and must not be touched.

## iPad architecture

The target is an 8 GB M4 iPad Pro. The proposed route is Madeira + FEX + Wine ARM64EC + Direct3D-to-Metal, subject to later evidence. This bridge does not install or configure that runtime.

## Public/private evidence boundary

- `hf2 status` and `hf2 logs` are detailed local-only diagnostics. Never paste or commit their output.
- `hf2 public-status` emits the only machine snapshot allowed in tracked files or public task results.
- Raw log tails belong under ignored `.private-state/logs/` and never under tracked `STATE/` files.
- Public output must not include user names, absolute local paths, numeric storage or file sizes, installed-app versions, unrelated project names, device serials, environment contents, credentials, or raw logs.

## Evidence rules

- Read-only checks come first.
- Machine evidence beats descriptions; conflicts are called out.
- Reports say what happened, what it means, why it matters, and what is next.
- No success claim without machine-readable evidence.
- Unknown or unverified facts remain explicitly marked `unverified`.
- Tasks declare `MODE: read-only` or `MODE: modify`.
- Modify-mode work requires a reversible path and an `.orig` backup before changing an original.

## Success gates 1-14

1. The repository exists under the confirmed GitHub owner and name.
2. The repository is public and contains no secrets or private host inventory.
3. The repository can be fetched unauthenticated.
4. `hf2 public-status` runs from a fresh shell without changing anything or exposing local-only details.
5. `hf2 doctor` clearly identifies missing prerequisites in local-only output.
6. Compatibility environments are only observed, never changed by the bridge.
7. Goose uses the Venice-compatible OpenAI endpoint only after a key and model are supplied by Joey.
8. Goose receives only the developer, GitHub, and memory extensions for bridge work.
9. A task always receives a result, including a clear failed result on timeout or error.
10. The watcher processes at most one task per cycle.
11. The atomic lock is released on success, failure, and interruption.
12. Generated status timestamps do not create noisy commits by themselves.
13. A launchd job survives login/reboot and writes its own local logs.
14. A sanitized end-to-end task result is fetchable from outside the Mac through GitHub raw content.

## Audit snapshot

The initial read-only audit was performed before implementation on 2026-10-09. It found that the owned archive was not proven fully local and that extraction should remain out of scope. Machine-specific evidence is retained locally rather than in this public repository.

