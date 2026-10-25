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

## Fire Demon Slash checkpoint (2026-10-24)

- User authorized fixed spell balance and routine direct installation.
- Implemented independent original-source air/finisher contact regions and caps,
  fixed spell-tier/Shaman damage; suppressed native Quake damage/graphics.
- Preserved previous original/variant folders and generated a separate 27-clip
  offline 1.5x variant. Body and world effect remain separate.
- 36 Python passed / 1 Windows symlink skip, 18 linked production C# checks,
  Release warnings-as-errors and package/installed 24-file closure passed.
- 0.4.0-dev installed with verified previous-Mod backup; API/save untouched.
- Source masks and contact rules are retained; finisher timing is intentionally
  adapted to native landing. All gameplay acceptance items remain pending.
- See `research/fire-demon-implementation-20261024.md` and build report for hashes.


## 0.4.2 user-reported skill corrections

Reject sensor/weapon colliders that previously routed room-wide damage to boss
HealthManager ancestors. Share native layer/hurtbox filtering across both skills.
Raise pre-finisher air art and damage by 0.25 native hero collider heights and
suppress only the inherited Quake landing BigShake actions, restoring on cleanup.
Preserve native movement, original art, dimensions, immunity and fixed damage.
Build, run regression checks, back up and install with the game stopped; gameplay
acceptance remains pending. See research/skill-collision-and-shake-20261024.md.

0.4.2 checkpoint: all automated/build/package checks passed; installed with verified backup and hashes. Gameplay remains pending.


## 0.4.3 source presentation restoration

The user supersedes centering/raising and the native landing adaptation. Restore
original directional spawn and mask conversion, use the untouched main effect5
character flashes/blink gaps, and trigger the finisher on air-effect expiry in
midair. Hold native antic through the source clock, then restore through native
Quake Finish/Spell End without forced diving. Preserve full-cast immunity, fixed
damage and the 0.4.2 hurtbox filter. Reuse existing original assets; do not overwrite
any originals/variants. Run source-image/core/build/preview/closure checks and
back up/install directly. See research/fire-demon-source-restoration-20261024.md.

0.4.3 checkpoint: complete automated/build/preview/package checks passed; installed with backup and matching hashes. Source artwork unchanged; gameplay remains pending.


## 0.4.4 Fire Demon movement correction

The user reports drift from movement input during the extended custom cast.
Maintain native input denial, neutral axes/velocity and no gravity throughout
preparation, air and finisher; observe before input and around native physics.
Keep original updates running and source effect5 animation/midair finisher,
damage/immunity unchanged. Release before native recovery and stop writes on
cancel/detach. Build/check, back up/install and verify; client movement, pause
and recovery acceptance remains pending. See research/fire-demon-movement-lock-20261024.md.


## 0.5.0 execution

- [x] Commit complete current state before edits (a07b2ac; no push).
- [x] Persist scope/design/source-native research before implementation.
- [x] Implement up/down/focus adapters, actual-damage buff and Storm local contacts.
- [x] Create new source bake/variant, preserving prior original artwork/folders.
- [x] Add meaningful production-core and real source-image/mask checks.
- [x] Run complete fresh Windows export, warnings-as-errors Release and closure checks.
- [x] Review source frame previews, cross-layer contracts and lifecycle cleanup.
- [x] Update specs/docs and install with complete backup and stopped game.
- [x] Verify package/installed hashes; record evidence and pending gameplay.

0.5.0 checkpoint: package `f369de9c912766fed6071d4f25c1d7d4d201b43fa21d5ae65946022b01304b3c`,
DLL `6233aefc6348665d10a2f42ccddc840c3cc00224eb9bfff9b66c1d1c1099ea9c`, 25 installed
files with a complete previous-Mod backup. 42 Python checks (41 passed, one Windows
symlink privilege skip), 38 production C# checks and Release compilation passed.
Gameplay acceptance remains pending; parent task stays in_progress.

