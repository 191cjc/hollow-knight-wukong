# Spell layout and Bloodthirsty Fire Eye (0.5.0)

## Authorization and baseline

The user requests a current-workspace commit first, Fire Demon on up + spell,
Bloodthirsty Fire Eye instead of held focus healing, and Flame Storm on down +
spell. They explicitly authorize recommended implementation decisions without
questions and will test/review later. Routine direct installation remains
authorized. The downloaded source lacked .git; git history was fetched from
the original repository and attached without overwriting working files. The
complete 0.4.4 snapshot was committed as
`a07b2ac4981caca2b84af7a4f9ae1dc270a3d42d` before implementation.

## Source/native evidence and design

- Original staff effect3 is 16 ticks; effect4 is 17 ticks. Flame Storm's flame
  overlay lives separately in skill1V472/effect3, with eight source images.
  Preserve all originals/previous bakes and generate a separate new variant.
- XML skill1101030: shootTime534ms, per-target cap5, interval100ms. WKEntity.skill3
  sets gravity and velocity to zero until it exits state73. PlayerEntity contact
  code confirms per-target cap/cooldown; retain native target evasion as before.
  Use original ab_effect3 frame masks converted from SWF, rather than a room-wide
  circle inferred from rangeFront999. Damage adaptation: 7 per contact (35 max),
  upgraded11 (55 max), Shaman ceil1.5 =>11/17 (55/85 max). Actual HP loss may be
  lower due to native evasion. No additional invulnerability for Flame Storm.
- Fire Demon should hold Scream Antic1/2 rather than Quake Antic. Native up-spell
  unlock/tier is screamLevel; down-spell unlock/tier is quakeLevel. Keep native
  choice/eligibility, tier upgrade and Spell Twister cost. Hold the exact native
  completion events; up antic uses FINISHED, down uses ANIM END. Native TakeMP
  occurs in skipped burst/level states, so replacement must charge the FSM's
  current MP Cost exactly once when each accepted cast starts. This also closes
  the previous held-Quake resource gap.
- Bloodthirsty Fire Eye uses native focus start, Soul drain, charm charge timing,
  cancellation and eligibility. Play effect4 synchronized to actual native drain
  progress. Intercept only native focus AddHealth calls (Focus Heal / Focus Heal2)
  to activate a five-scaled-second buff without immediate HP gain; leave other
  healing intact. Defer forcing native focus finish to the next update boundary
  so SetState does not reenter the currently executing native action list. End
  after one completed charge, even while focus remains held.
- The buff heals one ordinary HP after actual player nail/spell/dash damage to a
  living enemy. Whiffs, invulnerable/blocked hits, scenery and already-dead targets
  do not count. Read HP around actual native HealthManager hit dispatch. Preserve
  token/hero ownership across synchronous callbacks. One shared >=1s cooldown
  applies across targets, phases, attacks and refreshes. Full HP does not consume
  a proc. Expiry is half-open [activation, activation+5), no expiry or activation
  heal. Recast refreshes duration without stacking/cooldown reset. Scene/death/
  detach clears cast and buff. Do not add the source game's attack-stat bonuses.

## Change boundary and execution

NativeSpellV77 will share validated up/down/focus reflection/suppression; NativeV77
will own private focus-progress fields. FireDemonSlash retains its source clock,
full-cast protection and physical lock on the up-spell antic. New FlameStorm and
BloodthirstyFireEye runtime objects integrate through WukongRuntime/Presenter.
Engine-free buff/contact policy gets production tests for expiry, refresh,
cooldown, zero damage, duplicate/reentrant/stale callbacks and interruption.
Artwork tooling adds only the source Flame Storm overlay to a new profile/bake;
source-mask evidence and tests cover original shapes and actual images.

Sequence: baseline commit (done), persist scope/design (this document), research
exact masks/events, implement runtime/core and separate artwork, run appropriate
checks/build and visual review, update executable specs/docs, back up/install
with game stopped, verify closure/hashes. Keep new changes reviewable in the
working tree after the requested baseline commit. Do not push or touch API/saves.
Native gameplay acceptance remains pending; parent task stays in_progress.
