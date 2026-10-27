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
- Preserve native enabled/visibility writes while suppressing the original body drawing. Source Wukong faces right; cancel inherited root mirroring and apply one explicit facing mapping. v06 uses original Wukong composite nail clips, including directional poses; see the nail presentation contract below.
- Appearance enlargement is baked into separate PNG variants; do not add a runtime appearance multiplier. Preserve baseline pixel-to-world calibration and use the variant's feet offset to anchor to the native collider. Never enlarge the hero root or change body colliders to resize the artwork.
- Each combo hit window still restarts the selected native NailSlash transaction. v06 supersedes the earlier native-art preference: Presenter suppresses only the five actual hero mesh draw submissions; enabled writes, charm logic, polygons, contacts and CancelAttack remain native.
- Cancel/detach closes owned hit windows, clears queued input and restores only the same hero's owned timing/geometry/rendering. Cover jump/dash/turn/damage/death/scene/control loss, disable, hero replacement and failed initialization. Old callbacks cannot reset a newer native action.
- Compilation with newer pinned Unity compile references is not an exact runtime compatibility proof. Only the actual baseline client can establish native FSM, charm, collision and rendering acceptance.
- Flame Dash calls native HeroDash once and owns only its presentation and added damage. Use the unchanged hero collider bounds for sweeps; deduplicate actual responders per dash token and preserve native evasion. Suspend the separate Sharp Shadow source while owned to avoid double damage. Keep movement, unlocks, cooldown, collision and invulnerability native.
- A dash sweep captures its token before sampling. Recheck it before every target and after the native TAKE DAMAGE event: synchronous FSMs may cancel/unload/replace the dash. Old sweeps must not hit for a newer dash or overwrite its previous center. Restore owned renderer suppression on every exit. See `docs/FLAME_DASH.md`.
- Fire Demon Slash must replace native up-spell Scream damage sources rather than stack with them. Original AS3 uses independent air/finisher effect regions, per-target caps (11/1) and a 100 game-ms air contact cooldown, not nine guaranteed animation pulses. Finisher creation follows completion of the air effect in the original code. Treat movement/input/Soul integration separately from damage ownership. See `docs/FIRE_DEMON_RESEARCH.md` and the preserved `reference/flash/fire-demon/` evidence. Do not silently use XML decimal growth: this archived SWF declares skillAdd as int and truncates the fractional source values. Original source damage units need an explicit Hollow Knight stat mapping.

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

`FireDemonDamage(screamLevel, shamanStone)` is the only runtime damage table:
2/14 or 3/22 (air/finisher); Shaman Stone uses ceil(x1.5), giving 3/21 or 5/33.
Never read nail damage for this spell. `SpellHitLedger` owns per-target 100ms
contacts/cap 11, one finisher and cast tokens; no lag catch-up pulses.

Native spell damage can originate in PlayMaker TakeDamage as well as
DamageEnemies. Suppress scoped native effect colliders and reject their source
identities at HitTaker/HealthManager boundaries. Hold Scream Antic1/2 (Fire Demon) or Quake Antic (Storm) tk2d
completion with a real ignored FsmEvent (null can retain an old callback). Source
FireDemonTimeline owns preparation [0,5), air [5,36), finisher [36,56), at 30 FPS.
Finisher never waits for landing. Fire Demon finishes through Spell End; Storm through Quake Finish/Spell End, which restore input, animation and gravity. Never release the held completion into native Scream Burst or Level Check 2/Quake Down. On dead/transitioning/inactive heroes, do not
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
body frames; never solve input drift by removing their animation. Version0.5.1
restores the source skill's own controlled forward travel (below); input denial
must not suppress that travel. Completion/cancel must stop all movement writes before native recovery.
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


## Spell-slot and focus completion contract (0.5)

- `NativeSpellV77(hero, NativeSpellSlot.Up/Down/Focus)` validates the exact native
  state/action signatures before patching. Up holds Scream Antic1/2 FINISHED;
  down holds Quake Antic ANIM END using a real ignored FsmEvent, not null.
  The actual Tk2dPlayAnimationWithEvents native completion delegate only sends
  that event; OnEnter does not Finish the action independently. Restore all owned
  events/effect renderers/colliders on failure/dispose. Focus never disables
  effect colliders; suppress focus visuals only during ordinary focus, not dreams.
