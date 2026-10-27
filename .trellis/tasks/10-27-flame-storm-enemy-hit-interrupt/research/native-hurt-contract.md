# Research: pinned native enemy damage, recoil and hurt-entry contract

- Query: Does the pinned native damage path expose a supported generic enemy attack interruption/hurt route, and what evidence is required for a Flame Storm-only v77 adapter that restarts hurt on every actual damaging hit?
- Scope: internal binary/source research, with external package provenance only.
- Date: 2026-10-27.
- Active task: `.trellis/tasks/10-27-flame-storm-enemy-hit-interrupt` (planning only).
- User decision: every effective hit must restart the supported native hurt response, including when the target is already hurt. This is now recorded in `prd.md` as R8. The user subsequently clarified that work remains feasibility/enemy-list research only; no implementation or task activation is authorized yet.

## Findings

### 1. Evidence and reproducibility

Inspected the existing binaries without building or editing tools. The package metadata at `.tools/hollow-knight-api-v77/.wukong-toolchain.json:2` pins Hollow Knight `1.5.78.11833`, Modding API `77`. The inspected `Assembly-CSharp.dll` SHA-256 is `0890edcd1b60ae22ea9c4a2d7c16056795b321f0efbb078d447e06730c0e784b`. The existing inspector DLL SHA-256 is `a81bb3db2918e25da6581eed03883a9fa6779d999f6f332a4680d82a1678c3e6`.

Raw evidence written alongside this report:

- `research/native-hurt-il.txt`: HealthManager fields/Awake/Hit/TakeDamage/NonFatalHit/ApplyExtraDamage, all Recoil methods and FSMUtility methods. Its line anchors below are relative to this task directory.
- `research/native-hurt-reentry-il.txt`: HitTaker.Hit, HealthManager.IsInvincible and tk2dSpriteAnimator Play/PlayFromFrame overloads. Requests for `PlayMakerFSM:SetState` and `HutongGames.PlayMaker.Fsm:SetState` produced no matching types in the inspected assembly.

Reproduction commands, from the repository root:

```bash
.tools/dotnet/dotnet .tools/runtime-inspect/bin/Debug/net10.0/inspect.dll \
  .tools/hollow-knight-api-v77/Assembly-CSharp.dll \
  'HealthManager:Hit' 'HealthManager:TakeDamage' 'HealthManager:NonFatalHit' \
  'HealthManager:Awake' 'HealthManager:ApplyExtraDamage' 'Recoil:*' 'FSMUtility:*' \
  'FSMUtility:SendEventToGameObject'

.tools/dotnet/dotnet .tools/runtime-inspect/bin/Debug/net10.0/inspect.dll \
  .tools/hollow-knight-api-v77/Assembly-CSharp.dll \
  'PlayMakerFSM:SetState' 'HutongGames.PlayMaker.Fsm:SetState' \
  'tk2dSpriteAnimator:Play' 'tk2dSpriteAnimator:PlayFromFrame' \
  'HitTaker:Hit' 'HealthManager:get_IsInvincible'
```

The inspector source `.tools/runtime-inspect/Program.cs:1` reads Cecil metadata/IL; it does not instantiate Unity components or prove serialized enemy behavior.

### 2. HealthManager.Hit and TakeDamage do not provide a universal hurt state

`research/native-hurt-il.txt:145` / `HealthManager.Hit`:

1. Return if `isDead`, `evasionByHitRemaining > 0`, or `DamageDealt <= 0`.
2. Send `DEALT DAMAGE` to the source GameObject.
3. Resolve the actual cardinal direction and blocking rules.
4. Call `Invincible` when blocked; otherwise call `TakeDamage`.

`DEALT DAMAGE` therefore happens before the blocking decision and HP subtraction. It is not proof of actual damage.

`research/native-hurt-il.txt:185` / `HealthManager.TakeDamage`, relevant IL order:

| Native step | IL offset | Meaning for this task |
| --- | --- | --- |
| Reject ignored Acid, apply native cheat damage override | `0000..0025` | Entry alone is not proof of HP loss. |
| Set direction, send `HIT` to target | `0038..004b` | Target FSMs may synchronously transition before HP loss. |
| Send `HIT LANDED` to source | `0050..005c` | Still before HP subtraction. |
| Send `TOOK DAMAGE` to target | `0061..006d` | Also before HP subtraction. |
| If configured, send `HIT` to `sendHitTo` | `0072..008c` | This is a GameObject event destination, not a designated hurt-state handle. |
| Call target Recoil.RecoilByDirection if present | `0091..00ac` | Native recoil already runs for this hit; do not add a second recoil call. |
| Native attack-type feedback and hit effect | `00b1..0332` | Feedback does not establish AI interruption. |
| Compute rounded DamageDealt * Multiplier; honor `damageOverride`; subtract HP with native lower clamp | `0332..0360` | A positive requested damage number or prior event is insufficient to establish the resulting HP change. |
| HP > 0: call NonFatalHit(IgnoreInvulnerable) | `0365..0375` | NonFatalHit itself does not select a hurt FSM state. |
| HP > 0: send `STUN DAMAGE` to cached stun FSM if present | `037a..0392` | This is already sent by native damage; its serialized consumer is still unknown. |
| HP <= 0: call Die | `0398..03b7` | Preserve death; do not follow with a forced hurt transition. |

