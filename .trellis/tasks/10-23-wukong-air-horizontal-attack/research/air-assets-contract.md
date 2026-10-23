# Research: Air attack asset timing and shared contract

- Query: Introduce one airborne horizontal staff hit using existing `jumpAttack`; identify a visual hit window, a minimal asset/runtime contract, affected consumers, and meaningful contract checks.
- Scope: internal; archived source animation, actual baked preview, profile/manifest/bake/validation/package boundaries. Native IL and runtime hook integration belong to the separate runtime research.
- Date: 2026-10-23

## Findings

### 1. Actual visual and timing evidence

Inspected the real image `assets/processed/wukong/previews/jumpAttack-contact.png` with the image tool. It contains three unique sampled poses, labeled ticks 0, 2 and 4. The full animation is already baked, so this feature needs no new artwork, legacy parser capability or additional clip.

Read-only inspection of the checked-in original JSON and generated manifest found:

| Evidence | Observed value |
| --- | --- |
| Source `skeleton.json` root | DragonBones 2.3, `frameRate: 30` |
| `res.animation[name=jumpAttack]` | `duration: 10`, `autoTween: 0`, `tweenEasing: null`; no top-level frame list |
| Visible staff timeline `wq1` | Three source frame durations: 2, 2, 6 |
| Source events/actions/sounds in this animation and its timelines | None found |
| Generated clip | 10 one-tick records, `loop: false` |
| Generated pixel runs | `[0,2)` at atlas rect `(924,452,231,226)`; `[2,4)` at `(1155,452,231,226)`; `[4,10)` at `(1386,452,231,226)`; all atlas 0 |
| Existing preview GIF | Three merged frames lasting 70, 60 and 200 ms; total 330 ms |
| Exact runtime source clock | 10 / 30 = 0.333333… seconds before attack-rate scaling; GIF delays are only 10 ms review quantization |

Source evidence is at `assets/zmxy4/animations/2001/manV535/skeleton.json:1` (single-line JSON; JSON paths above). Generated duration and clip data start at `assets/processed/wukong/character.json:1665`. `tools/bake_character.py:85` chooses distinct preview poses; `:108` quantizes GIF boundaries, while `:156` samples every exact source tick and `:223` retains one record per tick.

The two early poses hold the staff across/behind the shoulders. At tick 4, the body leans forward and the staff extends forward and down. The character faces right. The image supports a forward attack controlled by horizontal input, but it does not depict a perfectly level staff thrust and does not justify inventing a different pose. There is no event in `jumpAttack` from which to infer original-game damage semantics.

**Recommended authored transplant settings, accepted by the coordinating session:** one half-open hit window `[4,7)`, `range_multiplier: 1.0`. This gives 4 ticks (0.133333… s) of startup, 3 ticks (0.1 s) of hit opportunity, and 3 ticks (0.1 s) of recovery under the existing held final pose. Window start matches the first visible forward strike; ending at tick 7 is a deliberate gameplay choice, not recovered AS3 behavior. Attack-rate scaling must apply consistently to all three portions through the shared core clock.

Do not infer native slash size from the apparent pixel length. Keep the original horizontal slash geometry and native range charms, with the existing authored multiplier 1.0. Only actual client inspection can establish the visual/collision match. The staff's slight downward angle does not authorize changing directional damage, adding downward knockback, pogo or a new gravity mechanic.

### 2. Pivot, canvas and direction remain established contracts

The generated canvas is 231 × 226; root `(119,174)` in PNG top-left coordinates; nominal body height is 101. Those values apply equally to `jumpAttack` and grounded clips (`character.json:2779` through `:2802`, exact fields). Keep all 10 source tick records and their common root. Do not crop/center each airborne frame, derive an airborne offset from its opaque bounds, or resize the body when the staff extends.

The current loader converts atlas rectangle Y and pivot Y independently at `src/WukongKnight/CharacterAssets.cs:91`. Retain that conversion. The baked image faces right; use the existing presenter's one explicit facing mapping. No second mirror or `jumpAttack`-specific sign inversion is needed. The hero's native transform/movement remains the basis for the airborne sprite position.

### 3. Minimal schema extension and compatibility decision

Recommend **character manifest schema version 2**, with a single required `combat.air_attack` object. Retain the exact four ordered ground stages, existing `chain_grace_seconds`, shared frame encoding and all 13 required clips. No generic action registry or fifth ground stage is needed.

