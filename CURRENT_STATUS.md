# Current status: Wukong0.7.8 awakening charms

Updated2026-10-27 (Asia/Shanghai), branch feat/fire-eye-charm, after checkpoint23852f3.

| Native charm | Current behavior |
| --- | --- |
| Deep Focus /34 | 汲元火眼·觉醒 / Jiyuan Fire Eye: Awakening;2notches;3second base buff or6seconds when equipped at activation; generated icon and native acquisition/save identity retained |
| Dashmaster /31 | 烈焰闪·觉醒 / Flame Dash: Awakening; native2notches/icon/acquisition; airborne Up-only plus normal dash enables upward Flame Dash |

Upward dash uses native eligibility, normal/Sharp Shadow speed, duration and the
shared aerial allowance. A separate unsaved guard permits one successful upward
use before an accepted physical landing. Pogo, walls, wall jump, generic air-move
resets, damage and charm toggles do not replenish it. Native accepted bottom
landings cover ordinary, hard and down-dash landing on layer8 terrain and
HeroWalkable platforms, preserving native SteepSlope/state rejection. Normal
completion removes only exact owned positive-Y momentum before native end
callbacks; newer jump/bounce/recoil motion retains ownership. Existing damage,
active-dash protection, charm bonuses and horizontal/downward behavior remain.

The separate v078 original/full1.5x/packed variant adds12upward ticks:
60clips/1571ticks/16runtime pages. Only flames rotate offline; body/root/aura
stay upright. Production-sampler checks preserve all1559earlier ticks at both
sizes and reconstruct the new packed pixels exactly. Prior variants and the
0.7.7rollback package are retained. Character canvas/root/calibration and combat
masks remain unchanged.

Fire Eye icon pixels remain unchanged. The renamed preview is publicly verified:
Preview: https://litter.catbox.moe/3gm8ze.png
Transparent PNG: https://litter.catbox.moe/4dfkjd.png
Temporary72hour links expire approximately2026-10-30 17:28 (Asia/Shanghai).
Icon SHA256: 8d397a5d5e9138e4f6a3030fd1cf1db4e358bfe6d920d0d17cac427f745573d5.

Validation: scripts/build.sh --no-incremental passed70Python tests and91actual
production-linked Core checks. The final affected pinned-reference Release and
package checks were repeated after the MonoMod ILLabel matcher correction:
0warnings/0errors,19file package closure and ZIP CRC/byte equality passed.
Package: artifacts/WukongKnight-0.7.8-dev.zip
ZIP SHA256: 8d83d0e8ec79c253549677a53b99bcd9114a2c491a07d6cfb81c67a7a63ffd6a.
DLL SHA256: 11c2e94339e4721ab0f5d12ddab4dc306260d52ca1a23944505685234c03cf54 (211968bytes).
Evidence: .trellis/tasks/10-27-fire-eye-charm/research/awakening-build.log and
awakening-implementation.md; final independent audit is recorded by the main session.

Actual client acceptance remains pending (runtime_tested=false). No0.7.8install
was performed because this Linux environment has no mounted Windows Steam path.
Native UI/equipment, keyboard/controller input, shared allowance/landings, ceilings,
Sharp Shadow interactions, focus charms and disable/re-enable need client checks.
See docs/CLIENT_ACCEPTANCE.md. The user explicitly authorized committing all
workspace contents and pushing the current branch to origin after validation.

---

# Previous status: Wukong0.7.7 Fire Eye Sigil

Updated2026-10-27 (Asia/Shanghai), branch feat/fire-eye-charm, based on187fca8.
Fire Eye lasts3seconds, or6seconds when Fire Eye Sigil is equipped at successful
completion. The two-notch charm replaces Deep Focus (ID34), retaining its native
collectible, owned/equipped save identity and inventory slot. Former Deep Focus
healing/charge tradeoff is removed through exact owning native focus-action reads.
Other charm modifiers, source visuals, healing triggers/global cooldown and cleanup
remain intact. Native methods recalculate used notches and overcharm on restoration.