`HealthManager.Awake` caches the first same-GameObject FSM whose exact `FsmName` is `Stun Control` or `Stun` (`research/native-hurt-il.txt:95`, IL `0054..009f`). It does not discover a generic `Hurt` state. Presence of this component is not a support predicate: no serialized state graph, thresholds, counters or phase semantics are provided by these IL instructions. Do not add another `STUN DAMAGE`, force `STUN`, set counters, or replace a boss stagger/phase with normal hurt without target-specific evidence.

The observed chain exposes generic **notifications**, not a universal supported operation that cancels an enemy attack, clears its attack resources, starts a hurt action and safely resumes its AI.

### 3. NonFatalHit is animation/evasion feedback, not AI cancellation

`research/native-hurt-il.txt:455`, `HealthManager.NonFatalHit(bool ignoreInvulnerable)`:

- `ignoreInvulnerable == true`: return without changing hit animation or default evasion.
- Otherwise, if `hasAlternateHitAnimation`, call `animator.Play(alternateHitAnimation)` when the animator exists, then return; if it is missing, return.
- Otherwise, assign `evasionByHitRemaining = 0.2f`.

There is no enemy control-FSM transition, attack collider cleanup, projectile/timer cancellation, general movement ownership or native action recovery in this method. Alternate animation metadata is not enough to mark a target supported. Preserve this existing evasion branch; do not clear evasion or set IgnoreInvulnerable merely to increase interruption frequency.

### 4. Recoil cannot implement repeated forced hurt

`research/native-hurt-il.txt:696`, `Recoil.RecoilByDirection`:

- Immediately returns while its internal state is nonzero (`IL_0000..0008`). A later actual damaging hit during recoil therefore need not restart recoil or emit recoil-direction events.
- Otherwise obeys `freezeInPlace`, `preventRecoilUp`, native collider sweep and native magnitude/duration.
- Emits `RECOIL HORIZONTAL` plus `HIT LEFT`/`HIT RIGHT`, or `HIT DOWN`/`HIT UP`, on eligible native recoil entry (`IL_007f..00fe`). Consumer state transitions remain serialized target behavior.
- `UpdatePhysics` handles physical recoil/freeze and native timeout (`research/native-hurt-il.txt:852`). It is not a generic attack/hurt controller.

`Recoil.Freeze` (`research/native-hurt-il.txt:801`) either invokes the opted-in `OnHandleFreeze` handler, or owns native freeze motion and sends `FREEZE IN PLACE` to the specifically named `Climber Control` FSM if present. That path is not evidence of a generic hurt response for arbitrary enemies. `CancelRecoil` invokes `OnCancelRecoil` when leaving an active recoil (`research/native-hurt-il.txt:787`), so calling cancel/recoil to simulate retriggering could introduce unrelated controller behavior.

Do not change `freezeInPlace`, cancel native recoil, force transforms/velocity, or call Freeze as a substitute for the requested original hurt state. Leave the current Flame Storm recoil wrapper unchanged.

### 5. Event delivery and repeated animation entry have important limits

`FSMUtility.SendEventToGameObject` (`research/native-hurt-il.txt:1061`) resolves a native FsmEvent and calls `Fsm.Event` on **every** FSM on the addressed GameObject; child traversal occurs only when the bool argument is true. The observed native damage calls use false. Re-emitting broad `HIT` after damage would duplicate an event already sent and might affect unrelated same-object FSMs/counters. A verified reaction adapter should address only its verified controller/route.

The exact pinned PlayMaker runtime is unavailable in this environment:

- No `PlayMaker.dll`, scene `.assets`, or `globalgamemanagers` file was found by file enumeration under the repository, `/home/ubuntu` or `/tmp`.
- `.tools/hollow-knight-api-v77/MMHOOK_PlayMaker.dll` exists, but HookGen wrappers are not the implementation of `PlayMakerFSM.SetState` or `HutongGames.PlayMaker.Fsm.SetState`.
- The source adapters reflect `SetState(string)` at `src/WukongKnight/NativeSpellV77.cs:61` and `NativeDreamV77.cs:41`; this proves the existing API binding pattern, not same-state restart semantics.

