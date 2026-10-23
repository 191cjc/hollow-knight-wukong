# Independent Quality Review

- Date: 2026-10-23.
- Reviewer: dispatched `trellis-check` agent; no recursive agents, staging, commits or archive operations.
- Active task: `.trellis/tasks/10-23-wukong-character-basic-attacks`.
- Result: task-scope automatic checks pass after one local runtime cancellation fix. Client acceptance is still pending; `runtime_tested=false`.

## Scope and applicable checks

This is one repository containing the `net472` C# Mod, Python asset/build tools and their Python/engine-free C# checks. There is no frontend application or additional product package to check. The applicable index is `.trellis/spec/backend/index.md`, especially `character-assets.md` and `native-combat.md`; its older generic quality documents and the frontend index are unfilled templates rather than additional runnable requirements.

Loaded the curated check context, PRD, design and implementation plan, final implementer notes, current source/tests/scripts, generated manifest/build report and exact local native IL. The repository has an unborn branch and an untracked baseline, so this review inspected actual task-scope files rather than relying on `git diff HEAD`.

No dedicated linter or Python type checker is configured. Bash syntax and Python compilation are the available static syntax checks. The real Release build enforces C# nullable/type checks and warnings-as-errors against the pinned game/API/Unity compiler inputs.

## Findings (fixed)

### Canceled native damage could retain its old contact list

Files:

- `src/WukongKnight/WukongRuntime.cs`
- `src/WukongKnight/NativeV77.cs`
- `src/WukongKnight/Core/DeferredContactCleanup.cs`
- `tests/WukongKnight.Core.Tests/Program.cs`
- `tests/WukongKnight.Core.Tests/WukongKnight.Core.Tests.csproj`

Exact baseline IL establishes the failure path:

1. `NailSlash.CancelAttack` disables its attack polygon, clash polygon and mesh, and clears `slashing`. It does not empty `DamageEnemies.enteredColliders`.
2. `DamageEnemies.FixedUpdate` iterates that private `List<Collider2D>` backwards and calls `DoDamage` for each live target. It does not inspect its source slash polygon. The list is otherwise cleared by `DamageEnemies.OnDisable` or individual physics exit callbacks.
3. `DamageEnemies.DoDamage` sends the target FSM event `TAKE DAMAGE` **before** calling `HitTaker.Hit`. A guard only in HitTaker cannot prevent that earlier interaction event.
4. The previous Release invalidated slash/source ownership immediately. After an Update-time jump/dash cancellation, a later damage update could therefore dispatch stale contacts as an ordinary unowned native source before physics exits had emptied them.

The fix clears contacts only for `DamageEnemies` components beneath the specific owned slash whenever a pulse closes or the transaction releases. The new member name/type check and list access remain centralized in `NativeV77`: private `DamageEnemies.enteredColliders : List<Collider2D>`.

A close can itself occur inside a damage callback. Clearing that native list immediately would invalidate the original backwards enumeration. The production engine-free `DeferredContactCleanup<T>` records active iteration depth per source; pending clears run in the outermost native FixedUpdate wrapper's `finally`. While a source awaits that clear, its remaining `DoDamage` calls are suppressed. Other sources retain their original behavior. The owned `DoDamage` entry also synchronizes the combo clock and rechecks ownership/window/pending state **before** calling the original method, covering script-order boundaries and `TAKE DAMAGE` as well as Hit.

Unload inside damage dispatch keeps only the two damage guards until current native enumerators finish and deferred clears run, then unregisters them. No cross-frame source quarantine is added: after an old enumeration finishes, a new original aerial/directional attack may reuse the same normal/alternate slash. No enemy-wide invulnerability or unrelated contact list is changed.

The added regression runs the actual linked production helper with a live backwards contact loop. It verifies canceling during the first callback preserves enumeration integrity, suppresses remaining dispatches, clears at completion, leaves other sources alone, releases nested callbacks only at the outer boundary and allows the same source to begin a new transaction. This is a real cleanup-policy check; it is not a simulated Unity/client acceptance claim.

## Reviewed behavior

