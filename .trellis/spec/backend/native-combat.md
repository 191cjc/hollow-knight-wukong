# Native Hero and Combo Integration Contract

## 1. Scope / Trigger

Use this when changing character presentation, ground combo timing, native hook ownership, hit deduplication or lifecycle cleanup. Current baseline is Hollow Knight 1.5.78.11833 / Modding API v77 / net472. Implementation lives in `src/WukongKnight/NativeV77.cs`, `WukongRuntime.cs`, `WukongPresenter.cs` and `Core/ComboTimeline.cs`.

## 2. Signatures

- Pure combo: `Press(double now, double timeScale)`, `Advance(double now, double nextTimeScale)`, `Cancel()` return ordered ComboEvent records; `TryHit(long token, int window, int responderId)` owns per-window target identity.
- Native On hooks wrap exact pinned signatures for HeroController.Attack/CanAttack/ResetAttacks, NailSlash.StartSlash/FixedUpdate/CancelAttack, DamageEnemies.FixedUpdate/DoDamage, HitTaker.Hit and HealthManager.Hit. Private HookGen hooks exist in the locked MMHOOK DLL; do not invent public game members to make compilation pass.
- Version-sensitive reflection belongs only in NativeV77. Check required fields/methods before enabling replacement.
- Mod initialization/unload owns subscriptions and disposable resources; an attached WukongLifetime owns synchronization and detach callbacks for its current hero instance.

## 3. Contracts

- Only owned, grounded, normal horizontal attacks enter the combo; air/up/down/wall attacks retain original semantics, including pogo. Preserve native HeroController, collision, animator, FSMs and resource/save systems.
- One accepted input starts one stage; at most one follow-up can be buffered during the configured window. Fourth-stage completion, timeout and interruptions reset the chain. Held input must not silently auto-play all four attacks.
- Advance gameplay timing in fixed-step synchronization so rendering at 15 FPS does not skip a short hit window. Visual sampling follows the same scaled source-tick clock; Quick Slash scaling applies consistently.
- Each accepted stage initializes its native DoAttack/Attack transaction once. Capture only its selected normal/alternate StartSlash and activate controlled native hit windows; do not call Attack again at the hit frame or add a parallel custom damage source.
- Synchronize an owned DoDamage entry before its native FSM event: native TAKE DAMAGE precedes HitTaker, so synchronizing only in Hit cannot reject all expired-window interactions. Native source damage/FSMs preserve nail upgrades, applicable charms, soul and scene interactions. Do not add SoulGain manually. Original attack polygons and clash interactions require explicit ownership and cleanup.
- Closing an owned slash must also clear its descendant DamageEnemies contact lists: native CancelAttack only disables polygons/mesh and leaves enteredColliders until a later physics exit. If a close occurs during native iteration, defer the list mutation to the outermost FixedUpdate finally and suppress that source's remaining DoDamage callbacks, including TAKE DAMAGE events. Do not retain suppression into a later native air attack. Unload inside a native iterator retains only these cleanup guards until its synchronous unwind completes. `Core/DeferredContactCleanup.cs` owns this tested policy; private contact-list access belongs in NativeV77.
- Hit identity is the actual responder, not the collider. A stage token plus window ID rejects duplicate targets and stale callbacks; stage3 has two independent target sets. A native HealthManager evasion rejection must not consume an opportunity prematurely or be bypassed by rewriting global enemy invulnerability.
- AttackHook/DoAttackHook are Action notifications, not cancelable filters. AfterAttackHook is before StartSlash in this version. ResetAttacks clears attack flags/time but not attack_cooldown; keep a deliberate owned timing release policy.
- Preserve native enabled/visibility writes while suppressing the original body drawing. Source Wukong faces right; cancel inherited root mirroring and apply one explicit facing mapping. Up/down native slash effects remain available with Wukong body fallback poses.
- Appearance enlargement is baked into separate PNG variants; do not add a runtime appearance multiplier. Preserve baseline pixel-to-world calibration and use the variant's feet offset to anchor to the native collider. Never enlarge the hero root or change body colliders to resize the artwork.
- Each combo hit window restarts the selected native NailSlash animation and keeps its original renderer visible. Do not suppress its mesh in StartSlash or FixedUpdate; CancelAttack closes its visual with the owned hit window. Original slash resources and charm variants remain authoritative.
- Cancel/detach closes owned hit windows, clears queued input and restores only the same hero's owned timing/geometry/rendering. Cover jump/dash/turn/damage/death/scene/control loss, disable, hero replacement and failed initialization. Old callbacks cannot reset a newer native action.
- Compilation with newer pinned Unity compile references is not an exact runtime compatibility proof. Only the actual baseline client can establish native FSM, charm, collision and rendering acceptance.
- Flame Dash calls native HeroDash once and owns only its presentation and added damage. Use the unchanged hero collider bounds for sweeps; deduplicate actual responders per dash token and preserve native evasion. Suspend the separate Sharp Shadow source while owned to avoid double damage. Keep movement, unlocks, cooldown, collision and invulnerability native.
- A dash sweep captures its token before sampling. Recheck it before every target and after the native TAKE DAMAGE event: synchronous FSMs may cancel/unload/replace the dash. Old sweeps must not hit for a newer dash or overwrite its previous center. Restore owned renderer suppression on every exit. See `docs/FLAME_DASH.md`.
- Fire Demon Slash must replace native Quake damage sources rather than stack with them. Original AS3 uses independent air/finisher effect regions, per-target caps (11/1) and a 100 game-ms air contact cooldown, not nine guaranteed animation pulses. Finisher creation follows completion of the air effect in the original code. Treat movement/input/Soul integration separately from damage ownership. See `docs/FIRE_DEMON_RESEARCH.md` and the preserved `reference/flash/fire-demon/` evidence. Do not silently use XML decimal growth: this archived SWF declares skillAdd as int and truncates the fractional source values. Original source damage units need an explicit Hollow Knight stat mapping.

