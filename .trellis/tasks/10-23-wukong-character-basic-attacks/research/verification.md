# Final implementation and verification checkpoint

Date: 2026-10-23. Version: 0.2.0-dev.

The approved implementation is ready as a local development package: default staff Wukong presentation and a real four-stage grounded horizontal combo. Native air/up/down attacks and pogo stay on their original control path. This record establishes implementation, offline previews and automated verification; client acceptance is pending.

## Evidence

- Source inventory/re-extraction/hash checks pass, including complete decode of all 14 MP3 files.
- Baked assets: 13 clips, 329 source ticks, 52 unique cells, one 1848x1582 RGBA atlas; shared 231x226 canvas and root (119,174). Final authored windows: [4,7), [5,8), [3,5)+[11,14), [5,8).
- Visual review: actual overview, idle and attack contact sheets, plus owner review of movement/jump/death/mirrored edge previews. See visual-review.md and asset-implementation-notes.md. This does not establish in-game scaling or collision.
- Final `bash scripts/build.sh > artifacts/build.log 2>&1`: exit 0; 23 Python tests and 10 linked-production C# checks pass; Release build has 0 warnings and 0 errors.
- Independent review found/fixed stale DamageEnemies contacts after cancellation, including list mutation during traversal and native FSM event timing before HitTaker. Production cleanup policy has a regression check; details are in quality-review.md.
- Main independently verified final report SHA-256, ZIP CRC/member list and pending client status. ZIP contains exactly WukongKnight.dll, README.txt, character/character.json and character/atlas-000.png. No previews or game/API/Unity assemblies are included.

## Final package

- ZIP: `artifacts/WukongKnight-0.2.0-dev.zip`, 532,705 bytes.
- ZIP SHA-256: `761fc0564c5f68bec1c4be13cf1c5aeb99a78f95ad72a1197005418e0d32a1ea`.
- DLL: 39,936 bytes; SHA-256 `438285a885006b01109dccd773f5d8c994c3d9dd19447e711c5e5005ed039c04`.
- Manifest and atlas hashes are recorded in artifacts/build-report.json. Earlier build-integration-notes.md package hashes are the initial checkpoint; use this final record/report for installation.

## Pending work

- `runtime_tested=false`, `client_acceptance=pending`. PRD AC1–AC6 need an actual compatible Hollow Knight client, especially two stage3 HP losses with Quick Slash/native evasion, soul/charms/breakables, air/downslash/pogo and lifecycle/visibility.
- Installation and test steps: docs/CLIENT_ACCEPTANCE.md. The matching Windows API is needed for Windows game testing. Existing tooling can run in WSL2 Ubuntu 24.04; native Windows bootstrap/build support is not implemented in this task.
- At the build checkpoint Git had no initial commit and the existing baseline was untracked. The user subsequently explicitly requested upload to https://github.com/191cjc/hollow-knight-wukong.git, authorizing a complete initial project commit and push to its empty main branch. The updated commit-plan.md includes the existing baseline; tools, caches and generated artifacts retain their existing ignore rules.
- Keep task in_progress while client acceptance remains open; do not archive it as fully verified.
