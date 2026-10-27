> Planning update (2026-10-27): the user selected attack cancellation plus each enemy's native default behavior and requested a development version. The revised ../prd.md, ../design.md and ../implement.md are authoritative. Earlier hurt-animation and research-only descriptions below are historical; no product implementation has started.

# 替代方案评估：命中后强制行走

日期：2026-10-27。用户问“假如改为是对任意敌人强制置为行走状态呢”。这是替代方案的可行性咨询，尚未决定替换已记录的受击需求；保持规划，不修改产品代码。

## 结论

对存在已确认兼容行走入口的敌人，可以研究通过该入口结束当前动作。但在保留原生 AI 的前提下，不能用统一的 `Walk` 状态切换覆盖任意敌人。相较原生受击方案，它可以去掉受击动画重启的要求，仍然没有解决控制器差异、攻击退出清理和阶段保护。

## 已有证据

- 固定版 DLL 的 `Walker.BeginWalking(int)` 设置自己的 `Walker.States`，播放配置的 `walkClip`，设置朝向、行走计时、音频和水平速度。`Go(int)` / `StartMoving()` 也是该组件自己的移动入口。它们不是所有 `HealthManager` 都实现的敌人公共接口。
- `Climber.Walk()` 和 `Crawler.Walk()` 是各自控制器的协程；其启动/停止、转向和反应行为不能用 `Walker` 的内部状态值替代。详见 `native-controller-candidates.md`、`native-controller-candidates-il.txt`、`native-controller-nested-il.txt`。
- 已查公开源码分别引用 Boss 的 `Idle`、`Idle Stance`、`Fly 2`、`Teleport` 等结构。飞行、固定和传送型敌人的正常行为不能统一假定为一个安全的 `Walk` 入口；公开状态名也不足以确定当前版本完整图结构。
- 部分攻击属于其他组件/FSM或独立对象，已在 `boss-hurt-candidates.md` 中记录。改动移动状态或仅播放行走动画，不证明这些攻击已经停止。

## 对用户目标的影响

1. 行走不提供受击僵直。即使成功返回行走/待机，攻击选择逻辑也可能很快再次启动；每次有效命中重置默认行为不能自动保证一段禁止攻击的时间。
2. 退出攻击时仍需核实近战判定、冲刺参数、持续发射和相关控制器的清理。不能把修改速度或播放行走动画作为已经打断攻击的证据。
3. 空中、隐身、无敌、死亡和阶段转换中仍需排除不兼容入口，不能为满足“任意”而越过原生必要流程。

更贴近“打断当前攻击”的可评估方案是：每次有效命中取消当前攻击，并返回该敌人经过核实的默认行为（行走、飞行或待机）。这仍需要逐敌人确认入口/清理；如果还要求命中后一段时间不能重新攻击，则是额外的控制时长需求，不能由一次行走切换推导出来。

没有为替代方案新增已验证支持敌人，也没有修改当前受击需求或要求用户批准实现。
