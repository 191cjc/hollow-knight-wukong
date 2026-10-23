# 实施与验证计划

## Entry Gate

- [x] 用户授权创建任务并规划。
- [x] 用户选择实际四段棍系连击。
- [x] 用户确认仅接管地面水平攻击，保留空中/方向攻击及下劈弹跳。
- [x] 完成研究、PRD 收敛、方案一致性自查与上下文清单校验；已补充并行资源协议，最终实现上下文 7 项、检查上下文 10 项（含代码归纳规范与完成记录）。
- [x] 用户在最终方案后明确回复“开始吧”；已 start，状态为 in_progress，工作分支 feat/wukong-character-basic-attacks。

勾选项有实现或自动检查记录；客户端检查仍保持待验收。

执行分工：asset_implementation 负责烘焙/配置/Python 动画测试，runtime_implementation 负责 C#/连击测试，build_integration 先准备共享依赖以解除编译阻塞，再负责构建/校验/打包和文档。所有代理使用 research/runtime-asset-contract.md，不覆盖对方文件。

## Milestone 1: Reference and Animation Prototypes

1. [x] 核对已固定的 API DLL/研究签名；准备固定版本与散列的 Unity 编译引用、图像工具环境，不改动游戏目录。
2. [x] 按实际数据与历史解析器证据，实现最小 idle/attack1 烘焙原型，验证全局变换、默认装备、枢轴、隐藏项及半透明填充值处理。
3. [x] 生成可视预览，核对完整默认人物与棍子。若出现部件缺失/错位，先修正转换，不以无效帧推进游戏接入。
4. [x] 完成原生普通攻击接入的最小编译/时序原型，验证所需成员、Hook 顺序、私有冷却/状态和 Slash 激活/取消路径；特别核对 FixedUpdate 延迟、DamageEnemies 重复回调与 HealthManager 命中无敌。源码/自动检查不等于第三段已实机产生两次 HP 损失。
5. [x] 若上述原型发现需改变玩法范围或重写原版核心，回到规划；常规局部数学修正不扩大范围。

## Milestone 2: Assets and Runtime

可以在正式清单/连击配置协议确定后并行分派两个 trellis-implement；每个提示以 Active task 路径开头，声明文件所有权及共享工作区约束。研究和协议通过原生上下文注入，缺失时由子代理读取任务。

**资源代理所有权**：烘焙与采样工具、图像依赖锁、角色/连击数据配置、Python 转换测试。不得修改 src/、集成脚本或对方测试。

1. [x] 实现固定脚底原点、图集与帧偏移协议，并将 13 个约定动作全部烘焙。
2. [x] 从四段实际预览确定移植用前摇、命中、收招帧和判定形状，清楚区分源证据与设计值。
3. [x] 输出动作预览、图集与清单，包含源散列、尺寸、帧率、裁剪偏移及全部引用。
4. [x] 验证缺失时间轴、隐藏装备、alpha=1 填充、负缩放、Z 顺序及嵌套变换；为风险点添加可证伪的测试。

**运行时代理所有权**：src/WukongKnight/、csproj、无引擎 C# 连击测试。按已定协议消费资源，不自行更改协议或集成脚本。

5. [x] 分离纯逻辑连击核心与 Unity/原生攻击适配，记录四段时序和至多一个缓存输入。
6. [x] 实现图集加载、校验、孙悟空视图与基础状态映射，资源成功后才隐藏原骑士本体。
7. [x] 接入地面水平攻击的原生事务，按各段窗口启停判定，第三段两次命中并去重；恢复/保留骨钉、护符、魂和可破坏物交互。
8. [x] 方向/空中攻击走原版，保留下劈弹跳；孙悟空身体使用明确姿势映射，上/下劈方向由保留的原版斩击特效表达。
9. [x] 在超时、第四段结束、跳跃、冲刺、受击、死亡、换场、退出及禁用路径清理视图/判定/缓存/订阅并恢复状态。
10. [x] 用实际核心代码验证四次输入、单次输入不自动四连、缓存上限、截止时间边界、取消恢复和每窗口/每目标去重，不以静态配置相等作为测试。

## Milestone 3: Integration and Review

资源和运行时完成后派 trellis-implement 进行集成，所有权为依赖准备、现有构建/校验/打包脚本、清单和用户文档；不得覆盖两个代理的已验证修改。

