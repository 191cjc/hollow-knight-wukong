# Research: Native Knight runtime integration and compile references

- Query: Build a default staff Wukong visual replacement and a real four-stage grounded horizontal combo, preserving the Knight controller, air and directional attacks, pogo, nail upgrades, charms, soul and scene interactions.
- Scope: mixed; repository source, exact local API v77 binary metadata/IL, pinned official API source and public NuGet package metadata.
- Date: 2026-10-23
- Baseline: Hollow Knight 1.5.78.11833, Modding API v77, net472. No installed game or actual client execution was available.

## Findings

### Files and related specs

- `src/WukongKnight/WukongKnight.csproj:3`: net472, deterministic compilation, nullable and warnings-as-errors; currently references only Assembly-CSharp plus Microsoft.NETFramework.ReferenceAssemblies 1.0.3.
- `src/WukongKnight/WukongKnightMod.cs:16`: log-only Initialize; no existing runtime integration to preserve.
- `tools/bootstrap.py:53`: downloads/extracts the locked API archive, not a complete game Managed directory.
- `toolchain.lock.json:12`: API v77 Linux release URL and SHA256 already pinned.
- `.tools/hollow-knight-api-v77/Assembly-CSharp.xml:2949`: AttackHook, DoAttackHook, AfterAttackHook, SlashHitHook and HeroUpdateHook documentation. This XML describes API additions, not every native controller method or field.
- `.trellis/spec/backend/index.md` and `quality-guidelines.md` are unfilled templates. `.trellis/spec/guides/index.md` directs source-based reuse and cross-layer checks; no executable C# / Unity runtime convention exists yet.

### Reproducible compile references: bounded public route

The exact API source tag `1.5.78.11833-77` resolves to commit `3c47ab577dfcac71bcfae73415618c79310b8f52`:

- Release: <https://github.com/hk-modding/api/releases/tag/1.5.78.11833-77>
- Linux API archive: <https://github.com/hk-modding/api/releases/download/1.5.78.11833-77/moddingapi.v77.linux.zip>
- Official archive SHA256: `5d2327d76b2c48e2694e43e90689d867eaa9ac1d9e6fd2998c93087de7b61ddb`.
- Local Assembly-CSharp.dll: 4,041,216 bytes, SHA256 `0890edcd1b60ae22ea9c4a2d7c16056795b321f0efbb078d447e06730c0e784b`.
- Local MMHOOK_Assembly-CSharp.dll: 9,070,080 bytes, SHA256 `5a7bed2338d3af4f2cba73e331bdf5d0a4f9c791aeb825f0bf9e5691e321e0bb`.

Public compile-only engine reference candidate:

- Package index: <https://api.nuget.org/v3-flatcontainer/unityengine.modules/index.json> lists only `2021.3.33` at research time.
- Pinned package: <https://api.nuget.org/v3-flatcontainer/unityengine.modules/2021.3.33/unityengine.modules.2021.3.33.nupkg>
- Downloaded into memory for archive inspection only: 3,386,574 bytes, SHA256 `d32d34526d89958c63220d3a5ce26c5c44c11bfd411a2e1fbc3200088ef160c4`.
- Package includes `lib/net45/UnityEngine.dll`, `UnityEngine.CoreModule.dll`, `UnityEngine.Physics2DModule.dll`, `UnityEngine.AnimationModule.dll`, `UnityEngine.AudioModule.dll`, and `UnityEngine.ImageConversionModule.dll`; net35 and netstandard2.0 groups also exist.
- NuGet metadata describes these as engine modules, with developmentDependency=true. This is a community-distributed package; its author text `Unity` is not proof of official Unity publisher ownership.

Recommended implementation: pin and hash this archive in the toolchain lock, extract only the net45 modules actually required into a dedicated ignored compile-reference directory, and use explicit `<Reference>` entries with `<Private>false</Private>`. Reuse the API release's MMHOOK and MonoMod libraries. Do not add an unrestricted PackageReference that accidentally copies engine DLLs to the mod package. The expected minimum is CoreModule, Physics2DModule, ImageConversionModule, AudioModule and the UnityEngine forwarding facade; let compilation establish whether AnimationModule or another base type is also required. Runtime/package checks must reject all UnityEngine/API/PlayMaker/framework DLLs in the shipped mod ZIP.

