# Independent quality review: single airborne horizontal attack

- Date: 2026-10-23
- Task: `.trellis/tasks/10-23-wukong-air-horizontal-attack`
- Reviewed baseline: `9517499` on `feat/wukong-air-horizontal-attack`.
- Scope: all current-task production, tests, profile, tooling, package documentation and executable specs; not just the runtime worker's files.
- Result: **automatic quality gate passed; no findings requiring a code change. Client acceptance remains pending.**

## Findings (fixed)

None. The independent review did not modify production code, tests, resource inputs or package documentation. This report is the only review-owned change, so the existing complete package remains current.

## Findings (not fixed)

None identified within the approved task scope. Actual game execution is an explicitly unperformed acceptance step, not a passing result from these checks.

## Independent code review

- **Input and native transaction:** initial air entry ignores the returned `StageStarted` event while already inside the player's native `Attack`, preventing a second `DoAttack`. Only buffered ground transitions process a `StageStarted` event into another native transaction. Active air presses never call ground `Press` or buffer another air action. The pre-update ownership snapshot and post-update queue clear reject queues produced by the original update, including a frame in which ownership ends. Directional presses cancel ownership before native input/cooldown processing; jump cancellation runs before native double-jump gating.
- **World transitions and damage ordering:** ground/air use the same mode-aware contact policy. It permits air ascent/fall, cancels air on landing and clears inactive ground grace when leaving a platform. Runtime observation runs before the same-fixed-timestamp guard, and owned `DoDamage` synchronizes before the original FSM event. A landing observed later within an already-advanced physics tick still closes the air pulse.
- **Identity and cleanup:** one `ComboTimeline` supplies a monotonically increasing serial for both modes. Events retain their own definition across a ground transition. Window/target ownership and stale-token checks remain shared. The prior deferred contact-list clearing, pending-source damage suppression, outermost native traversal cleanup and unload guard paths remain intact; no parallel damage/soul system or enemy-global evasion rewrite was introduced.
- **Cooldown and presentation:** production `AttackTiming` scopes ownership to the token, keeps the maximum of authored air duration and the recorded native cooldown, and releases the native remainder on air completion/cancellation. It retains ground completion/cancellation policy. The presenter samples the controlled core's elapsed source ticks and tracks token changes even for consecutive `jumpAttack` clips.
- **Cross-layer contract:** source profile, shared Python profile/manifest validator, generated schema-2 manifest, C# loader and package agree on required `combat.air_attack`. The new object permits exactly `clip`, `hit_windows`, `range_multiplier`, requires nonlooping `jumpAttack`, exactly one bounded integer/nonboolean half-open window and finite/nonboolean reach in `[0.25,3]`. Wrong schema/resources fail initialization before native-body replacement. Profile/generator versions remain 1; sampling and atlas encoding are unchanged.
- **Tests and scope:** existing ground/deferred-cleanup checks remain; new checks exercise actual linked production air/contact/timing code. Python tests cover malformed air contracts, authoritative clip duration, old cache rejection/rebuild, deterministic real bakes and package preservation on invalid inputs. No fake game/Unity stubs, extra dependencies, raw asset edits or unrelated toolchain changes were added. Native input and SpriteRenderer execution remain client checks.
- **Docs/specs:** README, status, asset instructions, packaged README, client checklist and backend contracts consistently describe one controlled air-horizontal action, preserved native directional/wall/pogo behavior, schema-2 pairing and version `0.3.0-dev`. `runtime_tested=false` and client pending status remain explicit.

## Verification

Checks were independently executed after implementation stabilized:

| Check | Result |
| --- | --- |
| `git diff --check` | Pass |
| Python `py_compile` for changed tooling/tests | Pass |
| `bash -n scripts/build.sh` | Pass |
| Python unittest discovery | **28 tests passed** |
| Release linked-production C# core tests | **19 checks passed** |
| Actual net472 Release compilation, warnings as errors | **Pass: 0 warnings, 0 errors** |
| Source hash + generated character validation | Pass: schema 2, 13 clips, 329 source-tick records |
| Final staged directory closure and report file hashes | Pass: exactly README, DLL, manifest and one atlas |
| Final ZIP member order, CRC and bytes against staged files | Pass |
| Built DLL / staged DLL / report hash agreement | Pass |

No standalone Python linter/type-checker is configured. Python syntax validation, executable tests, whitespace checks and the actual C# compiler were used; this report does not claim an unconfigured tool ran. The earlier complete `build.sh` run is recorded in `artifacts/build.log`; because review changed no product input, a second full asset/build/package run was unnecessary.

Final artifact independently checked:

- ZIP: `artifacts/WukongKnight-0.3.0-dev.zip`, **534,511 bytes**, SHA-256 `00a35bb7011608200bcdb8a0c3f4d0cc9d2ef08f79fd474e35ddc39240679a40`.
- DLL: **43,520 bytes**, SHA-256 `b89ef76c0dd2df71157d958a606e45ea33655cadbc9d0b76627b39a2abf8adec`.
- Manifest air settings: `jumpAttack`, `[4,7)`, reach `1.0`; exact generated manifest bytes are retained in the staged directory and ZIP.
- Report: all automatic checks true, `runtime_tested=false`, `client_acceptance=pending`.

## Acceptance limit

There is no installed/running Hollow Knight client in this review. Actual collision/FSM behavior, HP losses, nail/charms/soul, input cadence, landing/double-jump/directional/pogo behavior, low render FPS and Unity lifecycle/rendering still require the documented client checklist. Compilation against pinned v77 and newer compile-only Unity references is not evidence of exact client compatibility.