- Replaced up/down antic skips the later native TakeMP state. `SpendSoul()` must
  charge current FSM MP Cost once per accepted cast, including Spell Twister.
  Read screamLevel for Fire Demon and quakeLevel for Storm; no nail scaling.
- Storm uses `FlameStormClock` (16 ticks), `FlameStormRules` (original ab_effect3
  local mask, tier7/11, Shaman11/17) and `SpellHitLedger(cap5)`. Preserve 100ms
  per-target contacts, native evasion and shared sensor filtering. No lag catch-up
  or extra immunity. Maintain input/velocity/no-gravity during the action and
  release through native recovery; never teleport or freeze Rigidbody constraints.
- Fire Eye uses native focus eligibility, drain/cancel and charm timing.
  Animation starts on ordinary focus entry at original30Hz scaled time; native
  Soul progress does not drive it. After overlay completion hold only final
  original body pose. See0.5.3 below; native completion alone activates the buff.
- Intercept only AddHealth during Focus Heal/Focus Heal 2. Suppress immediate
  heal and activate `BloodthirstyBuff`; defer Focus Get Finish until the native
  action returns. Other healing must call the original entry unchanged.
- Buff is `[completion, completion+5)` in scaled Time.time. Capture the current
  buff token/instance and enemy HP before native HealthManager.Hit, then compare
  actual HP after the original dispatch. Nail/NailBeam/Spell/SharpShadow qualify;
  scenery, dead targets and zero HP loss never heal. Call AddHealth(1) with a
  reentrancy guard; use one >=1s deadline across all attacks/targets and refreshes.
  Full HP does not spend a proc. Refresh replaces expiry, preserves cooldown and
  invalidates old callbacks. Clear on death/hazard/scene/detach, with no expiry heal.
- Tests link actual production policies for cooldown/expiry/refresh/full HP/stale
  ownership and Storm mask/tier/clock/cap. Native focus routing, Soul cost,
  graphics and cleanup remain pending client acceptance after compile checks.

## 0.5.1 source movement and Jiyuan Fire Eye visual contract

1. Trigger: Fire Demon previously finished at the stationary cast root; Fire Eye
   had its action but omitted the independently loaded original buff visual.
2. Signatures: FireDemonTimeline.TravelPixels is unsigned source displacement;
   FireDemonTravel.Reset/Advance(clock) consume it once. BloodthirstyBuff.VisualTick
   returns30Hz elapsed ticks only while Active(now); presenter owns fireEyeAura.
3. Contract: source shootSpeedX50 * Physics.deltaTime0.1 =5 pixels/tick in [5,36),
   cap155px, signed once by captured facing. Use baseline unitsPerPixel, never
   ArtworkScale. Sweep the unchanged body using Collider2D.Cast with its actual
   native collision mask and useTriggers=false. Clamp against forward-facing
   hit normals; a full32-result buffer rejects the step. Consume blocked distance
   so no later motion can bank it. Air effect is castOrigin+(177facing,+95);
   finisher/body use the resulting hero root. No downward snap or targeting.
4. Lifecycle/error matrix: repeated/older observations ->zero additional travel;
   new cast ->Reset; terrain block ->clamp/discard; complete/cancel/detach ->no
   more movement writes. Source interval owns motion while input remains denied.
   Buff expiry/death/scene/detach ->aura disabled; refresh ->restart visual clock,
   preserve healing cooldown. Presenter cleanup destroys child aura with view;
   both use the same owned material. Missing aura clip fails asset loading safely.
5. Base/good/bad: unobstructed right/left casts finish155 source pixels forward;
   terrain limits travel while preserving native hero size. An input-driven drift,
   teleport through walls or aura retained after expiry violates this contract.
6. Tests: production source travel boundaries, repeated/sparse samples, reset,
   discarded blocked intervals and buff visual lifetime. Python checks independent
   SWF image hashes, original symbol/registration and real baked frames. Native
   sweep/input/graphics remain client acceptance, including walls/slopes/platforms.
7. Wrong: freeze all authored forward motion to prevent keyboard drift. Correct:
   deny input continuously and separately apply only source-timed swept travel.

Public skill name is Jiyuan Fire Eye (汲元火眼). Legacy internal Bloodthirsty class
names and archived buff labels do not change the user-requested5s/1HP/1s policy.


## 0.5.2 Fire Eye presentation selection