The user-selected gpt-image-2.5-flare generated a flame/eye charm. Its original is
preserved; deterministic offline processing produces the separate transparent PNG.
The final PNG is embedded in the DLL and its extracted bytes match exactly.
Public preview: https://litter.catbox.moe/3b20ya.png
Transparent PNG: https://litter.catbox.moe/jqwude.png
Temporary links expire approximately2026-10-30T08:34UTC (72hours).

Full scripts/build.sh passed:67Python tests,81production-linked Core checks,
Release0warnings/0errors, source/atlas validation and19file ZIP byte equality.
Current character resources remain59clips/1559ticks/16runtime pages; no active
variant selection or prior source/character-art files were changed. Earlier stale
baseline cache was preserved by hash before regenerating validation fixtures.
Package: artifacts/WukongKnight-0.7.7-dev.zip
ZIP SHA256: 9acab5d2f65e24b956ff91b2631ef96d4bb95961bae5da16269a57bca7f3b98b
DLL SHA256: 00df7bb966a70ae0c88340a24f2d4fe4ba5e9e4ca68763a3d69fd059a2379d2b (196608bytes).

Actual client acceptance remains pending (runtime_tested=false). No0.7.7install
was performed because this Linux environment has no mounted Windows Steam path.
Native serialized action discovery, collection/UI/text/icons/notches/overcharm,
Quick Focus/Shape of Unn, Soul/cancel and disable/re-enable still need client checks.
Other skill routes, enemy recorder and unfinished Storm attribution remain intact.
Task: .trellis/tasks/10-27-fire-eye-charm; see research/final-validation.json and
docs/CLIENT_ACCEPTANCE.md. The user authorized the local implementation commit; no remote push is authorized.

---

# Previous status: Wukong0.7.6 directional control swap

Updated2026-10-26 (Asia/Shanghai). Installed0.7.6-dev in the authorized WukongKnight
directory at 2026-10-26T22:13:22.043917+08:00, with the game stopped. Down spell is
Earthbreaker Fist; down Dream is Flame Storm. Live native Soul cost once, damage,
source masks/clocks, ghost mimicry, all artwork and Earthbreaker full-action/
confirmed-landing recovery are preserved. One Runtime-owned Dream adapter is
shared and restored after both borrowers finish. Storm retains its successful
native recovery. Other inputs and detached summons retain existing behavior.

Forced enemy hurt-state transitions are assessed only, not implemented. Supporting
selected common enemies is moderate effort; reliable all-enemy/Boss support needs
per-enemy state/phase rules and attack-residue cleanup. Some enemies lack a hurt
pose. Existing native damage/recoil events remain authoritative.

Validation:66Python passed/one Windows symlink-privilege skip;76actual linked C#
core checks and warnings-as-errors Release passed. Native/compiled ownership,
Soul and recovery paths reviewed;19installed files/ZIP verified. All17character
resources remain byte-identical (59clips/1559ticks/16pages). No API/save changes.
Client gameplay/input/combat acceptance pending: runtime_tested=false, task
in_progress. This checkpoint records all0.7.6 changes after baseline05ea9ea.
The user authorized a local commit; no remote push was requested.

Package: artifacts/WukongKnight-0.7.6-dev.zip.
ZIP SHA256: bdc1cfff83eb5fe19a85ee25f06f85e2b52ab1cd20083eccac564695611ba93b.
DLL SHA256: 3fba97edae4e339e77b581d21d200e13fc3e6012c290f46e28d1b248b2e32b43 (115200bytes).
Backup: installed-WukongKnight-before-0.7.6-20261026-221319.zip.
Backup SHA256: 411d7e8056fee9c72daf6a9bc64a3e1136375510bee842d5ec41c402026c9fa3.
Evidence: reference/flash/fist/control-swap-v076.json and task research/control-swap-v076-20261026.md.

