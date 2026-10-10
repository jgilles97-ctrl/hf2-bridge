# HANDOFF

## Goal

Build and verify a boring, robust, observable shared workspace connecting Venice chat, Codex, Goose, GitHub, this Mac, and an iPad. The bridge must be proven end to end before any game work begins.

## Hardware

- Reference machine: Apple Silicon Mac, currently observed as arm64 with macOS 27.0 and approximately 10 GiB free on `/`.
- Target: 8 GB M4 iPad Pro.
- External volume observed at `/Volumes/Untitled`.

## Legal/ownership stance

The planned runtime is a local compatibility runtime for a Windows x86-64 Unity IL2CPP game (House Flipper 2, Steam AppID 1190970). It is not described as a native iOS port. Use only software and files Joey owns or is authorized to use. No credentials, cracked binaries, or game archive contents belong in this repository.

## What we do NOT have

- No Unity source code.
- No iOS project.
- No `.ipa`.
- No verified extracted game executable on the reference Mac at audit time.
- No proven local, non-placeholder copy of the iCloud archive at audit time.

## Mac reference runtime status

CrossOver 26.3 is installed. Bottles observed: `ChickenChase-XP`, `GardenDreams`, `HF2-Test`, and `Sims4-offline`; `default` points to `Sims4-offline`. Steam was found in `HF2-Test`. House Flipper 2 `Player.log` and `Player-prev.log` were found in that bottle. The `Sims4-offline` bottle is out of scope and must not be touched.

## iPad architecture

The target is an 8 GB M4 iPad Pro. The proposed route is Madeira + FEX + Wine ARM64EC + Direct3D-to-Metal, subject to later evidence. This bridge does not install or configure that runtime.

## Evidence rules

- Read-only checks come first.
- Machine evidence beats descriptions; conflicts are called out.
- Reports say what happened, what it means, why it matters, and what is next.
- No success claim without pasted or machine-readable evidence.
- Unknown or unverified facts remain explicitly marked `unverified`.
- Tasks declare `MODE: read-only` or `MODE: modify`.
- Modify-mode work requires a reversible path and an `.orig` backup before changing an original.

## Success gates 1-14

1. The repository exists under the confirmed GitHub owner and name.
2. The repository is public and contains no secrets.
3. The repository can be fetched unauthenticated.
4. `hf2 status` runs from a fresh shell without changing anything.
5. `hf2 doctor` clearly identifies missing prerequisites.
6. CrossOver and the protected bottle are only observed, never changed by the bridge.
7. Goose uses the Venice-compatible OpenAI endpoint only after a key and model are supplied by Joey.
8. Goose receives only the developer, GitHub, and memory extensions for bridge work.
9. A task always receives a result, including a clear failed result on timeout or error.
10. The watcher processes at most one task per cycle.
11. The atomic lock is released on success, failure, and interruption.
12. Generated status timestamps do not create noisy commits by themselves.
13. A launchd job survives login/reboot and writes its own logs.
14. An end-to-end task result is fetchable from outside the Mac through GitHub raw content.

## Audit snapshot

The initial audit was performed before implementation on 2026-10-09. The archive path is present but marked `compressed,dataless`; its full contents are not proven local. The internal disk showed approximately 10 GiB available, so extraction is intentionally out of scope.

=== MY FULL HANDOFF PASTE GOES HERE ===