```json
{
  "schema_version": 2,
  "combat": {
    "chain_grace_seconds": 0.35,
    "stages": ["existing four ground-stage objects, unchanged"],
    "air_attack": {
      "clip": "jumpAttack",
      "hit_windows": [{"start_tick": 4, "end_tick": 7}],
      "range_multiplier": 1.0
    }
  }
}
```

This is an illustrative excerpt; `stages` remain the current four objects, not strings. In `data/character/wukong-staff.json`, add the same `combat.air_attack` object; the baker already copies `profile["combat"]` into the manifest (`tools/bake_character.py:238`).

Why bump the character schema: the old 0.2 decoder requires version 1 (`CharacterAssets.cs:50`) and reads only `chain_grace_seconds` and `stages` (`:99`). Keeping schema 1 with a new required field would let an old DLL silently ignore the new air configuration. Version 2 makes old DLL/new resources fail the supported-version check and retain the original hero. New DLL/old resources should likewise fail before hiding the native body. Requiring the new field is necessary even with the version bump.

This is a small change to already affected consumers: baker output version, Python validator version, C# loader version, fixtures, docs and the generated manifest. The source profile version and generator algorithm version can stay 1: source sampling/atlas encoding is unchanged, and the existing fingerprint already includes profile, baker and validator hashes (`tools/bake_character.py:143`). Character-schema and build-report-schema numbers are separate contracts; `tools/package.py:112` currently uses build-report schema 2 and `tools/validate_character.py:193` uses validation-report schema 1. Do not mechanically change unrelated report versions.

Required air validation on both Python and C# boundaries:

- `air_attack` is an object and is present; reject missing/null/list values.
- Exactly the three fields `clip`, `hit_windows`, `range_multiplier`; reject a buffer, air chain grace, custom damage multiplier or other unimplemented semantics.
- `clip` is exactly `jumpAttack`, exists, has positive ticks and is nonlooping. Reuse its authoritative `duration_ticks`; do not duplicate 10 in the air configuration.
- Exactly one hit window, with integer (not boolean) `start_tick`/`end_tick`, satisfying `0 <= start < end <= clip.duration_ticks`. Half-open boundaries apply to damage and visual clock alike.
- `range_multiplier` is finite numeric, not boolean, within `[0.25,3]`, matching the existing Python grounded boundary (`tools/validate_character.py:170`). The current C# grounded loader is looser (`>0 && <=4`, `CharacterAssets.cs:109`); do not perpetuate that discrepancy for the new field. Align touched validation paths where practical.
- No `buffer_open_tick` in `air_attack`: it is a single attack. The core can use an explicit air-horizontal mode and the same monotonically increasing ownership token, as the runtime research recommends. It must not derive an air combo or replay buffered ground input from this object.

### 4. Affected files and current patterns

| File | Current behavior / expected work |
| --- | --- |
| `data/character/wukong-staff.json:13` | Add the required air object after the unchanged four ground stages. |
| `tools/bake_character.py:32` | Current profile validator is four-stage only; validate the air object before declaring a bake valid. Update generated character version at `:230`. |
| `tools/validate_character.py:75` | Require character schema 2. Combat validation currently ends after the four stages at `:156`–`:181`; add strict air validation and nonlooping clip rule. Update the frame-record error text at `:150` if it still names schema v1. |
| `src/WukongKnight/CharacterAssets.cs:28` | Update version-specific comment/check; expose decoded air definition to the runtime. Keep disposal on failed parse (`:40`) and do not enable native-body suppression after unsupported resources. |
| `assets/processed/wukong/character.json` | Regenerate to schema 2 with the air object and changed input/profile/code fingerprints. The source artwork and resulting atlas pixels need not change. |
| `tests/test_character_package.py:29` | Upgrade valid fixture to schema 2 and include `air_attack`. Existing invalid-schema mutation at `:67` currently sets 2, so change it to 1 or another unsupported version; otherwise it becomes a false negative. |
| `tests/test_animation_bake.py:189` | Extend the real deterministic bake/roundtrip check to retain air settings and existing 13 clips/common canvas/tick totals. Actual jumpAttack boundary tests can use its real three held poses. |
| `tools/package.py:12` | Advance the development package version together with the Mod version; keep DLL and schema-2 resources in one package. Update README prose at `:15`–`:28` and implemented metadata at `:116` to describe one authored air-horizontal strike while directional/pogo remain native. |
| `README.md`, `CURRENT_STATUS.md`, `docs/CHARACTER_ASSETS.md` | Replace stale claims that all air attacks remain native; document the one air-horizontal action, 10 tick duration, `[4,7)` authoring and schema-2 pairing. Do not describe air multi-stage combos as implemented. |
| `docs/CLIENT_ACCEPTANCE.md:26` | Split air-horizontal acceptance from native up/down/pogo preservation and add air/ground transition cancellation cases. |
| `data/generated/development-manifest.json` | Existing clip/frame/atlas counts stay 13/329/1 if pixels unchanged; keep `runtime_tested: false`. No inventory-count inflation merely because an existing clip gains gameplay use. |
| `.trellis/spec/backend/character-assets.md`, `native-combat.md` | Main session should update schema and gameplay-scope contracts after implementation/review. Researcher does not edit specs. |