Normal focus selects fireEyeCast, the complete original21-tick casting overlay
composited above the unchanged shorter body. Sample below duration using the
existing BloodthirstyFireEye.Progress; do not loop at completed progress1.
Startup holds tick0 and native charge/charm timing remains authoritative.
Cancellation/death/recoil/scene use existing selection priority and remove the
cast effect immediately. This layer owns no new timer, health, Soul, collider or
input writes. The buff's independent fireEyeAura renderer and healing lifetime
remain unchanged; an already active buff can coexist with a new cast. Offline
scaling only, and cleanup remains the presenter's existing material/view disposal.


## 0.5.3 original source clock (supersedes0.5.2 animation timing)

1. Trigger: native startup held Progress=0, then discrete Soul drain drove the
   full21-tick clip. Opening source frames appeared slow despite correct art.
2. Signatures: FireEyeCastClock.Observe(casting, scaledNow), Tick(scaledNow),
   Clear(); BloodthirstyFireEye.CastTick exposes the same owned clock.
3. Contract: start on ordinary focus entry, including startup, once per cast;
   repeated Update/FixedUpdate/LateUpdate observations cannot restart it. Advance
   at original30 Hz using Time.time. Pause freezes that clock. At21 ticks the
   presenter shows only the final original body pose until native completion.
4. Ownership: no animation-driven buff activation, Soul spending, input writes
   or completion delay. Remove obsolete private MP-progress reflection and the
   unused NativeV77 constructor dependency. Native charm/completion/cancel rules
   remain authoritative; an early native completion can truncate graphics.
5. Lifecycle/error matrix: ordinary focus false, death/hazard/scene/detach ->clear;
   new focus ->tick0; repeated observer ->keep origin; invalid clock ->no advance;
   pause ->stable tick; native completion ->existing buff/finish path unchanged.
6. Tests: link actual production clock into core suite, verify early startup30Hz,
   repeated/sparse samples, long charge, scaled-time pause and rapid cancel/rehold.
   Verify package character bytes identical to0.5.2; native visual acceptance
   remains pending, including Quick/Deep Focus, Unn and pause/recovery.
7. Wrong: equal normalized progress for17/21-tick tracks or holding startup at0.
   Correct: shared source tick from focus entry with each track's original end.


## 0.6.0 nail presentation (supersedes native slash artwork preference)

`WukongPresenter(hero, assets, native)` captures/restores the actual normal,
alternate, up, down and wall NailSlash MeshRenderer.forceRenderingOff values.
Never disable their objects/components, animator, damage or polygon colliders.
Construction validates the new sprites/view first, then suppresses meshes; all
captured values restore on failure/dispose. Native enabled writes still execute.
Body/aura ownership and every combat hook remain as before. Beam objects are
outside the suppression set.

Combo stages sample nailAttack1..4 at existing combo source ticks. Other attacks
choose nailUp/nailDown from `NativeV77.Selected(hero)` identity, otherwise
nailAir/nailAttack1, and sample `min(Ticks-epsilon, AttackProgress(hero)*Ticks)`.
AttackProgress clamps native attack_time/attackDuration to[0,1], matching the
native scaled timer and Quick Slash duration. Native reset/pogo/cancel wins;
there is no independent timer, new input owner or added damage transaction.

Good: a down-pogo uses the rotated art while native DownAttack remains active.
Bad: rotating the hero root, scaling slash geometry, disabling NailSlash, or
calling HitTaker to make new art damaging. Missing mesh/property/clip fails
initialization with restoration, never leaves an invisible native hero.
Source/pixel checks cover art; Release validates actual API members. Client
tests must cover pacing, mesh suppression/restoration, charms and pogo.


## 0.6.1 independent nail arc range

1. Scope: follow original charm range without scaling Wukong body. StartSlash
   already applies serialized scale*1/1.15/1.25/1.4 and optional M animation.
2. Signature: NativeV77.NailRangeScale(hero)->Vector3 uses validated v77 private
   NailSlash.scale and actual selected slash.transform.localScale; read only.
3. Contract: abs(actual.x/base.x),abs(actual.y/base.y),1. Missing selected slash
   returns identity. Presenter sets only its independent arc child's localScale;
   (1-ratio)*fixed source center corrects attachment. Center Unity Y is
   (NominalBodyHeight*ArtworkScale/2-FeetOffsetPixels)/100. Body never changes.
   Combo native windows initialize scaling before source arcs become visible;
   ordinary attacks already run native StartSlash. Do not run it for visuals.
