# Read-only enemy FSM recorder (diagnostic build)

User approved (2026-10-27) a passive diagnostic to collect original enemy FSM data
from their own client instead of sharing game resources.

- `src/WukongKnight/EnemyFsmDump.cs`, created by `WukongKnightMod` independently of
  the character runtime; version string `0.7.6-dev+fsmdump`.
- Writes to `<Mod dir>/fsm-dump/`: `<scene>__<enemy>.txt` once per scene/enemy name
  on HealthManager.Start (hierarchy, components, colliders, every FSM on the enemy,
  its children and parent: events, variables, global/state transitions, action types
  and public field values); `scene__<scene>.txt` FSM index 1.5s after scene load;
  `trace-<time>.txt` live state changes of recorded FSMs plus HealthManager.Hit
  attack type/source/HP before/after (16 MB cap, flushed every 2s).
- Reflection reads only. Risk noted: reading FsmState.Actions on not-yet-initialized
  FSMs triggers PlayMaker's lazy action load early; expected benign, unverified.
- Built 0/0 warnings/errors, 81 Core checks pass. Full package not produced here:
  this machine lacks the active v074 processed variants (stale 0.3-era bake), so
  only the DLL was staged at artifacts/fsmdump-0.7.6-dev/WukongKnight.dll
  (sha256 c3849511feb6d68dc949f6f6b1faf27f7b4aee0f40d38feaf5248b5529936f16).
  Install target D: is not reachable from this host; user installs the DLL.