### Query-based skill contacts

`SkillTargetPolicy.QueryMask(nativeAttackMask)` removes layers 9/20/26/31 from
the actual `Physics2D.GetLayerCollisionMask(17)`. Both dash sweep/overlap and spell
overlap use it. `NativeV77.SkillTarget(collider, hero, mask)` rejects disabled,
inactive, hero-descendant and Geo colliders before resolving up to three levels.
`SkillTargetPolicy.Allows(layer, mask, healthTarget)` additionally requires layer
11 for HealthManager targets; allowed layer-17 boss weapons must not route damage
to an ancestor boss. Do not reject all triggers: real hurtboxes may be triggers.
Resolve before deduplication/contact ledgers/FSM side effects. Query overlaps do
not inherit the source object's layer collision filtering automatically. Hornet's
44-unit Refight Range on layer13 caused room-wide damage through parent walking.
Core tests use extracted native layer/mask cases and verify sensors cannot
consume a later valid body hit. In-client distance tests remain required.

Fire Demon 0.4.3 restores original relative effect roots and mask centers;
the centered/raised adaptations are superseded. See the source-clock rules below.

## 4. Validation & Error Matrix

### Fire Demon adapter rules

`FireDemonDamage(quakeLevel, shamanStone)` is the only runtime damage table:
2/14 or 3/22 (air/finisher); Shaman Stone uses ceil(x1.5), giving 3/21 or 5/33.
Never read nail damage for this spell. `SpellHitLedger` owns per-target 100ms
contacts/cap 11, one finisher and cast tokens; no lag catch-up pulses.

Native Quake damage can originate in PlayMaker TakeDamage as well as
DamageEnemies. Suppress scoped native effect colliders and reject their source
identities at HitTaker/HealthManager boundaries. Hold only Quake Antic's tk2d
completion with a real ignored FsmEvent (null can retain an old callback). Source
FireDemonTimeline owns preparation [0,5), air [5,36), finisher [36,56), at 30 FPS.
Finisher never waits for landing. FinishCast enters Quake Finish directly; native
Spell End restores input, animation and gravity. Never release ANIM END into the
native Level Check 2/Quake Down path. On dead/transitioning/inactive heroes, do not
force recovery/control regain. Restore all owned patches on disposal/failure.

Use the existing untouched effect5 clip for moving character flashes and real
blink gaps, not the normalized/held legacy fireDemonAir/Dive/Land clips. The normal
native body remains independently hidden. Original air spawn is (+177 facing,
+95 Unity up) source pixels; air/finisher local centers/dimensions live in
FireDemonGeometry. Source rectangles and offsets use baseline world units per
pixel, not offline ArtworkScale. Preserve both facing directions and world anchors.
Native antic EnemyKillShake is disabled/restored; Down/Land and their BigShake
events are never entered. No global camera patch is permitted.

