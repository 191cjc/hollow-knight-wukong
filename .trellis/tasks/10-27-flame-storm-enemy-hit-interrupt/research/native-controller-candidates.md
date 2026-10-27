# Research: native C# enemy controller candidates

- Query: Can the pinned native C# controllers establish any concrete enemy with a real hurt/attack-cancel/reentry mechanism without the unavailable serialized enemy FSMs?
- Scope: internal; project/API binaries and XML only. No game execution, public-source search, product implementation or task activation.
- Date: 2026-10-27.
- User constraints: establish feasibility and the enemy list first. Every actual damaging hit must restart the supported hurt response, including during an existing hurt response.
- Baseline: Hollow Knight `1.5.78.11833` / Modding API `77`, existing `.tools/hollow-knight-api-v77/Assembly-CSharp.dll`; binary SHA-256 recorded in `native-hurt-contract.md`.

## Findings

### 1. Result and support classification

**Confirmed named enemies satisfying the complete requested behavior from this local evidence: none.** This is a limit of the available evidence, not a finding that all enemies lack hurt states.

There is one concrete **component-level native reaction candidate**, `Climber.Stun()` / `DoStun()`. Its original C# code really suspends its own movement coroutine, runs a native `Stun` animation wait, and resumes walking. It is more than a VFX-only hit flash. However, the code alone does not establish which actual enemy prefabs use it, their attack-resource ownership or the required repeated-animation restart. In fact, the repeated-animation gap is visible in the pinned native code itself.

| Controller/component | Confirmed native mechanics | Classification for the requested feature |
| --- | --- | --- |
| `Climber` | Native Stun coroutine: stop own coroutines, zero body velocity, play/wait for `Stun`, restart Walk; ignored while its turn coroutine is active. | Concrete investigation candidate only. No verified enemy mapping; native repeat does not guarantee animation restart; no attack-resource cleanup proven. |
| `Crawler` | Walk/turn locomotion, native Recoil configuration and cancellation callback. | No dedicated hurt entry established. Movement freeze/recoil is not sufficient. |
| `Walker` | Waiting, stopping, walking and turning behavior; configured idle/walk/turn clips. | No native hurt action established. Stop is locomotion ownership, not a verified attack/hurt route. |
| `EnemyHitEffectsArmoured`, `EnemyHitEffectsBlackKnight`, `EnemyHitEffectsGhost`, `EnemyHitEffectsShade`, `EnemyHitEffectsUninfected`, `InfectedEnemyEffects` | Hit sound, sprite flash, impact particles/objects and optional `DAMAGE FLASH`/armour-effect notifications. | Hit feedback only; cannot establish AI attack cancellation, hurt state or recovery. |
| `ScuttlerControl` | Accepted hit sets `alive=false`, cancels run/bounce, produces terminal effects and deactivates or runs its native healing-related tail. | Terminal responder behavior, not a surviving HP-loss/hurt/recovery state. No added interruption candidate. |
| `CorpseDeathStun`, `CorpseDeathStunChunker` | Corpse subclasses with death-stun/jitter coroutines. | Death presentation, excluded from the required nonfatal enemy reaction. |
| `BigCentipede`, `BrokenVesselGlob`, `HiveKnightStinger`, `FakeBat` | Burrow/movement, projectile motion or bat dispatch behavior in the inspected code. | No dedicated hurt/reentry route found in these classes. This does not prove that every prefab using them lacks an additional serialized FSM. |
| Other ordinary enemies and bosses | No per-enemy serialized controller structure is supplied by this DLL/XML. | Unverified; do not infer support or absence from journal names, class names or shared HealthManager fields. |

No enemy names are assigned to `Climber`/`Crawler` merely from familiarity with Hollow Knight. A component-to-prefab mapping must be evidenced by actual prefab data or reliable corresponding source dumps.

### 2. Search coverage and files found

Read the active `prd.md` and the prior `native-hurt-contract.md`; preserved the existing relevant native-combat contracts. The original API XML predominantly documents Modding API interfaces and does not provide enemy prefab/controller wiring.

The existing Cecil inspector was used unchanged for top-level native method bodies. Its implementation `.tools/runtime-inspect/Program.cs:3` enumerates `module.Types`, so it cannot visit compiler-generated nested iterator types. To resolve the material coroutine gap, a task-local read-only PE/ECMA-335 decoder was added under this task's research directory. It does not modify/rebuild the shared helper, load Unity, or write outside this research directory. It uses only Python's standard library, reads the pinned DLL, and records abbreviated member names and IL offsets. This is a research evidence tool, not product implementation.

Persisted evidence:

