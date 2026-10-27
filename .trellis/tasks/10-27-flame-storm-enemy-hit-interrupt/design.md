# Flame Storm attack interruption and native default behavior

## Status and decisions

Planning against main@cadb864 / 0.7.6-dev. The user selected cancellation plus native default behavior and requested a first development version. This revised plan supersedes forced hurt. The user approved the full plan with “开始吧”; the task is now in_progress on feat/flame-storm-enemy-interrupt. Implementation is authorized within these boundaries.

Every actual surviving Storm HP loss attempts to cancel an eligible current attack and return to the target's native walking, flying or idle behavior. Native AI chooses subsequent actions. No hurt animation, timed attack prohibition or polling reset is added. Unknown targets retain native damage/recoil. Ordinary enemies and bosses use the same compatibility standard, with variants verified independently.

## Change boundary and flow

The missing behavior belongs to the enemy attack controller after accepted damage, rather than the overlap query or animator alone.

FlameStorm.FixedUpdate → existing contact ledger → NativeV77.FireDemonHit/SpellHit → HealthManager.Hit observation → exact-source nonfatal damage attribution → compatible native attack exit/default entry → native AI.

Expected files and responsibilities:

- FlameStorm.cs: expose only minimum exact source/current-token identity needed by observation; preserve queries, ledger, timing and native damage.
- WukongRuntime.cs: reuse its existing hit hook and preserve combo/Fire Eye behavior. Keep any nesting/attribution guard scoped to actual damage dispatch.
- New NativeEnemyInterruptV77.cs: own reflection, layout checks, concrete profiles, attack cleanup/default entry and mismatch outcomes. Keep PlayMaker details out of overlap and pure core code.
- A production core policy only if needed for reusable real attribution decisions, linked directly into existing tests; no second test-only model.
- Tests, native combat spec, skill/client docs and package version metadata as required for the resulting development version. No artwork/game/API changes.

Capture the exact live Storm instance/source/token, actual HealthManager instance, initial HP and relevant eligibility before original damage. After dispatch require unambiguous actual nonfatal HP loss, the same live skill/target and eligible current controller state. Nested damage making attribution ambiguous skips the extra effect. Recheck identity/liveness after callbacks that can cancel, replace or unload owners.

Interruption causes no extra native hit. Keep existing five-hit/contact-interval rules. Shared Spell/FireDemonHit callers cannot trigger this behavior merely by using the same helper.

## Concrete native profiles

Each profile must establish exact enemy/variant identity, controller/FSM signature, supported attack states, safe native cancel/recovery/default entry and its prerequisites. Inspect native exit/entry cleanup of attached hitboxes, charge/continuous emission and related current attack controllers. Identify death/phase/scripted/hidden/airborne exclusions and record provenance plus runtime checks.

Prefer an existing native cancellation/recovery route. Direct transitions require a complete exit/default contract. Presence of Walk/Idle, setting Walker state, starting Climber.Walk or changing an animation does not prove attack cancellation.

Resolve required layout and cleanup dependencies before the first mutation. Unknown structure, missing members, conflicting Mod changes or protected states skip extra interruption without suppressing damage or disabling the Mod. Avoid a predictable mismatch leaving the enemy partly modified.

After return, native AI controls its actions. A hit already in default behavior does not create an independent control timer; a later damaging hit during a new compatible attack can cancel it again. Do not restart arbitrary waits to fabricate suppression.

## Damage, cleanup and lifetime

No actual HP loss, fatal damage, inactive/destroyed target, revoked token, unrelated source or ambiguous nested attribution means skip. Preserve native evasion, HP, invincibility, death and phase progression.

Close only the interrupted attack's still-owned resources. Already independent projectiles retain native lifetimes; do not clear bullets or children indiscriminately. Prefer no persistent target mutations/caches. Enemy references must not outlive pooling identity changes or scene teardown; restore only owned changes if any are needed.

Preserve Storm recovery/shared Dream ownership, Fire Eye healing and all other skill paths. Do not invent global time, transform, velocity or AI overrides as a default-return mechanism.

## Evidence and first-version gate

Read research/default-behavior-candidates.md and force-walk-alternative.md. The new research identifies Super Spitter, RoyalGaurd and Electric Mage as structural candidates only. None has a complete source-proven cancellation/default-return contract. Earlier Stun candidates are historical, not support entries.

The fixed API DLL establishes native damage ordering and distinct movement controllers. Full baseline client prefab/FSM/action data and actual PlayMaker runtime are absent locally. Before adding a profile, obtain sufficient complete evidence for cancellation/return and specify runtime guards. Before claiming gameplay support, execute its client matrix. A zero-profile adapter, logging-only build or name-based heuristic does not meet the requested working-version acceptance. Report exact missing evidence if no real profile can be established; do not silently substitute another deliverable.

## Validation, rollout and rollback

Test actual production source/token/target/damage attribution and failure outcomes: no/fatal damage, wrong source, repeated hits, unsupported/protected layouts, nesting, recast, cancellation and teardown. Inspect pinned native and compiled call order; do not substitute fake Unity APIs for native acceptance.

Run relevant core tests, pinned-reference warnings-as-errors Release build and full asset/Python/package checks for a development package. Align version metadata/docs, preserve prior complete artifacts, and mark gameplay results pending unless actually tested. Client checks must show real attack cancellation and subsequent normal AI, rather than only an animation or HP loss.

Remove the added Storm observer/adapter as a unit to restore original native damage/recoil. No save/asset migration is needed. Deployment is outside this planning action.