Accordingly, **whether same-state SetState re-enters actions in this exact client remains unverified**. Do not assume it; do not bounce through arbitrary idle, init, attack or phase states to manufacture reentry. Inspect the real PlayMaker binary and exercise the actual FSM before selecting a supported same-state entry mechanism.

There is a separate, confirmed animation issue even if FSM reentry is supported. In `research/native-hurt-reentry-il.txt:142`, `tk2dSpriteAnimator.Play(string)` resolves the clip and calls `Play(clip)`, which passes `startTime = 0` to the three-argument overload. That overload at `research/native-hurt-reentry-il.txt:190` checks `startTime == 0 && IsPlaying(clip)` (`IL_0018..002a`) and returns after updating FPS (`IL_002c..0033`), without resetting `clipTime`. Reentering a native action that only calls ordinary `Play` can therefore leave the same hurt clip running from its current frame.

`PlayFromFrame(string, frame)` / `PlayFromFrame(clip, frame)` exist (`research/native-hurt-reentry-il.txt:170`), but a bare animator restart does not reset native FSM waits/completion delegates, cancel attacks or establish recovery. A particular adapter must prove that both its FSM reaction and animation clock restart coherently using the enemy's original action contract. Do not use the existence of PlayFromFrame to declare generic support.

### 6. Recommended v77 adapter boundary and gates

These are planning recommendations, not approved implementation and not a verified support catalog.

Keep version-sensitive enemy FSM/reflection work in a dedicated v77 adapter following the existing NativeV77/NativeSpellV77/NativeDreamV77 boundaries. The Flame Storm overlap loop should request a reaction only after a scoped native hit transaction reports a confirmed, nonfatal loss. A target qualifies only if all of the following still hold at reaction time:

1. This exact current Flame Storm instance and cast token own the contact; its native hit was issued through the existing accepted contact/ledger path.
2. The transaction source is the exact Flame Storm source, the hit type is Spell, and the HealthManager is the actual resolved responder. A shared Spell type or an arbitrary HP decrease does not establish attribution.
3. Around that actual native HealthManager dispatch, `beforeHP > afterHP > 0`, the responder remains alive/not destroyed, and native dispatch completed normally. Rejected hits, scenery responders and fatal hits skip reaction. Prefer the current HealthManager.Hit hook boundary (`src/WukongKnight/WukongRuntime.cs:435`) over a blanket before/after comparison around SpellHit, since SpellHit sends TAKE DAMAGE first (`src/WukongKnight/NativeV77.cs:181`).
4. Preserve and restore any scoped transaction context in finally; do not let nested hits or a newer cast inherit an old attribution. If synchronous nested callbacks cause ambiguous HP attribution, fail closed for the extra reaction rather than treating the enclosing HP delta as independently proven Flame Storm loss.
5. After native callbacks, recheck the skill instance/token, runtime lifetime, target instance, active controller/structure and verified phase/eligible-state predicates. Native events can synchronously cancel/unload the skill, replace the target or enter death/stagger/phase control.
6. A supported profile verifies the exact target controller layout and has a proven hurt entry **and same-state restart route**, valid originating states, attack-resource exit cleanup and normal recovery. Missing/mismatched data skips only the extra reaction and preserves native damage/recoil.
7. Consume the reaction opportunity at most once per actual accepted damaging dispatch. A second actual damaging contact may restart hurt; repeated hook/event observations of the same dispatch may not. Rejected damage does not generate retries or restore/expand the existing contact budget.

The user-selected repeated-hit behavior is not satisfied by `if (activeState == hurtState) return`. Nor is it established by blindly calling SetState(hurtState) or animator.Play on every hit. The supported route must intentionally restart its original reaction clock each time, including while already hurt. If the real target cannot safely do this, mark the profile unsupported until a compatible original route is demonstrated; do not silently weaken the selected behavior.

Death and phase/stagger transitions have priority. Profiles need explicit evidence of those guards, rather than a universal state-name blacklist. Do not disable components/FSMs globally, destroy unrelated projectiles/children, or invent post-hit invincibility. Cleanup should cover only the interrupted attack resources that the verified controller owns. Whether already detached projectiles belong to that attack and need stopping must be determined from the actual prefab/actions, not guessed.

### 7. Serialized enemy evidence still needed before any supported profile can be claimed

For each proposed target/layout, obtain a reproducible dump from the **actual pinned client**, with the following minimum contents:

