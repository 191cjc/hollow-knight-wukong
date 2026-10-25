# Spell controls (0.7.3-dev)

The 0.4.4 workspace was committed before these changes as
`a07b2ac4981caca2b84af7a4f9ae1dc270a3d42d`. No remote push was made.

| Input | Replacement | Native progression |
| --- | --- | --- |
| Neutral quick spell | Afterimage Combo (残影连打) | Native forward spell unlock/tier (`fireballLevel`), current MP Cost once |
| Dream Nail | Godslayer Strike (灭神一击) | Hold/release or automatic maximum; full charge preserves native Dream impact |
| Down + Dream Nail | Earthbreaker Fist (辟地拳) | Native Dream Nail unlock; current native MP Cost once |
| Up + Dream Nail | Fire Ape Assault (火猿出击) | Native Dream Nail unlock; current native MP Cost once |
| Up + spell | Fire Demon Slash | Howling Wraiths / Abyss Shriek (`screamLevel`) |
| Down + spell | Flame Storm | Desolate Dive / Descending Dark (`quakeLevel`) |
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
control. No extra invulnerability is granted to this skill.

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

`data/character/wukong-staff-presentation-v062.json` produces the separate
`assets/processed/wukong-presentation-v062-original` bake. The active offline1.5x
copy is `assets/processed/variants/wukong-presentation-v062-1p5`:45clips,991ticks,
32atlas pages. This includes the original spell/nail art and flameDashDown. All earlier original/variant folders and archived inputs are preserved.
Run `scripts/prepare-all-assets.bat` to repeat preparation.

Production core tests cover buff boundaries, real HP loss, global cooldown,
refresh, full HP, stale tokens and Storm timing/caps/masks/damage. Source image
checks compare all new Storm frames and the Fire Eye action to the real source.
Compilation, preview, ZIP and installed-file verification are recorded in the
build report; gameplay remains pending in `CLIENT_ACCEPTANCE.md`.


## 0.7.3 defense and final-hit update

Up spell Fire Demon final contact uses native slam-strength horizontal enemy
recoil2 without forced landing. Down Dream Earthbreaker prevents incoming HP
damage throughout its owned launch/fall/landing action. Up Dream Fire Ape remains
vulnerable to native HP damage but continues its source action through ordinary
hits, retaining native post-hit cooldown. Death/hazards/scenes still win and
cleanup restores the exact native Dream damage transition. See FIST_SKILLS.md.