## 0.5.1 execution

- [x] Record original motion and buff-symbol provenance.
- [x] Restore controlled source travel and align final effect/damage.
- [x] Decode/pack original aura in new unscaled and offline1.5x folders.
- [x] Render aura for the exact existing buff lifetime and update public name.
- [x] Run production/source checks, Release compilation and visual review.
- [x] Back up/install, verify closure/hashes and preserved assets; record results.

0.5.1 checkpoint:45 Python passed/one symlink-privilege skip,41 production C#
checks and Release passed; source previews and25-file install verified. Previous
Mod fully backed up;252preserved assets/738existing frames unchanged. ZIP
`fd70a08e8dfa8aa67e07679f1f88a2839cb43f01293e56105a0f5820a309db8f`; DLL
`d325708ba16679d11459e753d30969d540c3ff586d796188c8fe75fe05318e3e`. See
research/source-motion-fire-eye-v051-20261024.md; client acceptance pending.


## 0.5.2 casting overlay execution

- [x] Identify original overlay, child transforms and source attachment semantics.
- [x] Preserve full existing asset hash baseline and persist scope/design/plan.
- [x] Add bounded original effect4 reader and complete cast clip/new art profile.
- [x] Route native focus presentation to composite with immediate cancel cleanup.
- [x] Verify real original frames/nested clocks/scaling and review final previews.
- [x] Run full fresh export, production tests, Release and package closure.
- [x] Back up/install with game stopped; verify all files and preserved assets.
- [x] Record evidence, specs and pending client visual acceptance.


0.5.2 checkpoint:49 Python passed/one Windows privilege skip,41 production C#
checks and warnings-as-errors Release passed.27package/installed files and ZIP
bytes verified with complete0.5.1 backup;285preserved files and748old frames in
both sizes unchanged. Both-facing actual atlas previews reviewed. ZIP
`84ba8f2480f3df47eee34e5f339f8ead8a4364ab6093d023a95c2ecb4a3a630a`; DLL
`9ad0bb14f35a5d208dd685faf7569cc0474859908bc510405cef7ead7a7eb29f`. Gameplay acceptance pending.


## 0.5.3 Fire Eye clock execution

- [x] Trace source clock, native Soul drain and startup freeze; record boundary.
- [x] Preserve all current original/variant artwork hashes before edits.
- [x] Add scaled30Hz cast lifecycle clock and use it for source sampling.
- [x] Hold only final body after overlay; retain native complete/cancel behavior.
- [x] Add production clock regressions for start, repeats, pause, reset and end.
- [x] Run fresh Python/core/Release/package checks; verify preserved art hashes.
- [x] Back up/install stopped-game update; verify full package/installed bytes.
- [x] Update contracts/status/research with pending client pacing acceptance.


0.5.3 checkpoint:49Python passed/one Windows symlink privilege skip,45production
C# checks and warnings-as-errors Release passed. All27package/installed files
and ZIP bytes verified;322preserved assets and25character files unchanged.
Complete0.5.2 Mod backed up; client pace/charm acceptance remains pending.
ZIP `b25c3485e29f8e1942b257faa24bd6a9bb3014271b0dbd8d206d11958ac05158`;
DLL `58d40a2c099e115c29d49a298c2d45b59b9646d24ae0e607a32264b7e5c29a7d`.


## 0.6.0 nail visuals execution

- [x] Identify original combo/air/up overlays and native slash ownership.
- [x] Preview source up/down rotation; preserve322existing assets and plan scope.
- [x] Extract bounded single-bone image reader without changing flame pixels.
- [x] Bake seven new clips/new profile/offline1.5x variant and source regressions.
- [x] Replace actual hero mesh submissions and choose native directional poses.
- [x] Review both-facing actual atlas previews and all previous registered frames.
- [x] Run full fresh Python/core/Release/package checks.
- [x] Back up/install with stopped game; verify exact package/installed closure.
- [x] Update source evidence/contracts/status and pending gameplay acceptance.