---

# Previous status: Wukong0.7.5 native down-spell recovery

Updated2026-10-26 (Asia/Shanghai). Version0.7.5-dev is installed in the authorized
WukongKnight directory with the game stopped and a complete previous0.7.4 backup.
Baseline bf81c06 is preserved. This checkpoint records the complete0.7.4/0.7.5
source/config/test/documentation changes. The user authorized committing and
pushing all current changes; origin now uses verified SSH authentication.

Native Spell Control Quake Finish calls HeroController.QuakeInvuln, assigning live
INVUL_TIME_QUAKE (installed prefab default0.4s) to parryInvulnTimer. Fire Demon now
calls that same method once after successful source-end control recovery; player
Earthbreaker calls it once after confirmed landing recovery. Existing full-action
HP guards remain. The new recovery tail follows native ordinary-damage/hazard/
expiry rules, without a custom HP guard or saved invincibility. Cancellation,
unlanded timeout, ghosts, death/hazards/scenes and teardown grant no timer.
Other skills, movement, damage, Soul and all17active character resources stay intact.

Validation:66Python passed/one Windows symlink-privilege skip;74actual production
C# core checks and warnings-as-errors Release passed. Native serialized prefab/FSM,
installed QuakeInvuln/Update/TakeDamage and actual compiled success/cancel paths
were reviewed. All19package/installed file hashes and archive bytes verified.
All17character resources are byte-identical to0.7.4 (59clips/1559ticks/16pages).

Package: artifacts/WukongKnight-0.7.5-dev.zip.
ZIP SHA256: 4aa3c475eab814ad9c99476895285cd24d3aa36cd9169a6789c129c711ef21ef.
DLL SHA256: 22d5815734409e60f807408f391f40fb3224b9c3881bd8ef784538c661388b25 (113664bytes).
Installed at 2026-10-26T21:27:17.336268+08:00.
Backup: installed-WukongKnight-before-0.7.5-20261026-212714.zip.
Backup SHA256: 289a269aa8f47c3561681e987360637574c4d8883974db438ef4fd93fcd416be.
No API/save modifications. Client recovery/contact/projectile/hazard/expiry and
prior-skill acceptance remain pending; **runtime_tested=false**, task in_progress.
Evidence: reference/flash/fist/quake-recovery-v075.json and
.trellis/tasks/10-23-wukong-character-basic-attacks/research/quake-recovery-v075-20261026.md.

---

# Previous status: Wukong0.7.4 independent summons

Updated2026-10-26 (Asia/Shanghai). Version0.7.4-dev is installed in the authorized
WukongKnight directory with the game stopped and a complete previous0.7.3 backup.
Local checkpoint bf81c06 is preserved; this request remains uncommitted.

- Neutral spell summons one independent Afterimage Combo attacker. Its original
  71-tick route/hits and four persistent trail ghosts run while the hero moves,
  jumps, attacks or casts. Terrain sweeps affect only the clone. Neutral casting
  pays live MP Cost once and returns directly from Has Fireball? to Inactive,
  avoiding native antic/flip/control/gravity/velocity writes and Spell End resets.
- Up Dream Fire Ape uses source skill5Awake1 moving awakening: body-free105-tick
  back/front effects follow live hero position/facing around ordinary animation.
  Normal incoming HP damage, recoil and hit pause run. Prior armor, StartRecoil
  hook and Dream damage transition override are removed. The effect retains its
  local hit caps/cooldowns and separate3s post-effect cooldown; cost remains once.
- Godslayer/Earthbreaker retain hero ownership and existing copied-ghost behavior;
  Earthbreaker immunity and Fire Demon final recoil remain. Ordinary actions/hits
  leave summons running; death/hazards/scenes/detach remove every actor/trigger.

