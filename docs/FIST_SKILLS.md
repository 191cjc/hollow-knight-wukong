# Fist skills (0.7.6-dev)

Original fist checkpoint: e44de07. The0.7.4/0.7.5 changes start from committed
0.7.3 checkpoint bf81c06 and are recorded together in the subsequent workspace
checkpoint. GitHub uploads use the verified SSH remote.

| Input | Action | Cost / progression |
| --- | --- | --- |
| Neutral quick spell | Afterimage Combo (残影连打) | Native fireballLevel; current MP Cost once, including Spell Twister |
| Dream Nail | Godslayer Strike (灭神一击) | Requires native Dream Nail unlock; hold then release, no Soul cost |
| Down + spell | Earthbreaker Fist (辟地拳) | Native quake unlock; ground launch or airborne slam; current native MP Cost once |
| Down + Dream Nail | Flame Storm (烈焰风暴) | Native Dream Nail unlock; fixed quakeLevel damage; current native MP Cost once |
| Up + Dream Nail | Moving-awakening Fire Ape (火猿出击·动觉醒) | Follows live hero position/direction; current native MP Cost once |

Existing staff attacks, up/down spells, focus, dash and death remain integrated.
Directional Dream Gate shortcuts now use the requested fist actions. Menus, locked
Dream Nail, death, transitions and conflicting native control prevent new casts.
Earthbreaker blocks incoming HP damage throughout its owned player action,
including launch, fall and landing tail. Copies/waves do not extend this window.
Afterimage and moving-awakening Fire Ape are independent summons, never owned
player actions. The player keeps native movement, attacks, animation and gravity.
Fire Ape follows the current hero root/facing, with its back layer behind the body
and roar in front; it never shows the original locked punching-body pose. No armor:
normal incoming HP damage, native recoil, hit pause and invincibility cooldown run
unchanged. Ordinary hits affect the player while independent effects continue.
Death/hazard/scene/detach destroys all actors. No StartRecoil hook, Dream damage
event override, manual HP writes or saved invincibility is used.
All four fist actions and copied hits now use native Q Slam horizontal spell recoil
magnitude2, replacing the weak0.15 multiplier. Body hits push away from their cast
root; Godslayer waves push along travel even after passing a target center. Native
HitTaker/HealthManager/Recoil handles acceptance, resistance and terrain. Do not
force enemy positions/velocity or bypass boss recoil immunity. Existing damage,
contact caps, Soul rules and other spells retain their previous values.

Earthbreaker and Fire Ape use the live native Spell Control MP Cost: normally33
Soul, or24 with Spell Twister. The separate native Set Spell Cost FSM updates it
on CHARM INDICATOR CHECK, independently of a spell cast. Insufficient Soul rejects
the action. Earthbreaker acquires native control before charging TakeMP once;
Fire Ape pays once without acquiring control. Recheck eligibility/ownership after
native callbacks before starting either action.
Canceled acquisition produces no action or extra ghost charge. Godslayer remains
free and keeps native full-charge Dream interactions. Damage factors are unchanged.

## Source evidence and adapted balance

Original 2006 body/effects are retained under assets/zmxy4. WK2Entity.as,
E3506.as, original per-frame contact rectangles and source hashes are preserved
in reference/flash/fist. Root/masks use baseline pixels per world unit, independently
of offline artwork enlargement. Sensor/weapon filtering reuses SkillTargetPolicy;
rangeFront=999 is never used as a collision extent.

One independently summoned attacker uses source effect4 for71ticks at30Hz,
with latched position/facing, its own contact ledger and source travel. The hero
stays free and can move/jump/attack/cast other skills concurrently. Five original local masks
have independent caps 2/1/1/1/1; the double punch has a 300ms contact interval.
Each contact deals 3/5 damage for normal/upgraded forward spell, or 5/8 with
Shaman Stone. Maximum stationary full contact is 18/30 or 30/48. Native evasion
may reduce hits. Source forward travel is terrain swept, capped at 540 original
pixels. Four ghost births follow source frames12/26/40/52. Recast replaces them;
unused ghosts last ten scaled seconds, deferring expiry while mimicking an action.
A ghost is consumed after one copied Godslayer/Earthbreaker action: remove it at
the end of the release/landing tail instead of returning to idle. Copies already
in progress are not restarted by a later cast. Canceling an unreleased copied
Godslayer charge removes that ghost. Emitted waves keep their independent lifetime.

