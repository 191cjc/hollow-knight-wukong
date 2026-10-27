# Follow-up: Afterimage / Storm input swap

User request (2026-10-27): “然后几个按键交互换一下，残影连击和烈焰风暴换一下”.
This is an authorized, bounded implementation follow-up in the active task.

## Change boundary

Current: FistSkills consumes NativeSpellV77.Forward at the native Has Fireball?
gate and immediately releases it after summoning Afterimage. FlameStorm consumes
down-Dream, acquiring the shared NativeDreamV77 for its controlled action.
Target: neutral quick spell starts Storm; down-Dream summons Afterimage.

Input acquisition lives in FistSkills.Observe and FlameStorm.Observe, with adapter
construction/lifetime in WukongRuntime.TryAttach/Detach. The forward adapter's
current early gate and direct Inactive recovery assume an independent summon;
do not blindly use its recovery to end a controlled Storm. A small ownership/
entry refactor may be required so the exact existing native cancellation and
recovery contracts remain coherent. Reuse verified hero native evidence; missing
enemy FSM data does not block swapping hero skill input routes.

Expected product paths: FistSkills.cs, FlameStorm.cs, WukongRuntime.cs and only
if required NativeSpellV77.cs / NativeDreamV77.cs. Source-backed Core changes/tests
are justified only for a real changed policy. README.md, docs/SPELL_LAYOUT.md,
docs/FIST_SKILLS.md and current docs/CLIENT_ACCEPTANCE.md checks must agree with
the new routes. Preserve each existing file's newline convention.

## Execution / review

1. Read the latest owning native-combat spec (especially native spell gates,
   shared Dream, directional control/recovery and the unreleased draft limits).
2. Choose the smallest safe entry/ownership change. Implement the two mappings
   while retaining summon independence, damage/tier/budget/artwork, single Soul
   payment, native cancellation and completion-only Storm recovery protection.
3. Inspect same-frame observations, held input, rejection/no-Soul, reentry from
   payment/native callbacks, death/hazard/scene/dispose, shared Dream isolation
   and down-spell Earthbreaker. Recheck identity after native callbacks.
4. Run production-linked Core checks and the pinned Release build. Inspect actual
   native/compiled call boundaries when needed; do not invent Unity substitutes
   or mirror tests. No artwork regeneration or enemy adaptation is in scope.
5. Independent Trellis check reviews this follow-up diff and its interaction with
   the preserved attribution draft. Record checks, unresolved client acceptance
   and precise changed paths in research/input-swap-implementation.md.

Keep the original interruption PRD/design/plan as the background scope; this
follow-up supersedes only the earlier down-Dream/neutral-spell input mapping.
Do not mark the parent task complete or package the unused attribution draft.
