# Fire Demon Slash implementation / balance checkpoint

The user authorized choosing sensible fixed spell damage and installing future
updates directly into the existing D: Steam WukongKnight Mod folder.

Implemented 0.4.0-dev: independent original-source rectangle contacts, 100ms
per-target interval/cap 11, once-per-target finisher, fixed damage by native spell
tier, Shaman Stone ceil(x1.5), no nail scaling. Damage pairs: 2/14, 3/22, 3/21 and
5/33, theoretical full-contact totals 36/55/54/88. Native enemy protection still
applies. Native movement/input/Soul are retained; original Quake damage sources
are blocked. This supersedes the earlier native-damage draft.

Source effect masks are preserved at original pixel size; the separate body and
world-effect art is generated offline 1.5x into new variant folders. Added source
sampler coverage, linked actual production spell ledger into core checks, and
reviewed an actual atlas-derived contact sheet. Explicit adaptation: landing
triggers the finisher, whereas original AS3 uses air-effect deletion.

Inspection of the installed game proved Quake can damage through PlayMaker
TakeDamage -> HitTaker.Hit, not merely DamageEnemies. NativeSpellV77 therefore
disables scoped quake colliders/renderers and retains their source identities;
runtime HitTaker and HealthManager guards reject those sources as well. Animation
completion fields use a real ignored FsmEvent so an old tk2d callback cannot survive
a null assignment. Partial constructor cleanup and held-state disposal were reviewed.

Verification: 36 Python passed, 1 symlink privilege skip; 18 linked C# production
core checks; Release warnings-as-errors; package closure/ZIP bytes; installed
24-file closure and hashes. Atlas 27 clips / 722 ticks / 21 pages, 861x497 canvas,
root (391.5,342), nominal body height 101, feet offset 9. Gameplay remains pending.

ZIP SHA256: `95b21174b44c17cb84d9c13a4f421f33fef95ddb1ed94a0f0d18b31a17a122a9`.
DLL SHA256: `17184349cce4fee192ed34a89802bba3ae7ff82685753ce915b54cf0e5a213ca`.
Installed 2026-10-24 00:11:51 +08:00 while the game was stopped. Previous Mod backup:
enclosing `work/backups/installed-WukongKnight-before-0.4.0-20261024-001151.zip`.
API/save files were not modified. No .git directory exists in this downloaded
checkout, so no commit was created. Existing task status remains in_progress;
client acceptance is not inferred from automated checks.
