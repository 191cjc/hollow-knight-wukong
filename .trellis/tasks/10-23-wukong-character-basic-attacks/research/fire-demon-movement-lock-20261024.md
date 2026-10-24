# Fire Demon movement input correction (0.4.4)

## Scope and evidence before implementation

The user reports physical drift when moving during Fire Demon Slash. 0.4.3
extends Quake Antic to 56 source ticks but only observes it after Hero.Update;
it supplies no sustained input/physics lock. The native state performs
RelinquishControl/zero velocity/no gravity once on entry. Native Move consults
acceptingInput, not controlReqlinquished; RelinquishControl returns immediately
when controlReqlinquished is already true. IgnoreInput also resets axes only
when acceptingInput was true. Thus relying on the initial relinquish call does
not establish the full custom-duration invariant at subsequent update boundaries.
This is a verified ownership gap, not a claim to have reproduced the player's
exact event sequence in a running client.

Actual installed 1.5.78.11833/API v77 IL was inspected. Evidence:
`work/fire-demon-movement-native.txt`, `fire-demon-control-callers.txt`,
`fire-demon-movement-failsafe.txt`, and the existing native spell FSM JSON.
PauseInput/UnPauseInput are distinct from the global pause UI; do not disable
InputHandler or skip HeroController.Update/FixedUpdate.

## Narrow plan

1. FireDemonSlash owns a validated native Rigidbody2D reference. While its cast
   is active, use native RelinquishControl + IgnoreInput + ResetInput, retain
   the native no-gravity preparation behavior, and neutralize physical velocity.
   Check completion/cancellation before writing the lock.
2. Observe the cast before Hero.Update reads input, and before/after the native
   Hero.FixedUpdate, independent of WukongLifetime's Unity component order.
   Keep original updates executing once. Unsubscribe the added hook on disposal.
3. Native Quake Finish/Spell End remains the release path. Do not teleport or
   rescale the hero, freeze Rigidbody constraints, change authored moving flashes,
   change contacts/damage/immunity, or enter Quake Down/Land.
4. Bump runtime/package to 0.4.4, update acceptance/spec/build information. Run
   the complete existing production checks, warnings-as-errors compilation,
   compiled native boundary review and package validation. Original artwork must
   remain byte-identical. Back up/install with the game stopped and verify hashes.

Actual movement, pause/resume, repeated casts and recovery need client acceptance.
The active parent task remains in_progress.


## Completed implementation and inline quality review

FireDemonSlash validates/stores the real native Rigidbody2D and maintains the
scoped cast hold only after interruption/completion checks. WukongRuntime now
observes before native Update and on both sides of native FixedUpdate. Native
updates execute once, including ordinary exploration; disposal removes the hook.
The private ResetInput method is resolved by the existing NativeV77 version gate
and invoked through the narrow adapter; direct public access is not supported.
No new artwork or detached input policy was introduced. Source flashes, immunity,
fixed damage, hurtbox filter and airborne finish remain unchanged.

Inline trellis-check and trellis-update-spec review: completion/cleanup ordering,
matching hook signatures against pinned MMHOOK, native/compiled IL call ordering,
failure/partial initialization and subscription symmetry reviewed. Specs and
client checklist now cover held/reversed/released movement, pause/recovery and
scene/detach. Actual Unity input/physics checks remain pending; the existing
engine-free core suite does not prove those client interactions.

Full fresh export passed: 38 Python tests, 1 explicit Windows symlink privilege
skip, 27 checks using production C# core; Release warnings-as-errors passed.
No fake Unity stubs or source-string tests were used. All 22 character resources
are byte-identical to 0.4.3; package/installed 24-file closure and hashes passed.

DLL: 65024 bytes, SHA256 `2e8ac316f2300a8983a9ebae7e35423a27108055f8da3ee87a48a24ef76a5ead`.
ZIP SHA256: `8d541197f5e4886ff093bc4d91e6944e314de809a9a2767401f1fb7943e993ca`.
Installed: 2026-10-24T11:53:27.220567+08:00.
Complete prior-Mod backup: `C:\Users\19122\Documents\Codex\2026-10-23\qin\work\backups\installed-WukongKnight-before-0.4.4-20261024-115326.zip`.
Game was stopped; API/save files were not modified. Task stays in_progress.
