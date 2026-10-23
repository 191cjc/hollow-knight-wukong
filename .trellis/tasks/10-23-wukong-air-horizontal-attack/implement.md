# 空中棍击实施计划

## Baseline / Authorization

- [x] 当前 main 内容已提交并同步 origin（9517499），开始前工作区干净。
- [x] 用户要求开始引入空中攻击，并回复确认单段空中水平棍击范围；按现有授权执行。
- [x] 已阅读既有 PRD/设计/实现、native-combat/character-assets 规范与共享思考指南。
- [x] 新任务独立记录，旧地面任务保留客户端待验收；工作分支 feat/wukong-air-horizontal-attack。

## Research and Contract

- [x] 核对 jumpAttack 实际预览、10 tick 与 [4,7) 窗口证据，持久化 air-assets-contract.md。
- [x] 核对原生地空门控/冷却、ShouldCancel、同名动画与 token，持久化 air-runtime.md。
- [x] 选定 schema2 + combat.air_attack；保留 ground stages 与图集结构，版本 0.3.0-dev。
- [x] 形成非空 implement/check 上下文（各 7 项），task.py validate 通过，已进入 in_progress。

## Implementation

- [x] 运行时代理扩展单核心双模式/单调 token、空中单段与模式边界、原生冷却释放、输入/展示和 schema loader。保留地面四段与接触列表清理路径。
- [x] 链接实际生产核心测试空中输入/窗口/去重/取消/Quick Slash/地空转换，共 19 项检查，原地面和清理回归继续通过。
- [x] 资源集成代理更新 profile/bake/validator/Python fixture/包与状态，28 项 Python 测试通过；不改原始素材/引擎引用/采样器。
- [x] 两方稳定后由集成代理运行一次完整 build.sh，产出 0.3.0-dev 包、报告、真实自动检查结果和哈希；Release 0 警告/0 错误，主会话再次核对 ZIP 与原地面配置。

## Quality and Handoff

- [x] 独立 trellis-check 全范围审查通过，无需代码修复；独立复跑 28 Python / 19 C# / Release 及闭包/散列检查，包未变化。详见 research/air-quality-review.md。
- [x] 主会话审阅实际 jumpAttack 预览与新运行时路径，更新可执行规范和验收/完成记录。
- [x] 开发包与验证结果已准备交付；客户端状态 pending，未执行的项目保持未勾选。
- [x] 用户已确认按地面/空中两项功能分别提交：地面已有 6be5bd6；空中改动独立提交至功能分支。客户端验收仍 pending，任务保持 in_progress。

## Commands

```bash
.tools/python/bin/python -m unittest discover -s tests -p 'test_*.py'
.tools/dotnet/dotnet run --project tests/WukongKnight.Core.Tests --configuration Release
bash scripts/build.sh
```

沿用 build.sh 的项目本地 DOTNET_ROOT/DOTNET_CLI_HOME/NUGET_PACKAGES。复查 schema、profile、package、status 端到端一致性，不以文件存在或静态常量相等替代行为测试。
