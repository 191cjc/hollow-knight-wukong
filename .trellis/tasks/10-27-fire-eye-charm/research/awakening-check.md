# Independent awakening increment check

Reviewed the complete increment after `23852f3` on 2026-10-27. The reviewer
loaded check.jsonl, PRD/design/implementation plan, the real pinned-v77 research,
and the owning native-combat/character-assets contracts. No recursive delegation,
fake engine types, commits or pushes were used.

## Findings (fixed)

1. **Native landing outside layer8 did not restore upward use.**
   `CheckTouchingGround()` uses three layer8-only rays. Native
   `OnCollisionEnter2D` also accepts `HeroWalkable` on other layers, so its actual
   landing could leave the extra upward allowance exhausted. Merely treating all
   bottom collisions as landing would bypass native `SteepSlope`/state gates;
   waiting for another observation also lost contact while an up dash was active.

   The adapter now validates and observes the existing bottom branch's three
   accepted actions: `DoHardLanding` (IL_0166), `BackOnGround` (IL_018a), and the
   downward-dash `SetState(6)` (IL_01ad). Existing native direction, layer/tag,
   hard-landing, slope and state branches execute unchanged. A local token is
   captured before each call; after it returns, only the same current owner/token
   with actual grounded/hard_landing/dash_landing state confirms the contact.
   `UpwardDashPolicy.ConfirmLanding` preserves current direction but restores its
   extra use even before the dash clock ends. It remembers no collision object
   or contact for replay after takeoff. Passive grounded/ray observation still
   requires an inactive upward action and never treats a timeout alone as floor.

   The new production-linked Core regression covers native rejection, confirmed
   contact during an active dash, preservation through completion, rejection of
   a previous contact token and no stale contact replenishment after takeoff.
   Source evidence: `upward-dash-hero-il.txt`, methods CheckTouchingGround and
   OnCollisionEnter2D; no game execution is implied.

2. **Sharp Shadow restoration could lose state during synchronous callbacks.**
   `FlameDash.Begin` originally saved the suppression result only after
   `SetActive(false)`. A synchronous detach in that call could clean up while
   the restore bit was still false, leaving native damage suppressed. `Stop`
   also restored the native object before detaching its dictionaries/restore
   bit, allowing an old cleanup to clear suppression acquired by a new dash.

   `NativeV77.SuspendSharpShadow` now writes the owning restore bit through a
   reference before `SetActive`. `Stop` invalidates hits, detaches/reset its
   restore bit and renderer map, restores its old renderer flags, then makes
   the native SetActive call last. `Dispose` marks the old instance disposed
   before that cleanup and destroys its source in finally. The existing Begin
   token check rejects a replaced transaction without overwriting newer state.
   This ordering was reviewed directly and compiled against the real references;
   Unity callback execution remains in the client matrix.

## Findings (not fixed)

No remaining confirmed source defect or unresolved product decision was found
in the reviewed increment. Actual-client acceptance remains outstanding; this is
a validation limit, not a claim of gameplay success. The main session owns final
spec/task/status evidence and the final package/public-image audit.

## Review coverage

- Input: exactly three native CanDash checks and two actual virtual HeroDash
  input/queue calls remain. The added filter can only narrow native approval.
  The arm is consumed before callbacks and cleared by LookForQueueInput finally;
  direct scripted starts are not marked. Pending startup survives passive
  observation, while explicit CancelDash invalidates its pending direction.
- Native vector: the unique OrigDashVector result is transformed before the
  existing ModHooks chain; selected normal/Sharp speed, timer, native callbacks
  and collider remain. A local token guards the result recorded after ModHooks.
  Only proven unchanged positive Y is removed before successful native finish;
  newer jump/bounce/recoil and cancellation preserve their motion.
- Allowance: no writes to airDashed, direction input, dashingDown, equipment,
  acquisition, cost31, collider, cooldown or saved invincibility. Pogo/walls
  keep native common-charge recovery but cannot refresh the extra upward guard.
  Both native landing paths and passive terrain grounding retain token ownership.
- Lifecycle: ManualApply handles are retained before Apply. Every installed
  native/localization hook is removed on failure/disposal; runtime attachment
  rechecks the current adapter/FlameDash after synchronous native starts.
  Damage, Sharp Shadow deduplication and full-active-dash HP protection still use
  the existing once-per-responder transaction in all directions.
- Fire Eye: charm34's functional source is unchanged from the previously checked
  checkpoint apart from its exact display name and an internal comment. Its
  real equipment snapshot, 3/6s expiry, native34 acquisition/save identity,
  2-notch accounting, scoped Deep Focus suppression and icon lifecycle remain.
  Charm31's exact UI name/description adds its ability without an icon/cost hook.
- Artwork: the opt-in v078 profile, optional/required clip lists, presenter
  direction and native clock agree. The upward affine affects flames only;
  active folders are separate original/full1.5x/packed variants. The reviewed
  directional sheet shows vertical up flames for both facings. Source/pixel
  regression tests compare every old1559tick at both sizes and new up frames,
  including packed reconstruction. Earlier assets and the generated icon remain
  preserved; main independently audits its360-file preservation snapshot.
- Product/version: runtime, csproj, package tool and current docs identify
  0.7.8-dev, 60clips/1571ticks/16packed pages. New native31 functionality is
  accurately separate from unchanged3/6s34 behavior. The raw/icon paths and
  embedded WukongKnight.FireEyeSigil.png identity stay stable despite the rename.
  No platform templates/configuration changed.

## Verification

- Whitespace/lint: `git -c core.whitespace=cr-at-eol diff --check` passed after
  the review fixes. The repository has no separate lint command in its build gate.
- Type/compile: real pinned-v77 net472 Release build with `--no-incremental`
  and TreatWarningsAsErrors passed, **0 warnings / 0 errors**.
- Focused tests: **91 production-linked Core checks passed**, including the
  new active-contact/stale-token landing regression and existing Fire Eye tests.
- Full gate: the implement agent owns the single final `bash scripts/build.sh`
  run after these fixes; its final result will be recorded below before signoff.
- Runtime: no actual Hollow Knight client or Windows install was accessible.
  Serialized charm UI/FSM wiring, controller input, moving/thin/steep terrain,
  jump-held/released motion, normal/shadow dash and disable/re-enable remain
  explicitly pending in docs/CLIENT_ACCEPTANCE.md. runtime_tested remains false.
