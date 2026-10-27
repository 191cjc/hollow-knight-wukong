> Planning update (2026-10-27): the user selected attack cancellation plus each enemy's native default behavior and requested a development version. The revised ../prd.md, ../design.md and ../implement.md are authoritative. Earlier hurt-animation and research-only descriptions below are historical; no product implementation has started.

# 烈焰风暴强制受击：可行性与敌人名单

日期：2026-10-27。基线：`main@cadb864` / `0.7.6-dev`，Hollow Knight `1.5.78.11833` / Modding API `v77`。

## 结论

**实现方向在机制上可行，但需要按敌人的原生控制结构适配，没有统一的强制受击接口。当前调查得到候选名单，尚未得到满足全部要求的已验证支持名单。**

原生伤害、击退、`HIT`、`TOOK DAMAGE` 和 `STUN DAMAGE` 不能独立保证敌人停止攻击。对存在合适受击入口的敌人，可以研究在烈焰风暴实际造成非致命伤害后进入该入口；没有对应状态或结构未核实的目标保持正常伤害，不附加打断。

用户已经确认：**每次实际扣血都重新受击，包括上次受击尚未结束时。** 不能把重复命中简化成延长等待、继续播放同一动画，或使用会被下一次伤害提前解除的普通 Boss 眩晕而声称满足需求。

最新授权仅限可行性和名单调查。没有修改产品代码，没有启动实现，没有执行客户端测试。任务保持 `planning`。

## 名单与证据等级

“候选”只说明找到具体原生入口或控制器线索；不等于已确认可以安全打断任意攻击。以下名单不穷尽所有具有受击/眩晕机制的敌人。

| 对象 | 查到的原生结构线索 | 当前结论 | 仍需确认 |
| --- | --- | --- | --- |
| 普通爬墙敌人，内部对象 `Climber` | 固定 API DLL 中 `Climber.Stun()` → `DoStun()` → 播放 `Stun` → 恢复 `Walk`；历史场景清单 `Crossroads_01/_Enemies/Climber` 和 `Climber 1` 同时列有 `HealthManager`、`Recoil`、`tk2dSpriteAnimator`、`Climber`。 | **候选**。已找到真实原生临时受击/恢复逻辑及历史组件映射，尚未核实当前客户端配置。这里保留内部名称，未凭记忆添加图鉴名称。 | `Stun` 动画库、转向期间的原生跳过规则、重复动画从头开始、全部攻击资源归属。原生重复 `Stun()` 会重启等待，但普通同动画 `Play` 不保证重新播放。 |
| 格林 | 第三方源码读取 `Control/Stun`。 | **Boss 候选**，不是已支持。 | 原生入口/重组恢复、再次受伤如何退出、隐身和特殊攻击保护、独立攻击对象。第三方修改后的 `Stun → Reformed` 不当作原版出口。 |
| 梦魇之王格林 | 第三方源码读取 `Control/Stun`，另行处理气球阶段。 | **Boss 候选**，与普通格林分别核实。 | 重复进入、阶段和无敌保护、火柱等独立攻击。 |
| 纯粹容器 | 第三方源码读取 `Stun Air`、`Stun Land Y`，对 `LAND` 添加兜底。 | **Boss 候选**；`Stun Air` 只是已知中间状态，不能直接当通用入口。 | 完整入口、落地和恢复、攻击判定关闭、阶段保护、受击中的重复命中。 |
| 残破容器 | 第三方源码读取 `IK Control/Stun Start`，对 `LAND` 添加兜底。 | **Boss 候选**。 | 空中打断和落地恢复、再次进入、独立 `Spawn Balloon` 状态机与攻击判定。 |
| 大黄蜂（初战） | 第三方源码从原始 `Control/Stun Start` 提取资源；另有自行重写的眩晕流程。 | **Boss 候选**。重写流程帮助定位风险，不能代替原版动作证据。 | 原版冲刺/针攻击清理、落地/恢复、重击重启。重写流程展示再次受伤可能提前结束眩晕，必须专门处理此差异。 |
| 无上辐光的 `Stun1` 路径 | 第三方源码把 `Stun1` 与 `Phase Control/P4 Stun1` 血量阶段、相机和多个状态机联系起来。 | **排除这条路径**：阶段转换不能当逐次命中的受击动作。 | 尚未发现另一条独立、兼容的普通受击入口；不能据此断言该敌人绝无其他入口。 |
| 失落近亲、大黄蜂二战、辐光、其他 Boss | 当前公开材料未建立各自完整、可重入的原生受击契约。 | **未核实，暂不列支持**。不能从相似敌人或相同 FSM 名称继承支持。 | 各变体自己的入口、保护状态、重复命中、攻击清理和恢复。 |
| 其他普通敌人，包括历史组件清单中的 `Zombie Runner`、`Zombie Hornhead`、`Zombie Barger`、`Ruins Sentry 1`、`Mossman_Runner` 等 | 已查 C# `Walker`、`Crawler` 和若干命中特效组件；历史清单只能说明组件存在，不能给出完整序列化 FSM。 | **未核实，暂不列支持**。不能把停止行走、击退或闪光当受击状态，也不能因未查到而认定没有。 | 当前版本各敌人的实际状态机/动画、攻击退出和恢复。 |