Validation:66Python passed/one Windows symlink-privilege skip;74actual production
C# core checks and warnings-as-errors Release passed. All19package/installed
files and ZIP bytes verified. All1308previous asset files retain their SHA256;
all57previous clips/1349ticks preserve pixels, timing, root and combat. New
v074 original/full1.5x/packed folders add only two body-free layers:59clips,
1559ticks,16compact pages. Packed pixels, both-facing artwork previews and actual
compiled ownership/forward-recovery/no-armor boundaries were reviewed.

Package: artifacts/WukongKnight-0.7.4-dev.zip.
ZIP SHA256: 12c0a3ede15ea74d5d902376c6882fe0a4d93584dddcded0004b3d7b6171c577.
DLL SHA256: 8f9043b0db33eef4313a09acb61fba7509ab33a4c52aeb50f46c605656af6de6 (113152bytes).
Installed at 2026-10-26T20:49:12.265687+08:00.
Backup: installed-WukongKnight-before-0.7.4-20261026-204909.zip.
Backup SHA256: 5a42c2d234bb50f0abfeccafb773dadca57e121a09c31ae981a7a3bee4d87f1f.
No API/save modifications or new commit/push. Client free movement, controls,
damage/recoil/terrain and cleanup acceptance remain pending; **runtime_tested=false**,
task in_progress. See reference/flash/fist/detached-v074.json and
.trellis/tasks/10-23-wukong-character-basic-attacks/research/detached-v074-20261026.md.

---

# Previous status: Wukong0.7.3 skill defense and final-hit recoil

Updated2026-10-24 (Asia/Shanghai). Version0.7.3-dev installed in the authorized
WukongKnight directory with game stopped and complete previous0.7.2 backup.
Checkpoint e44de07 and earlier artwork remain;0.7 changes are saved in the
0.7.3 local checkpoint commit.

- Fire Demon final hit now uses native Q Slam horizontal Spell recoil magnitude2,
  away from its actual moved effect root. Native resistance, midair completion,
  damage/regions and air/Flame Storm recoil remain intact.
- Earthbreaker blocks incoming HP damage throughout the actual owned player
  launch/fall/landing tail; copies/waves never extend the protection window.
- Fire Ape retains native HP damage/charms/callbacks/post-hit cooldown while
  resisting ordinary hit cancellation and recoil. The exact native Dream damage
  transition is restored on finish/cancel/dispose; death/hazards/scenes still win.
  No cast/clock restart, additional Soul charge or saved invincibility writes.

Validation:64Python passed/one Windows symlink privilege skip;71actual production
C# core checks and warnings-as-errors Release passed. All15package/installed
files/ZIP verified. All13active character resources are byte-identical to0.7.2;
57clips/1349ticks/12compact pages reused. Native installed/reference recoil IL is
identical; actual damage-effect FSM and compiled hit/guard/recovery boundaries
reviewed. Evidence: reference/flash/fist/defense-v073.json and
.trellis/tasks/10-23-wukong-character-basic-attacks/research/defense-v073-20261024.md.

Package: artifacts/WukongKnight-0.7.3-dev.zip.
ZIP SHA256: fc2cb558e6ff6c2a23fad38afac2ef04033d2cfc8aaeb7ac02a99f66a38c1d0d.
DLL SHA256: ea68288ef0d8d281ae8d94496859846577da1f95262a983941ab638d1f9b9b68 (112640bytes).
Installed at 2026-10-24T22:38:39.785196+08:00.
Backup: installed-WukongKnight-before-0.7.3-20261024-223837.zip.
No API/save changes or remote push. Actual client damage/armor/recoil/
recovery acceptance is pending; **runtime_tested=false**, task in_progress.

---

# Previous status: Wukong0.7.2 copied ghosts and knockback

Updated2026-10-24 (Asia/Shanghai). Version0.7.2-dev installed in the authorized
WukongKnight directory with game stopped and complete previous0.7.1 backup.
Checkpoint e44de07 and earlier artwork remain; new0.7 changes are uncommitted.