4. Validation: missing/wrong baseline field fails version gate; zero baseline
   X/Y fails attachment/update, triggering existing detach/restoration. Arc uses
   body enabled/color/facing, disappears outside nail clips and dies with view.
5. Good: both charms read actual1.4 and stable upright body; base has ratio1.
   Bad: a separate charm table, scaling the composite/root, or calling extra
   StartSlash. Do not duplicate source hitboxes or damage to match the picture.
6. Checks: source arc extraction/recomposition/105new pixels, unchanged874old
   frames per size, native IL table/M sequence, Release actual member checks;
   client verifies equip/unequip, repeated attacks, both facings, pogo, teardown.
7. Wrong: renderer.localScale=charmScale for the whole body/composite. Correct:
   body samples preserved poses and only nailArc follows actual native ratio.


## 0.6.2 direction and native focus end alignment (supersedes0.5.3 origin)

1. Scope: Dashmaster flames were horizontal; Fire Eye cast played too early.
2. Signatures: NativeV77.DashingDown(hero)->bool through FlameDash.Downward;
   NativeSpellV77.FocusSecondsRemaining->double(-1 before normal focus drain);
   FireEyeCastClock.Observe(casting,remainingSeconds,scaledNow), Tick(now), Clear.
3. Contract: read private native dashingDown, not held input/inferred facing.
   Presenter selects flameDashDown with the same DashProgress clock, white color
   and native dash visibility handling. Only offline flame Draws rotate90;
   body, aura, arcs, view/root/colliders and path damage remain unchanged.
   Native focus remaining=(focusMP_amount-MP_drained)*drainMP_time-drainMP_timer,
   clamped0 while drainMP=true. Capture now+remaining once, after native charm
   selection. Tick=(now-deadline)*30+21; unscheduled returns-1. Negative tick
   shows only opening effect4 body;[0,21) samples original composite;>=21 uses
   final body only. Short native charges start in source tail, never stretch.
4. Error/lifetime matrix: wrong private field type -> fail initialization safely;
   no drain/invalid remaining -> no schedule; invalid now/ordinary focus false,
   death/scene/detach -> clear; repeat observations -> same deadline; pause ->
   scaled clock unchanged; complete/cancel -> normal native/buff cleanup wins.
5. Base/good/bad: normal .891s drain delays flames .191s; Quick .594s uses last
   .594s at30Hz; Deep waits longer. Bad: hardcoded normal duration, restarting
   deadline on every observer, normalized/discrete Soul frame stepping, delaying
   native completion or rotating all hero graphics to point dash flames down.
6. Tests: actual production deadline for startup/window/end, native-rate samples,
   short tail, repeats/pause/cancel/recast/invalid and early native completion;
   source directional pixels/1.5x and979old ticks, actual-reference Release.
   Client still checks both facings, charms/Unn, interruptions and native timing.
7. Wrong: start flames on focus entry then hold final body for long charges.
   Correct: hold opening body without effects, end-align the original30Hz window.


## 0.6.3 active dash protection and source death

1. Scope: user requests full Flame Dash HP immunity and original Wukong death.
   This supersedes earlier native-only dash immunity; all dash motion stays native.
2. Signatures: Runtime.SkillProtects(self)->bool observes FlameDash/FireDemon at
   TakeDamage/TakeHealth entry. HeroDie(orig,self)->IEnumerator starts presentation
   then returns orig(self) unchanged. NativeV77.DeathEffect(hero)->GameObject.
   Presenter.BeginDeath(now); SourceDeathClock(ticks,rate).Begin/Tick/Clear;
   NativeDeathV77.Suppress/Restore and ReadyToResume.
3. Contract: active actual dash or FireDemon rejects incoming HP damage; stale
   ownership is observed/cleared first. No saved invincibility writes. Real death
   captures facing/world anchor, uses original65ticks/30Hz and holds final pose;
   ignore native enabled/alpha for this presentation only. Survivable hazard is
   hurt/recovery, not real death. Native death iterator remains authoritative.
4. Error/lifetime matrix: wrong death prefab/FSM/variables -> fail attachment
   safely; source clock invalid -> no start; duplicate death -> no restart;
   pause -> stable tick; source end -> final pose until native resume; scene/
   hero teardown/disable/failure -> clear and restore every owned renderer flag.
   Suppress prefab/Head/Sword graphics and only named Corpse Nail Hero pooled
   visual spawn; leave state transitions/camera/audio/save/Geo/shade logic alive.
