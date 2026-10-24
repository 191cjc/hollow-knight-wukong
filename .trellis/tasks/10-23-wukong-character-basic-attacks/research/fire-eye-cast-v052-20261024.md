# Missing Jiyuan Fire Eye casting overlay (0.5.2)

The user distinguishes the during-cast winding flames from the after-cast ef
aura introduced in0.5.1. The missing source is the already archived independent
skill1V472/effect4, not buff80014 (which has no graphical resource).

Source evidence: reference/flash/fire-eye/casting/evidence.json fingerprints
the original packed SWF, decoded skeleton/atlas, main SWF and decompiled Entity.
ManResourceManager.buildSkillByDragon registers every skill armature in
actionSkillFactory at unit scale for Wukong. Entity.onUpdateAnimationAfter2
attaches the same-named skill armature above the body, with the same action
clock; onSkillArmaAdd sets its relative root to(0,0). This was absent from the
previous body-only focus presentation.

The local3.0 overlay has four independent bones and21 ticks. Seven winding-flame
images each last two ticks at[0,14). At14, three slots reveal two nested armature
types (seven ticks each): the red buff fragment and two eye flashes. Child
clocks must start at reveal; flattening only the first bone omits the ending.

The new bounded reader preserves local transforms and slot order, and composites
the overlay above body effect4 with one shared root/facing. The17-tick body
holds tick16 during the final four overlay ticks. All21 overlay ticks map to
native drained-Soul progress, retaining native startup/charm timing and cancel.
This is an explicit visual timing conversion: no extra focus duration or post-
cancel tail. Existing effect4 remains unchanged. The independent ef buff aura,
five-second duration and actual-damage healing policy are untouched.

New assets use wukong-staff-spells-v052.json, wukong-spells-v052-original and
variants/wukong-spells-v052-1p5. All previous inputs/bakes are preserved against
work/spells-v052-preserved-assets.json (285files). Active art has30clips,
769ticks and24atlas pages. Actual atlas preview reviewed in both facings.

Fresh Windows export:50 Python cases,49passed, one symbolic-link privilege
skip;41actual production C# checks; warnings-as-errors Release compiled. The
27-file package/ZIP/installed closure and byte equality passed.285preserved
files retain hashes;748previous frames in each of unscaled/1.5x folders are
pixel-identical (1496 comparisons). New21cast frames and1.5x output match real
source sampling; both-facing actual atlas preview reviewed. Parent remains
in_progress because gameplay acceptance has not been performed.

Installed at 2026-10-24T15:37:25.212510+08:00 with game stopped.
Complete previous-Mod backup:
`C:\Users\19122\Documents\Codex\2026-10-23\qin\work\backups\installed-WukongKnight-before-0.5.2-20261024-153724.zip`.
ZIP SHA256: `84ba8f2480f3df47eee34e5f339f8ead8a4364ab6093d023a95c2ecb4a3a630a`.
DLL SHA256: `9ad0bb14f35a5d208dd685faf7569cc0474859908bc510405cef7ead7a7eb29f`.
No API/save changes. See artifacts/build-report.json for exact file hashes.

Review: source root/depth and nested child clock preserved; bake fingerprints
include all new inputs/code; Python optional and C# required clips agree.
Presenter routes only casting to fireEyeCast, clamps completion below duration,
and retains existing cancellation/disposal/visibility/facing behavior. No new
renderer, gameplay timer, collider, damage or healing ownership. Existing buff
aura and previous mechanics remain unchanged. Original source has a shorter
body than overlay; holding the final body pose for four ticks is the documented
timing adaptation used to show the complete overlay inside native focus charge.
Gameplay acceptance remains pending; parent task stays in_progress.