- Each ghost copies Godslayer/Earthbreaker once, then disappears after its release/
  landing tail. Busy copies are not restarted. Canceled unreleased Godslayer copies
  are consumed. Idle ghosts retain10seconds; emitted waves finish independently.
- Earthbreaker descent is1.5x faster (33instead of22source pixels/tick) for player
  and copies; ground rise/air antic, landing tail and terrain sweeps are retained.
- All fist hits use native Q Slam horizontal Spell recoil magnitude2. Body hits
  push away from their cast root; Godslayer waves push along travel. Native enemy
  resistance/blocking/terrain remains authoritative. No forced enemy movement or
  added hero immunity. Damage/masks/Soul and other spell recoil remain unchanged.

Validation:64Python passed/one Windows symlink privilege skip;65actual production
C# core checks and warnings-as-errors Release passed. All15package/installed
files/ZIP verified. All13active character files are byte-identical to0.7.1;
57clips/1349ticks/12compact pages reused. Compiled shared spell helper retains
Fire Demon/Storm0.15air/1finisher and circle behavior; native ownership checks
remain before/after TAKE DAMAGE callbacks. Native/source evidence is stored in
reference/flash/fist/combat-v072.json and docs/FIST_SKILLS.md.

Package: artifacts/WukongKnight-0.7.2-dev.zip.
ZIP SHA256: 8134013624ceb5dff4b52b8b951aaf8af41b98485effb0c6b2a04a278b15beab.
DLL SHA256: 3c2a3db5b0435919f953e3697c91a792ace9f4d48e996ec59311798055b3c2a2 (109056bytes).
Installed at 2026-10-24T21:00:45.280719+08:00.
Backup: installed-WukongKnight-before-0.7.2-20261024-210043.zip.
No API/save changes, new commit or remote push. Actual client input/combat/recoil/
contact-damage acceptance is pending; **runtime_tested=false**, task in_progress.

---

# Previous status: Wukong0.7.1 fist corrections

Updated2026-10-24 (Asia/Shanghai). Version0.7.1-dev installed into the authorized
WukongKnight directory with the game stopped. The previous0.7.0 Mod is completely
backed up; checkpoint e44de07 and all original/previous asset folders are retained.
New0.7 work remains reviewable locally; no new commit or remote push.

- Down Dream Earthbreaker and up Dream Fire Ape require current native Spell
  Control MP Cost (normally33, Spell Twister24). Reject insufficient Soul before
  taking control; charge native TakeMP once after acquisition and before gameplay.
  Recheck Soul/ownership around native callbacks. Mimic ghosts cost no extra Soul;
  neutral Godslayer stays free. Existing damage factors/masks remain unchanged.
- Godslayer automatically fires once at source frame60 (59elapsed ticks:1.967s,
  Dream Wielder0.983s), retaining earlier key-up release/full-tier38tick behavior,
  native full-wave Dream interaction,25-tick release tail and100ms spawn delay.
- Last two persistent ghosts use original held punch/kick poses40/53 instead of
  stretched transition poses39/51. New original/full1.5x/packed folders preserve
  all prior assets; no runtime stretch/collider changes. Both-facing preview reviewed.

Validation:64Python passed/one Windows symlink-privilege skip;60actual production
C# core checks and warnings-as-errors Release passed. All15package/installed files
and ZIP bytes verified. All1007prior asset files unchanged. Only afterimageIdle3/4
changed; the other1347ticks at each size are byte-identical, with unchanged
combat/canvas/root/calibration.57clips/1349ticks/12compact pages; lossless packed
reconstruction and source composition passed. Details: docs/FIST_SKILLS.md,
reference/flash/fist/corrections-v071.json and artifacts/build-report.json.