- `research/native-controller-type-catalog.txt:1`: 1,662 global-namespace TypeDef names, including nested types, extracted from the DLL's 3,553 total TypeDefs. This prevents treating a PlayerData journal key from a string search as proof of a controller type.
- `research/native-controller-method-catalog.txt:1`: method inventories for those global-namespace TypeDefs.
- `research/native-controller-hurt-methods.txt:1`: a method-name sweep across **all** TypeDefs/namespaces for hurt/stun/hit/attack-cancel/damage entry names. This is discovery evidence only, not proof that differently named FSM actions cannot exist.
- `research/native-controller-candidates-il.txt:1`: top-level Climber/Crawler/Walker/Scuttler and hit-effect method bodies from the original Cecil inspector.
- `research/native-controller-secondary-il.txt:1`: top-level BigCentipede/BrokenVesselGlob/FakeBat/HiveKnightStinger/corpse-stun, PlayHitEffects/BeginRecoil and Extensions.PlayAnimWait bodies from the original Cecil inspector.
- `research/native-controller-nested-il.txt:1`: decoded Climber.DoStun/Walk, Crawler.Walk/Turn and Extensions.PlayAnimWait iterator bodies.
- `research/native-controller-metadata.py:1`: task-local decoder used for the catalog and nested-body evidence; rerun from repository root with `python3 .trellis/tasks/10-27-flame-storm-enemy-hit-interrupt/research/native-controller-metadata.py`.

The all-namespace entry-name search found `Climber.Stun`/`DoStun`, shared HealthManager/damage/feedback methods, corpse death methods, Scuttler's terminal Hit, player-only handlers and scenery Hit handlers. It did not find an additional dedicated enemy `Hurt`/`Stun` controller entry. This search narrows candidate investigation; it is not a complete enumeration of native serialized enemy states or proof about all unnamed entry routes.

### 3. Climber: actual original reaction path

Native method bodies in `research/native-controller-candidates-il.txt`:

- `:16`, `Climber.Awake`: acquires its own Rigidbody2D, BoxCollider2D and tk2dSpriteAnimator.
- `:30`, `Climber.Start`, IL `00cf..00f2`: when Recoil exists, sets `SkipFreezingByController=true` and attaches `Climber.Stun` to native `Recoil.OnHandleFreeze`. It then starts `Walk`. This demonstrates an intended native reaction route, rather than an invented state name.
- `:225`, `Climber.Stun`, IL `0000..001b`: if `turnRoutine != null`, return. Otherwise call `StopAllCoroutines()` on this Climber component, then start its own `DoStun()` coroutine.
- `:237`, `Climber.DoStun`: constructs its compiler-generated iterator. The iterator body is the part needed to understand actual reaction/recovery.

`research/native-controller-nested-il.txt:158`, `Climber/<DoStun>d__23.MoveNext`, RVA `0x0002d26c`, 105 bytes:

1. Set the component's body velocity to native Vector2.zero (`IL_001e..0029`).
2. Start/wait for `Extensions.PlayAnimWait(anim, "Stun")` (`IL_002e..0052`).
3. After that wait completes, start `Climber.Walk()` (`IL_005a..0066`).

`research/native-controller-nested-il.txt:3`, `Climber/<Walk>d__17.MoveNext` begins the native walk animation and movement and manages its turn routine. These bodies establish a real native temporary movement/stun/recovery mechanism at the component level.

Material limitations:

- The DLL does not establish a particular enemy prefab that owns this component or a configured `Stun` clip. `PlayAnimWait` assumes its clip lookup succeeds; validating the actual animator library is required.
- The original Recoil callback path additionally depends on target Recoil settings such as `freezeInPlace`; these are not established by the Climber method body. Calling Climber.Stun directly would need a verified profile rather than treating Recoil presence as proof.
- `StopAllCoroutines()` affects this Climber's coroutines. It does not prove cancellation of arbitrary attack scripts, sibling FSMs, child DamageHero hitboxes, projectiles or external scheduled actions on the prefab. No such resources are identified here.
- The source controller's own exposed routines are locomotion/stun, not named attack routines. Do not advertise stopping a specific enemy attack based only on its walking suspension.
- The original turn exclusion is explicit and must not be silently bypassed to claim universal interruption.

### 4. Climber's repeated reaction does not satisfy the full repeated-animation requirement by itself

`research/native-controller-nested-il.txt:375`, `Extensions/<PlayAnimWait>d__5.MoveNext`, RVA `0x0008300c`, 126 bytes:

1. Look up the requested clip with `GetClipByName` (`IL_0022..0033`).
2. Call ordinary `tk2dSpriteAnimator.Play(clip)` (`IL_0034..003b`).
3. Wait `clip.Duration` using native WaitForSeconds (`IL_0040..0059`).
4. Wait one native end-of-frame and return (`IL_005a..007d`).

This is a fixed clip-duration wait, not an animation completion delegate or a wait that rechecks the current clip's completion. Calling `Climber.Stun()` again while already stunned can cancel/recreate its coroutine and duration wait, because it does not set `turnRoutine` for the stun. However, the animator is still subject to the pinned same-clip fast path from `native-hurt-reentry-il.txt:190`: `Play` with time zero on an already playing same clip updates FPS and returns without resetting its frame clock.

