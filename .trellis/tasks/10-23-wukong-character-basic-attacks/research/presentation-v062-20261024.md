# Dash direction and end-aligned Fire Eye0.6.2 (2026-10-24)

## Native evidence

HeroDash sets private dashingDown=true only for native permitted downward dash
(Dashmaster31, airborne, down and no horizontal input); native velocity/collision
and current swept Flame Dash damage already use that real direction. NativeV77
validates/reads the bool through FlameDash.Downward. Presenter chooses new
flameDashDown using the same native DashProgress/visibility path. No movement,
damage, cooldown, collision, immunity or input policy changes.

HeroController.orig_StartMPDrain sets drainMP=true, timer/drained0, interval from
the actual selected FSM rate and amount from focusMP_amount (then API hooks).
orig_Update increments timer with scaled deltaTime, takes individual Soul while
subtracting interval from timer, and completes when MP_drained==focusMP_amount.
Thus remaining=(amount-drained)*interval-timer is continuous seconds, including
the sub-Soul remainder, without discretely stepping animation frames.

NativeSpellV77 reads/validates these five fields only for focus. At first actual
drain observation, FireEyeCastClock captures scaledTime+remaining once, after
native charm selection. Tick=(scaledTime-deadline)*30+21; negative/unscheduled
means effect4 opening body only, no casting overlay. The original21/30s layers
end at native completion; short charges select the tail without changing speed.
Repeated observations cannot restart it; pause freezes scaled time. Native
completion/cancel/death/scene/detach still wins without an art tail. Native
AddHealth/buff activation/finish logic, five-second ef aura and heal policy stay
unchanged. No fixed normal/charm duration table or extra drain/Soul writes.

## Artwork preservation

New profile wukong-staff-presentation-v062.json adds flame_dash_down_center_pixels
[0,-44.5]. flame_dash_down_samples reuses effect2 source ticks4..15 and rotates
ONLY flame_dash_fx Draws clockwise90 in Y-down source space:
matrix[0,1,-1,0,-44.5,-44.5]. Source body/order/timing stay exact; view/root/aura/
nail transforms unchanged. Runtime flipX keeps the vertical travel axis for
either facing. New v062 original and offline1.5x folders preserve all442older
source/processed files and all979old frames per size, plus combat/canvas/pivot/
calibration.45clips/991ticks/32pages;12new source frames and offline1.5x pixels
checked, both-facing actual atlas preview reviewed.

## Checks and installation

Fresh56Python checks passed, one Windows symlink privilege skip;46production
C# checks and warnings-as-errors net472 Release passed. Production deadline
tests cover startup/window/end, native normal/quick/deep/short rates, repeated
observers, pause, cancel/recast/invalid input, clear and early native completion.
Native original/drain and compiled Mod IL reviewed; hashes retained in report.
All35package/installed files, exact closure and ZIP bytes verified.

Version:0.6.2-dev; DLL79872bytes.
DLL SHA-256:1f047bf6a8198d6a2683b82afc2bfa369857e7464df9eb05d40ff54feb3f33b6
ZIP SHA-256:d526b746f05272fab6d9cd766928a97c568b8ee759c0d8827647a49186624df2
Installed:2026-10-24T17:12:58.115199+08:00
Full previous-Mod backup:C:\Users\19122\Documents\Codex\2026-10-23\qin\work\backups\installed-WukongKnight-before-0.6.2-20261024-171256.zip
Game stopped; no API/save changes. Gameplay acceptance remains pending for both
dash facings, alternating directions/cancel, native focus/Quick/Deep/Unn timing,
pause/interruption and prior mechanics. Task remains in_progress; changes remain
local/uncommitted and no remote publication occurred.
