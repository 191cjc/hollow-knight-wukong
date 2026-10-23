# Runtime Implementation Record

Date: 2026-10-23. Baseline: Hollow Knight 1.5.78.11833 / Modding API v77 / net472.

## Delivered code

- `CharacterAssets.cs` is the single version-1 JSON decoder, validating identity/schema, finite numeric metadata, atlas relative paths/hash/decoded dimensions, shared frame cells/root/pivot, clip tick totals/required clips, and ordered 1/1/2/1 combat windows before creating a replacement view. Failed partial loading disposes all owned textures/sprites.
- `WukongPresenter.cs` adds a separate SpriteRenderer, retains native animator/FSM/control/collider, samples source ticks, and maps death/hurt/special/native attack/air/movement/idle states. Native body enabled/color are retained as visibility/flash signals. `Renderer.forceRenderingOff` is resolved against the **actual running engine** before hiding the body; unsupported engines fail back to the original appearance. Source frames face right. Parent world X/Y mirroring is canceled; cState.facingRight controls one explicit flip. Fixed scale uses the initial hero collider height against nominal body height. A six-source-pixel constant upward calibration aligns the reviewed idle alpha foot boundary with the collider foot; all clips retain the same virtual root/scale.
- `Core/ComboTimeline.cs` is engine-free source shared directly with the C# executable tests. It owns four-stage ordering, one buffered input after buffer_open_tick, inclusive end+grace deadline, stage4 reset, cancellation/token invalidation and per-window actual-responder identity. Quick Slash applies one seconds-per-source-tick ratio to the complete stage/window/visual clock.
- `NativeV77.cs` centralizes private v77 field/method validation and input reflection. Original DoAttack/Attack initialize each accepted stage once; the selected normal/alternate StartSlash is captured and later permitted at each authored hit window. Native AttackDuration is owned per token so native Update cannot end a stage early. Normal completion releases its authored cooldown; cancellation preserves only the unexpired original native cooldown (`max(0,nativeCooldown-elapsed)`), never a stale preattack value.
- `WukongRuntime.cs` owns the current hero, hook subscriptions and scene/lifetime cleanup. Gameplay advances on Time.fixedTime, including synchronization from the selected slash and owned damage dispatch so Unity script ordering cannot retain an expired pulse. The chosen native attack/clash polygons are enabled only in authored windows; original native StartSlash still provides range-charm setup/audio/animation/FSM state. Native selected renderer is hidden while owned; geometry scale includes the native charm scale multiplied by the manifest reach. No parallel overlap damage, fabricated HitInstance, or manual soul gain was added. Air/up/down/wall attacks and native directional slash rendering/pogo remain original.
- `WukongKnightMod.cs` supports ITogglableMod with idempotent initialize/unload and external `character/character.json` loading beside the DLL. Native hero stays visible on invalid assets or incompatible runtime metadata.

## Exact local IL confirmed during implementation

Read-only Mono.Cecil inspection of the locked API and HookGen references was performed with temporary tooling under ignored `.tools/runtime-inspect/`.

- DoAttack's wrapper/orig_DoAttack does **not** call CanAttack itself; native input gates before invoking it. Buffered stage setup can invoke this one native transaction while the pure core already owns the next stage; CanAttack continues to reject unsolicited native repeats during that stage.
- HitTaker.Hit uses singular `GetComponent<IHitResponder>()`, dispatches that responder and walks parents up to recursionDepth. The scoped hook repeats that exact parent walk and calls original HitTaker with depth 1 for each allowed responder. HealthManager deduplication is applied in its Hit hook; other Component responders use their own instance IDs.
- HealthManager.Hit rejects `evasionByHitRemaining > 0`; NonFatalHit sets 0.2 seconds. Owned rejected hits do not consume the per-window target identity, so native repeated callbacks can retry before the window closes. Enemy evasion/invulnerability values are never changed. Current third-stage windows are [3,5) and [11,14); default-clock gap exceeds 0.2s, but accelerated/native FSM behavior still requires client acceptance.
- NailSlash.Disable only marks animCompleted. The owned FixedUpdate override prevents native animation-completion/stepCounter timing from closing the authored polygons prematurely; original behavior resumes once ownership releases.
- FaceRight writes root localScale.x=-1; FaceLeft writes +1. The presenter's explicit inherited-mirror cancellation matches this behavior.
- Original HeroAnimationController.StopAttack stops only UpSlash/DownSlash animations; grounded horizontal cleanup does not need to stop the body animator or replace its normal FSM path.

