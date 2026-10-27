# Development checkpoint: incomplete, native profile blocked

Date: 2026-10-27. Branch: `feat/flame-storm-enemy-interrupt`, based on `main@cadb864`.

## Current outcome

The user approved the revised plan with “开始吧”; task status is `in_progress`. The implementation agent produced a scoped accepted-damage attribution draft and linked-production tests. **The requested gameplay interruption is not implemented.** No enemy profile is enabled, no enemy state is changed, and no new feature version/package or deployment was produced. AC1/AC3 and full native attribution/lifecycle acceptance remain incomplete.

The user confirmed that their actual game resources cannot currently be shared. A local filesystem search found no accessible baseline game scene/prefab assets or actual PlayMaker runtime. A bounded public-source search also did not obtain a complete compatible cancellation/cleanup/default-return path. See `default-behavior-full-evidence.md`; state names and randomizer changes cannot substitute for the missing original graph.

## Completed draft work

- `src/WukongKnight/FlameStorm.cs`: binds a budgeted dispatch to exact source/cast token/resolved HealthManager/initial HP, clearing the temporary observation when dispatch unwinds or Storm ends.
- `src/WukongKnight/WukongRuntime.cs`: observes the existing native Hit hook with nesting/sequence checks; preserves normal dispatch and Fire Eye order. The resulting eligibility value is deliberately unused until the actual native adapter and remaining guards exist.
- `src/WukongKnight/Core/ScopedEnemyDamage.cs`: single-use identity/token/HP policy, linked directly into the existing executable core tests.
- Core test project/Program: five added checks for identity, actual surviving loss, nested callbacks, revoked/reused observations and repeated budgeted hits.

Implementation-agent verification: 81 core checks, pinned-reference warnings-as-errors Release build with zero warnings/errors, and diff whitespace check. Independent review in `check-draft.md` confirmed all 81 checks, a clean pinned-reference Release rebuild and compiled damage/Fire Eye/recovery/finally ordering. It found no additional mechanical regression and accepted only an explicitly unfinished, unreleased draft. No client gameplay or interruption-profile validation occurred.

The owning native-combat spec and its index now explicitly record the unreleased observation contract, the unused result, missing direct-HP/lifetime guards and native-profile/client acceptance requirements. This documentation does not declare any enemy support or completed gameplay feature. Final context validation passed for both eight-entry manifests. Documentation whitespace is checked with `git -c core.whitespace=cr-at-eol diff --check` to preserve the owning spec's existing CRLF format; the plain check treats those added CR terminators as trailing whitespace.

## Required work before adding any enemy control

1. Obtain one exact compatible enemy's original complete attack cancellation/cleanup/default path and its prerequisites, including actions, transition destinations and referenced attack objects/controllers. Runtime structure matching alone does not establish semantics.
2. Finish observation guards for `HealthManager.ApplyExtraDamage(int)`/other known direct HP changes and for disable/re-enable/pooling of the same target reference. Current Hit sequence and final liveness alone do not prove those identities.
3. Integrate the verified native cancellation route with protected death/phase checks and exact ownership rechecks. Leave unsupported targets on normal damage/recoil.
4. Run the full declared client matrix and development-package gate. Compilation/policy tests cannot establish successful enemy interruption.

The necessary input can be a targeted original FSM/actions/transitions text or JSON dump; sharing the full game directory is not inherently required. `minimum-client-evidence.md` lists the concrete fields and source links without inventing an exporter command.

## Continuation and lifecycle

The implementation plan is already approved. Resume the evidence/adapter work within the same task when the missing data becomes available; do not ask for task creation or repeat planning approval unless the accepted behavior changes. Keep this work as an uncommitted incomplete draft; do not archive or describe the task as complete, advance the version, or package the observer as a working feature.

## Session restart and authorized input-swap follow-up

The user requested neutral quick spell => Storm and down-Dream => independent
Afterimage, then asked to restart the session. Requirements/context and native
entry research are saved, but no input-swap product/test/user-doc changes or
build/tests have occurred; current bindings remain unchanged. The implement
agent stopped and saved `input-swap-implementation.md`. Read
`session-handoff.md` first in the new session. The user has already authorized
this bounded follow-up; resume implementation and independent review without
repeating task-creation/planning approval. Parent task remains in_progress and
the original enemy-interruption draft remains incomplete.
