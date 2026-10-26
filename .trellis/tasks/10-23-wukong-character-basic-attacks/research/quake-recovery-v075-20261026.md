# 0.7.5 original down-spell recovery protection

The original down spell has a recovery window. Installed resources.assets
HeroController19582 serializes INVUL_TIME_QUAKE=0.400000006s; adjacent native
INVUL_TIME=1.3s/INVUL_TIME_STAL=1.75s validate the configuration prefix. Only the
stable header/early public configuration prefix was decoded; API-added suffix
fields do not affect this evidence. Spell Control20204 Quake Finish calls
QuakeInvuln; Quake Antic calls CancelParryInvuln.

Actual installed QuakeInvuln IL assigns INVUL_TIME_QUAKE to parryInvulnTimer.
HeroController.Update subtracts Time.deltaTime, and TakeDamage checks the timer
for ordinary hazardType1. This is distinct from saved isInvincible or the native
post-damage coroutine. Native spike/acid/hazard and direct-HP rules remain; no
custom blanket post-action TakeDamage/TakeHealth guard is appropriate. Reuse the
real native method and its live configured duration, not a duplicated0.4constant.

## Implementation and boundary review

FireDemonSlash's source Complete branch first cancels hit/render ownership, finishes
native Spell End and refreshes state. If the adapter/hero is still live/nonrecoiling,
call QuakeInvuln once. The existing early cancellation condition is only factored
into CanRecover without changing its checks. Failed payment, foreign-state changes,
normal cancellation, death/hazard/scene and Dispose do not call the method.

FistSkills.Observe passes completed:true only from its natural ActionFinished
branch after native Dream ownership/recoil checks. Stop snapshots whether this is
the player Earthbreaker with confirmed landedAt before invalidating action/token
and finishing Dream recovery. After live/nonrecoiling/disposed rechecks it calls
QuakeInvuln once. All other Stop callers pass false. Unlanded bottomless timeout,
Godslayer, ghost completion, CancelAll and Dispose cannot grant the timer. Stopped
ownership makes repeated observations idempotent. No new timer polling/refresher,
core state model, motion change or saved invincibility was introduced. Existing
whole-action protection remains continuous into native recovery during ordinary
enemy damage; the native recovery tail retains original hazard rules.

Actual Release IL reviewed: Fire Demon call follows Clock.Complete, Cancel,
FinishCast and liveness gates; Cancel/Dispose contain no grant. Fist Stop gates
completed, Earthbreaker and landedAt before clearing action/token, then Dream
Finish and live checks before grant. Its three Observe Stop call sites pass false,
false and true respectively; CancelAll/Dispose pass false. Neither ghost nor
detached-summon paths call QuakeInvuln. Evidence is recorded in
reference/flash/fist/quake-recovery-v075.json.

## Verified delivery and remaining acceptance

Fresh full export:66Python passed/one Windows symlink-privilege skip;74actual linked
production C# core checks; warnings-as-errors Release; package closure and ZIP-byte
checks passed. All17character resources match the0.7.4snapshot byte-for-byte;
59clips/1559ticks/16pages reused.19exported/installed files verified. No tests were
added that merely duplicate the two completion guards; actual native and compiled
integration boundaries were inspected alongside the existing core regressions.

Installed 2026-10-26T21:27:17.336268+08:00 with game-stopped checks before backup
and copies. Complete validated previous0.7.4backup:
installed-WukongKnight-before-0.7.5-20261026-212714.zip
Backup SHA256: 289a269aa8f47c3561681e987360637574c4d8883974db438ef4fd93fcd416be.
The installer verifies package/source/artwork hashes before mutation and restores
every prior Mod file if copy/installed verification fails. No API/save changes.
DLL SHA256: 22d5815734409e60f807408f391f40fb3224b9c3881bd8ef784538c661388b25 (113664bytes).
ZIP SHA256: 4aa3c475eab814ad9c99476895285cd24d3aa36cd9169a6789c129c711ef21ef.

User game-client testing must verify continuous cast-to-recovery ordinary damage
protection, roughly0.4s recovery expiry, free movement/attacks, native hazards,
keyboard/controller, repeated/paused observers, cancellation/timeout/copies and
all prior skills. runtime_tested=false; task in_progress. No new commit/push.
