# Session handoff — 2026-10-27

The user is restarting the session. Implementation has been stopped before any
input-swap product edits; resume only when the user continues in the new session.

## Workspace and authorization

- Repository: `/home/ubuntu/hollow-knight-wukong`.
- Branch: `feat/flame-storm-enemy-interrupt`.
- HEAD/base: `cadb86455be8d481abd6f35fa9252f03e1d849fd`, version `0.7.6-dev`.
- Active task: `.trellis/tasks/10-27-flame-storm-enemy-hit-interrupt`, status
  `in_progress`. All current changes are uncommitted. No package, installation,
  version bump, archive or deployment has occurred.
- User explicitly approved task creation and implementation with “创建” and
  “开始吧”. Do not ask again for task creation or implementation approval.
- Latest authorized development request: swap Afterimage Combo and Flame Storm
  inputs. This is a bounded follow-up in the same task, independently deliverable
  from the blocked enemy-interruption work. No extra planning approval is needed.
- Preserve the existing draft and other edits. Trellis implement/check agents are
  the default; main session owns coordination/spec/lifecycle. Dispatch prompts
  start `Active task: <task path>`; child agents must not recursively dispatch.

## Latest request: input swap — NOT implemented yet

| Input | Current actual code | Requested target |
| --- | --- | --- |
| Neutral quick spell | Independent Afterimage Combo | Flame Storm |
| Down + Dream Nail | Flame Storm | Independent Afterimage Combo |

The user called Afterimage “残影连击”; current docs also call it “残影连打”.
Preserve skill damage, tiers, artwork, clocks, budgets, native Soul amount paid
once, original summon independence and Storm control/recovery behavior. Preserve
up/down spell, neutral/up Dream and focus. Respect native unlock/input gates and
the existing airborne down-Dream eligibility. Do not reset an unrelated owner.

Planning/context already written:

- `prd.md`: authorized follow-up and acceptance criteria at the top.
- `research/input-swap-plan.md`: change boundary and execution/check scope.
- `research/current-input-control-contracts.md`: exact relevant pre-swap native
  spec excerpt; the full owning spec exceeds context injection's 32768-byte cap.
- `implement.jsonl` and `check.jsonl`: **10 entries each**, both validate without
  truncation warnings. They include the follow-up and focused native contracts.

Implement agent `/root/implement_input_swap` was dispatched. It finished research
only and was asked to stop for the session restart. It confirmed **no product,
test or user-documentation edits and no input-swap build/tests yet**. Its final
checkpoint is `research/input-swap-implementation.md`. Do not assume that agent
survives the session restart; inspect the report and dispatch a new implement
agent for remaining work when resuming.

Agent's intended approach (researched, not implemented/reviewed): historical
commit `bf81c06` used a controlled Forward `Fireball Antic` completion hold with
`Spell End` recovery. Restore that known hero entry for Storm and move exclusive
Forward adapter ownership/lifetime from FistSkills to FlameStorm. FistSkills can
read the shared live MP Cost through its Down adapter. Down-Dream Afterimage uses
`TryBeginSummon` and `dream.CanBegin(native, true)` without Dream Begin/Finish,
keeping the player free. Dream control remains for Godslayer. Preserve Storm's
quakeLevel damage, 16-tick action, successful-only QuakeInvuln and attribution
draft. Review entry/reentry, suppression, cancellation and teardown carefully.

Next: implement the swap; update README.md, docs/SPELL_LAYOUT.md,
docs/FIST_SKILLS.md and current docs/CLIENT_ACCEPTANCE.md checks; run applicable
Core checks and pinned Release build; dispatch independent trellis-check; update
owning spec to describe the implemented input ownership. Current docs/code still
show old bindings. Report pending actual-client checks separately. Do not mark
the whole enemy-interruption task complete after only finishing this follow-up.

## Original enemy-interruption work — incomplete, evidence blocked

Accepted design: each actual nonfatal Storm hit cancels a compatible enemy's
current attack and returns it to its own native walking/flying/idle behavior.
Native AI then runs normally. No stun timer, forced hurt animation restart or
generic Walk/Idle/END reset. Preserve normal damage/recoil on unknown/protected
layouts; stop owned current-attack resources, leave independent projectiles.

**No verified native enemy profile or gameplay interruption exists.** Native
enemy FSM/actions/cleanup data is unavailable locally. The user explicitly said
“暂时没办法共享” their game resources; do not ask for the same directory again.
Bounded public-source searches did not obtain complete graphs. Electric Mage,
Super Spitter and Kingsmould clues are research candidates only, not support.
One complete original target-FSM/actions/transitions dump could suffice without
the entire game directory. Do not invent viewer export commands or enable a
profile from state names alone. No further research loop without new evidence.

Completed **draft only**:

- New `src/WukongKnight/Core/ScopedEnemyDamage.cs`: exact reference/source/target/
  token, initial HP, single-use, nested-Hit sequence/revocation checks.
- `FlameStorm.cs`: scoped dispatch observation with finally/cancel cleanup.
- `WukongRuntime.cs`: observes existing HealthManager.Hit, preserves native damage
  and Fire Eye order. **Completion result is deliberately discarded.**
- Existing Core tests link this actual helper; five new check groups.
- `native-combat.md` and backend index explicitly describe the unreleased draft
  and its limits; no supported-enemy claim.

Known blockers before any enemy-control consumer: ApplyExtraDamage/direct HP
writes bypass Hit sequence, and same-reference disable/re-enable/pooling lacks
lifetime identity. Plus actual native cancellation/cleanup/default route and
client acceptance. A no-op adapter/observer package cannot satisfy the feature.

Previously completed verification applies to this draft only: **81 Core checks
pass**, pinned-reference Release rebuild **0 warnings/errors**, compiled hook/
finally/order checks, independent review in `research/check-draft.md`. No native
enemy/client acceptance or full package gate was run. These are not input-swap
validation results.

Read `research/development-checkpoint.md`, `implementation-evidence.md`,
`check-draft.md`, `default-behavior-full-evidence.md` and
`minimum-client-evidence.md` for exact evidence and limitations.

## Validation and file conventions

Pinned target: Hollow Knight `1.5.78.11833` / Modding API v77. API DLL is
`.tools/hollow-knight-api-v77/Assembly-CSharp.dll`; actual enemy scene/prefab data
and real PlayMaker runtime are unavailable. No fake Unity APIs for tests.

```bash
DOTNET_ROOT="$PWD/.tools/dotnet" DOTNET_CLI_HOME="$PWD/.tools/dotnet-home" NUGET_PACKAGES="$PWD/.tools/nuget" .tools/dotnet/dotnet run --project tests/WukongKnight.Core.Tests --configuration Release
DOTNET_ROOT="$PWD/.tools/dotnet" DOTNET_CLI_HOME="$PWD/.tools/dotnet-home" NUGET_PACKAGES="$PWD/.tools/nuget" .tools/dotnet/dotnet build src/WukongKnight/WukongKnight.csproj --configuration Release --nologo --no-incremental
python3 .trellis/scripts/task.py validate .trellis/tasks/10-27-flame-storm-enemy-hit-interrupt
git -c core.whitespace=cr-at-eol diff --check
```

Preserve per-file line endings. The owning native-combat spec and several old
sources/docs use CRLF: plain `git diff --check` flags newly added CR terminators,
so the CRLF-aware check above was used alongside an actual trailing-space scan.
Do not normalize the entire file as unrelated churn. The latest changes after
the already-reviewed code draft are task artifacts/context and spec documentation.
