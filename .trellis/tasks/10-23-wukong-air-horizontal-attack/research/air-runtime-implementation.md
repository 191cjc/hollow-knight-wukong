# Runtime implementation: single airborne horizontal strike

Implemented against the approved task design on 2026-10-23. Runtime owner changed only `src/WukongKnight/**`, `tests/WukongKnight.Core.Tests/**` and this allowed implementation note. No commit, push, client execution, dependency upgrade or full package build was performed by this worker.

## Production changes

- `Core/ComboTimeline.cs`: one scheduler and monotonically increasing token sequence for `GroundCombo` and `AirHorizontal`. `AttackDefinition` contains shared timing/reach/windows, `ComboStage` adds only ground buffering. `CurrentAttack` and each event's immutable mode/definition avoid ground-stage indexing for air and preserve an earlier definition when one Advance emits end/start transitions.
- `PressAir` starts one standalone action only while inactive. Active air calls to either Press entry point cannot buffer or restart. Completion/cancel resets ground continuation. `ObserveContact` is also used while inactive, so leaving a ledge during ground grace resets the next stage. It permits air ascent/fall and cancels air on landing or wall contact, while retaining ground jump/leave-ground cancellation.
- `Core/AttackTiming.cs`: tested per-token original-native-cooldown policy shared by `NativeV77`. Owned air cooldown is max(authored duration, recorded native cooldown), and both normal/canceled release retain only the native remainder. Ground normal completion remains its existing deliberate zero-cooldown chaining policy; ground cancellation still retains original remainder. Stale owners cannot release a newer transaction.
- `WukongRuntime.cs`: grounded/airborne normal horizontal selection, common interruption observation, current action windows and original native capture/damage/cleanup reuse. Up/down attack input during air cancels before native input/direction/cooldown gates; ground down still follows its existing horizontal convention. Fresh jump/dash press cancels before native Update, allowing native double-jump gates to decide normally. No rigidbody, gravity or jump-counter writes were introduced.
- Native queues are cleared before and after the original Update while input is owned. The post-clear also applies if that owned frame's action ended synchronously, preventing a rejected press queued by original Update from silently replaying after air completion. A directional request explicitly passed back before original Update is not post-cleared unless a new controlled action actually owns it.
- Physics synchronization observes world/contact interruption **before** its same-fixed-timestamp advance guard. Thus a later landing observation in an owned DoDamage/Slash/Hit synchronization can close an air window even when its clock already advanced earlier that tick. Existing pre-FSM DoDamage suppression, scoped responder dedupe, native evasion rejection and deferred contact-list cleanup are retained.
- `WukongPresenter.cs`: samples the selected action's shared source clock and tracks token plus clip name, including transitions from controlled animation to same-name native fallback. Existing body/root/facing mapping is unchanged.
- `CharacterAssets.cs`: requires schema 2 and a required exact-three-field air object, exact nonlooping jumpAttack, one valid integer half-open window, finite numeric range 0.25..3. Shared window decoder also rejects extra fields; ground range now matches existing Python bounds. Failed initialization still disposes partial resources and leaves native body visibility intact.
- Mod and project version are `0.3.0-dev`.

## Verification performed

Commands used the existing project-local SDK and `DOTNET_ROOT`, `DOTNET_CLI_HOME`, `NUGET_PACKAGES` layout:

```bash
.tools/dotnet/dotnet run --project tests/WukongKnight.Core.Tests --configuration Release
.tools/dotnet/dotnet build src/WukongKnight/WukongKnight.csproj --configuration Release --nologo
git diff --check
```

Result: **19 linked-production core checks passed**, including all 10 baseline cases and 9 additions covering air half-open boundaries, repeated-input rejection, per-target dedupe, Quick Slash/20 ms physics timing, ground/air token transitions, inactive grace reset, ascent/fall/landing/wall contact, event definition identity, same-clip clock restart, original cooldown remainder and stale-owner release. Release compilation against pinned real API/HookGen/Unity references succeeded with **0 warnings and 0 errors**. Diff whitespace check passed.

The native queue post-clear, exact reflected input members, pre-FSM damage order and renderer/Unity lifecycle are reviewed production adapters; the pure tests do not pretend to execute a Unity scene or synthetic game-controller stub. Full Python/build/package validation is coordinated by the asset integration worker after this stable handoff.

## Remaining acceptance

Actual client behavior remains pending: horizontal hit/feedback/reach, nail/charm/soul behavior, repeated-air cadence, keyboard/gamepad direction, native up/down/wall/pogo, landing/double-jump/dash/turn interruption, low FPS/pause, damage/death/scene changes and unload/reload. Compile references are not runtime compatibility proof. No new custom damage source, manual soul grant or enemy-wide evasion changes were introduced.
