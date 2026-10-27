# Spell controls (0.7.6-dev)

The 0.4.4 workspace was committed before these changes as
`a07b2ac4981caca2b84af7a4f9ae1dc270a3d42d`. No remote push was made.

| Input | Replacement | Native progression |
| --- | --- | --- |
| Neutral quick spell | Flame Storm (烈焰风暴) | Native forward spell unlock; quakeLevel damage tier; current MP Cost once |
| Dream Nail | Godslayer Strike (灭神一击) | Hold/release or automatic maximum; full charge preserves native Dream impact |
| Down + Dream Nail | Afterimage Combo (残影连打) | Native Dream Nail unlock; fireballLevel damage tier; current native MP Cost once |
| Up + Dream Nail | Fire Ape Assault (火猿出击) | Native Dream Nail unlock; current native MP Cost once |
| Up + spell | Fire Demon Slash | Howling Wraiths / Abyss Shriek (`screamLevel`) |
| Down + spell | Earthbreaker Fist (辟地拳) | Desolate Dive / Descending Dark unlock; unchanged nail-based damage |
| Hold spell/focus | Jiyuan Fire Eye (汲元火眼) | Native focus eligibility, charge, cancellation and Soul drain |
| Dash | Flame Dash | Native dash movement, cooldown, unlock and collision |

Directional/air nail attacks and pogo retain native behavior.
See FIST_SKILLS.md for the new four-action source, charge, balance and lifecycle contract.
The neutral/up/down spell replacements each charge the FSM's current `MP Cost` once when
entering the held antic: normally 33 Soul, or 24 with Spell Twister. The native
spending states occur after the antic and are skipped with their damage states;
explicitly charging once also fixes the previous held-Quake resource gap.
Down/up Dream actions use that same live cost, reject insufficient Soul before
acquisition and spend once on successful start. Only neutral Dream remains free.

## Jiyuan Fire Eye (汲元火眼)

The source's staff `effect4` body action (17 ticks, source name 汲元火眼) and
the independent skill1V472 `effect4` casting overlay form `fireEyeCast`. The
original seven winding flames play during source ticks0..13; nested red/eye
flashes play during ticks14..20 at their original relative transforms. The body
holds its final pose for the last four overlay ticks. The two layers share
the original30 FPS scaled clock and end at the actual native focus deadline.
Startup and any earlier charge show only effect4 body tick0, without flames.
After native StartMPDrain selects its rate, capture scaledTime plus remaining
drain time once. Play the source during the final0.7seconds; native charges
shorter than that select its tail at original speed. No charm timing table or
discrete Soul-progress frame stepping is used.
Native Quick/Deep Focus timing, Soul cost, cancellation and completion stay
authoritative. Early completion/cancellation stops the visual without extending
focus. An interrupted charge grants no new buff. Original `effect4` remains
preserved.
Completion suppresses the native focus `AddHealth` call and activates a buff;
**there is no immediate heal**, including with Deep Focus. One completed charge
ends that focus cycle. Other healing continues through its native path.

For five scaled gameplay seconds after completion, actual enemy HP loss from
player nail, nail beam, spell or dash hits can heal one ordinary HP. All enemies,
attacks and multi-hit phases share a cooldown of at least one second. Whiffs,
blocked/evaded attacks, scenery and attacks on already-dead enemies do not heal.
Full health consumes no healing opportunity. A refresh replaces the expiry with
five seconds from the new completion; it cannot stack or reset the cooldown.
Death, hazard transition, scene transition and detach clear the effect.

The original independent buff visual is now included: skill1101040 -> buff810001
-> resources17 ->810001/1.swf symbol `ef`. Five original lossless images form a
10-frame loop. Its source registration follows the hero root and current facing,
with enlargement baked offline. It appears on successful charge completion,
loops throughout the five-second buff and disappears with expiry or cleanup.
Source decompilation, timeline and hashes are in `reference/flash/fire-eye/`.

The active interval is `[completion, completion + 5)`. Pause freezes the scaled
clock. There is no automatic activation/expiry heal or source-game attack bonus.
Focus spell state changes are deferred out of the native `AddHealth` action to
avoid reentering PlayMaker's executing action list. Dream focus is excluded.

## Flame Storm

The original staff `effect3` body and separate `skill1V472/effect3` eight-image
flame overlay play for 16 ticks at 30 FPS (about 0.533 seconds). Source WKEntity
holds gravity and velocity while spinning. The adaptation maintains native input
denial, zero velocity and no gravity during the action; native finish releases
control. There is no full-action HP guard. Its successful native recovery timer is retained.

Original `ab_effect3` is sprite39 placing rectangular shape32. At the right-facing
hero source root its Unity Y-up center is (-6.4639412, 35.0111057), dimensions
402.9517788 x 170.0001534 source pixels. Mirror center X for left facing. Convert
with baseline collider-height calibration, independently of offline 1.5x art.
Do not interpret the source's `rangeFront=999` as a room-wide damage region.
Selected original XML tags and hashes are in `reference/flash/flame-storm/`.

