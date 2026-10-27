# Input swap implementation checkpoint

Date: 2026-10-27. User requested a session restart while implementation research
was in progress. No product code, tests or user-facing documentation have been
edited for this follow-up. The current mapping remains neutral quick spell to
Afterimage Combo, down + Dream Nail to Flame Storm. No new build or core test run
has been performed for this follow-up. Earlier draft checks are not swap checks.

## Authorized target and preserved scope

Neutral quick spell must start Flame Storm. Down + Dream Nail must summon the
independent Afterimage Combo. Keep costs exactly once, each skill's existing
damage/tier/clocks/assets/contact budgets, Storm's controlled action and successful
completion-only QuakeInvuln, and Afterimage's independent actor/ghost behavior.
Retain the existing airborne down-Dream eligibility. Other routes remain intact.
The pre-existing enemy-damage attribution draft remains unmodified and implements
no enemy interruption. No package/version/commit/deployment was started.

## Research completed and preferred implementation

Read the current code in FlameStorm.cs, FistSkills.cs, WukongRuntime.cs,
NativeSpellV77.cs and NativeDreamV77.cs, current user docs and owning native combat
sections, task follow-up plan, historical native evidence and git history.

The current Forward adapter holds Has Fireball? before taking hero control and
returns directly to Inactive. That release is appropriate for the existing detached
summon and cannot simply become the recovery path for a controlled Storm.

Preferred approach, researched but not yet applied:

- Restore the earlier known controlled Forward entry from git bf81c06:
  NativeSpellV77.Forward validates/holds the Fireball Antic animation completion
  (original ANIM END event), then releases through Spell End. Native eligibility,
  MP/direction/fireball unlock checks remain upstream; native spending/projectile
  states stay skipped. That historical production adapter supplies a source-backed
  control/recovery route without borrowing Dream control or requiring Dream unlock.
- Move the single Forward adapter's ownership/construction/disposal from FistSkills
  to FlameStorm. Poll each held antic once and use the existing controlled Soul
  transaction before beginning the unchanged Storm ledger/clock/damage. Successful
  Storm finish invalidates ledger/attribution first, releases Spell End, then grants
  existing native QuakeInvuln only after live/recoil/disposal rechecks. Cancellation
  and disposal grant no timer. Audit payment callbacks/reentry and stale held states.
- FistSkills retains only its Down spell adapter and reads its SoulCost, the same
  shared live Spell Control MP Cost variable. Route down-Dream to TryBeginSummon
  for Afterimage, capturing origin/facing, checking input once per frame and checking
  eligibility after native TakeMP. Use dream.CanBegin(native, true) for the old
  airborne down-Dream route. Never call Dream.Begin/Finish for the independent
  Afterimage summon. Godslayer remains the sole controlled Dream consumer; Ape
  remains an independent live-following effect.
- Adjust runtime constructors/observation/source suppression/lifetime as necessary;
  never leave duplicate Forward patches or finish another native cast. Preserve the
  scoped damage-attribution changes already present in Storm/runtime/Core/tests.

Historical evidence: git bf81c06:src/WukongKnight/NativeSpellV77.cs uses Fireball
Antic and Spell End for controlled Forward. Current v074 early-gate evidence is
reference/flash/fist/detached-v074.json and the prior task's detached-v074 report.
Native Dream gate/control evidence is reference/flash/fist/native-contract.json
and current NativeDreamV77.CanBegin. Full native-combat owning sections were read.

## Remaining work

1. Implement the preferred approach after checking constructor failure cleanup,
   active other-action/native cancellation boundaries, repeated observations,
   held inputs and payment callback revocation. No actual implementation exists yet.
2. Update current controls and acceptance in README.md, docs/SPELL_LAYOUT.md,
   docs/FIST_SKILLS.md and docs/CLIENT_ACCEPTANCE.md. Preserve newline conventions.
   Main session owns .trellis/spec updates and parent task lifecycle.
3. Run pinned-reference warnings-as-errors Release build and existing real linked
   Core tests; add tests only for a real changed production policy, not test-only
   input models or fake Unity APIs. Inspect actual native/compiled boundaries.
4. Independent Trellis quality review, then record exact files/check results.
   Keyboard/controller, native scene/control behavior and gameplay remain client
   acceptance work and must not be inferred from compilation.

Only this checkpoint file was created by the input-swap implementer before stopping.

## Implementation (2026-10-27, resumed session)

Implemented the preferred approach above. Files: NativeSpellV77.cs (Forward holds
Fireball Antic ANIM END, FinishCast -> Spell End; Has Fireball? no longer patched),
FlameStorm.cs (owns/disposes Forward, BlocksNativeSource, held-antic begin through
TryBeginControlled, Spell End stop, unpaid release of a held antic during
recoil/death/hazard/transition; attribution draft retained), FistSkills.cs (Forward
removed; down-Dream Afterimage via CanBegin(native,true)+TryBeginSummon; SoulCost
from Down adapter), WukongRuntime.cs (constructors, Storm source blocking),
FistRules.cs comment. Docs: README, SPELL_LAYOUT, FIST_SKILLS, CLIENT_ACCEPTANCE;
spec native-combat/index; AGENTS.md note.

Checks: pinned Release build 0 warnings/0 errors; 81 Core checks pass (no new
policy needed: payment transactions are the existing linked FistRules helpers);
CRLF-aware diff --check clean; task validate passes. Client checks pending.

Independent review: one high finding fixed — TryBeginControlled's pre-acquisition
Soul/cost rejection skips cancel, which could leave Fireball Antic held with
control relinquished; FlameStorm now releases via Spell End on any rejection
(mirrors Earthbreaker). Rebuilt 0/0; 81 Core checks pass. Noted pre-existing
pattern (not new): adapter Dispose skips FinishCast when CanRecover is false.