5. Good: downward dash immune only while active; dead body/ghost visible after
   native renderer disables. Bad: save isInvincible, skip Die/FSM, alter death
   wait, activate source death on survivable spike/acid hit, or reset on every frame.
6. Tests: actual source-clock repeats30Hz/pause/end/clear/recast/invalid, fresh
   bundle/65original+enlarged pixel checks, compiled TakeDamage/TakeHealth and
   original Die return boundary, all old assets unchanged. Client death/charms/
   hazard/save/respawn acceptance remains separate.
7. Wrong: follow native mesh enabled for the replacement death or turn off the
   death FSM. Correct: override only source death presentation and own/restore
   the selected native visual suppressions while native progression runs.


## 0.7 fist and Dream ownership

Neutral spell holds Fireball Antic ANIM END, charges current MP Cost once and
finishes via Spell End, skipping native projectile creation. NativeDreamV77 validates
actual Dream Nail states/actions and inactive Dream Effects/Hitbox before patching.
Disable only the Inactive physical-input listener; hold Start completion with a
real ignored event. Begin via Fsm Cancel/Take Control to preserve cancellation of
other hero FSMs. End/Regain Control retains native Dream Convo handling. Restore
listener entry cache when re-enabling it while Inactive; it may have been disabled
before its first OnEnter. Never force recovery on dead/transitioning heroes.

Dream direction is latched on press. Godslayer release latches tier; source38ticks
full, Dream Wielder2x charge. Force one full release at frame60 (59elapsed ticks; Dream Wielder2x); key-up may release earlier. Full hero wave alone
clones actual native Dream hitbox, tag/layer/Send Event FSM and SendDreamImpact;
only clone Deactivate is disabled. Attach a kinematic Rigidbody2D/full kinematic
contacts to replace the original inherited hero body, then move its Rigidbody
position in fixed steps. Without it, static NPC/scenery triggers can be missed.
No manual Soul/essence, invented DREAM NAIL event or dream triggers on ghosts.

FistSkills shares actual SkillTargetPolicy before source cap/interval ledgers,
and rechecks held state/token after native callbacks. Source masks are local with
Y converted once; artwork1.5 does not scale damage regions. Explicit subskill caps
are2/1/1/1/1 (Afterimage),1 per Godslayer/fall/landing,5/2 at434/400ms (Ape).
Use bounded native-body terrain casts for hero travel; independent ghost movement
uses equivalent bounds without adding a hero collider. Stop input/velocity writes
before native recovery. Independent waves may outlive ordinary recovery; death,
hazard/scene/detach destroys all ghosts/waves/dream triggers. No extra immunity.

Regression: actual production charge/latched tier/pause/interval/cap/mirror/travel
policies, full source pixels, compact frame registration and source hashes. Client
Dream NPC/enemy/scenery behavior, keyboard/controller, terrain, damage interruptions
and all previous skills remain mandatory pending acceptance.


Native listener cache: v77 FsmState.OnUpdate iterates its cached ActiveActions
without checking Enabled. set_Enabled only changes a flag. Remove the exact
Inactive ListenForDreamNail action from that cache on attachment; retain all other
actions. On restoration while Inactive, prime its input cache and reinsert it at
its original order if absent. If another state is active, normal future OnEnter
rebuilds the list using restored Enabled. Exact pinned IL is preserved under
reference/flash/fist/native-listener-cache.txt.


## 0.7.1 directional Dream Soul transaction

NativeSpellV77.SoulCost reads/validates the actual Spell Control MP Cost. Native
Set Spell Cost, independent of casting, updates33/24 through CHARM INDICATOR CHECK.
Do not duplicate that charm table or modify the variable. FistRules.TryBeginDream
rejects insufficient Soul before acquisition, rechecks Soul/ownership after native
cancellation, charges native TakeMP once and rechecks ownership before gameplay or
ghost mimicry. Failed acquisition never charges; failed held ownership recovers
through native Dream Finish. Neutral Godslayer stays free. Source maximum charge
is59elapsed ticks, distinct from38full-damage ticks. Observe latches once, keeps
the25-tick tail/100ms wave and uses observation time after slow frames so the
release cannot disappear before spawning. Pauses use unchanged scaled time; a
held key never synthesizes a fresh DreamPressed edge. Damage/masks remain intact.