**当前已验证支持数：0。** 这表示证据不足，不表示需求不可实现，也不表示候选敌人没有相应状态。不得以空适配器或仅能正常扣血作为功能完成。

## 可行性已确认到哪一步

1. **烈焰风暴可以接入实际扣血观察。** 当前 `FlameStorm` 经现有命中预算调用原生伤害；运行时已有 `HealthManager.Hit` 前后 HP 观察边界。额外反应必须绑定确切技能实例、施放令牌和实际目标，并避开嵌套回调的归因歧义，不能用碰撞或 `Spell` 类型直接判断。
2. **原生控制器确实存在临时受击并恢复的机制。** 固定 DLL 的 `Climber` 是具体证据；Boss 公开源码提供了多个原始状态名线索。尚未核实逐敌人的完整动作契约。
3. **重复重启是单独的要求。** 固定 DLL 的 `tk2dSpriteAnimator.Play` 对已经播放的同动画可能直接返回；`Recoil` 在已击退时也可能直接返回。真正支持必须同步保证控制流程、动画及其恢复重新开始，不能只重发事件。
4. **停止敌人本体不自动清除攻击。** 近战判定、持续发射、独立状态机或生成对象可能需要原生退出流程清理。只处理该攻击应退出的资源，不能用清空所有子对象/弹幕替代适配。

## 定稿支持名单所缺的材料

本地有固定版 `Assembly-CSharp.dll` 和只读元数据工具，但没有可读取的实际游戏安装、场景/预制体 `.assets`、完整敌人 FSM/动画库或真实 `PlayMaker.dll`。历史 Windows 安装路径、HookGen DLL、第三方源码及仅含组件名的场景清单都不能补齐这些证据。

下一步需要读取当前基线客户端的候选敌人对象，确认：

- 精确场景/变体、控制器和完整受击入口/恢复路径。
- 打断前后的攻击判定、相关状态机、无敌/死亡/阶段保护。
- 受击中再次实际扣血时，动画和状态重新开始；最后一次命中后正常恢复。
- 实机检查攻击前摇/攻击中/空中/受击中/致死/无敌等情况。

在得到这些数据之前，本调查可以给出上述候选与排除路径，不能给出可靠的最终支持白名单。

## 证据与可追溯来源

- `native-hurt-contract.md`、`native-hurt-il.txt`、`native-hurt-reentry-il.txt`：固定版原生伤害事件/HP 顺序、击退和动画重播限制。
- `native-controller-candidates.md` 及配套 `*-il.txt`：固定版 `Climber` 和其他控制器的完整调查范围、方法与限制。
- `boss-hurt-candidates.md`：逐 Boss 源码行号、不可混同的原版/重写行为、独立攻击资源和固定提交来源。
- `hit-path-and-native-state-evidence.md`：当前项目命中路径和归因边界。
- 历史场景清单：[EnemyRandomizerDB `5ee334b` / Crossroads_01](https://github.com/Kerr1291/EnemyRandomizerDB/blob/5ee334bdf9dff8ac0fb11f0aebc060c91eb40f84/EnemyRandomizerDB/SceneData/SceneData_Crossroads_01.xml#L9467)。`Climber` / `Climber 1` 位于 9467 / 9489 行，组件项位于 9486 / 9508 行。这是历史组件映射，不含 FSM 动作和动画配置，亦未声明匹配当前客户端基线。
- 同一固定提交的 `SceneData_Abyss_02.xml`、`SceneData_Deepnest_03.xml`、`SceneData_Fungus1_01.xml` 提供上述部分普通敌人 `Walker` 组件线索；它们同样不证明完整受击结构。公开下载仅保存在 `/tmp/wukong-hurt-feasibility-20261027`，关键结论已持久化于本任务。

本次仅进行了源码、固定 DLL 元数据和公开源码/历史场景清单调查。没有产品构建、部署或客户端验证。
