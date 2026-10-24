# Original Wukong nail presentation0.6.0 (2026-10-24)

## Result and boundary

Original ground4-stage and air arcs replace native mesh drawing. Up uses original
effect1 body/arc; down rotates only that arc180 about fixed source(0,-44.5),
keeping an upright jumpAttack body retimed10/15. Native nail damage, charms,
reach, Soul, polygons, clashes and pogo still run. Native attack_time/duration
drive noncombo action progress; combo uses its existing shared source clock.

Only actual hero normal/alternate/up/down/wall mesh forceRenderingOff flags are
captured/suppressed and restored on failure/dispose. Native enabled writes,
animation, damage transactions/FSMs and projectiles remain untouched. There are
no new combat hooks or hitboxes. CharacterAssets requires all7new composites.

## Source and asset evidence

See nail-source-v06-evidence.json for archived input hashes. Original Entity
attaches same-named skill1 overlays above the body at(0,0) with common timing.
The bounded single-bone reader now also serves existing flame extraction; hidden
displayIndex=-1 is explicitly empty. Nail overlays draw above body; previous
Dash/Storm layering is preserved. New v06 profile/folders preserve earlier art.

Scripts/prepare-all-assets.bat is the reusable generation entry point. The
original source/earlier enlarged folders remain intact; an intermediate v06
variant is also preserved. The active final variant is
assets/processed/variants/wukong-nails-v060-1p5. A source fingerprint refresh
correctly rejected reuse of the intermediate resized folder; generation chose
a new destination rather than overwriting it.

## Validation

- All322previous asset hashes unchanged.
- All769previous ticks in each size byte-identical in registered canvas space;
  combat, canvas, root and body calibration also unchanged.
- Original image/hidden schedules and body-above/below layering checked.
- Down transform verified on multiple points for all15ticks; body never rotated.
- All105new original/enlarged atlas frames match actual source sampling and
  offline premultiplied1.5x resizing;37clips/874ticks/28pages total.
- Both-facing actual exported preview reviewed without clipped preview margins.
- Fresh build:53Python passed, one Windows symlink privilege skip;45actual linked
  production C# checks; net472 Release warnings-as-errors passed against locked API.
- Native IL confirms attack_time advances by scaled deltaTime and resets on
  attackDuration; duration selects native Quick Slash value. StartSlash continues
  enabled/polygon/animation behavior while mesh draw submissions are suppressed.
- Exact package/ZIP/installed closure and hashes verified for31files.

## Installed artifact

Package SHA-256: 025cd4e38334e7844a2bc5fc39589d8c874ec308a634d6645cb6025469b6dd8c
DLL SHA-256: 5d0ec8b0423f4ba543a0c1b5e332aa383fcbc9215604c1f8fe2302b860108cb0 (77312bytes)
Installed: 2026-10-24T16:26:01.371379+08:00
Complete prior-Mod backup: C:\Users\19122\Documents\Codex\2026-10-23\qin\work\backups\installed-WukongKnight-before-0.6.0-20261024-162600.zip
Game was stopped. No API/save files modified. Actual gameplay remains pending;
task stays in_progress. See docs/CLIENT_ACCEPTANCE.md. Prior local changes remain
uncommitted for review; no remote publication.
