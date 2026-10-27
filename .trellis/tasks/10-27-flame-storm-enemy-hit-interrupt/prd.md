# 烈焰风暴命中打断与默认行为恢复

## Authorized follow-up: swap Afterimage and Storm inputs (2026-10-27)

The user directly requested swapping the two existing skill inputs. Implement this
bounded follow-up in the current task/branch; original enemy-interruption work
remains an incomplete draft and is not a prerequisite for this input change.

- Neutral quick spell now invokes Flame Storm, replacing Afterimage Combo there.
- Down + Dream Nail now summons Afterimage Combo, replacing Flame Storm there.
- Keep Afterimage an independent summon and Storm a controlled spinning action.
- Keep both skills' damage, tiers, artwork, clocks, contact limits, Soul amount,
  recovery protection and summon behavior; charge the current native MP Cost
  exactly once on accepted activation. Respect the new input's native unlock and
  eligibility gates, including the existing airborne down-Dream route.
- Preserve neutral/up-Dream, up/down-spell and focus routes. Do not trigger both
  skills from one press, leave duplicate adapter ownership, reset unrelated casts,
  or grant recovery protection on rejection/cancellation.
- Update current control tables and client checks. Verify relevant production
  policies, native entry/payment/cleanup boundaries and pinned-reference build;
  report actual client execution separately.

This request authorizes implementation directly; no new planning approval is
needed. It does not authorize packaging the enemy-interruption draft as working.

## Goal

每次烈焰风暴实际造成非致命伤害时，打断兼容敌人当前的攻击，并返回该敌人自身的原生默认行为，例如行走、飞行或待机。提升攻击打断能力，不再要求播放受击动作。

## Background

- 用户于 2026-10-27 同意创建任务，并在原方案中选择每次有效命中都重触发；之后先调查可行性和名单。
- 用户了解任意敌人没有统一 Walk 入口后，最新要求“按此方向开发一版”，接受每次有效命中取消当前攻击并返回各自默认行为。本文件取代旧受击方案；历史研究保留，不能继续把受击动画重播作为验收条件。
- 基线为 `main@cadb864` / `0.7.6-dev`，Hollow Knight `1.5.78.11833` / Modding API `v77`。烈焰风暴使用下方向 + 梦之钉，经原生伤害链处理命中和击退。
- 原生伤害和击退不保证停止 AI；普通敌人和 Boss 的控制器、默认入口及攻击退出不统一。

## Requirements

- R1：新增打断只归属于本次烈焰风暴，不改变其他攻击或技能。
- R2：仅对本次实际造成非致命 HP 损失、仍存活且身份有效的目标尝试打断。未扣血、原生拒绝、无敌和致死命中不强制改状态。
- R3：对有适配依据并通过当前实例结构检查的敌人，取消当前攻击并返回其原生默认行为；不能只播放行走动画、设置速度或统一切换同名 Walk/Idle。
- R4：普通敌人和 Boss 按同一兼容标准判断。未知布局、无安全返回入口或被其他 Mod 修改而不匹配的目标保留正常伤害/击退，跳过额外打断。候选不等于已支持，不能以零适用目标的空适配器交付功能。
- R5：关闭被中断攻击仍由敌人持有的近战判定、蓄力、持续发射和相关活动逻辑，正常交还 AI。已独立发射的投射物保留原生行为；不全局清空弹幕或子对象。死亡、阶段转换和不兼容脚本状态优先。
- R6：保持烈焰风暴现有伤害、五次命中预算、接触间隔、持续时间、范围、魂消耗、动画和玩家恢复规则。
- R7：原生回调可同步取消技能、替换/销毁目标或卸载 Mod；新增副作用前重新核对归属，旧回调不得改变新技能或目标。
- R8：连续有效扣血逐次尝试打断当时正在进行的攻击；返回默认行为后由原生 AI 决定后续动作。本版不新增受击动画、固定禁止攻击时间或定时反复重置循环。
- R9：记录具体适配入口、结构约束及证据等级。自动检查、原生布局确认和实机结果分别报告，没有实机记录不宣称客户端通过或任意敌人通用。

