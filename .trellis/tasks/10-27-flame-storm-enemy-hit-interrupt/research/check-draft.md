# Review: incomplete damage-attribution draft

Date: 2026-10-27. Branch: `feat/flame-storm-enemy-interrupt`.
Baseline: `main@cadb864`, Hollow Knight `1.5.78.11833` / Modding API v77.

## Verdict

**Draft checks pass; the requested enemy-interruption feature does not pass acceptance.** No new mechanical/local correctness issue was found, and no production or test changes were required by this review. The existing changes may remain as an explicitly unfinished, unreleased branch draft. They must not be packaged, installed or described as a working interruption release: there is no native enemy profile and the observation result is deliberately discarded.

## Scope reviewed

- Full production/test diff: `FlameStorm.cs`, `WukongRuntime.cs`, the new `Core/ScopedEnemyDamage.cs`, `tests/WukongKnight.Core.Tests/Program.cs` and its project file.
- Current PRD, design, execution plan and every curated check-manifest source, including the complete saved native hook context and `implementation-evidence.md`.
- Actual owning `.trellis/spec/backend/native-combat.md` sections for native damage, query masks, real linked-source tests, Fire Eye, shared Dream ownership and native Quake recovery. Relevant existing `NativeV77`, `BloodthirstyFireEye`, runtime teardown and native dispatch paths were inspected.
- Package discovery: both SDK projects were identified. The Mod project includes the new Core source through its existing default compile glob; the test project links that exact production file. The package tool stages the built DLL rather than maintaining a separate source-file list. No generated assets, public configuration, templates or package schema changed.

## Findings (fixed)

None. Lint/hygiene, compilation and applicable Core checks passed without reviewer changes.

## Findings (not fixed)

1. **No attack-cancellation/default-return implementation.** At `WukongRuntime.cs:470`, the accepted observation result is discarded. There is no verified enemy identity/layout, declared attack-state set, native cancel/recovery/default route, resource cleanup or recovery test. AC1 and AC3 are unmet; protected-phase/layout behavior cannot be validated against a nonexistent profile. This is the explicitly recorded evidence/design blocker, not a mechanical fix. Obtain complete native transitions/actions and references for at least one real enemy before integrating a narrowly guarded adapter. State names or a generic `Walk`/`Idle`/`END` rule are insufficient.

2. **Direct native HP changes can evade the Hit sequence.** `ScopedEnemyDamage.Complete` and `WukongRuntime` reject nested `HealthManager.Hit` calls, but `HealthManager.ApplyExtraDamage(int)` directly writes HP after `EXTRA DAMAGED` without routing through Hit. A synchronous extra-damage/direct-write path inside the observed dispatch can contribute to its HP delta without changing `healthHitSequence`. Final HP equality does not isolate that contribution. Native IL was rechecked during this review. The current result has no side-effect consumer, so this remains a recorded unfinished attribution blocker; it is not safe input for a future adapter yet. Broadening global hooks is a native-integration/design decision outside this mechanical review. Resolve the applicable bypasses before consuming results, and do not claim arbitrary third-party HP writes are universally observable.

3. **Reference identity does not establish a pooling lifetime.** `ScopedEnemyDamage` matches source/target references and the cast token; `CompleteEnemyHit` checks the target's current enabled/active/nondead state. A target disabled and re-enabled/reused during the same synchronous dispatch can satisfy those final checks with the same reference. `HealthManager.OnEnable` only starts persistence handling and supplies no generation identity. A target-lifetime guard or proven profile-specific equivalent is still required before an adapter can mutate the target. No claim that AC5 is complete is warranted. This also remains intentionally unfinished because the draft has no target mutation.

4. **Native integration/client acceptance is absent.** Core tests exercise the actual pure policy, not Unity/FSM lifecycle, attack hitbox/emitter shutdown, death/phase exclusions or subsequent AI. No game resources, complete native profile layout or client execution were available. The acceptance matrix, final supported list, spec/client-documentation updates and development package gate remain outstanding. The current spec correctly continues to say forced enemy state behavior is not implemented; no supported list or version bump should be added for this draft. This is a material verification gap, not a failed Core assertion.

