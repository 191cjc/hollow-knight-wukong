# Current status: Wukong, combo, Flame Dash and Fire Demon Slash

Updated 2026-10-24 (Asia/Shanghai). Development version: **0.4.4-dev**.
Baseline: Windows / Hollow Knight 1.5.78.11833 / Modding API v77 / Unity 2020.2.2f1.
Client acceptance remains pending; `runtime_tested=false`.

| Area | Current behavior |
| --- | --- |
| Artwork | Original archived images, original bakes and all earlier variants are preserved; active offline 1.5x artwork remains 27 clips/722 ticks/21 pages |
| Collision | Native hero collider and native nail effects retain their original size; no runtime appearance enlargement |
| Ground combo | Four intentional inputs, one buffered follow-up; third stage has two hit windows, each with native slash effects |
| Flame Dash | Native dash key/movement/unlocks/cooldown/collision; source flame art and once-per-target along-path damage |
| Skill targets | Shared native Attack mask; enemy HealthManager damage requires actual Enemies-layer hurtboxes; no remote damage through sensors/weapons |
| Fire Demon | Source effect5 moving character flashes/blink gaps; original directional air spawn and mask conversion; air expiry triggers midair-capable finisher, no forced dive |
| Fire Demon movement | Native input and physical velocity held throughout the custom cast; checked before input and around native physics; native recovery on completion |
| Fire Demon protection | Scoped full-cast TakeDamage/TakeHealth guards, native recovery and complete cleanup, no save invincibility changes |
| Fire Demon damage | Fixed spell-tier/Shaman values 2/14, 3/22, 3/21, 5/33; 100ms per-target air interval/cap 11 and one finisher; no native Quake damage stacking |
| Other mechanics | Other artwork is prepared; remaining active skills/fist switching are not playable |

0.4.3 supersedes the 0.4.1 centered start, 0.4.2 raised placement and earlier
ground-contact finisher adaptation. The missing moving character was the original
main effect5 layer: normalized/hidden in the earlier runtime. It is now played
directly from existing atlas frames, including genuine invisible gaps. Original
air effect starts at (+177 facing, +95 upward) source pixels at tick 5; expiry at
tick 36 starts the 20-tick finisher. Native Quake Antic is held until tick 56,
then Quake Finish/Spell End recover without entering Down/Land. No extra Quake
start or landing camera shake is added. All prior hurtbox corrections remain.

Use scripts/prepare-all-assets.bat for repeatable asset preparation. This revision
reuses existing original artwork; no asset pixels or variants were overwritten.
See docs/FIRE_DEMON_SLASH.md and docs/CLIENT_ACCEPTANCE.md for contracts/checks.

Windows export uses pinned Python/Pillow and official Roslyn against locked
net472/API references. The build report records exact completed test counts,
package hashes and installation evidence. One symlink test is skipped because
Windows lacks symlink privilege; optional ffmpeg/ffprobe decoding is unavailable.
The Linux SDK/MSBuild build script is not executed by this Windows export.

Routine installation into the authorized D: Steam library Mod directory requires
a stopped game, complete previous-Mod backup and installed closure/hash checks.
Current deliverable: artifacts/WukongKnight-0.4.4-dev.zip. No API/save modification.
Real gameplay must verify both facings, source flashes and airborne finisher,
immunity/control/gravity recovery, actual HP loss, distance filtering and cleanup.


0.4.4 fixes user-reported movement input during Fire Demon: input denial and
neutral axes/velocity persist across the full source timeline. Both native
updates still execute; source flashes and airborne finisher are retained.
See research/fire-demon-movement-lock-20261024.md in the active task.
Current build/installation evidence is recorded in artifacts/build-report.json;
actual client movement and recovery acceptance remains pending.

Latest verification: 38 Python passed / 1 Windows privilege skip, 27 production
C# checks, Release warnings-as-errors; 24 installed files/closure
and hashes passed, 22 unchanged character resources. Installed
2026-10-24T11:53:27.220567+08:00 with complete previous-Mod backup.
