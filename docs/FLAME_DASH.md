# Flame Dash / 烈焰闪

Version0.6.3-dev replaces the normal dash presentation and adds along-path damage.
The original dash key, ability unlock, movement, cooldown, gravity, wall collision
and native invulnerability rules still come from `HeroController.HeroDash`.
There is no added MP cost, armor, invulnerability or manual soul gain.

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


## Active dash immunity (0.6.3)

Runtime SkillProtects observes actual FlameDash ownership at both incoming
HeroController.TakeDamage and TakeHealth entry points. Either active Flame Dash
or protected Fire Demon rejects the incoming HP-damage call. Observe first so
an ended/cancelled/stale dash cannot retain protection. Both horizontal and
Dashmaster downward dashes are covered; no saved isInvincible flag/timer writes,
movement/cooldown/collision changes or extra damage transaction. Existing
sharp-shadow source suppression and native recovery remain intact. Death/scene/
disable release ownership; direct native death processing is still authoritative.

Client checks: enemy contact/projectiles and spikes/acid during active dash,
damage immediately before/after it, left/right/downward dash, shadow-dash charms,
pause/cancel/scene/disable and persistent invincibility state after completion.
