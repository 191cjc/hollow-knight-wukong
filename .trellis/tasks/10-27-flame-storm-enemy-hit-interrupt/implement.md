# Execution plan: Flame Storm attack interruption/default return

## Authorization and phase gate

The user accepted the default-behavior direction and requested a development version. This is the updated concrete plan required by project workflow. The user has now approved the complete revision with “开始吧”; implementation is authorized. The task is in_progress on feat/flame-storm-enemy-interrupt.

- [x] Task creation consent and original repeated-effective-hit preference recorded.
- [x] User selected cancellation plus each enemy's native default behavior, superseding forced hurt.
- [x] PRD/design rewritten and manifests curated around the selected direction.
- [x] Present the full revised plan and obtain subsequent review approval.
- [x] Run task.py start, create/register feature branch and load Phase 2 context.

One feature with one integration gate; no child task tree is needed. After approval, use configured Trellis implement/check agents. Main session owns scope, evidence decisions, integration/spec/docs/version consistency and finish.

Current checkpoint (2026-10-27): source/token/HP observation draft and linked tests exist, but no native cancellation profile is enabled and AC1/AC3 remain unmet. User cannot currently share client assets; complete public native graph evidence was not found. See research/development-checkpoint.md and research/check-draft.md. Do not treat draft code verification as completed feature acceptance or package it as the requested version.

## 1. Establish real native cancellation/default-return evidence

- [x] Inspect pinned damage/event/HP ordering and distinct Walker/Climber/Crawler mechanisms.
- [x] Persist a compact new-direction candidate report. Super Spitter, RoyalGaurd and Electric Mage are structural clues, not supported entries.
- [ ] Establish at least one real enemy/variant's supported attack states, safe cancel/recovery/default route, required cleanup and protected-state prerequisites.
- [ ] Obtain missing baseline client layout/actions or equivalent complete evidence; document provenance and runtime guards before adding any profile.
- [ ] If no real profile can be established, report the missing data. Do not deliver an empty adapter, diagnostic-only version or universal name-based reset as completion.

## 2. Implement scoped accepted-damage observation and native adaptation

- [ ] Preserve FlameStorm queries, ledger, five-hit budget/contact interval, native damage and player recovery.
- [ ] Capture exact Storm instance/source/token, actual responder and HP in the existing hit observation boundary.
- [ ] Dispatch native damage once; require surviving actual HP loss and current ownership before every extra side effect. Reject ambiguous nested attribution.
- [ ] Implement a versioned adapter with real profile signatures. Validate required dependencies before mutation; prefer native cancellation/recovery actions.
- [ ] Close declared current attack resources and return to native default behavior. No added hurt animation or attack-lock timer.
- [ ] Unknown/protected/no-damage/fatal/stale targets keep normal damage/recoil. Preserve Fire Eye and other helper callers/skills.
- [ ] Handle pooling/destruction, cancellation/recast, scene/unload and ownership restoration without stale callbacks.

## 3. Verify and package the development version

- [ ] Test production gating/attribution directly, extracting/linking core policy only when it is part of the implementation. No duplicate model/fake game API.
- [ ] Cover wrong source, no/fatal damage, repeated accepted hits, unsupported/protected layouts, nesting, revocation and teardown.
- [ ] Inspect real native signatures/IL and compiled call order; use pinned references and warnings-as-errors Release build.
- [ ] Run relevant existing Python/asset/core checks and full package gate. Preserve source/baked art and prior complete builds.
- [ ] Align version/package metadata and verify exact output closure; do not count stale artifacts as validation.
- [ ] Report core/build/layout verification separately from pending actual-client checks.

Validation commands after implementation:

```bash
DOTNET_ROOT="$PWD/.tools/dotnet" DOTNET_CLI_HOME="$PWD/.tools/dotnet-home" NUGET_PACKAGES="$PWD/.tools/nuget" .tools/dotnet/dotnet run --project tests/WukongKnight.Core.Tests --configuration Release
DOTNET_ROOT="$PWD/.tools/dotnet" DOTNET_CLI_HOME="$PWD/.tools/dotnet-home" NUGET_PACKAGES="$PWD/.tools/nuget" .tools/dotnet/dotnet build src/WukongKnight/WukongKnight.csproj --configuration Release --nologo
bash scripts/build.sh
```

## 4. Client acceptance and quality review

For each supported enemy/variant and both facings, hit during supported windup, active attack and recovery. Verify attack cancellation, owned hitbox/continuous emission shutdown, correct default behavior and successful subsequent AI actions. Repeat effective hits during a new attack. Preserve already independent projectiles according to native lifetimes.

Check airborne prerequisites, invulnerability, deaths/phases, unsupported layouts, props, other skills, Fire Eye healing, shared Dream/player recovery, cancellation/recast and scene/unload. Keep runtime_tested=false unless gameplay is executed. Never generalize one profile or compilation to all enemies.

- [ ] Trellis quality review against final PRD/design/spec and full diff; self-fix verified findings.
- [ ] Update native combat spec and skill/client docs with actual default-return coverage and evidence.
- [ ] Record supported profiles, skipped cases and outstanding client work. No-op behavior cannot pass AC1.
- [ ] Record progress/build results; commit/deploy only within applicable authorization.

## Risky files and rollback

WukongRuntime.cs owns damage attribution and observer order. FlameStorm.cs owns source/token/contact/recovery. The new native adapter owns complete attack cleanup, default entry and death/phase/mismatch guards. Core tests and package/spec/docs follow only when necessary.

Rollback the added observer/adapter together to restore original damage/recoil. No save, game/API or artwork changes.