The attached hero remains protected throughout preparation, air and finisher via
TakeDamage/TakeHealth guards that observe native state first. No save/global
invincibility flag changes. Native CanTakeDamage=false is insufficient because
its alternate branch can still apply spike/acid HP loss. Custom protection stops
on completion/cancel/detach, with native recovery behavior left native. Finisher
phase changes retain Active; stale callbacks cannot damage or change newer casts.

Extended Quake Antic must maintain movement ownership through the whole cast,
not only its native entry actions. `FireDemonSlash.Observe()` checks active state,
interruptions and timeline completion before calling native RelinquishControl,
IgnoreInput, ResetInput, AffectedByGravity(false) and zeroing the native Rigidbody2D
velocity. RelinquishControl early-returns if already relinquished; IgnoreInput
resets axes only when acceptingInput changes. Explicit ResetInput is required.
Observe before Hero.Update and before/after Hero.FixedUpdate; the attached
lifetime's FixedUpdate order is insufficient. Keep both original updates alive
exactly once and unsubscribe the physics hook on unload. Preserve authored moving
body frames; never solve input drift by removing their animation or teleporting
the hero. Completion/cancel must stop all movement writes before native recovery.
No persistent constraints, saved momentum or global InputHandler changes.

Required client regression: hold/reverse/release directions in all three phases,
ground/air casts, hold across recovery, pause/resume, low FPS, repeated casts and
detach/death/scene. Core timing tests cannot prove Unity input/physics behavior.

| Condition | Required behavior |
| --- | --- |
| Missing/mistyped private member or required engine API | Log and disable replacement; keep/restore original visibility/control. |
| Unsupported or missing asset manifest | Do not hide the original hero; dispose partial sprites/textures/view. |
| Input outside ground-horizontal scope | Cancel owned ground state if needed, call original behavior once. |
| Same responder hit twice in one window | Reject the duplicate; a later valid window may hit again. |
| Native target still evading a hit | Preserve rejection; allow a later callback inside the valid window rather than changing enemy-wide state. |
| Interrupted/stale stage token | Close owned damage and reject old callbacks without touching a newer stage. |
| Closing a slash during native contact traversal | Suppress the remainder of that source's traversal, then clear contacts once the final iterator returns; do not mutate the list from inside Hit. |
| No client available | Report compiled/automatically checked separately; actual gameplay remains pending. |

## 5. Good / Base / Bad Cases

- Base: one press starts attack1, its window opens/closes, then control recovers without automatic attack2.
- Good: four intentional inputs yield ordered stages; attack3 can hit the same target once per valid pulse; jump/air/downslash immediately retain native control and pogo.
- Bad: repeated DamageEnemies callbacks produce extra hits, old cleanup clears a new airborne attack, or successful compilation is described as verified in-game combat.

## 6. Tests Required

- Link the actual engine-free core into `tests/WukongKnight.Core.Tests`; run it using the local SDK. Assert input buffering/cap, timeout boundaries, fourth-stage reset, cancellation, token/window target ownership, two pulses and Quick Slash clock consistency.
- Link the production deferred-contact helper into the core tests. Cancel during a reverse-index contact traversal, ensure later targets receive no callback, retain nested-iteration guards until outer exit, and allow the same source to start a later native transaction.
- Verify exact compiled hooks/members against the pinned local DLL, and compile Release with warnings-as-errors. Do not create fake Unity/game stubs as a substitute.
- Client acceptance covers two actual HP losses for stage3, duplicate colliders, native soul/breakables/terrain feedback, nail/charms, directional/air/pogo, low FPS, pause, scenes/death/reload and disable/re-enable.
- Review failure cleanup and partial initialization, including registration/unregistration symmetry; pure core tests do not exercise Unity lifecycles.

## 7. Wrong vs Correct

Wrong: clear `hero.cState.attacking` inside AfterAttackHook to skip the native Slash, then send a custom HitInstance and manually grant soul.

Correct: let the original transaction initialize once; defer only the owned selected Slash until the authored window, use the native hit/feedback chain with scoped deduplication, and release that stage's timing and renderer ownership on every exit. See WukongRuntime/NativeV77 for the concrete adapter, and keep its token guards when adding skills.