## Ownership and cleanup

A stage token is invalidated before native slash/control cleanup callbacks. Cancel closes polygons, drops the buffer and native queue, restores owned timing/scale/renderer, then calls native ResetAttacks while scoped. Scene changes, hero disable/destroy/replacement, control loss, jump/dash/turn, recoil/death/hazard, initialization failure and mod unload route through the same cleanup. Individual restore failures are logged and other owned members still unwind. Constructor failures unregister partial subscriptions. Sprites/textures/materials are owned resources; game/API/Unity/Newtonsoft DLLs use Private=false and are not runtime payload files.

The adapter rejects a physics timestep longer than the shortest **scaled** authored hit window rather than silently dropping an entire window. With ordinary 20ms physics, slow render updates still run all physics steps. No coroutines with old-stage callbacks were introduced.

## Checks actually run

1. `.tools/dotnet/dotnet build src/WukongKnight --configuration Release`, with project-local DOTNET_ROOT/DOTNET_CLI_HOME/NUGET_PACKAGES: **passed, 0 warnings, 0 errors**.
2. `.tools/dotnet/dotnet run --project tests/WukongKnight.Core.Tests --configuration Release`: **9 passed**, linking the actual production ComboTimeline source. Covers one press/no automatic chain, four inputs/order, early/bounded buffer, exact grace boundary, cancellation/stale token, multi-target/per-window dedupe and stage3 rearm, complete Quick Slash scaling, short windows under slow rendering with fixed-step scheduling, and stage4 buffer reset.
3. Exact pinned DLL metadata/IL checks above: performed; all used HookGen signatures compile against the real local references. No fabricated Unity/game test stubs were used.
4. Main-session authored-asset preview inspection: source-right facing, common root and six-pixel feet calibration communicated by the asset owner; runtime consumes final reviewed windows rather than the initial illustrative profile.

## Pending client acceptance / limits

No game installation or Unity process was available. `runtime_tested` remains false. Compile/core tests cannot prove scene/prefab FSM acceptance, two actual stage3 HP losses/soul events, charm damage/filtering, duplicate-collider behavior, breakable/lever/terrain events, native collider reach vs visible staff, render scale/shader/visibility or lifecycle behavior. All those remain the documented client checklist.

The first build retains native horizontal collider geometry (with authored timing and explicit reach multiplier currently 1.0) and native directional effects; it does not claim to reconstruct source AS3 hit geometry. Fourth-stage source artwork is intentionally retained even though the staff sits behind the forward arm pose. Unsupported native body actions use documented Wukong fallback poses. The package uses newer pinned compile references, and the running client's required engine methods/renderer property must still be verified by the runtime gate and client acceptance.

## Independent-review follow-up

The initial owner checkpoint above had 9 core checks. Final review added `Core/DeferredContactCleanup.cs` and the tenth actual-production-source regression check after confirming that NailSlash.CancelAttack does not clear DamageEnemies.enteredColliders. Closing an owned pulse now clears only that slash's descendant contacts. If closing occurs from inside native damage traversal, mutation waits until its outermost FixedUpdate finally; remaining DoDamage calls are suppressed, including FSM TAKE DAMAGE events. The owned DoDamage entry synchronizes the fixed clock before any native event, then rechecks ownership/window/pending cleanup. A later original airborne attack inherits no suppression. Unload from inside traversal leaves only these two guards until synchronous unwind completes. Private contact-list access stays in NativeV77.

Final full build passes 23 Python and 10 linked-production C# checks, with Release 0 warnings/0 errors. The final package hashes are in `artifacts/build-report.json` and `research/verification.md`; the earlier owner checkpoint is retained as historical evidence. Client acceptance remains pending.