Package: artifacts/WukongKnight-0.7.1-dev.zip.
ZIP SHA256: 4bd12ac765ef50bf620a436f1cd7b6b56ec13e7fd513edd06dcd8ab7649bc4d1.
DLL SHA256: f3cb98842dbf29a809a7dcb307f93c9c6a6afbcd07ad80258e2eff7ca0c81e05 (108544bytes).
Installed at 2026-10-24T19:59:53.052966+08:00.
Backup: installed-WukongKnight-before-0.7.1-20261024-195951.zip.
No API/save files modified. Actual gameplay acceptance remains pending;
**runtime_tested=false**, parent task stays in_progress. See docs/CLIENT_ACCEPTANCE.md.

---

# Previous status: Wukong0.7 fist skills

Updated2026-10-24 (Asia/Shanghai). Version0.7.0-dev installed into the authorized
WukongKnight directory. Current workspace checkpoint was committed first as
**e44de07**; new changes remain reviewable locally, with no remote push.

| Input | Implemented action |
| --- | --- |
| Neutral quick spell | Afterimage Combo, original fists/flames, four ten-second mimic ghosts |
| Dream Nail | Godslayer hold/release, damage; full charge retains native Dream interactions |
| Down + Dream Nail | Earthbreaker, ground launch/air slam and terrain-limited landing |
| Up + Dream Nail | Fire Ape, original body/back/front layers and local contacts |

All previous staff/nail/up-down-spell/focus/dash/death mechanics remain integrated.
Fist actions require native progression, use explicit balanced damage and have no
added immunity. Directional Dream Gate shortcuts are intentionally occupied.
Godslayer full charge38/30s, or38/60s with Dream Wielder; partial/ghost hits grant
no native dream interactions. Source files, masks and native adapter evidence are
under reference/flash/fist; balance/lifecycle details are in docs/FIST_SKILLS.md.

Validation:63Python checks passed, one Windows symlink-privilege skip;55actual
production C# core checks; warnings-as-errors Release compile. All15package/
installed files and ZIP bytes verified.57clips/1349ticks/12runtime atlas pages.
491preexisting asset files preserved unchanged. All991prior ticks remain registered;
rebaking into the larger source canvas changes at most one premultiplied8-bit
channel level from floating-point raster rounding. Every unique packed1.5x cell
reconstructs its enlarged source exactly. New clips were compared to original
source composition, and the complete effects/poses preview was inspected.

Package: artifacts/WukongKnight-0.7.0-dev.zip.
ZIP SHA256: 5d498a363a0d4513fb23bc391e7d83eb84b5b1e5f940cf041a341ca51968f2ee.
DLL SHA256: 29e9d3a8082eebb3d09da74c5d9a633385b7d1bda39d0d2d3206273be02b82ea (107520bytes).
Installed at 2026-10-24T19:18:33.064219+08:00 with game stopped. Complete
initial previous0.6.3 backup: installed-WukongKnight-before-0.7.0-20261024-191008.zip.
Native listener cache removal/restoration and standalone dream-trigger kinematic
contacts are included in this final installation. No API/save files modified. Actual gameplay acceptance is pending,
**runtime_tested=false**; task remains in_progress. See docs/CLIENT_ACCEPTANCE.md.

---

# Previous status: 0.6.3 character, nail arcs and spells

Updated2026-10-24 (Asia/Shanghai). Development version: **0.6.3-dev**.
Baseline: Windows / Hollow Knight1.5.78.11833 / Modding API v77 / Unity2020.2.2f1.
Actual client acceptance remains pending; runtime_tested=false.