Each target permits at most five contacts, at least 100 game-ms apart, while it
overlaps that local mask. Native enemy evasion/protection still applies; lag does
not generate catch-up hits. Query contacts use the established Attack-layer and
actual Enemies-hurtbox filter, so Hornet/Buzzer sensor children cannot route hits
to distant enemies. Native Quake damage and graphics are suppressed.

| Tier | Damage per contact | Maximum five contacts | With Shaman Stone |
| --- | ---: | ---: | ---: |
| Basic down spell | 7 | 35 | 11 x 5 = 55 |
| Upgraded down spell | 11 | 55 | 17 x 5 = 85 |

Values are fixed spell damage independent of nail upgrades; Shaman uses
ceil(x1.5). Maximums assume full contact and are not guaranteed enemy HP loss.

## Artwork and verification

`data/character/wukong-fist-v074.json` produces the separate
`assets/processed/wukong-fist-v074-original` bake. The active offline1.5x copy is
`assets/processed/variants/wukong-fist-v074-1p5`; its -packed runtime copy contains
59clips/1559ticks/16pages, including the body-free moving-awakening Ape layers.
All earlier original/variant folders, clip pixels and archived inputs are preserved.
Run `scripts/prepare-all-assets.bat` to repeat preparation.

Production core tests cover buff boundaries, real HP loss, global cooldown,
refresh, full HP, stale tokens and Storm timing/caps/masks/damage. Source image
checks compare all new Storm frames and the Fire Eye action to the real source.
Compilation, preview, ZIP and installed-file verification are recorded in the
build report; gameplay remains pending in `CLIENT_ACCEPTANCE.md`.


## 0.7.3 defense and final-hit update

Up spell Fire Demon final contact uses native slam-strength horizontal enemy
recoil2 without forced landing. Down-spell Earthbreaker prevents incoming HP
damage throughout its owned launch/fall/landing action. Up Dream Fire Ape remains
vulnerable to native HP damage but continues its source action through ordinary
hits, retaining native post-hit cooldown. Death/hazards/scenes still win and
cleanup restores the exact native Dream damage transition. See FIST_SKILLS.md.


## 0.7.4 free-player adaptation (supersedes Ape armor)

Neutral spell summons an independent Afterimage attacker, then immediately returns
the native pre-antic route to Inactive without motion/control/gravity writes. The
clone attacks/moves/leaves ghosts while the hero acts freely. Up Dream Fire Ape
uses source moving awakening, follows live hero position/direction, and leaves
hero action/animation untouched. Native damage and recoil are fully restored.
Both still spend current native MP Cost once. Earthbreaker/Godslayer are unchanged.


## 0.7.5 native recovery protection

Successful up-spell Fire Demon and player down-spell Earthbreaker completion now
use original QuakeInvuln once after control recovery. Native INVUL_TIME_QUAKE
defaults to0.4s, protecting against ordinary enemy contact/projectile damage;
native hazard/expiry rules remain. Existing protection during each action stays
intact. Canceled actions, Earthbreaker without confirmed landing and copied ghosts
do not grant the recovery timer. No other skill/asset/HP/Soul rules are changed.


## 0.7.6 route swap and enemy hurt feasibility

Storm now starts on down-Dream input (including air), using the same live MP Cost
and shared controlled transaction as paid native-held casts. Its16-tick motion
lock, mask, five-hit/100ms cap, quakeLevel/Shaman damage and artwork are unchanged.
Successful end calls native QuakeInvuln after Dream End, retaining the old Quake
Finish recovery; canceled/dead/hazard/scene/disposed actions do not grant it.
Earthbreaker now starts in native Quake Antic and finishes through Spell End;
its existing confirmed-landing-only recovery call prevents duplicate/cancel grants.

Forced enemy hurt states are assessed only. The current path dispatches TAKE
DAMAGE and HitTaker/HealthManager native hit events and recoil. More recoil does
not guarantee interruption. Common enemies with verified hurt FSMs can be handled
at moderate effort, but bosses need explicit supported FSM/state/phase rules and
cleanup of attack hitboxes/projectiles. Some enemies lack a dedicated hurt pose.
Universal reliable support is substantially harder; a supported-enemy adapter
with native fallback is recommended over unconditional FSM state mutation.


## 0.7.6 Afterimage / Storm input swap

Neutral quick spell now starts Flame Storm. Native CanCast, MP, fireballLevel and
Wallside? checks run unchanged; Storm holds the Fireball Antic completion (ANIM END),
charges live MP Cost once, and finishes through Spell End. The projectile and
native spending states are skipped. Storm alone owns this Forward adapter. Its
16-tick action, mask, caps, quakeLevel/Shaman damage and successful-only
QuakeInvuln are unchanged; rejection/cancellation grants no timer.

Down + Dream Nail (including air) summons the detached Afterimage Combo. It reads
the same live MP Cost, pays once after the existing down-Dream eligibility, and
never begins/finishes native Dream or owns the player. Godslayer is the only
remaining Dream-controlled action.