**Compatibility boundary:** the selected engine reference package is a separate, newer compile API surface; this research did not establish the client's Unity editor version or an exact engine binary match. API AssemblyRefs expose engine assembly version 0.0.0.0 and cannot establish editor version. Use only long-established public Unity APIs and compare every newly used signature with the installed baseline's actual Managed metadata before claiming client compatibility. Avoid a direct PlayMaker dependency by not reading `normalSlashFsm` or native FSM fields in C#; reuse public HeroController/NailSlash calls.

For strict exact-runtime engine references, the official fallback is the baseline client's Managed directory:

- [Pinned API README](https://github.com/hk-modding/api/blob/3c47ab577dfcac71bcfae73415618c79310b8f52/README.md#build) explicitly instructs copying the game's Managed directory to Vanilla for API development.
- [Pinned official build workflow](https://github.com/hk-modding/api/blob/3c47ab577dfcac71bcfae73415618c79310b8f52/.github/workflows/build.yaml#L34) obtains `managed.<platform>.tar.gz` from `hk-modding/hk-binary-archives` with a secret deploy key. That repository returned HTTP 404 publicly; it is not an unauthenticated bootstrap source.
- No exact public PlayMaker or full game-reference package was established. Do not claim missing references are already solved merely because the current log-only scaffold compiles. The compile-only route avoids requiring the user to upload game files in order to begin development; installed-client metadata and real play remain acceptance gates.

### Exact attack hooks and signatures

Pinned source: [HeroController.cs](https://github.com/hk-modding/api/blob/3c47ab577dfcac71bcfae73415618c79310b8f52/Assembly-CSharp/Patches/HeroController.cs), [ModHooks.cs](https://github.com/hk-modding/api/blob/3c47ab577dfcac71bcfae73415618c79310b8f52/Assembly-CSharp/ModHooks.cs).

| API / native member | Verified behavior |
| --- | --- |
| `ModHooks.AttackHook` | `Action<GlobalEnums.AttackDirection>`; notification, cannot return cancellation. Source ModHooks.cs:1374. |
| `ModHooks.DoAttackHook` | `Action`; notification before original DoAttack. Source ModHooks.cs:1407. |
| `ModHooks.AfterAttackHook` | `Action<AttackDirection>`; source HC:230-237 calls it **before** `NailSlash.StartSlash()`, then aborts StartSlash if `cState.attacking` was cleared. XML's “end” summary is incomplete. |
| `ModHooks.HeroUpdateHook` | `Action`; called before native Update, HC source:825-830. Use a MonoBehaviour LateUpdate for final visual synchronization. |
| `HeroController.Attack(AttackDirection)` | Public in the exact local DLL, RVA 0x1cb68. Native On hook can wrap this method. |
| `HeroController.DoAttack()` | Private in exact final DLL, RVA 0x1fefd, despite patch source spelling public. Private hook is generated by official `HookGen --private`. |
| `HeroController.CanAttack()` | Private bool, RVA 0x227dc. Native gate checks cooldown, attacking, dash, death, hazards, relinquished control and hero states. |
| `HeroController.CancelAttack()` | Private void, RVA 0x20ce5. If attacking, calls selected `slashComponent.CancelAttack()` and `ResetAttacks()`. |
| `HeroController.ResetAttacks()` | Private void, RVA 0x20db4. Clears nail charging, attack/up/down flags and `attack_time`; does **not** reset attack_cooldown. |
| `NailSlash.StartSlash()` | Public void, RVA 0x26308. Reads configured native direction, starts audio/animation, applies native longnail/mantis/fury behavior, resets slash counters and marks slashing. |
| `NailSlash.CancelAttack()` | Public void, RVA 0x26649. Clears slashing and disables its attack polygon, clash polygon and mesh. |
| `HitTaker.Hit(GameObject, HitInstance, int)` | Public static void, RVA 0x64b8. Walks target and parents up to the recursion limit, dispatching IHitResponder.Hit. |

Official API csproj runs HookGen with `--private` for Assembly-CSharp and PlayMaker. Read-only metadata inspection of the **exact local MMHOOK DLL** confirmed these delegate Invoke signatures (fully qualified nested orig delegate names shown):

```csharp
// On.HeroController
void orig_Attack(HeroController self, GlobalEnums.AttackDirection direction);
void hook_Attack(On.HeroController.orig_Attack orig, HeroController self,
                 GlobalEnums.AttackDirection direction);
bool orig_CanAttack(HeroController self);
bool hook_CanAttack(On.HeroController.orig_CanAttack orig, HeroController self);
void hook_DoAttack(On.HeroController.orig_DoAttack orig, HeroController self);
void hook_CancelAttack(On.HeroController.orig_CancelAttack orig, HeroController self);
void hook_ResetAttacks(On.HeroController.orig_ResetAttacks orig, HeroController self);
void hook_Start(On.HeroController.orig_Start orig, HeroController self);

// On.NailSlash
void orig_StartSlash(NailSlash self);
void hook_StartSlash(On.NailSlash.orig_StartSlash orig, NailSlash self);
void hook_FixedUpdate(On.NailSlash.orig_FixedUpdate orig, NailSlash self);
void hook_CancelAttack(On.NailSlash.orig_CancelAttack orig, NailSlash self);
```

The corresponding no-extra-argument orig delegates all return void and accept only their HeroController or NailSlash instance. Use these generated hooks directly; there is no need to acquire a PlayMaker reference merely to use this adapter surface.

Useful exact local fields:

- Public: `HeroController.normalSlash`, `alternateSlash`, `upSlash`, `downSlash`, `wallSlash` are NailSlash; `cState` is HeroControllerStates; `vertical_input` and `move_input` are float. Public `ATTACK_DURATION`, `ATTACK_DURATION_CH`, `ATTACK_COOLDOWN_TIME`, `ATTACK_COOLDOWN_TIME_CH`, `ATTACK_RECOVERY_TIME`, `ALT_ATTACK_RESET` are float.
- Private float: `attack_time`, `attack_cooldown`, `attackDuration`, `altAttackTime`. Private selected `slashComponent` is NailSlash. Access these only through one narrow version-checked ReflectionHelper adapter if needed; do not scatter field strings across gameplay code.
- Private queue state: `attackQueuing` bool and `attackQueueSteps` int. Original queue is five fixed steps (source HC:378-381), much shorter than some four-stage recovery windows. A deliberate combo buffer is required if the next press must survive the full recovery.
- Public `NailSlash.animName` string and `scale` Vector3; native collider, renderer, slashing and counters are private.

### Native transaction reuse: recommended bounded prototype

Keep the native HeroController, Rigidbody2D, colliders, input handler, tk2d animator and player state machines. Add an owned Wukong presenter plus a pure combo timeline and a small v77 adapter.

1. Wrap `On.HeroController.Attack`. Intercept only the owned hero, `attackDir == AttackDirection.normal`, `cState.onGround`, and a live input/control/scene state. Explicitly exclude wallSliding. All other calls pass to `orig` once. Reset a pending grounded combo when leaving ground or receiving a directional attack; do not rewrite air/downslash/pogo behavior.
2. Let original DoAttack and original Attack perform native input/direction/state setup once per **accepted stage**, including current charm selection. The local `orig_DoAttack` (RVA 0x2425c) chooses upward first, downward only while airborne, otherwise normal; it writes attack_cooldown from the charm-specific field before calling Attack, and schedules terrain-thunk checks afterward.
3. During this one owned orig-Attack call, wrap `On.NailSlash.StartSlash` narrowly to capture the selected normal/alternate native slash and defer its activation to the authored hit timeline. Do not clear cState.attacking just to exploit AfterAttackHook's early return: that changes native reset/cancel behavior. Do not call a second original Attack at the hit frame: it would duplicate native attack events, shield/beams and state setup.
4. At an owned hit event, invoke the selected existing `NailSlash.StartSlash()` through a one-shot permit, letting its original native animation, collider and damage FSM execute. Hide its renderer while keeping its collider and original FSM enabled; Wukong's baked pose supplies the visible staff. The permit must be scoped with try/finally and only affect this hero's captured slash. Up/down/wall slashes and any other mod's slash must pass through.
5. Native NailSlash.FixedUpdate (RVA 0x26514) enables the attack and clash polygons on stepCounter==1, disables them at stepCounter>=5 after an enabled tick, and cancels once animation and minimum polygon time complete. Thus an authored event cannot simply mean “damage occurs this instant”: account for the fixed-step activation latency. The prototype must demonstrate that these real native hit windows align to the Wukong hit frames. If native timing cannot be aligned, use a version-scoped NailSlash FixedUpdate adapter for only the captured slash; keep its native FSM transaction and explicitly own its polygons instead of adding a second damage system.
6. For attack3's second configured hit, first close/cancel the preceding native hit window, then rearm the same original native transaction at the second timeline event. Verify its source/FSM target memory and HealthManager invulnerability permit the intended second hit. Do not assume two StartSlash calls imply two HP losses; if this fails, stop at a documented prototype gate and adapt the owned transaction, not enemy-wide invulnerability.
7. Own stage timing and one queued follow-up input; stage duration and native attack_cooldown must agree. Because native Update increments attack_time and resets attacks independently, the adapter must set/version-check attackDuration and attack_cooldown for the accepted stage or wrap the native reset gate. Preserve Quick Slash via an explicit ratio based on native charm/noncharm cooldown, rather than replacing all attack constants globally. Resolve this integration in the prototype before implementing the whole combo.
8. On cancellation, call the native cancel/reset path while ownership is still marked, then remove owned hit windows, buffer and animation override. Do not restore stale cState snapshots or write `attacking=false` after a newly started native aerial attack. A scoped stage token ensures late animation callbacks cannot cancel a newer attack. Cooldown policy must be explicit: native ResetAttacks does not clear it. Never restore an old preattack cooldown after the player has entered another action.

This is a prototype recommendation, not a proven final runtime implementation. Its value is preserving native damage and interaction ownership with small, auditable hooks; the stage scheduler still changes actual cadence, poses and active hits, so it meets the selected behavioral combo goal rather than merely selecting four visual clips.

### Damage, scaling and duplicate prevention

- Reuse the original initialized normal/alternate slash **instances**, rather than cloning bare DamageEnemies components. Their existing FSMs carry current nail/charm damage, collision filtering, direction, hit effects and scene-object events. A clone may keep stale charm data and duplicate trigger consumers.
- Source HC:61-68 selects Quick Slash duration; HC:95-137 implements Grubberfly beams; HC:233-236 starts the selected NailSlash and sends Dreamshield SLASH. Native NailSlash.StartSlash applies longnail/mantis/fury rendering/scale state. Preserving source calls is necessary but not sufficient to claim every charm works: validate the actual FSM data in the client.
- Exact local HealthManager.Hit (RVA 0x33020) returns immediately while `evasionByHitRemaining > 0`, sends `DEALT DAMAGE` to `HitInstance.Source`, then performs its native hit path. HealthManager.TakeDamage (RVA 0x33448) sends `HIT LANDED` to Source and calls `HeroController.SoulGain()` for qualifying nail damage. Do not add manual SoulGain on top.
- Exact DamageEnemies.DoDamage (RVA 0x2f318) sends `TAKE DAMAGE` to the target, builds HitInstance from its public fields, sets `Multiplier=1`, `IsExtraDamage=false`, and calls `HitTaker.Hit(target, hit, 3)`.
- DamageEnemies is **not inherently one-hit-per-swing**: OnTriggerEnter2D adds to enteredColliders, FixedUpdate calls DoDamage repeatedly for each active collider, and OnDisable clears this list. Native HealthManager/FSM rejection currently limits repetitions. Multiple colliders can resolve to the same responder. A new hand-built DamageEnemies hitbox would need a deliberate responder/pulse policy and object-interaction equivalent.
- `ModHooks.HitInstanceHook` is documented broadly, but pinned ModHooks.cs:390 identifies its actual caller as `HutongGames.PlayMaker.Actions.TakeDamage`. A direct custom HitTaker/HealthManager.Hit call must not be assumed to invoke this API hook automatically.
- Source ownership invariant: during one owned native hit pulse, only the chosen original slash may have its relevant attack collider open; no custom overlap loop or added DamageEnemies may also damage the same target. Cancel/close old pulse before opening the next. Do not hide a slash by disabling its whole GameObject, which also disables the FSM/collider.
- Keep upward/downward slash objects and their collider/layer/HitInstance behavior unchanged. Local NailSlash.orig_OnTriggerEnter2D (RVA 0x26678) has explicit 270-degree bounce and shroom/spike handling; rewriting all collisions would break pogo.
- Do not promise arbitrary collider shape/range changes without checking the existing slash's sprite-driven PolygonCollider2D and Clash Tink polygon. Initial four-stage prototype can reuse the native horizontal collision shape with authored stage-specific timing; staff-specific reach is an explicit next adapter step, and range charms must multiply any new base reach.

### Attach, detach, rendering and recovery contracts

- Register hooks once in Mod.Initialize; support ITogglableMod.Unload if dynamic disable is offered. Keep exact delegate instances for removal. Never let re-enable multiply the subscriptions.
- Attach one owned component when HeroController exists and is initialized, including the already-loaded-save case. A Start hook must call orig first; HeroUpdate discovery can cover late availability but must be idempotent.
- Cache hero-instance identity. On scene unload, death, hazard respawn, relinquished control, hero replacement, owned component OnDisable/OnDestroy, and mod unload, invalidate the stage token, close captured native slash windows, clear queued attacks and dispose owned sprites/textures/audio objects. Restore only the renderer/geometry/settings actually owned by this adapter, and only to their current owner instance.
- Preserve the original tk2d animator running internally to drive gameplay/animation-state logic. Render a separate child SpriteRenderer using baked PNG frames, a stable feet pivot, facing and scale. Mirror native world placement and visibility states such as entering/exiting scenes, recoil, death, dash and cutscenes. A LateUpdate presenter can overwrite its own pose after the original controller updates.
- Hide only the native body and selected native slash renderer; never deactivate the hero root, replace its collision bounds, or turn off the tk2d animator/FSMs. If using Renderer.forceRenderingOff to preserve native enabled-state visibility, first verify that property in the actual baseline engine metadata. If using enabled=false, account for native code that writes enabled and restores it every frame; cache-once/restore-once alone is insufficient to establish visibility correctness.
- Missing/unsupported renderer assets or hook preconditions should restore the native appearance and cancel this adapter cleanly, rather than leave an invisible playable character.

### Required prototype and client verification gates

1. Reproducible Linux compile with explicit compile-only references; inspect artifact contents to ensure none ship. Confirm exact local MMHOOK delegate shapes and all reflected fields at initialization.
2. Tiny native slash prototype first: one accepted horizontal input, deferred native hit, exactly one enemy damage transaction and one normal soul gain, breakable/grass/lever/nail-interactable behavior, expected terrain thunk, then cancel and restore.
3. Verify native first/second pulse behavior on attack3 against a stationary single target and a target with multiple colliders; verify actual two HP losses, no unplanned repeats, no global invulnerability edits, and pause/time-scale consistency.
4. Four-stage order, deliberate follow-up buffering, timeout reset, turn/jump/dash/damage cancellation, no late callbacks affecting the next attack. Verify stock cooldown and direction behavior immediately after cancellation.
5. Nail upgrades, Quick Slash, Strength/Fury, Longnail/Mark of Pride and Grubberfly/Dreamshield compatibility. Distinguish deliberate combo tuning from accidentally lost charm behavior.
6. Air horizontal, upslash, downward pogo on enemies/spikes/shrooms, wall interactions, scene changes, bench/death/reload and mod disable. Wukong visuals must follow these retained actions.

## Caveats / Not Found

- No actual installed client, Unity process, scene/prefab asset inspection, gameplay test or real-load result. Metadata and IL cannot establish that native prefab FSMs behave as expected under delayed/repeated activation.
- No exact public complete reference archive or engine editor version established; UnityEngine.Modules 2021.3.33 is a pinned compile-only candidate with a required baseline API-surface/client gate.
- Exact damage FSM layout, per-target pulse reset, effective invulnerability duration, sprite-driven collider geometry and some charm-specific damage setup live in game assets / further native logic. They are explicit prototype gates, not facts inferred from XML summaries.
- Only the existing API package and public source/archive bytes were read. Small Python PE/IL inspection libraries were loaded into memory for read-only analysis; no dependency installation, game modification or product/spec edit was performed.