## 0.7.2 copied ghost consumption and native slam recoil

GhostFinished(Action,released,actionSeconds,landingSeconds,age) owns expiry:
unused None expires at10s; copied Godslayer removes after its25/30s release tail;
copied Earthbreaker removes14/30s after landing or5s fall timeout. FistSkills
removes the renderer/list entry directly; never set completed copies back to None.
Only idle ghosts accept a copy. Stop removes unreleased Godslayer copies; emitted
waves retain their own lifetime/damage ledgers. Recheck ghost membership after
native callbacks before continuing enumeration. Death/scene/detach still clear all.

Hero/ghost EarthbreakerStep shares original17.8px/tick rise and16/8tick ground/air
antic with33px/tick descent (1.5x prior22). Terrain casts still clamp actual motion,
consume blocked travel and retain original damage regions and landing-tail poses.

Native Q Slam Hit L/R FSMs use Spell, circleDirection=false, magnitudeMult=2 and
horizontal0/180 directions. Fist Query now uses that recoil strength through shared
NativeV77.SpellHit/HitTaker/HealthManager/Recoil, preserving native resistance and
terrain sweeps. Body push direction is away from cast root (facing on exact center);
Godslayer wave direction stays along travel even after passing the target center.
Do not force enemy transforms/velocity or bypass invulnerability/recoil state.
FireDemonHit delegates to the shared helper with its unchanged0.15air/1finisher
and circleDirection values; Flame Storm also retains its existing wrapper behavior.
No extra hero immunity, damage/HP/Soul/mask changes or artwork regeneration.


## 0.7.3 owned defense and final-only slam recoil

FireDemonSlash.Query final hits now call SpellHit with circleDirection=false,
magnitude2 and FistRules.PushDirection away from actual effect root. Preserve
air0.15 and FlameStorm wrapper values, source regions and airborne completion.

Runtime.SkillProtects observes FistSkills at TakeDamage/TakeHealth entry; only
owned live Earthbreaker ProtectsHP joins the existing Dash/FireDemon guards.
HeroFinished centralizes unchanged source ends: Afterimage71ticks, Ape105ticks,
Godslayer25-tick release tail, Earth14-tick landing tail or5s timeout. Observe
expires ownership synchronously before hits. Ghosts/waves never protect the hero.

For owned Ape only, NativeDreamV77.SetDamageResistance replaces the exact Dream
HERO DAMAGED -> Cancel transition event with a private ignored event. Other native
FSM events and all other recipients keep running. DamageEventOverride captures
the original object, repeats idempotently, restores only its own replacement and
rejects foreign acquisition. Finish/Dispose restores even on death/scene cleanup.
Never suppress the global broadcast or entire proxy damage event.

Runtime hooks StartRecoil (after native TakeDamage has handled HP/charms/death/
hazards). Owned Ape uses NativeV77.ArmoredDamage: native DAMAGE visual/double-hit
prefab and native Invulnerable iterator, including native Stalwart Shell duration,
without recoil motion/SetState/freeze/control mutations. Other actions delegate
unchanged to orig. Do not skip native TakeDamage, deduct HP manually, set saved
isInvincible, restart source clocks, charge Soul again or ignore lethal/hazards.

Validation includes exact hero end/paused observers and real scoped-event restore/
recast/foreign-owner tests plus actual-reference Release/compiled hook inspection.
All13character resources are reused byte-for-byte. Client acceptance stays pending.


## 0.7.4 independent combo and moving-awakening Ape

This supersedes v073 Ape armor. Native StartRecoil and Dream HERO DAMAGED are
untouched. Only Godslayer/Earthbreaker use FistSkills.Active and hero control.
Afterimage and Ape use separate Summon references, FistSummonClock, source
position/facing/tier and FistContacts. OwnsSummon requires the current reference,
live hero and clock; ordinary damage/hero-action cancellation does not revoke
the actor, but death/hazard/scene/detach clears it. Cancel clocks before destroying
renderers; recheck identity after native damage callbacks.