1. [x] 固定图像依赖与 Unity 引用下载/散列，扩展 bootstrap 并允许用户以自己的兼容 Managed 引用覆盖。
2. [x] 将资源生成/校验接入 build.sh，保留原始素材重解包与散列校验；避免无必要地每次烘焙未改变输入。
3. [x] 打包器使用正式清单收集资源并检查完整性，只打包 Mod DLL、加工素材与说明。
4. [x] 更新开发状态/构建报告协议，区分已实现、自动检查通过和 runtime_tested；未实际执行的客户端验收保持 false/待验收。
5. [x] 更新 README、CURRENT_STATUS、素材/动画说明与安装验收清单；保留原始来源、处理规则和可重复命令。
6. [x] 按任务全范围分派 trellis-check，修复规范、类型/编译、资源协议、测试和包内闭包问题，形成最终检查记录。

## Planned Validation Commands

命令路径随实现落地；不能在交付中将本节的计划标为已通过。

```bash
python3 tools/bootstrap.py
.tools/python/bin/python -m unittest discover -s tests -p 'test_*.py'
.tools/python/bin/python tools/bake_character.py
.tools/dotnet/dotnet run --project tests/WukongKnight.Core.Tests --configuration Release
bash scripts/build.sh
```

脚本中沿用项目 DOTNET_ROOT/DOTNET_CLI_HOME/NUGET_PACKAGES 隔离方式。构建脚本需以约定 Python 环境执行需要图像依赖的步骤，避免系统 Python 缺 Pillow。

预览验收：查看实际生成的 idle、run、jump、attack1–attack4 动画与联系表，记录发现和修正；不能只检查 PNG 能解析。

包验收：逐项校验清单引用、尺寸/散列、预期 DLL 与资源、路径安全和排除游戏/API DLL。已有素材校验继续运行。

## Client Acceptance (Pending until Performed)

1. 核对 Hollow Knight/API/平台和编译引用所使用 API 的可用性；安装至实际 Mods 目录。
2. 新游戏/读档，检查日志与孙悟空默认外观、左右朝向、基础移动/跳跃/受击/死亡。
3. 分别按一次、连续四次、过早多次、超时后再按；验证输入缓存、四段顺序与恢复。
4. 对单个与多个敌人验证 1/1/2/1 次命中窗口，检查重复碰撞、伤害、击退、魂及可破坏物；验证不同骨钉与适用护符。
5. 验证空中水平攻击、上劈、下劈弹跳以及跳跃/冲刺/受击取消。
6. 换场、死亡重生、反复进入存档、禁用/恢复 Mod，检查无重复对象、残留伤害、隐形或控制锁。

## Finish and Rollback

- 自动检查和检查代理通过后，主会话总结真实结果并更新相关可执行规范；按流程准备提交与会话记录。
- 缺少客户端时交付可检查代码、预览和开发包，单列未完成的实机验收，不能标为角色实机已通过。
- 原始素材和游戏目录保持原状；移除/禁用 Mod 可恢复。未获最终方案批准前不执行 start、产品实现、部署或发布。

## Final Implementation Checkpoint (2026-10-23)

- 全范围独立审查已通过。修复取消后的原生接触列表残留，新增真实生产代码的安全清理回归检查；详见 `research/quality-review.md`。
- 最终完整构建通过：23 项 Python 测试、10 项 C# 检查，Release 0 警告 / 0 错误，资源与 ZIP 闭包校验通过。
- 当前开发包为 `artifacts/WukongKnight-0.2.0-dev.zip`；最终大小与散列见 `research/verification.md`、`artifacts/build-report.json`。
- 已更新可执行规范和当前状态；`runtime_tested=false`，PRD AC1–AC6 仍待客户端验收，任务保持 in_progress。
- 用户随后明确要求上传至 `https://github.com/191cjc/hollow-knight-wukong.git`，已授权初始完整项目提交及推送；按更新后的 `commit-plan.md` 执行，目标分支 main。不归档未完成实机验收的任务。

## Repository Upload

- 用户明确授权的完整项目已提交为 `6be5bd603fd8cd8e28611500277236393572f07c` 并上传至 `https://github.com/191cjc/hollow-knight-wukong` 的 main 分支；已核对远端 SHA。
- 使用既有 SSH 身份完成推送，原始素材与工程配置纳入初始基线；依赖缓存和生成产物保持忽略。
- 继续保留客户端待验收状态，任务未归档。