## Acceptance Criteria

- [ ] AC1 / R1、R3、R5：至少一个有证据的真实敌人适配能从所声明的攻击状态停止当前攻击、关闭相关活动判定/发射，并返回原生默认行为。
- [ ] AC2 / R2、R4：未扣血、拒绝、未知布局、无安全入口、死亡和失效目标不被强制改状态；正常伤害仍由原生链处理。
- [ ] AC3 / R5、R8：返回后 AI 正常继续；后续扣血可再次打断新攻击，不遗留错误重力/隐身/判定，也不额外添加攻击禁用时间。
- [ ] AC4 / R1、R6：伤害、接触预算/间隔、技能时钟、消耗、玩家恢复及其他技能保持原规则。
- [ ] AC5 / R7：嵌套伤害、取消、重施放、池化/销毁、切场和卸载不复用过期身份或错误归因的扣血。
- [ ] AC6 / R9：适配列表和验证范围随版本提供；构建成功、布局确认、客户端待验/已验明确区分。数据不足时记录确切缺口，不以日志框架或正常扣血代替打断完成。
- [ ] AC7 / R4、R5：受保护阶段、死亡流程和布局不匹配保留原生行为；普通敌人/Boss 与变体的支持不能互相推定。

## Out of Scope

- 把任意敌人统一强制切到名为 Walk/Idle 的状态，或重写所有敌人的 AI。
- 受击动画、强制眩晕/冻结、额外禁止攻击时间、绕过无敌/死亡/阶段机制、全局清空弹幕。
- 重新平衡技能，修改其他技能、原始素材、玩家控制、游戏 API 或存档。

## Technical Notes and Evidence

- `src/WukongKnight/FlameStorm.cs:75`：接触查询与施放身份；`:93` 先经过现有接触预算。
- `src/WukongKnight/NativeV77.cs:181`：共用原生伤害入口；`:82` 是目标过滤。Storm 经 FireDemonHit 委托给 SpellHit，不能让其他共用调用误触发新增行为。
- `src/WukongKnight/WukongRuntime.cs:435`：已有 HealthManager.Hit 前后 HP 观察入口，须保留 Fire Eye 观察并处理嵌套回调归因。
- `research/default-behavior-candidates.md`：本方向三个具体结构候选；当前均缺完整取消/恢复证据，不能直接启用。
- `research/force-walk-alternative.md`：默认行为替代方案的机制依据，其“尚未决定”说明是当时历史状态，用户现已接受方向。
- `research/native-hurt-contract.md`：伤害/HP 顺序及归因限制仍有效；旧受击重播要求已被本 PRD 取代。
- `research/feasibility-and-enemy-list.md`、`research/boss-hurt-candidates.md`：旧受击候选及阶段/多 FSM 风险，不能直接作为本方案支持名单。
- `research/native-controller-candidates.md`：Walker/Climber/Crawler 控制器差异；历史组件映射见旧名单。
- `research/hit-path-and-native-state-evidence.md`：当前命中路径与原始证据约束。
- `.trellis/tasks/10-23-wukong-character-basic-attacks/research/control-swap-v076-20261026.md`：此前强制受击未实现。

## Evidence Gate and Artifact Status

本版行为和边界已明确，范围为能确认安全入口/清理的适配，不承诺全敌人覆盖。当前缺少基线客户端完整敌人 FSM/动作资源；精确适配和客户端验收仍须补齐证据。若找不到任何可用布局，不以空功能包结束任务。

用户已用“开始吧”审核通过完整新计划；任务已启动为 in_progress，分支为 feat/flame-storm-enemy-interrupt。实现与检查按该计划进行；原生取消/恢复适配仍须满足上述证据门槛。
