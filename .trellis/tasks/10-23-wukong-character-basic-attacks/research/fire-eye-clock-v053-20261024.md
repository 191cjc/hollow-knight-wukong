# Jiyuan casting pace correction (0.5.3)

User feedback: the opening frames look slowed after adding the winding effect.
The source body has17ticks and independent overlay21ticks, both at30Hz. Their
duration mismatch requires only a final body hold; it does not itself slow early
frames. The actual0.5.2 runtime fed Progress*21 into the combined clip, forced
Progress=0 during Focus Start/Start Slug Anim, then sampled private MP_drained
divided by focusMP_amount. Native orig_Update increments MP_drained by1 per
drainMP_time interval; this is a discrete spending clock. It introduces startup
freeze and stretches source holds over native charge/charm duration.

Evidence: original source attachment timeScale and frameRate are retained in
reference/flash/fire-eye/casting/. Native orig_StartMPDrain and orig_Update IL
are recorded in work/spells-v05-focus-control.txt and work/native-control-il.txt.

Fix: add the real production FireEyeCastClock, observed by BloodthirstyFireEye
through its existing native lifecycle hooks. Start at first ordinary-focus
entry including startup; shared scaled Time.time advances both source layers
at30Hz. Repeated observers never restart. At tick21/0.7seconds remove completed
overlay and keep original body final pose until native charge completion.
Native completion/cancel remains authoritative and may terminate graphics
earlier; do not hold a fast cast or activate the buff from animation time.
Pause, cancellation, new charge, death, scene and disposal retain proper clock
lifecycle. The five-second independent ef aura and actual-damage healing policy
remain tied solely to native successful completion.

The obsolete NativeV77 MP-progress fields/method and unused constructor
dependency are removed. Reuse every v052 original/1.5x asset unchanged; this
revision changes runtime timing only, not pixels, scale, colliders or damage.
Production-core regressions cover startup pace, repeated/sparse observations,
long charge, pause and cancel/rehold/cleanup. Final export/install results below.


## Validation and installation

Fresh Windows export passed49Python cases (one additional Windows symbolic-link
privilege skip),45actual production C# checks and warnings-as-errors Release.
All27package files/ZIP bytes and installed file hashes match.322preserved assets
retain hashes;25character manifest/atlas files are byte-identical to0.5.2.
Installed with game stopped at2026-10-24T15:55:48.303970+08:00.
Previous complete-Mod backup: `C:\Users\19122\Documents\Codex\2026-10-23\qin\work\backups\installed-WukongKnight-before-0.5.3-20261024-155547.zip`.
ZIP SHA256: `b25c3485e29f8e1942b257faa24bd6a9bb3014271b0dbd8d206d11958ac05158`.
DLL SHA256: `58d40a2c099e115c29d49a298c2d45b59b9646d24ae0e607a32264b7e5c29a7d`.

Review confirmed no art/data/profile edits; both source layers use the same
cast-owned30Hz clock, independent of presenter clip changes or Soul increments.
Repeated hooks do not restart it. Clear paths cover cancel/inactive/death/scene/
detach; native finish and successful-heal interception remain unchanged. The
presenter removes the completed overlay rather than holding its last red image.
Both normal and long charge use one source pace; a fast native finish can end
the visual early. Native Quick/Deep Focus/Unn/startup and in-client pace remain
pending acceptance. Parent stays in_progress; no API/save modifications.