Packaging itself already uses the validator's resource closure (`tools/package.py:38`, `:57`), copies exact manifest bytes and only referenced atlases, and excludes previews/extra DLLs. The new gameplay configuration introduces no new runtime file type, so no new recursive scan or package layout is needed. Build ordering is already source check → bake → validate → Python tests → C# core tests → Release → package (`scripts/build.sh:19`).

### 5. Meaningful tests and review gates

1. Extend the valid synthetic resource fixture with air configuration. Reject schema 1, missing/incorrect air object, wrong clip, looping air clip, zero/multiple windows, negative/reversed/out-of-range ticks, fractional/boolean tick values, nonfinite/boolean/out-of-range reach and unsupported damage/buffer fields. Ensure errors are validation failures rather than accidental ignored fields or uncaught type-index errors.
2. The real profile/bake roundtrip must preserve all four ground stages unchanged, produce the exact accepted air object, retain 10 `jumpAttack` tick records and a nonlooping clip, and still validate the original source/atlas hashes. Two clean bakes must remain byte-identical. The old schema-1 cache must be rejected/rebaked through the normal fingerprint/validation path.
3. A focused real-animation test can establish three held pose runs with boundaries at 0/2/4 and 10 ticks total, proving the air startup window is tied to the first forward pose. It should not claim that pixel equality proves actual game contact.
4. Stage/package the upgraded manifest and assert its air object survives byte-for-byte. Keep the existing package tests for precise closure, dependency exclusion, no previews, failure preserving the previous good package and ZIP reproducibility (`tests/test_character_package.py:110`, `:122`, `:131`). An invalid/missing air object must not replace an existing usable package.
5. Runtime/core testing is owned by the other research/implementation path: verify exact `[4,7)` boundaries under default and Quick Slash time scaling, one target token per accepted attack, no input buffering/automatic replay, repeats through normal native gates, landing/cancel closes damage, stale air cleanup cannot affect a new ground/directional action, and source tick progress survives low render FPS.
6. Review the actual existing `jumpAttack-contact.png` after regeneration if image content changes, and inspect final ZIP bytes/version/resources. A schema bump should not unexpectedly change the original atlas pixels. A package file count or successful decoder is not a gameplay test.

### 6. References and related specs

- `.trellis/workflow.md`: research is persisted; implementation and independent check follow the approved task artifacts. This file is research only.
- `.trellis/spec/backend/character-assets.md`: public canvas/root, rational ticks, provenance, finite authored windows, manifest-driven closure and client-status boundary.
- `.trellis/spec/backend/native-combat.md`: shared native damage path, fixed-step clock, responder/window ownership, cancellation and client-only semantics. It currently states ground-only ownership and must be revised with the implementation.
- `docs/CHARACTER_ASSETS.md:27`: source animation events are not executed as gameplay. For `jumpAttack`, read-only source inspection found no events at all.
- Original archived asset above is the primary visual/timing reference. No new external library, internet timing guide or modern DragonBones behavior is required for this task; previous validated legacy parsing research is intentionally not repeated.

## Caveats / Not Found

- No actual Hollow Knight client is available to this research. Rendering scale/facing in Unity, native hit geometry alignment, soul/charm/interaction behavior, gravity/movement continuity, low-FPS input feel and cancellation/landing/pogo acceptance remain pending.
- The authored `[4,7)` window and `range_multiplier: 1.0` are transplant design values. There is no recovered source damage event or AS3 hit implementation establishing that the original game used them.
- The GIF is a quantized looping review artifact; neither its 330 ms total nor its visual repetition defines runtime attack cooldown or looping semantics. Use the nonlooping 10-tick manifest and native runtime gates.
- Character-schema 2 deliberately rejects mismatched old/new assemblies and resources. Ship the complete new development directory/ZIP, and keep an old complete version for rollback; do not recommend replacing only the DLL or only the manifest.
- This report has read source/runtime decoder code only to establish the asset boundary. Native IL, hooks and exact airborne caller semantics are outside its ownership.