Dream-key damage uses current nailDamage, rounded up, without Strength or
Shaman Stone. Partial Godslayer is 1x nail; full is 2.5x. Earthbreaker falling
contact is 0.4x and landing is 1.2x, each once per target. Ape uses independent
source caps5/2 and intervals434/400ms, at 0.4x/0.6x nail. Ghost attacks deal 20%
of these factors, rounded up with a minimum of one. They grant no duplicate dream
interactions. Ape recovery adds a three-second cooldown; other Dream actions add
0.25 seconds. Native Soul-on-nail is not added to fist damage.

Godslayer full charge is source frame39 (38 elapsed ticks, 1.267 seconds), or
0.633 seconds with Dream Wielder. Key-up latches the tier earlier. A held key
forces a full release at original frame60 (59 elapsed ticks:1.967 seconds, or
0.983 seconds with Dream Wielder), then plays original frames60..84 once. The punch spawns100ms after release
at original (+80 facing,+33 up). Full wave moves720 original pixels/second for
667ms and partial punch lasts500ms, hitting each target once. Only the player's
full wave clones the actual native Dream Effects/Hitbox, retaining its tag/layer,
Send Event FSM and SendDreamImpact handling. Disable only that clone's Deactivate
FSM and replace its polygon with the original local punch rectangle. A scoped
kinematic Rigidbody2D replaces the inherited hero body so triggers also reach static
dream scenery; full kinematic contacts are enabled only on this clone. Enemy Soul,
thoughts and dream-scene reactions remain native; there is no manual essence/Soul
award or guessed DREAM NAIL event.

NativeDreamV77 disables/restores only the Inactive Dream input listener, holds
the Start tk2d completion with an ignored real event, starts through native Fsm
Cancel broadcast/Take Control and recovers through End/Regain Control. It does
not enter native Dream Gate branches. Full-wave interaction may let native
conversation/scene FSMs take over. Cancellation stops body hits immediately;
ordinary recovery leaves independent projectiles alive until their short expiry.
Death/hazard/scene/detach destroy all actors and physical dream triggers.

Ground Earthbreaker rises for16 source ticks, then falls to actual terrain;
air casts use an eight-tick antic then fall. Descent is33original pixels/tick
(1.5x the earlier22); rise/antic and landing tail keep their source timing. Hero
and ghost use the same movement rule, with blocked distance consumed normally. The unchanged hero body is swept
at every movement step; falling pose holds source frame18 until contact and
landing resumes frame19. Timeout bounds a bottomless fall. Ape uses original
105-tick back/front effects as source skill5Awake1 moving awakening. The hero
uses ordinary movement/animation/facing; no scripted forward travel or input hold.
Movement is denied only during owned Godslayer/Earthbreaker actions.

Adaptations: fixed Hollow Knight damage/recovery replaces source RPG stats/MP.
Godslayer now follows the archived source automatic maximum-charge release.
Ghost idle images use original effect4 held poses at zero-based ticks11/25/40/53;
the last two previously froze stretched birth transitions at39/51. No compensating
nonuniform scale is used. They use source body/effects for mimicked attacks. Ghost Earthbreaker uses a terrain-swept box matching the unchanged native body bounds,
with its own launch/fall/landing clock and no additional physical collider.
Native scenery collision and full gameplay behavior still need client acceptance.

## Preserved artwork and compact runtime atlases

wukong-fist-v074-original preserves all57earlier clips/1349ticks and adds two
105-tick body-free Ape layers:59clips/1559ticks total. Its separate1.5x variant
keeps full canvases, and16compact runtime pages retain exact pixels. The -packed folder trims only
transparent margins, includes the shared root in every crop and shelf-packs them.
Each frame records source_x/source_y to retain exact pivot/feet registration.
No pixels are resampled during packing; reconstructing every unique cell must equal
the enlarged source exactly. Existing manifests without atlas_packing still require
the original shared-canvas format. All prior archived and processed folders remain.
The reusable entry point remains scripts/prepare-all-assets.bat.

