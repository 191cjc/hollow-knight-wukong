# Flame Dash / 烈焰闪

Version0.7.8-dev retains the native dash transaction and adds an optional upward
direction through Dashmaster. The original dash key, ability unlock, selected
normal/Sharp Shadow speed, duration, cooldown, gravity and terrain collision come
from `HeroController`. Along-path damage and active-dash HP protection apply to
all three directions. No MP cost or manual Soul gain is added.

## Flame Dash: Awakening / 烈焰闪·觉醒

Native Dashmaster (charm31) keeps its collectible, ownership/equipment, original
two-notch cost and icon. Native downward dash, shorter cooldown, Sprintmaster
run-speed combination and Sharp Shadow damage/speed interactions remain active.
While airborne with this charm equipped, hold Up without Down/Left/Right and
press the original dash key to move vertically upward. Grounded or diagonal
input retains ordinary native direction selection; Up+Down keeps native down
priority. The normal native CanDash result must approve the start.

All directions share native aerial dash allowance: an upward dash does not grant
a second lateral/downward dash. An additional unsaved guard allows one successful
upward dash until a real landing. Native bottom contact on layer8 terrain or a
HeroWalkable platform replenishes it only after native BackOnGround, hard landing
or downward-dash landing accepts that contact; native SteepSlope/state rejection
stays intact. This may restore use before the active dash clock ends without
changing its direction. Passive grounded state also requires the native
CheckTouchingGround ray. Pogo, bounce, walls, wall jump, ResetAirMoves, damage or
charm toggles do not replenish this extra guard. Rejected starts do not consume it.
A blocked repeated up-only chord is rejected and its forbidden queue is cleared,
so it cannot later turn into a queued sideways dash on landing. First-use native
cooldown/eligibility queues keep their original behavior.

Only the actual two native key/queue HeroDash callsites mark player input; their
original CanDash and OnDashPressed calls stay in place. Direct scripted HeroDash
calls retain native direction. Startup latches a token before native callbacks
and commits upward ownership only after the same hero/adapter and live dash
survive. Direction remains latched when keys or equipment change mid-dash.
The exact OrigDashVector result is redirected before the existing ModHooks vector
chain, preserving the live native speed and other subscribers. No down input or
dashingDown spoofing, airDashed reset, save flag, collider or constraint edits.

At the native normal FinishedDashing boundary, before native CancelDash/DashEnd
events, remove positive Y only if the same token still owns the exact last
post-ModHooks output. Changed/collision-limited motion, a new jump/bounce/recoil,
cancellation, death or transition wins; cleanup never writes after native
synchronous end callbacks. Ceilings retain native physical collision and may
leave the dash timer/protection running until its native end. JumpReleased stays
native; no fixed upward displacement is promised from compilation.

The flameDashUp clip uses the same12source ticks and native dash progress, with
flames alone rotated offline counterclockwise about(0,-44.5); body/root/aura stay
upright. New v078 original/full1.5x/packed folders preserve all previous1559ticks
at both sizes and lossless packed registration:60clips/1571ticks/16runtime pages.

## Artwork and source evidence

The character's `effect2` pose is combined with the six actual flame images from
`assets/zmxy4/animations/2001/skill1V472`, armature/animation `effect2`.
The dedicated reader supports this source's single local DragonBones 3.0 bone
and slot; it does not imply generic DragonBones 3.0 support. Each flame image is
held for two source ticks. The 12-tick clip is sampled over native dash progress.
All enlargement is offline, from the original-sized bake to a separate 1.5x bake.

Original skill `1101020` has `shootFrame=3`, `shootSpeedX=400`, `shootTime=334`,
`attMax=1` and `myBuff=60002`. These support the intent of a forward attack, but
their AS3 timing/unit/cancellation semantics have not been fully traced. This
implementation is a Hollow Knight dash adaptation, not a full original-game
simulation. See [skill research](SKILL_RESEARCH.md).

## Damage and ownership

`FlameDash` sweeps the existing hero collider bounds between physics positions
and samples the current overlap. It resolves the actual `IHitResponder` through
up to three transform levels, checks native enemy evasion, and permits one hit
per responder per dash. Damage equals current `nailDamage`; equipped Sharp Shadow
and Dashmaster together apply their 1.5x damage interaction. Hits use native
`TAKE DAMAGE` / `HitTaker` and `AttackTypes.SharpShadow`, respecting invulnerability.
Native Sharp Shadow's separate damage object is suspended during the owned dash
to prevent double damage; normal dash/shadow-dash VFX renderers are also hidden.

Each sweep captures its dash token. Ownership is checked before each target and
again after the synchronous FSM event, which can interrupt, unload or replace
the dash. Old callbacks cannot hit for a new dash or overwrite its previous
position. End, recoil, death, hazard, transition, disable and disposal stop the
owned damage and restore rendering. Teleport-sized steps do not become attacks.

## Validation

Automated checks cover all asset variants, six distinct flame images, native
metadata/compilation and production dash-ledger stale-token/deduplication rules.
The six-frame contact sheet was visually inspected for transparency, direction
and a coherent fire silhouette. Gameplay remains pending: validate ordinary and
shadow dash, walls, enemies with multiple colliders, Sharp Shadow/Dashmaster,
damage interruption, pause, scenes and disable/re-enable in the real client.

## Shared hurtbox correction (since 0.4.2-dev)

Both skills use NativeV77.SkillTarget and the actual Attack-layer collision mask.
HealthManager targets require layer-11 hurtboxes; Hornet/Buzzer detector ranges
and boss weapon children cannot route remote damage to their enemy ancestor.
Native non-health responders remain eligible. Filter before ledger/FSM writes.
See docs/FIRE_DEMON_SLASH.md for the separate source-presentation restoration.


## Active dash immunity (since0.6.3; direction extended in0.7.8)

Runtime SkillProtects observes actual FlameDash ownership at both incoming
HeroController.TakeDamage and TakeHealth entry points. Either active Flame Dash
or protected Fire Demon rejects the incoming HP-damage call. Observe first so
an ended/cancelled/stale dash cannot retain protection. Horizontal, awakened upward and
Dashmaster downward dashes are covered; no saved isInvincible flag/timer writes,
movement/cooldown/collision changes or extra damage transaction. Existing
sharp-shadow source suppression and native recovery remain intact. Death/scene/
disable release ownership; direct native death processing is still authoritative.

Client checks: enemy contact/projectiles and spikes/acid during active dash,
damage immediately before/after it, left/right/downward dash, shadow-dash charms,
pause/cancel/scene/disable and persistent invincibility state after completion.