Consequently, native Stun alone can extend/restart its wait while the displayed `Stun` animation continues instead of restarting from its beginning. The user explicitly selected restarting the hurt action on every actual damaging hit. This needs an evidenced compatible animation+controller restart route before this candidate becomes supported; a bare repeat of Stun or a generic SetState assumption is insufficient. No such compatible route or client acceptance is claimed here.

### 5. Why the other apparent candidates do not establish a hurt adapter

`Crawler.Start` (`research/native-controller-candidates-il.txt:515`) configures native Recoil speed, cancellation and `freezeInPlace` by CrawlerType. `Crawler/<Walk>d__11.MoveNext` (`native-controller-nested-il.txt:202`) plays `Walk`, applies its movement velocity, checks terrain and waits for turning. Its local variable named `hit` is the result of its own wall/ground ray checks, not proof of being hurt by a player hit. The source's native recoil/freeze behavior must not be relabeled as an original hurt state.

`Walker` (`native-controller-candidates-il.txt:2520`) exposes idle/walk/turn clips and state transitions for waiting/stopping/walking/turning. `BeginStopped` (`:2828`) can stop locomotion and optionally play idle, depending on a stop reason. There is no verified hurt clip/entry or attack cleanup in these routines; arbitrary Stop/idle use would invent the requested reaction rather than enter an evidenced original one.

The EnemyHitEffects bodies contain SpriteFlash/audio/particle work and effect events. For example, `EnemyHitEffectsBlackKnight.RecieveHitEffect` (`:896`) sends `DAMAGE FLASH` recursively and spawns hit feedback. Its component name does not identify a native Black Knight attack cancellation route. The shared `PlayHitEffects` FSM action (`native-controller-secondary-il.txt:786`) invokes feedback, and `BeginRecoil` (`:954`) invokes recoil; neither creates the missing attack/hurt/recovery contract.

`ScuttlerControl.Hit` (`native-controller-candidates-il.txt:3495`, IL `000e..0043`) checks alive, sets alive=false and cancels its run/bounce before terminal effects. That is not a surviving HealthManager HP-loss response, and restarting it would run terminal side effects. Its method name is not sufficient to call it a hurt action.

`CorpseDeathStun` / `CorpseDeathStunChunker` (`native-controller-secondary-il.txt:456` / `:489`) derive from Corpse/CorpseChunker. They are death presentation, not the requested live enemy reaction. Their existence does not justify forcing a nonfatal enemy into a death animation.

### 6. What would turn a candidate into a supported enemy entry

For Climber, obtain actual pinned prefab/runtime evidence that maps it to an exact enemy/variant, proves the animator has the original Stun clip, confirms the initialized controller and turn/stun behavior, identifies all relevant attack resources, and establishes a repeatable restart of both the original reaction and animation with recovery after the last hit. Test nonfatal actual Flame Storm HP loss, repeated actual damage while already hurt, native invincibility/rejection, death, teardown and any attached phase/controller behavior.

For FSM-driven ordinary enemies and bosses, actual serialized graphs and original action fields are still required as described in `native-hurt-contract.md`. The absence of an enemy-specific C# class is expected to leave behavior unresolved; it does not establish either support or a missing hurt state.

The resulting enemy list should retain three distinct outcomes: verified compatible native reaction; evidence that the particular original controller has no compatible reaction; and unknown/unavailable layout. All unknown layouts retain native damage/recoil and skip extra forced interruption. The current pass provides no entry in the first category and must not be reported as a completed supported-enemy catalog.

### 7. Related specs and external references

- `.trellis/spec/backend/native-combat.md:10`: exact native hooks and version-sensitive adapters.
- `.trellis/spec/backend/native-combat.md:22`: actual responder identity and native hit evasion.
- `.trellis/spec/backend/native-combat.md:28`: compilation is separate from actual-client acceptance.
- `.trellis/spec/backend/native-combat.md:426`: native recoil/terrain behavior must remain native; no forced enemy transform/velocity implementation.
- `.trellis/spec/backend/native-combat.md:523`: existing spell-slot/Dream ownership and unchanged Storm behavior.
- `native-hurt-contract.md`: native HP/event ordering, per-hit attribution, repeated-state caveats and required enemy profile evidence.
- External provenance only: <https://github.com/hk-modding/api/releases/tag/1.5.78.11833-77>. No public controller mappings or prefab dumps were fetched during this pass; the main session is researching public evidence independently.

## Caveats / Not Found

- No actual client/prefab/FSM/animation library data or real PlayMaker runtime was added. No client test occurred.
- No concrete named enemy is confirmed supported. Climber is a real native reaction mechanism and a useful next investigation target, not a supported-enemy promise.
- A method-name inventory can miss behavior implemented in serialized FSMs or through differently named helpers; it cannot justify an exhaustive unsupported-enemy list.
- No product files, specs, existing tooling, task lifecycle or Git state were changed. All writes remain inside this task's research directory, including a task-local read-only metadata evidence script.
