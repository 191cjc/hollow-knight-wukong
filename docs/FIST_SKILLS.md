# Fist skills (0.7.3-dev)

Checkpoint before this change: e44de07. No remote push.

| Input | Action | Cost / progression |
| --- | --- | --- |
| Neutral quick spell | Afterimage Combo (残影连打) | Native fireballLevel; current MP Cost once, including Spell Twister |
| Dream Nail | Godslayer Strike (灭神一击) | Requires native Dream Nail unlock; hold then release, no Soul cost |
| Down + Dream Nail | Earthbreaker Fist (辟地拳) | Direction latched on press; ground launch or airborne slam; current native MP Cost once |
| Up + Dream Nail | Fire Ape Assault (火猿出击) | Direction latched on press; current native MP Cost once |

Existing staff attacks, up/down spells, focus, dash and death remain integrated.
Directional Dream Gate shortcuts now use the requested fist actions. Menus, locked
Dream Nail, death, transitions and conflicting native control prevent new casts.
Earthbreaker blocks incoming HP damage throughout its owned player action,
including launch, fall and landing tail. Copies/waves do not extend this window.
Fire Ape still takes native HP damage, but HERO DAMAGED cannot cancel its owned
Dream action and ordinary StartRecoil cannot stop or displace it. Native damage
charms, UI and post-hit Invulnerable timing (including Stalwart Shell) remain.
Death, hazards, scene changes and teardown still terminate the action; the original
Dream damage transition is restored on every finish/cancel. No saved invincibility
flag, manual HP deduction, cast restart or additional Soul charge is used.
All four fist actions and copied hits now use native Q Slam horizontal spell recoil
magnitude2, replacing the weak0.15 multiplier. Body hits push away from their cast
root; Godslayer waves push along travel even after passing a target center. Native
HitTaker/HealthManager/Recoil handles acceptance, resistance and terrain. Do not
force enemy positions/velocity or bypass boss recoil immunity. Existing damage,
contact caps, Soul rules and other spells retain their previous values.

Earthbreaker and Fire Ape use the live native Spell Control MP Cost: normally33
Soul, or24 with Spell Twister. The separate native Set Spell Cost FSM updates it
on CHARM INDICATOR CHECK, independently of a spell cast. Insufficient Soul rejects
the action before taking control; successful acquisition charges native TakeMP
once, then starts the action/mimicry. Recheck Soul/ownership after native callbacks.
Canceled acquisition produces no action or extra ghost charge. Godslayer remains
free and keeps native full-charge Dream interactions. Damage factors are unchanged.

## Source evidence and adapted balance

Original 2006 body/effects are retained under assets/zmxy4. WK2Entity.as,
E3506.as, original per-frame contact rectangles and source hashes are preserved
in reference/flash/fist. Root/masks use baseline pixels per world unit, independently
of offline artwork enlargement. Sensor/weapon filtering reuses SkillTargetPolicy;
rangeFront=999 is never used as a collision extent.

Afterimage uses source effect4 for 71 ticks at 30Hz. Five original local masks
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
105-tick body, independent back ape and front roar, with terrain-limited source
forward travel. Movement input is denied while the owned action is active.

Adaptations: fixed Hollow Knight damage/recovery replaces source RPG stats/MP.
Godslayer now follows the archived source automatic maximum-charge release.
Ghost idle images use original effect4 held poses at zero-based ticks11/25/40/53;
the last two previously froze stretched birth transitions at39/51. No compensating
nonuniform scale is used. They use source body/effects for mimicked attacks. Ghost Earthbreaker uses a terrain-swept box matching the unchanged native body bounds,
with its own launch/fall/landing clock and no additional physical collider.
Native scenery collision and full gameplay behavior still need client acceptance.

## Preserved artwork and compact runtime atlases

wukong-fist-v071-original contains all prior clips plus twelve new clips. A separate
1.5x variant keeps the resized full canvases. The runtime -packed folder trims only
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
