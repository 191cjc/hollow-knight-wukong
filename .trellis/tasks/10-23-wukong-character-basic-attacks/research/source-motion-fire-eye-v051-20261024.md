# Source movement and Jiyuan Fire Eye corrections (2026-10-24)

## Scope and causes

The user reports that Fire Demon's final position should not be the starting
location, and that Fire Eye has no effect. They clarify its original name as
汲元火眼 and authorize proceeding with recommended choices without questions.
The0.5.0 motion hold removed the original skill's independent forward motion;
FireEye only displayed body effect4 and never loaded original buff art.

## Original movement evidence

skills.xml1101050 has shootFrame5, shootSpeedX50, shootSpeedY0. PlayerEntity.shoot
sets signed body velocity directly. BattleMap constructs Physics with the default
step0.1; each source30Hz tick advances that physics step. WKEntity spawns the
fixed air effect at177facing,-95 and creates the final effect at this.position
when the31-tick air effect expires, stopping horizontal velocity. The resulting
continuous world travel is5 source pixels/tick over ticks5..36,155px unobstructed.
The later move/gravity controls at source frame38 hold the final pose. targetMove
is enemy knockback, not player displacement. No target-seeking teleport is used.
Additional original AS3 is preserved under reference/flash/fire-demon/as3.

Runtime keeps native input denial/zero uncontrolled velocity/no gravity and
separately consumes authored horizontal motion once per source-time interval.
The actual unchanged hero body casts against its native collision mask with
triggers excluded; blocking normals clamp distance. A saturated32-result buffer
rejects the step. Blocked distance is discarded. Air effect is fixed at cast
origin; final art/damage are registered at the moved hero root. Full-cast immunity,
spell balance, local hurtbox filtering and source blink/body frames remain.

## Original Fire Eye artwork evidence

Original skill1101040 is named汲元火眼. Its myBuff810001 resolves to buff81000101,
resources17 and810001/1.swf symbol ef (sprite11). Five lossless2 92x170 bitmaps are
held twice each in a10-frame loop, with source registration(-51.35,-150.4).
The child SWF24Hz header does not change a loaded MovieClip's parent-stage30Hz
clock. BuffEffectEntity creates a loop for timed buffs; PlayerEntity adds it to
its front display layer and mirrors it with the hero direction. Source XML,
readable AS3, archive hashes and independent JPEXS image hashes are preserved in
reference/flash/fire-eye. Original10-second source stats do not replace the
user's requested five-second healing adaptation.

fire_eye_assets decodes original premultiplied ARGB with exact integer unpremultiply
and reads only this verified shape/timeline subset. It rejects unsupported shapes.
The new fireEyeAura loop shares the source sprite root/facing, is composited by a
separate renderer after successful focus completion, and follows existing buff
expiry/refresh/death/scene/detach. The shared view material and child object clean
up with the presenter. Healing is still1HP on actual attack damage, globally at
most once/sec for5 scaledseconds, with no immediate heal or cooldown reset.

## Validation and limits

New unscaled/1.5x art folders: wukong-spells-v051-original and
variants/wukong-spells-v051-1p5.29clips,748ticks,22pages. All738 prior frames compare
byte-for-byte equal to0.5.0.134 earlier baseline assets and252 preexisting assets
including0.5 bakes were verified unchanged.

Fresh exporter:46 Python cases,45passed/one Windows symlink privilege skip;
41actual production C# checks; Release warnings-as-errors passed. Independent
JPEXS exports match all five decoded bitmap hashes. Source-chain/timeline/bake
regressions and visual-clock/source-travel checks passed. Actual active atlas
composites were reviewed in both facings, including moving/attacking aura and
Fire Demon preparation/air/final positions. Preview images are source composites,
not gameplay screenshots. No client execution was performed.

## Export and installed evidence

Version: 0.5.1-dev
ZIP SHA256: fd70a08e8dfa8aa67e07679f1f88a2839cb43f01293e56105a0f5820a309db8f
DLL SHA256: d325708ba16679d11459e753d30969d540c3ff586d796188c8fe75fe05318e3e (75264bytes)
Installed: 2026-10-24T14:57:45.385057+08:00
Path: `D:\SteamLibrary\steamapps\common\Hollow Knight\hollow_knight_Data\Managed\Mods\WukongKnight`
Complete old-Mod backup: `C:\Users\19122\Documents\Codex\2026-10-23\qin\work\backups\installed-WukongKnight-before-0.5.1-20261024-145744.zip`
All25installed files match the package, game stopped, no API/save modifications.
Gameplay acceptance remains pending (source travel near walls/slopes/platforms,
held/reversed input, midair finish, immunity, visible aura/expiry/healing, charms,
pause and cleanup). Parent task remains in_progress; current changes are local.
