# 空中水平棍击技术设计

## Behavior Gap and Boundary

当前空中水平攻击仅保留原生 NailSlash 时序、孙悟空身体映射 jumpAttack；目标是让该单段动作与受控原生窗口同步。实现位置在现有 ComboTimeline / WukongRuntime / NativeV77 和资源协议，沿用原生攻击、伤害与接触列表清理。不会创建另一套伤害系统或空中连击，也不修改原生位移、重力、跳跃次数和方向/贴墙攻击。

## Character Contract

- character.json schema_version 从 1 升为 2，烘焙帧/图集结构、四段 stages 不变；profile_version 与 generator.version 不因像素算法未变而升级。
- 新必需字段：combat.air_attack = {clip: jumpAttack, hit_windows: [{start_tick: 4, end_tick: 7}], range_multiplier: 1.0}。不含 buffer_open_tick 或伤害倍率。
- jumpAttack 必须存在且非循环，命中窗一个、半开且位于该动作总时长之内；range_multiplier 在 0.25..3。默认动作 10 ticks / 30 FPS。[4,7) 是经姿势审阅的移植配置，不声称原游戏事件时序。
- baker/validator/runtime loader/fixtures 一致升级。新 DLL 需要 schema2 与空中字段，旧 DLL 看到 schema2 明确拒绝并保留原骑士。
- 包内 DLL、清单与引用图集完整交付，版本 0.3.0-dev；runtime_tested 仍 false。

## Shared Clock and Native Ownership

- 在同一个纯逻辑核心扩展 GroundCombo / AirHorizontal 两种明确模式，共享单调递增 token、窗口时钟和去重；保留原有地面 Press、缓冲与 grace 行为。空中单段不缓存、不自动续接，完成后不遗留地面连段。
- 核心公开当前动作定义/模式；事件能够在同次 Advance 涉及多个地面段时仍定位正确动作。运行时不再把所有定义都从 ground stages 索引取得。
- 原生 DoAttack/Attack 每次有效输入仅初始化一次；复用 normal/alternate Slash 捕获、窗口、碰撞、HitTaker/HealthManager 和 DeferredContactCleanup。空中 normal、非贴墙才接管；up/down/wall 仍调用原生路径。
- ShouldCancel 拆出共同中断与模式相关边界：ground 离地或跳跃取消；air 落地取消，但允许上升/下落。冲刺、受击、失控、转向、死亡、换场/销毁都关闭所属窗口。空中第二次跳跃输入仍可取消攻击，不增加物理限制。
- air active 的正常重复输入不缓存；方向输入先取消所属攻击，再交还原生方向与冷却门控。地面原有输入缓冲保留。
- 空中拥有期间冷却取 max(动作时长, 本次初始化的原生冷却)；空中正常/取消释放保留 max(0, 原生冷却 - 实际经过时间)。地面正常释放策略保持现状。
- Presenter 受控动作使用核心时钟，跟踪 token 以确保连续同名 jumpAttack 重播从起始姿势开始；地空切换按真实状态恢复。

## Affected Files / Ownership

运行时实现拥有 src/WukongKnight/* 和 tests/WukongKnight.Core.Tests/*：核心/输入/冷却/展示/JSON loader/版本及实际生产代码测试。

资源与集成实现拥有 data/character/wukong-staff.json、tools/bake_character.py、tools/validate_character.py、tools/package.py、tools/prepare_assets.py、Python 测试、README/CURRENT_STATUS/相关 docs：协议、缓存生成、打包状态与文档。不更改 bootstrap/toolchain、原始素材和 DragonBones 采样算法。

主会话拥有本任务记录、规范更新、分支与 Git 协调；代理共享工作区，不覆盖彼此修改。

## Verification and Limits

复用全部已通过的地面/清理回归；新增空中单次与重复输入拒绝、窗口开闭/去重、Quick Slash、取消/落地和地空切换的单调 token 等实际核心测试。对资源协议拒绝缺失/错版本/错 clip/loop/多窗/越界/自定义伤害；运行完整 build.sh 和独立全范围 trellis-check。

实际落地/命中、重复空攻节奏、方向/下劈弹跳、护符/魂、生命周期仍需客户端验收。服务器构建/核心模拟不能代替该验收；报告中明确分开。
