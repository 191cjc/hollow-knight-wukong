# Fire Demon Slash (0.4.4-dev)

Down + spell uses Wukong's original character animation and two skill effects.
Native input, unlocks, Soul spending and control recovery remain; the replacement
holds the native antic for its own timeline and never enters Quake Down/Land.
Full-cast hero damage protection and corrected enemy hurtbox filtering remain.

## Source presentation and timing

- Main `effect5` is the untouched 60-tick source animation, already present in
  the active 1.5x atlas. Its moving character flashes and real empty blink frames
  are displayed directly. The normal native hero remains suppressed separately.
  Earlier travel-normalized/held `fireDemonAir` clips stay preserved as assets;
  the playable skill no longer uses those clips or blanket-hides effect5.
- At body tick 5, `effect5_1` is spawned at original (+177 facing, -95 Flash
  Y-down), converted to +95 Unity Y-up with baseline world units per source pixel.
  It is world anchored and lasts 31 ticks, retaining all twelve nested slash
  slots. The original effect root is shared with the character's feet/root
  calibration. The previous centered/raised registration is superseded.
- At tick 36 (5 + 31), `effect51` spawns at the hero's then-current origin and
  lasts 20 ticks. This follows WKEntity's effect-expiry trigger, not a landing
  event. Ground and midair casts use the same source clock. No forced downward
  velocity, terrain snap or dive-floor damage source is introduced.
- At tick 56 the cast ends and native Quake Finish / Spell End restore native
  damage mode, spellQuake state, input, animation control and gravity. Finisher
  observation after lag samples its elapsed time; it never restarts a full phase
  or generates catch-up hits. Death/transition cleanup does not regain control
  on the dying or transitioning hero.
- Original Quake start/landing camera events are not part of this presentation.
  The antic's EnemyKillShake action is scoped off/restored; Down/Land states and
  their BigShake actions are never entered. Other camera events remain available.

## Movement during the cast

0.4.4 explicitly maintains native RelinquishControl/IgnoreInput/ResetInput,
zero Rigidbody2D velocity and no gravity while the custom cast is active. Observe
runs before HeroController.Update reads movement and before/after its native
FixedUpdate, so a held direction cannot move the physical root away from the
world-anchored air effect. Both original updates still run exactly once. The
source effect5 moving flashes remain animation, independent of physical motion.

Completion and cancellation are checked before applying this hold. Native
Quake Finish/Spell End releases input/gravity; no Rigidbody constraints or saved
velocity are installed, and no per-frame teleport is used. Pause UI remains
available, and death/scene/inactive cleanup does not force RegainControl.

## Original contact conversion and Hollow Knight balance

Source masks are solid original rectangles, independent of the offline 1.5x
artwork. Their centers below are relative to each effect's origin, with Y up.
The air origin itself has the original directional spawn offset above.

| Region | Width x height, source pixels | Local center (right facing) | Per-target rule |
| --- | --- | --- | --- |
| Air | 442.94934 x 209.89949 | (2.52776, 57.96991) | At most 11 contacts, at least 100 game-ms apart |
| Finisher | 261.99975 x 231.95052 | (-0.95083, 79.01354) | One hit |

Left facing mirrors spawn X and mask center X, retaining height and width. The
shared native Attack-layer query/resolver excludes sensors and weapon children
from HealthManager damage. In particular, Hornet's 44-unit Refight Range and
Buzzer alert sensors cannot cause room-wide hits or consume the hit ledger.
Legitimate trigger hurtboxes and native non-health responders remain eligible.
Native enemy hit evasion, directional protection and invulnerability still apply.

| Spell unlock | Air damage | Finisher | Maximum 11 + 1 | Shaman Stone |
| --- | ---: | ---: | ---: | ---: |
| Desolate Dive | 2 | 14 | 36 | 3 x 11 + 21 = 54 |
| Descending Dark | 3 | 22 | 55 | 5 x 11 + 33 = 88 |

These previously chosen fixed spell values remain independent of nail upgrades.
Shaman Stone uses ceil(x1.5) per component. Totals require all contacts; they are
not guaranteed HP loss. No native Quake damage stacks with the replacement.
See [archived source evidence](FIRE_DEMON_RESEARCH.md) for the original AS3 formula.

## Immunity, ownership and validation

HeroController.TakeDamage/TakeHealth observe the real cast at damage entry and
protect preparation, air flashes and the entire finisher. Ordinary incoming hits,
projectiles, spikes and acid cannot reduce HP through those entries during the
owned cast. End/cancel/detach releases the custom guards; no persistent global
invincibility or save flags change. Native cleanup behavior remains native.
Cast tokens reject stale air/finisher callbacks. Native animation events, camera
actions, renderers and colliders restore on disposal/partial initialization.

Real-source checks cover moving/empty body frames and byte equality of the baked
source frames. Production C# checks cover source phase boundaries without a
landing input, lag, both original mask directions and protected finisher/ledger
ownership, alongside all existing combo/dash/damage regressions. Full Windows
Release/package/installed verification is recorded in artifacts/build-report.json.
Original archives, unscaled bakes, 1.5x variants and earlier ZIPs are preserved.

Gameplay acceptance remains pending: verify moving flashes with both facings,
ground/midair finisher timing, control/gravity recovery, actual enemy HP changes,
full-cast immunity, no distant sensor hits and disable/re-enable/scene cleanup.