| Area | Evidence and conclusion |
| --- | --- |
| Core ordering/input | Actual linked core tests exercise one press, four deliberate stages, early input rejection, one buffered input, inclusive grace deadline, stage4 reset and canceled/stale ownership. |
| Physics/Quick Slash | Gameplay advances on fixed time, including owned damage dispatch; complete stage/window/visual scale uses the same source-tick ratio. Runtime rejects a timestep longer than an authored hit window. Low-render-rate core scheduling check passes. |
| Native transaction | Exact DoAttack IL does not call CanAttack itself. Original DoAttack/Attack initialize an accepted stage once, AfterAttack precedes StartSlash, only the selected horizontal StartSlash is deferred. ResetAttacks does not reset cooldown; owned release explicitly handles it. |
| Native hit dispatch | Exact HitTaker walks one `IHitResponder` at each parent. Dedupe uses responder identity per token/window. HealthManager evasion rejection does not consume target identity; no added damage multiplier, fabricated HitInstance or manual SoulGain exists. |
| Retained attacks | Eligible filters grounded normal horizontal attacks; air/up/down/wall use the original path. No downslash collision/pogo implementation was replaced. Final cleanup adds no persistent suppression for the next native attack. |
| Lifecycle/presentation | Attach/detach and constructor-failure cleanup retain native control/animator/FSMs and restore owned visibility/timing. Parent mirror cancellation and one explicit source-facing flip agree with reviewed source-right frames. Original enabled/color signals remain available. Actual rendering still needs the client. |
| Assets/schema | Profile/manifest contain all 13 clips and the reviewed half-open windows [4,7), [5,8), [3,5)+[11,14), [5,8). Constant 231x226 canvas/root(119,174), 329 ticks and one 1848x1582 atlas reach the runtime/package. Runtime converts atlas Y and pivot Y separately. |
| Conversion/build | Bounded legacy transform/pivot/visibility/alpha and deterministic regeneration tests pass. Build retains original archive/hash/re-extraction/audio checks. No unsupported source feature is silently treated as a general DragonBones runtime. |
| Package/status | Manifest-only staging, exact closure and ZIP byte verification pass. The package has only Mod DLL, README, manifest and referenced atlas; no engine/API/game DLLs or previews. Reports distinguish implementation/build/automatic checks from pending client execution. |

## Verification actually run

- `bash -n scripts/build.sh` — pass.
- `.tools/python/bin/python -m compileall -q tools tests` — pass.
- Local SDK `dotnet run --project tests/WukongKnight.Core.Tests --configuration Release` — 10 checks pass, linking actual production core/cleanup sources.
- Read-only Mono.Cecil inspection of the pinned local API: `HeroController.FixedUpdate`, `LookForQueueInput`, `DoAttack`, `DamageEnemies.FixedUpdate`, `DoDamage`, trigger enter/exit/disable and the previously recorded Attack/CanAttack/ResetAttacks/NailSlash/HealthManager methods — confirms the members/order used by this review. Temporary inspection output remains under ignored `.tools/runtime-inspect/review.txt`.
- Final `bash scripts/build.sh > artifacts/build.log 2>&1` — exit 0 after the complete fix. Original inputs/re-extraction/PNG/JSON/XML and all 14 audio full decodes pass; 23 Python tests and 10 C# checks pass; `net472` Release reports 0 warnings and 0 errors; package closure/ZIP CRC and bytes pass.

The initial post-fix build was refreshed after moving the owned clock synchronization ahead of `DoDamage`'s FSM event; only the final artifact hashes below are current.

## Final artifacts

| Artifact | Bytes | SHA-256 |
| --- | ---: | --- |
| `artifacts/WukongKnight-0.2.0-dev.zip` | 532705 | `761fc0564c5f68bec1c4be13cf1c5aeb99a78f95ad72a1197005418e0d32a1ea` |
| `artifacts/mod/WukongKnight/WukongKnight.dll` | 39936 | `438285a885006b01109dccd773f5d8c994c3d9dd19447e711c5e5005ed039c04` |
| `artifacts/mod/WukongKnight/character/character.json` | 57227 | `b0c7253fe3682901eff1682ca2add17fb6d79e387d1683e7aa01f2c694522aeb` |
| `artifacts/mod/WukongKnight/character/atlas-000.png` | 525049 | `8c7495d94164508119df6da65c389a326a1cda338c82364e51573fb476fb9963` |

## Findings (not fixed) / acceptance limits

No additional confirmed task-scope code defect remains from this review. No client or Unity process is available, so actual loading/rendering, two real stage3 HP losses, collision/FSM charm/soul/breakable behavior, air/up/down/pogo and scene/death/disable lifecycle acceptance remain unperformed. The newer pinned Unity references prove compilation only. Those existing client-only criteria remain pending; they are not presented as passed by core tests or this review.

Verified main-session follow-through: `native-combat.md` now covers contact-list ownership, deferred native iteration and the pre-Hit `TAKE DAMAGE` boundary; runtime notes record the review fix as a follow-up to the historical nine-test checkpoint; `CURRENT_STATUS.md` matches the final ten checks, package sizes and hashes above. All client-only acceptance items remain pending.