## 0.6.1 native charm arc size

- [x] Verify original StartSlash scale/M animation and preserve prior assets.
- [x] Export7arc-only clips to new original/offline1.5x folders.
- [x] Split runtime body/arc and apply actual native selected-slash scale ratio.
- [x] Check all105new source frames and874old frames at each size; preview sizes.
- [x] Run fresh Python/core/Release/package checks; review lifecycle/contracts.
- [x] Back up/install while stopped, verify all files/ZIP and record evidence.


## 0.6.2 presentation execution

- [x] Trace native downward flag and focus drain timing; snapshot prior artwork.
- [x] Add downward-only flame composite and new original/offline1.5x folders.
- [x] Align source casting end to native focus deadline; retain30Hz/cancellation.
- [x] Check source/pixels, all979old frames, deadline regressions and previews.
- [x] Run fresh Python/core/Release/package checks and review compiled adapters.
- [x] Back up/install with game stopped; verify exact files/ZIP and record evidence.


## 0.6.3 immunity and death execution

- [x] Trace actual death coroutine/prefab and original source death; re-download.
- [x] Archive/extract matching source separately and preserve current art hashes.
- [x] Extend incoming damage guard to actual active Flame Dash lifetime.
- [x] Play source death despite native mesh disable; suppress/restore native visuals.
- [x] Check source death/ghost pixels, clock lifetime and compiled hook boundaries.
- [x] Fresh full build/package; back up/install stopped game and verify all files.
- [x] Record evidence/specs/status and pending client death/dash acceptance.


## 0.7 fist skills execution

- [x] Commit current workspace checkpoint e44de07 before new implementation.
- [x] Snapshot current asset/report hashes and inspect native Dream Nail/Fireball.
- [x] Trace WK2 source clocks, masks, clone behavior and complete art layers.
- [x] Add new original/offline1.5x fist clips preserving all earlier artwork.
- [x] Implement neutral Afterimage Combo and four persistent mimic afterimages.
- [x] Implement charged Godslayer native dream interactions, Earthbreaker and Ape.
- [x] Integrate presentation/input/damage/cleanup without prior-skill regressions.
- [x] Add meaningful clock/token/damage/source-image regressions; inspect previews.
- [x] Run fresh checks/build/package, back up/install stopped game, verify hashes.
- [x] Update specs/status/research; retain pending gameplay acceptance.


## 0.7.1 execution

- [x] Verify native spell cost selection and source clone/max-charge evidence.
- [x] Implement one-time paid directional Dream casts and forced Godslayer release.
- [x] Generate unsquashed offline clone poses in new preserved folders.
- [x] Run production/core/source/pixel/Release/package checks and preview.
- [x] Back up/install with game stopped; verify installed hashes.
- [x] Update evidence/contracts/status; gameplay remains pending.


## 0.7.2 execution

- [x] Inspect native down-slam recoil and current ghost/movement ownership.
- [x] Remove completed/canceled copied ghosts and centralize faster descent.
- [x] Use native slam-strength fist recoil without changing other spells.
- [x] Run meaningful core/full build/package checks and preserve artwork hashes.
- [x] Back up/install stopped-game update; verify all installed files.
- [x] Record contracts/evidence/status with gameplay acceptance pending.


## 0.7.3 execution

- [x] Verify native HP/recoil/Invulnerable and Dream cancellation evidence.
- [x] Add final-only native slam recoil and scoped Earthbreaker immunity.
- [x] Add Fire Ape damage-resistant ownership without changing native HP paths.
- [x] Test lifetime boundaries, inspect compiled hooks, and run full build/package.
- [x] Preserve all character hashes; back up/install with game stopped and verify.
- [x] Update evidence/contracts/status; retain pending gameplay acceptance.
