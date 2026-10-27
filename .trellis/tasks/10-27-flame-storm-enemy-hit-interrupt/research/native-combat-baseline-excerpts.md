# Relevant native combat baseline excerpts

Source: `.trellis/spec/backend/native-combat.md` at `main@cadb864`.
Source SHA-256: `77e06ca3a6b13251ad133cdb0cbb8ad4599666be6f138f8cee0aefffc096695d`.

Exact relevant sections are copied below because the complete source exceeds the context injection size limit. This is baseline research, not a replacement spec. Read the complete owning section when editing it; the PRD/design defines the intended new feature.

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
