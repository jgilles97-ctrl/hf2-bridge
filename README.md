# hf2-bridge

The bridge is a small, observable handoff loop between Venice, this Mac, Goose, GitHub, and an iPad.

1. Venice or the iPad writes a numbered task into `INBOX/`.
2. A launchd job checks the repository every 60 seconds.
3. The job takes one task at a time using an atomic lock.
4. Goose reads the task, `HANDOFF.md`, and `RUNBOOK.md`.
5. Goose writes a numbered result into `OUTBOX/`.
6. The worker records evidence and failures instead of hiding them.
7. The job refreshes the machine snapshot and log tails.
8. Only meaningful changes are committed.
9. The job pushes the result to GitHub.
10. Venice or the iPad can fetch the result without shell access.

This repository contains plumbing and documentation only. It does not contain the game archive, game binaries, credentials, or CrossOver bottle files.