Global DragonBones2.3 fist colors and explicit linear tweens are opt-in; earlier
staff profiles retain strict rejection/default behavior. The local3.0 ape archive
allows only its one-tick linear frames and alpha fade. Unsupported depth/RGB/tween
features still fail. Partial-punch animation.scale=5 is applied to sampling only;
source files are never edited. The partial punch retains its original ten-tick
scaled loop during the500ms lifetime.

## Required client acceptance

Check all four inputs with keyboard/controller, locked Dream Nail, both facings,
partial/full/long-held charge and Dream Wielder. Verify full-charge enemy Soul/
thoughts plus dream scenery, and no dream effect from partial/clone attacks.
Check four clone births/proportions, ten-second expiry/recast/mimicry, actual local range against
Hornet/Buzzers, multiple colliders, terrain/ceilings/slopes, airborne Earthbreaker,
paused/slow frames, movement denial/recovery, damage/death/scene changes and disable.
Regression-check original staff/charms/pogo, up/down spell, focus, dash and death.
Compilation, source-pixel checks and pure core tests do not establish these results.


Native listener cache: v77 FsmState.OnUpdate iterates its cached ActiveActions
without checking Enabled. set_Enabled only changes a flag. Remove the exact
Inactive ListenForDreamNail action from that cache on attachment; retain all other
actions. On restoration while Inactive, prime its input cache and reinsert it at
its original order if absent. If another state is active, normal future OnEnter
rebuilds the list using restored Enabled. Exact pinned IL is preserved under
reference/flash/fist/native-listener-cache.txt.


## 0.7.4 neutral spell entry and summon ownership

Has Fireball? IntCompare.greaterThan CAST is held after native CanCast, MP and
fireballLevel checks, before Wallside? FlipSprite and Fireball Antic motion/control
actions. TakeMP charges live MP Cost once; return directly to Inactive. Do not
enter Spell End, which would clear velocity and reset control/gravity. Up/down/
focus stay on their native routes. Repeated same-frame observations cannot pay twice.

The combo actor alone travels540source pixels through terrain-swept bounds and
births four ghosts at elapsed ticks11/25/39/51. Travel steps split at birth ticks
so slow frames keep distinct positions. Recast replaces that actor/old ghosts;
independent waves/Ape survive. Player movement never changes clone origin/facing.
Hero Godslayer/Earthbreaker can still trigger existing ghost mimicry.

Ape acquires no Dream FSM/control, cannot duplicate while active, and retains the
previous3s post-effect cooldown independently of the other Dream actions. Source
local masks/caps5/2 and434/400ms cooldowns remain in one ledger across player
movement/turns/hits. Original body composite remains archived; new effect-only
back/front clips live in separate v074 original/full1.5x/packed directories.


## 0.7.5 post-action recovery

Successful player Earthbreaker landing recovery now calls original QuakeInvuln
once, after native control recovery and a live-hero recheck. It grants the native down-spell
timer: INVUL_TIME_QUAKE, default0.4s, against ordinary enemy damage. Native Update
and hazard rules handle expiry/acceptance. Existing full-action immunity remains.
Copied ghosts, canceled actions, unlanded bottomless timeout, death/hazard/scene
and teardown do not grant the timer. Godslayer and detached Ape/Afterimage stay
unchanged; no added armor or custom post-action HP guard. Artwork stays identical.


## 0.7.6 native ownership

Earthbreaker owns held Quake Antic instead of Dream Start, and suppresses native
Quake damage/effects. Its masks, nail factors, terrain travel, copied ghosts and
full-action immunity are unchanged. Spell End skips automatic Quake Finish so
only confirmed player landing grants one QuakeInvuln; cancel/timeout grants none.
Storm and Godslayer borrow one Runtime-owned Dream adapter; neither may end the
other's action. Finish both skill owners before disposing the shared adapter.
