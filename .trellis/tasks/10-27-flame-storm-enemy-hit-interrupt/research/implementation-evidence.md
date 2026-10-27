# Implementation draft: scoped native HP observation

Date: 2026-10-27. Baseline: main@cadb864 / Hollow Knight 1.5.78.11833 / Modding API v77.

## Status and boundary

This is an **unfinished attribution draft**, not an enemy-interruption feature. No native enemy cancellation profile was established. No enemy state, attack resource, projectile, speed or timer is modified. The accepted observation result is deliberately discarded in WukongRuntime until a complete native cancellation/cleanup/default-return contract and the remaining attribution guards are available. AC1/AC3 are unmet; do not release/package this as a working interruption version.

Changed production files:

- `src/WukongKnight/Core/ScopedEnemyDamage.cs`: one-shot reference/token/HP policy, linked directly into tests.
- `src/WukongKnight/FlameStorm.cs`: binds each existing budgeted native dispatch to the exact source, cast token, actual HealthManager and starting HP. Clears the temporary attempt when dispatch unwinds or the skill stops.
- `src/WukongKnight/WukongRuntime.cs`: wraps the existing HealthManager.Hit hook in a depth/sequence scope, preserving native dispatch and the existing Fire Eye observer order. Additional state has no target caches or asynchronous work.
- `tests/WukongKnight.Core.Tests/{Program.cs,WukongKnight.Core.Tests.csproj}`: five new linked-production checks.

The draft preserves the existing SpellHit/FireDemonHit call, target query masks, ledger/cap/contact interval, native damage/evasion, costs, artwork and successful recovery. There is no adapter stub, optional extension callback, telemetry or version bump.

## Exact observation boundary

1. After the existing contact ledger accepts, snapshot the resolved HealthManager reference, HP, exact source and cast token before calling FireDemonHit.
2. FireDemonHit still calls SpellHit, which sends TAKE DAMAGE, rechecks ownership, then dispatches HitTaker.Hit once.
3. In the exact HealthManager.Hit hook, require matching source/responder/token, top-level Hit depth and unchanged HP since step 1. A prior TAKE DAMAGE HP mutation cannot become the later hit's attributed loss.
4. Capture the resulting HP immediately after the existing native dispatch. Native nested Hit callbacks increment a shared sequence and invalidate the enclosing result even if they used a different source/target or did no damage.
5. Preserve Fire Eye observation first. Observe Storm before reading the final sequence so synchronous ownership recovery/cancellation callbacks cannot be hidden behind a previously captured sequence. Completion performs no native control event.
6. Completion requires the same current attempt/token, active skill/source/target, enabled and nondead HealthManager, unchanged post-hit HP, unambiguous Hit sequence, and positive HP strictly below the initial value. A result is single-use; later budgeted hits get fresh attempts.

## Native signatures and evidence

Pinned actual API Assembly-CSharp.dll SHA-256: `0890edcd1b60ae22ea9c4a2d7c16056795b321f0efbb078d447e06730c0e784b`.

- Existing HookGen signature used unchanged: `On.HealthManager.orig_Hit orig, HealthManager self, HitInstance hit`; calls `orig(self, hit)` through existing DispatchHealthHit.
- Actual native method: `System.Void HealthManager::Hit(HitInstance)`. Native damage/notification ordering remains as recorded in native-hurt-contract.md/native-hurt-il.txt.
- Newly checked public native method: `System.Boolean HealthManager::GetIsDead()` reads the native `isDead` field directly. Used only for the completion eligibility check; no new private reflection.
- Actual native bypass: `System.Void HealthManager::ApplyExtraDamage(System.Int32)` sends EXTRA DAMAGED, subtracts/clamps `hp` directly (IL_0011–0020), then calls Die when HP reaches zero. It does not route through HealthManager.Hit.
- Actual `HealthManager.OnEnable()` starts CheckPersistence; it is not proof that a disabled/reused HealthManager acquired a new reference identity.

The last two findings impose **remaining attribution work before any profile can consume this result**: synchronous ApplyExtraDamage/direct HP mutations during Hit are not covered by the Hit sequence, and a disable/re-enable/pooling cycle with the same reference cannot be distinguished by final liveness alone. An eventual native adapter also needs death/phase and layout validation. Additional global hooks were deliberately not added for an otherwise consumerless draft. Do not describe its result as proof against all native/modded HP mutations or pooling.

Read-only inspection command:

```bash
.tools/dotnet/dotnet .tools/runtime-inspect/bin/Debug/net10.0/inspect.dll .tools/hollow-knight-api-v77/Assembly-CSharp.dll 'HealthManager:ApplyExtraDamage' 'HealthManager:GetIsDead' 'HealthManager:OnEnable'
```

## Validation

- Core linked-source checks: 81 passing, including exact/wrong source/responder/token, no damage/healing/fatal outcomes, TAKE DAMAGE HP mismatch, nested Hit attribution, revoked/recast/completed results and five fresh accepted contact attempts under the existing ledger.
- Pinned-reference Release build: warnings-as-errors; passed with zero warnings/errors.
- No fake Unity/game APIs, native-client gameplay execution, adapter/layout verification, package/release build or deployment. These policy checks do not prove actual attack cancellation.

## Required continuation

Obtain at least one original baseline enemy FSM/action/animation layout with a proven safe native attack-exit/cleanup/default route, finish bypass/lifecycle attribution guards, integrate that real profile, then execute the declared client acceptance matrix. Current Electric Mage Gen/END and other public-source clues remain candidates only.
