# Initial Findings: Wukong Character and Basic Attacks

Date: 2026-10-23. Read-only evidence collected before implementation.

## Existing implementation

- `src/WukongKnight/WukongKnightMod.cs`: the only product C# source; initializes a log-only scaffold and reads an embedded development manifest.
- `src/WukongKnight/WukongKnight.csproj`: net472, nullable enabled, warnings as errors, deterministic builds; references only API Assembly-CSharp and framework reference assemblies.
- `scripts/build.sh`: asset validation and catalogue generation, Release build, then development packaging.
- `tools/package.py`: currently packages only DLL and README; a playable build will need its generated character assets included.
- Existing `artifacts/build.log` reports a successful scaffold build with zero warnings and errors. No new build or game execution was performed during discovery.

## Animation evidence

Source: `assets/zmxy4/animations/2001/manV535/skeleton.json` and `texture.json`.

- DragonBones 2.3, 30 FPS, main armature `res` with nested equipment and effects armatures.
- Ground attacks: attack1 12 frames, attack2 15, attack3 18, attack4 20.
- Other relevant clips: idle 22, walk 24, runNormal 12, runAttack 15, jumpNormal 35, jumpTwo 12, jumpAttack 10, jumpDown 35, hurtStand 49, dead 65.
- Equipment display names resolve to bundled sub-armatures such as `装备/fashion_wq1` and `装备/fashion_yf8`; their image display entries are present in the atlas. A composed default appearance appears feasible from local assets, but has not been rendered or visually verified.
- Conversion must account for DragonBones 2.x transforms, negative scales, nested armatures, display selection, pivots, tweening, z ordering and color/alpha transforms. Do not silently use newer-format assumptions.
- Python Pillow, NumPy and dnfile are not currently available in the inspected Python environment. Any required tool dependency must be reproducible rather than assumed present.

## Original attack records

Evidence: role 2001 in `data/source/roles.xml`, matching records in `data/source/skills.xml`.

| Action | ID | Raw cd | Raw attMax | Raw attInterval |
| --- | --- | --- | --- | --- |
| attack1 | 1001010 | 400 | 1 | 0 |
| attack2 | 1001020 | 500 | 1 | 0 |
| attack3 | 1001030 | 600 | 2 | 166 |
| attack4 | 1001040 | 667 | 1 | 0 |
| runAttack | 1001060 | 500 | 1 | 0 |
| jumpAttack | 1001070 | 334 | 1 | 0 |

All six records consume zero MP. Raw configuration units and event semantics remain untraced; these are evidence for a proposed transplant design, not established Unity timings. The third ground attack has a multi-hit configuration, so a cosmetic four-frame selector would not establish behavioral reproduction.

## API and build references

- Local `Assembly-CSharp.xml` documents `ModHooks.AttackHook`, `AfterAttackHook` and `HeroUpdateHook`, plus game/save/scene lifecycle hooks.
- Local API release contains Assembly-CSharp, MMHOOK_Assembly-CSharp, MMHOOK_PlayMaker, Newtonsoft.Json, Mono.Cecil, MonoMod DLLs and mscorlib, but no UnityEngine or PlayMaker implementation/reference DLLs.
- Pinned SDK executable exists under `.tools/dotnet/dotnet`.
- Read-only inspection of the official v77 GitHub release confirmed Linux, macOS and Windows API archives. It did not establish a source for the missing game/Unity compile references.
- A NuGet search for HollowKnight found templates/build helpers, but did not establish a ready compatible reference package. Further reference acquisition research is required before a concrete runtime build plan.

## Scope updates after initial discovery

- The user subsequently chose an independent four-stage staff combo, then confirmed that air/directional attack rules and pogo remain native. There is no independent running/aerial mechanic in this task.
- Current authoritative requirements and proposed nail/charm behavior are in prd.md; native integration and animation details are refined by runtime-integration.md and animation-conversion.md.
- Actual-client compatibility and acceptance must be recorded against the selected baseline. No game installation was identified during earlier setup.
