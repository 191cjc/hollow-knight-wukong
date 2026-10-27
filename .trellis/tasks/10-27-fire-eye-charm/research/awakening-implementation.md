# Awakening charm implementation

Increment after checkpoint `23852f3`, branch `feat/fire-eye-charm`.

## Product scope

- Charm34 is **汲元火眼·觉醒 / Jiyuan Fire Eye: Awakening**. Its existing
  two-notch cost, native acquisition/save identity, generated icon and activation
  snapshot (3seconds base /6seconds equipped) are retained.
- Charm31 is **烈焰闪·觉醒 / Flame Dash: Awakening**. The adapter changes its
  native UI text and adds airborne up-only dash. Native2notches, icon, collection,
  saved equipment, downward dash, cooldown, Sprintmaster and Sharp Shadow bonuses
  retain their original paths.
- Upward shares native aerial allowance. A separate unsaved guard allows one
  successful upward use until physical landing; rejected starts, pogo, walls,
  wall jump, generic ResetAirMoves, damage and charm toggles never replenish it.

## Native transaction

`NativeDashV77` validates the three CanDash and two HeroDash callsites in the
pinned native LookForQueueInput. It filters only that input path and leaves
every native CanDash / OnDashPressed / callvirt HeroDash in place. A marker just
before the actual call is consumed before native startup; a LookForQueueInput
try/finally clears it even if another hook swallows or throws. Direct scripted
HeroDash has no marker and retains native direction. Only a forbidden repeated
up chord clears its native dashQueuing flag at the end of this input pass; first
upward attempts retain native cooldown/eligibility buffering.

Runtime snapshots adapter/damage-owner identities and a Core token before native
callbacks, closes the old damage ledger, and calls original HeroDash exactly once.
It commits only after the same live hero/adapter/token and actual dashing survive.
Passive observation during startup does not revoke the pending token before
native HeroDash sets dashing. Explicit CancelDash, terminal cleanup or a newer
start do revoke it. Original HeroDash sets the common airDashed allowance itself.

The unique OrigDashVector result is redirected to `(0,abs(native.x))` before the
existing ModHooks.DashVelocityChange chain. Normal/Sharp Shadow speed is already
selected by native code. A method-local token survives reentrant vector hooks;
the exact post-ModHooks output is recorded only for the still-owned upward dash.
ILHooks use ManualApply and retained disposal handles before Apply. No fabricated
OrigDashVector endpoint, input/down-state spoof, native timer/cooldown/air-charge
reset, save flag, invincibility or collider/constraint change is introduced.

The landing IL hook keeps the native layer8/HeroWalkable bottom-contact branch
and its SteepSlope/state gates. It confirms only the exact native BackOnGround,
DoHardLanding or downward-dash SetState landing calls, with a token captured
before each native callback and current accepted landing state checked afterward.
No old contact is remembered. A real accepted landing replenishes the guard even
while the owned dash is still active, without releasing its direction. Passive
grounded state separately requires the native terrain-only CheckTouchingGround
ray. Generic BackOnGround timeout calls alone cannot replenish upward use.

At normal expired FinishedDashing, the Core policy releases direction and clears
positive Y only if the same token still owns the exact last post-hook velocity.
The write occurs before original CancelDash/DashEnd callbacks, with no write after
orig. Jump/double jump/wall jump/bounce/recoil revoke momentum cleanup; changed or
collision-limited output, cancellation and terminal state retain newer motion.
Native JumpReleased and ceiling collision behavior remain active.

FlameDash reuses its existing native-size swept query, one-hit responder ledger,
Sharp Shadow source suppression and actual-active HP guards. Its Upward property
selects only the current latched owned direction. Rendering follows the same
native dash progress and keeps the hero body/root/aura upright.
Sharp Shadow restoration ownership is saved before SetActive, and Stop detaches
old hit/render/restore state before restoration callbacks can begin a new dash.
Dispose marks the old owner first, preventing synchronous callback reactivation.

## Artwork and preview

`flame_dash_up_samples` rotates only flame Draws counterclockwise90degrees about
source(0,-44.5): `(x,y) -> (y+44.5,-x-44.5)`. Source body Draws,12ticks and order
remain exact. The new opt-in v078 profile generates separate original/full1.5x/
packed folders. Active metrics:60clips/1571ticks/16packed pages. Original canvas
709x566, root(261,392), nominal height101 and combat settings remain unchanged.

Focused production-sampler regressions passed: all1559old ticks retain exact
pixels at both sizes, and all12upward frames match direct source composition,
premultiplied bicubic enlargement and packed reconstruction. The main session
reviewed the six-sample comparison in both facings. Every old asset file and the
rollback ZIP are covered by its pre-increment SHA256 snapshot.

The preserved generated source is `output/imagegen/fire-eye-sigil-v1.png`.
Offline preparation changed only the preview title. Final icon SHA256 remains
`8d397a5d5e9138e4f6a3030fd1cf1db4e358bfe6d920d0d17cac427f745573d5`.
Preview SHA256 is
`2e651cf925fe057db370370b8b461669ce3ef0960dcca0a926ea088dd0935d20`.
The main session verified public HTTP200 PNG responses and matching local bytes:

- Preview: https://litter.catbox.moe/3gm8ze.png
- Transparent PNG: https://litter.catbox.moe/4dfkjd.png

The host retains these for72hours, approximately until2026-10-30 17:28 in
Asia/Shanghai. Public evidence is in `awakening-public-preview.json`.

## Verification and remaining acceptance

`bash scripts/build.sh --no-incremental` passed70Python tests (313.246seconds),
91production-linked Core checks and pinned-reference Release with0warnings and
0errors. It validated source inventory, active manifests/atlases and the exact
19-file package/ZIP closure. The old complete-character expectation was updated
from59to60clips for the added upward clip; its focused two-test suite passed too.

Independent review corrected HeroWalkable/active-contact landing and synchronous
Sharp Shadow restoration before that gate. It subsequently confirmed MonoMod
wraps branch operands in ILLabel during ILContext.Invoke; the native landing
matcher now accepts both ILLabel.Target and raw Instruction. Only that native
matcher changed after the full gate. The final no-incremental pinned Release and
package closure were repeated successfully, with evidence appended to
`awakening-build.log`; Python/Core source and tested artwork were unchanged.

Final package: `artifacts/WukongKnight-0.7.8-dev.zip`.
ZIP SHA256: `8d83d0e8ec79c253549677a53b99bcd9114a2c491a07d6cfb81c67a7a63ffd6a`.
DLL SHA256: `11c2e94339e4721ab0f5d12ddab4dc306260d52ca1a23944505685234c03cf54`
(211968bytes). The main session owns final independent ZIP/resource/preserved-file
audit and records its results separately.

The three unrelated build-discovery outputs (audio.json, inventory.json and
ASSET_INDEX.md) were restored from their exact pre-gate private snapshots. No
pre-existing or other agent edits were reverted.

No game client or Windows Steam mount is available in this Linux environment.
No installation or gameplay test was performed for this increment. The user
explicitly authorized committing all workspace contents and pushing the current
branch to origin; the main session owns that final operation after validation.
Native serialized UI, keyboard/controller input, cooldown/shared
allowance/landing, ceilings/corners/platforms, Sharp Shadow interactions, focus
charms/overcharm and disable/re-enable still require actual-client acceptance.
Compilation and offline source/pixel checks do not establish those outcomes.
