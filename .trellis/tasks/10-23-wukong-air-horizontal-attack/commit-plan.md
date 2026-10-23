# 提交计划（已获用户确认）

用户要求地面连击和空中攻击分别 commit。地面角色/四连击已有独立基线提交 `6be5bd6`（已推送）；本次创建空中攻击工作提交：`feat: add Wukong airborne horizontal staff attack`。

分支：`feat/wukong-air-horizontal-attack`，基线 `9517499`。
所有下列改动均由本次任务生成；无无法辨认的脏文件。

- `.trellis/spec/backend/character-assets.md`
- `.trellis/spec/backend/native-combat.md`
- `.trellis/tasks/10-23-wukong-air-horizontal-attack/check.jsonl`
- `.trellis/tasks/10-23-wukong-air-horizontal-attack/commit-plan.md`
- `.trellis/tasks/10-23-wukong-air-horizontal-attack/design.md`
- `.trellis/tasks/10-23-wukong-air-horizontal-attack/implement.jsonl`
- `.trellis/tasks/10-23-wukong-air-horizontal-attack/implement.md`
- `.trellis/tasks/10-23-wukong-air-horizontal-attack/prd.md`
- `.trellis/tasks/10-23-wukong-air-horizontal-attack/research/air-asset-implementation.md`
- `.trellis/tasks/10-23-wukong-air-horizontal-attack/research/air-assets-contract.md`
- `.trellis/tasks/10-23-wukong-air-horizontal-attack/research/air-quality-review.md`
- `.trellis/tasks/10-23-wukong-air-horizontal-attack/research/air-runtime-implementation.md`
- `.trellis/tasks/10-23-wukong-air-horizontal-attack/research/air-runtime.md`
- `.trellis/tasks/10-23-wukong-air-horizontal-attack/research/main-review.md`
- `.trellis/tasks/10-23-wukong-air-horizontal-attack/task.json`
- `CURRENT_STATUS.md`
- `README.md`
- `assets/processed/README.md`
- `data/character/wukong-staff.json`
- `docs/CHARACTER_ASSETS.md`
- `docs/CLIENT_ACCEPTANCE.md`
- `src/WukongKnight/CharacterAssets.cs`
- `src/WukongKnight/Core/AttackTiming.cs`
- `src/WukongKnight/Core/ComboTimeline.cs`
- `src/WukongKnight/NativeV77.cs`
- `src/WukongKnight/WukongKnight.csproj`
- `src/WukongKnight/WukongKnightMod.cs`
- `src/WukongKnight/WukongPresenter.cs`
- `src/WukongKnight/WukongRuntime.cs`
- `tests/WukongKnight.Core.Tests/Program.cs`
- `tests/WukongKnight.Core.Tests/WukongKnight.Core.Tests.csproj`
- `tests/test_animation_bake.py`
- `tests/test_character_package.py`
- `tools/bake_character.py`
- `tools/package.py`
- `tools/validate_character.py`

验证：28 项 Python、19 项链接生产核心的 C# 检查、Release 0 警告/0 错误、完整构建和独立全范围审查通过。

ZIP、构建输出与本地依赖由既有忽略规则管理，不加入源码提交。开发包已在本地 artifacts/WukongKnight-0.3.0-dev.zip。

客户端验收仍 pending，任务保持 in_progress；不归档当前或旧地面任务。
用户已确认分别提交两项功能。复用已推送的地面提交，并将上述空中攻击改动作为独立工作提交，推送到现有 origin 的功能分支（191cjc/hollow-knight-wukong）。

依据：用户回复“将刚刚的地面连击和现在的空中攻击分别commit提交”，确认按功能分别保留提交。
