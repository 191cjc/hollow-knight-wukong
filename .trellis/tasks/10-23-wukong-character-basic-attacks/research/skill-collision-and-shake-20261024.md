# Skill collision and landing shake investigation

## Skill hurtbox correction (0.4.2-dev)

Both skills query the actual native Attack (17) collision mask, excluding native
ignored layers 9/20/26/31 and Geo contacts. The shared NativeV77 resolver only
routes a HealthManager hit from an Enemies (11) collider. Hornet's layer-13
Refight Range (43.8482 x 3.6616), A Sphere Range and Buzzer Alert Range are sensors,
not hurtboxes. Hornet's layer-17 Needle Tink is also ineligible to damage its boss
ancestor even though Attack contacts are permitted by the matrix. Non-health
native responders remain eligible; legitimate trigger hurtboxes are not blanket
disabled. Filter before target deduplication, hit caps or TAKE DAMAGE events.

Fire Demon's air art and hit region move together by 0.25 native hero collider
heights upward, keeping their world anchor and original dimensions. Finisher
placement is unchanged. The native Quake1 Land and Q2 Land actions send BigShake
to CameraParent/CameraShake; NativeSpellV77 disables only those matched actions
and restores their original Enabled values on disposal/failed initialization.
Other camera shake events remain available. The old artwork variants are intact.

Client checks: cast far from Hornet and flying enemies and verify no HP loss;
then contact their bodies and verify damage, caps and native evasion. Check
left/right elevated air placement and both finisher tiers without inherited
landing shake; confirm disable/re-enable restores native actions.

Evidence: local level133 (Hornet Boss1), level37 (Angry Buzzer), globalgamemanagers
TagManager/Physics2DSettings and resources.assets Spell Control FSM. Read-only
UnityPy extraction is saved in enclosing work/skill-enemy-collider-evidence.json;
native DamageEnemies/HitTaker IL in work/skill-collider-native-review.txt. Native
Attack mask is 2184845768 (layers 3/6/7/8/11/12/17/19/20/21/25/31). Both native
Quake landing states have exactly one SendEventByName(BigShake). Actual game
Assembly-CSharp defines sendEvent:FsmString; PlayMaker defines FsmStateAction's
Enabled boolean property. No blanket global camera patch is used.

Implementation uses shared SkillTargetPolicy (actual production core linked to
tests), NativeV77 resolver and filtered queries in both skills. Three regression
checks cover extracted detector/weapon cases, ledger non-consumption and native
non-health interactions. New build/install evidence will be appended after checks.

## Completed verification

- Release warnings-as-errors build passed; 23 actual production C# core checks.
- 36 Python checks passed, one explicit Windows symlink-privilege skip.
- Source inventory/atlas validation passed with original assets unchanged.
- Actual 0.4.2 atlas-derived preview reviewed; air visual moved upward without
  changing the finisher or rebaking artwork.
- Native PlayMaker FsmState.ActivateActions IL checks get_Enabled before OnEnter;
  set_Enabled writes the enabled flag. Thus the matched disabled actions will
  not send their BigShake events. Evidence is in enclosing
  work/skill-shake-enabled-native-review.txt.
- Shared target filtering reviewed at all three query sites and before ledger/FSM
  writes. Existing ownership/evasion guards remain in place; failure/disposal
  restores scoped native action/render/collider patches.
- Package and installed closure: 24 files, hashes matched.
- Installed with game stopped: 2026-10-24T11:16:18.809846+08:00.
- Previous complete Mod backup: `C:\Users\19122\Documents\Codex\2026-10-23\qin\work\backups\installed-WukongKnight-before-0.4.2-20261024-111618.zip`.
- DLL SHA256: `b2d11cce482d249ed1dccc4be96c385a6b780a59ccc38927fb2b095e5c42d245`.
- ZIP SHA256: `542f392c74ad358474125c63b9098f862c85df4bcdeb0e77f830c39652ad2b03`.
- No game/API/save changes. Actual combat/placement/camera acceptance is pending;
  runtime_tested remains false and the task remains in_progress.
- Inline review followed trellis-check and trellis-update-spec. Native combat
  contract, package notes and client acceptance were synchronized. No .git exists
  in this downloaded checkout; no commit or push was performed.