Neutral forward gate is Has Fireball? IntCompare.greaterThan CAST, after native
eligibility/cost/direction/unlock checks, before Wallside? FlipSprite and Fireball
Antic writes. Replace only that event with a real ignored event; restore on detach.
Spend live native TakeMP once and return directly to Inactive, avoiding Spell End
velocity/control/gravity resets. Up/down/focus routes stay intact. Protect repeated
same-frame observations from duplicate payment; recheck owner after MP callbacks.

Combo clone travel uses existing swept native-size box helper, never hero Move.
Split540px travel at births11/25/39/51 so slow frames keep four trail positions.
Recast replaces clone/old ghosts but retains independent waves and Ape.

Source skill5Awake1 immediately returns hero to idle and follows both effect5_0/1
bodyPosition/facing each frame. Ape therefore never enters Dream.Begin/Finish,
never takes control or writes hero motion, and renders only new body-free source
back/front clips around the ordinary presenter. Its local masks/caps/cooldowns
follow the same live root/facing without resetting the ledger on turns/hits.
Reject a duplicate live Ape; use its separate previous3s post-effect cooldown.

Regressions: independent clocks/expiry, cancellation/recast/stale work, slow-frame
trail spacing, native Soul gates/MP revocation, independent local contact budgets,
body-free source layers, unchanged prior clip pixels and lossless packed art.
Compiled boundaries and native serialized gate events must also be inspected.
Client keyboard/controller/free movement/combat/terrain/cleanup remain pending.


## 0.7.5 native Quake recovery timer

Native Spell Control Quake Finish calls HeroController.QuakeInvuln, assigning live
INVUL_TIME_QUAKE to parryInvulnTimer. Installed resources.assets HeroController19582
serializes0.400000006s. HeroController.Update decrements Time.deltaTime; TakeDamage
honors the timer for ordinary hazardType1. Native spike/acid/hazard and direct-HP
rules remain distinct. Never replace this with a custom blanket TakeDamage/TakeHealth
post-action guard or saved isInvincible flag.

FireDemonSlash calls the real method once after successful source-end recovery;
FistSkills.Stop(completed:true) calls it only for confirmed player Earthbreaker
landing. Both invalidate body-hit/action ownership and finish native recovery first,
then recheck live nonrecoiling hero/disposal before granting the timer. Their full
owned-action guards remain unchanged. Cancel/Dispose, death/hazard/scene, unlanded
timeout, Godslayer, detached summons and copied ghosts grant no recovery timer.
No polling refresh: stopped body ownership prevents repeated end observations.
Native update/cancellation handles expiry. Actual native IL/prefab/FSM and compiled
success/cancel paths must be reviewed; package character bytes stay unchanged.


## 0.7.6 directional control ownership

Runtime creates one NativeDreamV77 and disposes it after FistSkills/FlameStorm.
Both borrow it. Shared CanBegin keeps native menu/control/unlock gates; only
down-Dream Storm extends air eligibility. Storm owns its ledger and may Finish
Dream only after an active ledger is revoked. Fist input ignores down Dream.
Core TryBeginControlled is the original TryBeginDream transaction extracted with
unchanged pre/post-acquisition Soul/ownership checks and exception recovery.

FistSkills owns native Down adapter/suppression. Observe each held Quake Antic
once, charge live MP Cost once, then begin unchanged Earthbreaker. Holding/Owns
choose down spell for Earthbreaker, Dream for Godslayer. FinishCast(false) routes
to Spell End and skips Quake Finish; confirmed player landing alone grants the
existing native recovery. Adapter disposal also skips Quake recovery. Storm
clears prior parry protection on start and grants original QuakeInvuln once only
after successful Dream recovery, preserving its old down-spell finish semantics.
Masks, source clocks, damage factors, ghost mimicry and all artwork are unchanged.
Native recoil/events do not universally force enemy hurt states; that feature is
not implemented. Client input/combat/recovery acceptance remains pending.


## 0.7.6 Afterimage / Storm input swap

Supersedes the v074 neutral gate and shared Storm/Godslayer Dream ownership above.
Neutral quick spell is Flame Storm; down + Dream Nail is the detached Afterimage.

NativeSpellV77.Forward holds Fireball Antic tk2d completion (original ANIM END)
after native CanCast/MP/direction/fireballLevel and Wallside? routing; FinishCast
enters Spell End, skipping projectile/spending states. Has Fireball? is no longer
patched. FlameStorm constructs/disposes the only Forward adapter and exposes its
BlocksNativeSource. Observe each newly held antic once through TryBeginControlled
(acquire = already held), charge live MP Cost once, then begin the unchanged
ledger/clock/quakeLevel damage. Active requires the held antic. Stop invalidates
attribution and ledger first, restores gravity, enters Spell End, then grants
QuakeInvuln only on successful completion with live nonrecoiling hero. A held
antic observed during recoil/death/hazard/transition is released unpaid.

