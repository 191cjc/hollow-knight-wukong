# Current native input/control contracts before follow-up swap

Source: `.trellis/spec/backend/native-combat.md`, copied 2026-10-27 before the
Afterimage/Storm follow-up. The approved PRD follow-up changes input bindings;
retain the exact native gating, resource, control and recovery invariants below.
This focused excerpt avoids truncation of the owning large spec during injection.

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
