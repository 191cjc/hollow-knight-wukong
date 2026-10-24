# Current status: Wukong character, nail arcs and spells

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