| Area | Current behavior |
| --- | --- |
| Baseline | Workspace committed as a07b2ac before spell work; subsequent changes remain local/uncommitted; no push |
| Artwork | Separate original/offline1.5x nail variant:45clips/991ticks/32atlas pages; all earlier originals/variants preserved |
| Charm visuals | Independent arc reads actual native selected-slash X/Y scale ratio; body stays offline1.5x; fixed character center preserved |
| Nail arcs | Original attack1..4 ground arcs, jumpAttack air arc, effect1 up body/arc; down rotates only effect1 arc180 around source(0,-44.5), upright body |
| Nail mechanics | Native damage/upgrades, charms, Soul, reach, clashes, collision and down pogo retained; actual five hero slash mesh draw submissions replaced/restored on detach |
| Combo | Four intentional inputs; one buffered follow-up; third stage has two native hit windows |
| Flame Dash | Native movement/unlocks/cooldown/collision; original flames and once-per-target path damage; Dashmaster downward flames follow native dashingDown, body stays upright; full incoming-damage protection for actual active dash, immediate end/cancel release |
| Up + spell | Fire Demon uses screamLevel, original moving flashes/masks, source forward travel, midair finisher at moved root, full-cast protection/input lock |
| Down + spell | Flame Storm uses quakeLevel, original16-tick body/flames, local mask, five-contact cap/100ms interval |
| Hold focus | Jiyuan Fire Eye (汲元火眼): original30Hz body/casting flames/eye flashes ending at native focus completion; earlier charge shows opening body only; short charge selects source tail; completion activates5seconds of one-HP healing after real attack HP loss, globally max once/sec; original red aura, no instant heal |
| Skill targets | Native Attack-layer/Enemies hurtbox filter; sensors/boss weapons cannot route room-wide damage |
| Death | Original 65-tick/30Hz falling/prone animation and ghost (ticks 8..31), fixed death anchor/facing; native death/save/Geo/shade/respawn progression retained |
| Other | Native forward spell; other prepared skill mechanics/fist switching remain unimplemented |

Replacement spells charge current native MP Cost exactly once, including Spell
Twister. Fire Demon has no native Scream damage stacking; Storm has no extra
immunity. Fire Eye retains native completion/cancel/Soul timing, preserves heal
cooldown on refresh, and clears on death/scene/detach. Casting graphics use the final0.7s before the actual native drain deadline.
Quick/Deep Focus and Unn follow the selected native rate. Source speed stays30Hz;
shorter charges select the source tail. Native completion/cancel wins immediately.

Full fresh Windows export: 58 Python checks passed, one additional Windows
symlink privilege skip; 49 actual production C# checks and warnings-as-errors
Release passed. All 35 package/installed files, exact file closure and ZIP
bytes verified. All 491 preexisting asset hashes and all 33 packaged character
resources are unchanged; all 991 previous ticks at both sizes remain identical.
Fresh original death bundle downloaded and archived separately; every original
and offline 1.5x death frame matches its source. Both-facing death/ghost previews,
native death FSM/coroutines and compiled protection/presentation IL reviewed.
Actual client acceptance remains pending.

Package: artifacts/WukongKnight-0.6.3-dev.zip.
Package SHA-256: ddb01403b43971936a9cc65fc72812a2a935b90c2712295fc7cf78e0f69c76b1.
DLL SHA-256: 2fbc6cddf3afedf5ace4c734298af061f7e4949e71be4cbe0675a4a4c1d8ac23 (83968bytes).
Installed at 2026-10-24T17:41:29.941723+08:00 into the authorized
WukongKnight Mod directory, with the game stopped and a complete previous-Mod
backup: installed-WukongKnight-before-0.6.3-20261024-174128.zip. No API/save files modified.

Pending gameplay: horizontal/downward dash immunity and end/cancel release; ordinary/dream deaths, both facings, ghost placement, survivable hazards and native death recovery; Dashmaster downward flames in both facings, end-aligned casting with focus charms/Unn and interruptions; original arc pacing/position in both facings, up/down poses,
Quick Slash, native down pogo/damage/charms, interruption and visibility restore;
all prior spell/focus/dash and scene/death/disable checks. See docs/NAIL_VISUALS.md,
docs/SPELL_LAYOUT.md, docs/DEATH_PRESENTATION.md and docs/CLIENT_ACCEPTANCE.md.