## Existing behavior and lifetime review

- Target masks, responder resolution, evasion, five-hit ledger and contact spacing are unchanged. Each budgeted target still invokes the existing `FireDemonHit`/`SpellHit` native damage chain once. No extra hit, HP assignment, transform/velocity override, attack timer or projectile cleanup is added.
- The exact source, target, token and pre-`TAKE DAMAGE` HP are scoped to the synchronous native dispatch. Prior HP changes reject observation. Wrong-source/target callbacks cannot consume a later exact matching observation; depth and the monotonically advanced Hit sequence conservatively reject nested Hit attribution.
- The existing Fire Eye token/HP snapshot, original damage dispatch, qualifying attack types and `AfterEnemyHit` invocation remain intact. Fire Eye runs before the new completion observation. The compiled call sequence reads the final Hit sequence after `storm.Observe`, so synchronous recovery callbacks cannot escape that sequence check. The existing Fire Eye algorithm itself was not expanded or claimed to isolate all nested damage.
- Temporary attribution is cleared in `FlameStorm.FixedUpdate`'s `finally`, and `Stop` clears it before revoking the ledger and finishing Dream. Runtime Hit depth also unwinds in `finally` on early returns/exceptions. Runtime disposal/replacement prevents completion through owner-reference and disposed/failed checks. There are no persistent enemy caches, delayed callbacks or subscriptions added by this draft. These observations do not resolve the same-reference reuse blocker above.
- The original Storm completion/cancellation entry and shared Dream disposal order remain. Successful recovery still revokes ownership before `dream.Finish`, then uses the original eligible-only `QuakeInvuln` call. Extra `Observe` calls use the existing ownership/liveness/completion checks; no new recovery timer or finish path was introduced.

## Verification

- **Lint/hygiene: pass.** `git diff --check`. No standalone C# linter is configured in this repository; compiler warnings are errors in both projects. There was no claim of running an unavailable separate lint tool.
- **TypeCheck/build: pass.** Local SDK `10.0.402`, pinned native references, Release `net472`, `--no-incremental`, zero warnings and zero errors.
- **Tests: pass for the draft's applicable Core scope.** All 81 linked-production checks passed, including wrong/exact source and responder, token changes, no/healing/fatal HP outcomes, pre-dispatch HP mismatch, nested Hit sequence changes, revoked/unobserved/reused results and five fresh accepted contacts under the unchanged ledger.
- **Read-only IL verification: pass.** Rechecked pinned `ApplyExtraDamage`, `GetIsDead` and `OnEnable`. API DLL SHA-256: `0890edcd1b60ae22ea9c4a2d7c16056795b321f0efbb078d447e06730c0e784b`. Inspected compiled `FixedUpdate`, `BeginEnemyHit`, `CompleteEnemyHit`, `Stop` and `HealthHit`: single native dispatch; temporary/depth `finally` cleanup; Fire Eye before completion; final sequence read after Observe; completion result discarded. Local compiled inspection output is `/tmp/wukong-interrupt-check-il.txt`.
- **Feature/native/client acceptance: incomplete.** No actual attack interruption, profile/layout acceptance, pooling/bypass integration or client gameplay was tested. No fake Unity/game APIs were introduced. Python/assets/full package checks were not run because those layers are unchanged and this is not a release/package gate. No version/package changes, installation, commit, archive or lifecycle completion were performed.

Commands executed:

```bash
DOTNET_ROOT="$PWD/.tools/dotnet" DOTNET_CLI_HOME="$PWD/.tools/dotnet-home" NUGET_PACKAGES="$PWD/.tools/nuget" .tools/dotnet/dotnet run --project tests/WukongKnight.Core.Tests --configuration Release
DOTNET_ROOT="$PWD/.tools/dotnet" DOTNET_CLI_HOME="$PWD/.tools/dotnet-home" NUGET_PACKAGES="$PWD/.tools/nuget" .tools/dotnet/dotnet build src/WukongKnight/WukongKnight.csproj --configuration Release --nologo --no-incremental
git diff --check
```