FistSkills keeps only the Down adapter and reads the shared live MP Cost through
it. Down + Dream uses dream.CanBegin(native, true), captures origin/facing, then
TryBeginSummon rechecks Alive/!Active/CanBegin after TakeMP. It never calls
Dream Begin/Finish; Godslayer is the sole NativeDreamV77 owner. Runtime still
creates the Dream adapter and disposes it after FistSkills and FlameStorm.
Afterimage damage stays fireballLevel/Shaman; Storm damage stays quakeLevel/Shaman.
Client keyboard/controller, wall-side, recovery and summon checks remain pending.


## Unreleased Storm damage attribution draft

### 1. Scope / Trigger

The 2026-10-27 branch draft observes one synchronous Flame Storm dispatch. It
implements no enemy interruption, native cancellation profile or supported-enemy
list. A successful policy result is deliberately discarded by HealthHit; it is
not yet safe input for enemy control. Task research/check-draft.md records gaps.

### 2. Signatures

Core ScopedEnemyDamage<TSource,TTarget> requires reference types and exposes:

```csharp
ScopedEnemyDamage(TSource source, TTarget target, long token, int initialHealth)
bool Begin(TSource actualSource, TTarget actualTarget, long token,
    int health, int depth, long hitSequence)
bool Complete(TSource actualSource, TTarget actualTarget, long token,
    int health, long hitSequence, bool stillOwned)
```

FlameStorm.BeginEnemyHit returns the active matching attempt or null.
CompleteEnemyHit returns bool only; neither method mutates an enemy FSM.

### 3. Contracts

Bind exact source/resolved HealthManager/cast token/HP before the existing
FireDemonHit dispatch, including its TAKE DAMAGE event. Only the first exact
matching Begin can be observed. It requires a positive token/initial HP,
unchanged initial HP and outer Hit depth1. Complete is single-use and requires
unchanged Hit sequence, exact identities/token, current ownership and surviving
HP loss. Finally clears the temporary attempt; Stop clears before Dream recovery.
Preserve original damage dispatch and Fire Eye observer order. Observe Storm
before reading the final Hit sequence because native recovery can reenter hooks.

### 4. Validation & Error Matrix

| Condition | Result / limitation |
| --- | --- |
| Wrong source/target/token at Begin | false; does not consume exact observation |
| First exact Begin with wrong HP/depth or nonpositive stored token | false; cannot retry that attempt |
| Nested Hit, revoked ownership, reused completion, no/fatal loss | false |
| Null constructor identity | ArgumentNullException |
| ApplyExtraDamage/direct HP writes during dispatch | Hit sequence cannot isolate them; unresolved |
| Same-reference disable/re-enable/pooling | Final liveness cannot prove target lifetime; unresolved |

### 5. Good / Base / Bad Cases

Good: a fresh attempt for each of five budgeted nonfatal contacts passes policy
checks independently. Base: evaded/no-loss or lethal damage yields no candidate.
Bad: matching references/current liveness are treated as proof of uninterrupted
target lifetime, or all HP loss is attributed to Hit despite known bypasses.

### 6. Tests Required

Linked-production Core checks cover exact identity/token, pre-dispatch HP,
positive surviving loss, nested Hit sequence, revocation, reuse and five contacts.
Pinned-reference compilation and compiled hook/finally ordering are also checked.
Before any consumer, resolve direct-HP attribution and target-lifetime guards,
then validate one real native cancellation/cleanup/default-return path and client
attack-resource shutdown, death/phase exclusions and subsequent AI. Current Core
checks/build do not establish any of those native acceptance results.

### 7. Wrong vs Correct

Wrong: consume Complete=true by searching for Walk/Idle or broadcasting END to an
unknown FSM. This can retain attack hitboxes/controllers or break phase logic.
Correct: keep the draft result unused until attribution/lifetime guards and an
exact native profile's original transitions/actions/resource cleanup are proven.
A future profile must preserve normal damage/recoil on unsupported layouts;
compilation or an empty adapter must never be reported as working interruption.