| Evidence | Required detail |
| --- | --- |
| Provenance and identity | Exact game/API/PlayMaker versions or binary hashes; scene/prefab path and variant; GameObject hierarchy; actual HealthManager/hurtbox/controller relationships. Ordinary enemies and bosses are evaluated by the same capability contract. |
| Controller structure | FSM names, enabled/active status, state names, local and global transitions, ordered action type names, action fields and FSM variable values. State names alone are insufficient. |
| Hurt semantics | Original incoming event/entry path, startup assumptions, animation clip/action, completion event/delegate, waits/timers, and the full normal recovery path. Establish it is a normal hurt response rather than death, stagger/threshold or phase change. |
| Attack cancellation | Every eligible attack/charge/continuous-firing state and its entry/update/exit actions; child attack hitboxes and DamageHero owners; associated coroutines/timers/other FSMs/scripts and projectiles. Prove the chosen interruption path releases or cancels these correctly. |
| Priority guards | Death, phase-change, stagger and scripted/control states plus the actual variables/events that make interruption invalid. Include callbacks caused by a lethal or threshold-crossing native hit. |
| Reentry | Real PlayMaker SetState/event behavior while already in hurt, animator action behavior, reinitialized timers and completion callbacks. A repeated damaging hit must restart the reaction and still allow recovery after the final hit. |
| Runtime acceptance | Before/after native HP and FSM transitions for an eligible attacking target, already-hurt target, rejected/invincible hit, fatal hit, phase transition, target destruction and scene/unload/cancel; verify no stale callbacks or attack residue. |

A read-only extraction from actual client prefabs/scenes or a runtime dump can supply this material. The current C# API DLL describes component behavior and fields; it does not contain these serialized state graphs. There is currently **no verified enemy support entry** in this report, and no specific enemy type is asserted to have a compatible Hurt/STUN/Hit route. A damage-attribution scaffold with an empty support table would not complete the user's requested behavior.

### 8. Files found and source patterns

- `.tools/runtime-inspect/Program.cs:1`: reusable read-only Cecil inspector; no tooling rebuild was needed.
- `.tools/hollow-knight-api-v77/.wukong-toolchain.json:2`: pinned API archive provenance/version.
- `.tools/hollow-knight-api-v77/Assembly-CSharp.dll`: native HealthManager, Recoil, FSMUtility, HitTaker and tk2dSpriteAnimator method bodies examined above.
- `.tools/hollow-knight-api-v77/MMHOOK_PlayMaker.dll`: generated hooks only; not sufficient to establish PlayMaker runtime state-entry semantics.
- `src/WukongKnight/NativeV77.cs:181`: shared SpellHit sends TAKE DAMAGE, rechecks ownership, then dispatches the native hit with IgnoreInvulnerable false.
- `src/WukongKnight/WukongRuntime.cs:435`: existing native HealthManager.Hit hook captures pre/post HP for Fire Eye and checks runtime/buff identity after callbacks; reuse its verified boundary without duplicating broad hooks.
- `src/WukongKnight/FlameStorm.cs:80`: current cast token capture; `:93` is the accepted contact-ledger dispatch. This confirms where a future scoped reaction request belongs; detailed hit-path research is already in `hit-path-and-native-state-evidence.md`.
- `src/WukongKnight/NativeSpellV77.cs:61` and `NativeDreamV77.cs:41`: existing reflected PlayMaker SetState binding, without proof of same-state restarts.

### 9. External references and related specs

- Pinned API release provenance (not fetched or treated as enemy prefab evidence): <https://github.com/hk-modding/api/releases/tag/1.5.78.11833-77>; local metadata identifies the Linux archive and archive checksum.
- `.trellis/spec/backend/native-combat.md:10`: exact hooks and version-specific reflection ownership.
- `.trellis/spec/backend/native-combat.md:20`: event-before-hit and synchronous lifecycle boundaries.
- `.trellis/spec/backend/native-combat.md:28`: compilation is not actual-client acceptance.
- `.trellis/spec/backend/native-combat.md:146`: current Storm clock, damage regions, cap and native evasion.
- `.trellis/spec/backend/native-combat.md:158`: existing actual native HP-loss attribution pattern.
- `.trellis/spec/backend/native-combat.md:426`: native recoil stays native; no forced enemy transforms or invulnerability bypass.
- `.trellis/spec/backend/native-combat.md:523`: current directional control swap and unchanged shared Dream/Soul/recovery ownership; forced hurt is not implemented on this baseline.
- `.trellis/workflow.md`: remain in planning until reviewed artifacts are approved; this report does not activate the task.

## Caveats / Not Found

- No real PlayMaker runtime DLL or serialized enemy scene/prefab evidence is available in the enumerated local roots. Same-state FSM reentry, attack exit cleanup and enemy-specific support cannot be established from HookGen or C# field names.
- No client execution occurred. Native IL establishes ordering and API behavior, not in-game reaction compatibility or a support coverage claim.
- The explicit repeated-hit decision requires more than selecting a Hurt state: the pinned animator can retain the same running clip, and the native recoil state refuses repeated entry.
- No production code, spec, task activation, tool binary or other task's files were edited. Only this task's research report and raw IL evidence were written.
