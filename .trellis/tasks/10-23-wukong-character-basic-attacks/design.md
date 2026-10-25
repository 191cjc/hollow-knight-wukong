# 孙悟空外观与四段普攻：技术设计

## Scope and Boundary

本任务以一份可安装、可验收的角色替换开发包为交付单位。动画生成、角色视图与普攻接入共享资源协议及游戏生命周期，按单任务内的三个里程碑推进；不拆成可以单独宣称角色可玩的子任务。

最小行为差距：当前只输出日志；目标是在保留 HeroController 探索控制的基础上显示孙悟空，并仅接管地面水平普通攻击。保留原骑士碰撞体、移动、存档、生命/魂以及方向和空中攻击规则。新增代码集中在资源转换、角色视图、四连击状态和原生攻击适配器。

## Architecture

1. **离线动画生成**：从固定的 2001/manV535 骨架及图集生成透明 PNG 图集、动画清单和审阅用联系表/动画预览。
2. **角色资源与视图**：校验清单和图集，创建附着于原 HeroController 的视图，按角色状态播放对应帧。
3. **无引擎连击核心**：消费按键边沿与逻辑时间，产生开始某段、打开/关闭某命中窗口、结束/取消等事件。
4. **原生攻击适配器**：筛选地面水平攻击，将连击事件转换为原生普通攻击事务与受控判定，保留骨钉、护符、魂及交互逻辑。
5. **生命周期所有者**：Mod 入口统一注册/撤销钩子，跟踪当前角色对象，管理附着、错误回退和禁用恢复。

资源清单是动画生成与运行时的边界。连击核心不引用 Unity/Modding；渲染不负责改写战斗数值，攻击适配器不直接操作原始骨骼。

## Offline Animation Conversion

- 采用 Python + 固定版本 Pillow 的离线仿射合成；不在游戏中嵌入 DragonBones 运行时。原始资源保持只读，加工结果输出到 assets/processed/wukong/。
- 针对实际 2.3 导出格式实现经过研究确认的有限特性：全局骨骼变换、嵌套装备骨架、显示项选择、帧保持、局部枢轴、Z 排序及颜色/透明度。
- 现有数据的骨骼没有 parent 字段；不能把动画帧作为现代 DragonBones 的绑定姿势增量相加。缺失主时间轴与隐藏装备动画不能误绘为绑定姿势。
- 所需纹理和嵌套骨架均能在当前包解析。旧数据解析以 research/animation-conversion.md 固定的 DragonBonesAS v4.1 旧格式解析器为依据；现有动作的补间已确认关闭，按关键帧保持采样，不默认加入平滑插值。若后续源数据超出当前有限特性，应明确失败而非误绘。
- 原图集存在 RGBA(0,0,0,1) 填充值；在加工副本中按明确规则处理，记录规则并测试占位纹理。禁止修改归档源图或以任意高阈值清除真实半透明内容。
- 首批生成 idle、walk、runNormal、jumpNormal、jumpTwo、jumpDown、jumpAttack、hurtStand、dead、attack1–attack4。其他原版动作使用明确的孙悟空姿势映射；不新增对应的独立招式机制。
- 所有帧共享脚底/根坐标和比例。裁剪使用每帧偏移，不能逐帧自动居中；攻击时棍子伸长不应让人物本体缩小。使用固定图集尺寸上限，保留 30 FPS 的时序。
- 自动生成四连击关键帧联系表及循环预览，核对身体完整性、武器、左右朝向、层级和脚底。实际烘焙预览确定攻击的命中帧与范围；这些记录为移植设计值。

## Generated Asset Contract

运行时清单采用 schema_version=1，至少包含：角色/外观 ID、源文件散列、生成器与规范化规则版本、帧率、固定原点/标称人物尺寸、图集路径/尺寸/散列、每帧矩形与原点偏移、各动作帧索引和循环方式。

另有统一的连击配置：四段动作名、总帧数、前摇/命中/收招帧区间、输入缓存及连段超时时间、判定形状/相对偏移、每窗口允许命中次数。转换器/校验器、运行时和打包器消费同一份正式协议，不重复硬编码图集路径或动作长度。

打包目录包含 DLL、说明以及相对路径的 character/ 资源。图集必须有清单引用；清单引用必须有包内文件。缺图集、错误尺寸、越界矩形、未知协议版本或不完整配置应阻止进入角色替换。

## Runtime Rendering and Lifecycle

- 保留原角色控制器与碰撞体，在角色之下附加一个视图对象。左右朝向跟随原角色，但避免父子同时翻转；比例只在初始化/明确校准时设置。
- 确认全部基础资源可用且视图可渲染后才隐藏原角色本体渲染器。保留其动画器与 FSM 运行；不通过每帧切回骑士贴图实现缺失动作回退。
- 动画优先级为死亡/受击/不可控特殊状态 → 当前连击 → 保留的原版攻击 → 空中/落下 → 地面移动 → 待机；同一动作持续时不重置帧计时。
- 方向和空中攻击保留原判定，孙悟空身体使用 attack/jumpAttack 的明确姿势映射；上/下劈保留原版方向斩击特效来表达判定方向，不声称源素材包含专门的空洞骑士上/下劈动作。
- 跟随原角色可见性与伤害闪烁/透明度，避免过场、换场或隐身状态中出现悬浮的孙悟空。特殊原版动作使用明确姿势回退，不承诺本次提供所有专用动画。
- 建立单一 Attach/Detach/Cancel 路径。新角色、场景切换、死亡重生、存档退出、禁用及初始化错误均清理本任务拥有的视图/判定/订阅，恢复修改过的原始渲染与控制状态。

## Four-Stage Combo

- 仅地面左/右普通攻击进入四连击；移动中地面攻击仍进入同一链。空中及上/下方向攻击直接沿用原流程，重置尚未完成的地面链。
- 每个按键边沿触发一次攻击。一段期间至多保留一个后续输入，不能单次按住无条件播完四段；释放按键本身不重置连段。
- 四段基础时长按素材的 12/15/18/20 帧、30 FPS 起步，即约 0.40/0.50/0.60/0.67 秒。保留 Quick Slash 时用原版护符/非护符冷却比对整段时序作一致调整；不能只缩短一部分造成动画/命中脱节。具体命中窗口在动画预览后配置，不能把 evtMohu 等未追踪事件直接视为命中帧。
- 初始连段宽限期为上一段结束后 0.35 秒，命中/收招期间的有效后续输入可缓存一次。四段结束回到第一段；超时、跳跃、冲刺、方向攻击、受击、死亡和角色销毁取消并清空缓存。
- 跳跃/冲刺可取消地面攻击；取消必须关闭所有判定并恢复正常原版控制。普通攻击不会额外锁定角色移动或消耗魂。
- 第一、二、四段各一个命中窗口，第三段两个。每个窗口独立去重，第三段两个窗口可以各命中同一目标一次；重复碰撞和一个目标的多个碰撞体不能造成额外命中。
- 每次命中使用现有骨钉及适用护符的伤害修正，不添加自定义倍率或终结技加成；第三段两次有效命中分别产生原版对应反馈。

## Native Attack Integration

API 的 AttackHook/DoAttackHook 是通知，不能被当作可取消的输入拦截器；AfterAttackHook 的实际调用顺序必须以固定版本代码/IL 为准。实现采用受控 On.HeroController 接入和原生 NailSlash 事务，具体可用签名、时序及约束见 research/runtime-integration.md。

每个有效段仅调用一次原生 DoAttack/Attack 初始化事务，在受控范围内捕获并延后所选 normal/alternate NailSlash.StartSlash；命中帧通过单次许可激活这个原生 Slash，而不是再次调用整个 Attack。只隐藏所选斩击的渲染，不关闭其 FSM/伤害对象；保留原版伤害、骨钉和反馈链，不额外调用 SoulGain 或发送平行 HitInstance。

先证明原生水平形状的单次受控命中，再按预览校准各段偏移/基本伸距，同时维护范围护符倍率和原版 clash 交互。一个窗口只允许所选 Slash 作为伤害来源。原生 DamageEnemies 会重复遍历碰撞体，不能将它误当成逐目标去重；去重策略需要按同一实际受击者识别并限定在本次窗口，不影响其他 Mod/攻击。

NailSlash.FixedUpdate 存在固定步激活和关闭延迟，必须据此安排窗口，必要时在限定到所选 Slash 的适配器内管理多边形时序。第三段第二窗口必须先关闭第一窗、再重置本次受击去重并重新激活。HealthManager 的命中无敌与原生 FSM 记忆可能拒绝第二击；不能通过改写敌人全局无敌时间来凑双击。

实现前先完成最小可编译的接入原型，确认固定 DLL 的 Hook 签名、原版攻击门控、私有冷却/状态及 Slash 激活/取消顺序。反射访问集中在单一版本检查适配器。ResetAttacks 不会清空原版攻击冷却，不能假设调用它就恢复了全部状态；清理时使用段令牌防止旧回调取消新攻击。不能每帧覆盖全局 canAttack，也不能结束时清空别的技能/过场锁。原版方向/空中攻击不走自定义攻击路径。

如果原生事务原型不能在计划范围内保持伤害、魂与交互语义，应记录证据并修订设计；不得悄悄交付仅切换动画的假连击，或扩展为重写整个 HeroController。

## Build and Compatibility

- 继续使用本项目 SDK、net472 及 API v77。固定公开 UnityEngine.Modules 2021.3.33 编译引用包，SHA-256 为 d32d34526d89958c63220d3a5ce26c5c44c11bfd411a2e1fbc3200088ef160c4；提取所需 net45 Core/ImageConversion/Physics2D/Audio 等模块并设为不复制。所有游戏/API/Unity 引用均不随 Mod 打包。
- 该编译引用包不等于客户端 Unity 精确匹配。只使用已核实可用的 API 子集，记录客户端所需模块/成员；实机验收核对游戏版本、API 平台和运行时方法可用性。禁止因编译成功就宣称游戏兼容通过。
- 适配器尽量不直接依赖 PlayMaker 字段，从而不为了本功能引入不必要的游戏编译引用。
- 图像工具依赖安装在项目 .tools/ 下的独立环境，锁定版本；构建流程明确先准备/烘焙资源，再校验/编译/打包。

## Files and Ownership

- 资源实现：tools/bake_character.py、必要的旧格式采样模块、图像工具依赖锁、角色/连击配置以及 Python 转换测试；负责生成资源协议和预览。
- 运行时实现：src/WukongKnight/ 下入口、资源加载/视图/状态适配、纯连击核心与攻击适配器、csproj，以及无引擎连击测试。
- 集成实现：tools/bootstrap.py、toolchain.lock.json、tools/prepare_assets.py、tools/package.py、scripts/build.sh、README/CURRENT_STATUS/相关文档；负责依赖准备、资源一致性、包内闭包和真实状态报告。
- 以上为预期变更边界。可根据原型合并很小的辅助类，但不能借本任务引入无关框架、全局战斗重构或通用美术编辑器。

## Validation and Deferred Items

自动验证：旧格式变换/隐藏/透明度的确定性例子、真实资源解析与烘焙完整性、输入缓存/超时/中断/第三段双窗口去重、Release 构建、包内文件闭包和不携带游戏 DLL。

视觉验证：实际生成的待机、移动、跳跃与四连击预览；重点检查层级、默认服饰与棍子、锚点和朝向。原生行为仍需客户端验证：碰撞、敌人伤害、魂、护符、可破坏物、下劈弹跳、换场与重生恢复。

服务器没有已确认的游戏安装；交付可以达到代码实现、自动检查、预览和开发包就绪，客户端验收保留明确待办。尚未反编译的原作 AS3 不阻塞本次移植设计，但不能宣称原版逐帧复刻。

回退方式为禁用/移除本 Mod，由统一清理恢复原角色；依赖和生成资源可重新准备，不修改游戏安装或原始归档。


## 0.4.2 user-reported skill corrections

Reject sensor/weapon colliders that previously routed room-wide damage to boss
HealthManager ancestors. Share native layer/hurtbox filtering across both skills.
Raise pre-finisher air art and damage by 0.25 native hero collider heights and
suppress only the inherited Quake landing BigShake actions, restoring on cleanup.
Preserve native movement, original art, dimensions, immunity and fixed damage.
Build, run regression checks, back up and install with the game stopped; gameplay
acceptance remains pending. See research/skill-collision-and-shake-20261024.md.


## 0.4.3 source presentation restoration

The user supersedes centering/raising and the native landing adaptation. Restore
original directional spawn and mask conversion, use the untouched main effect5
character flashes/blink gaps, and trigger the finisher on air-effect expiry in
midair. Hold native antic through the source clock, then restore through native
Quake Finish/Spell End without forced diving. Preserve full-cast immunity, fixed
damage and the 0.4.2 hurtbox filter. Reuse existing original assets; do not overwrite
any originals/variants. Run source-image/core/build/preview/closure checks and
back up/install directly. See research/fire-demon-source-restoration-20261024.md.


## 0.4.4 Fire Demon movement correction

The user reports drift from movement input during the extended custom cast.
Maintain native input denial, neutral axes/velocity and no gravity throughout
preparation, air and finisher; observe before input and around native physics.
Keep original updates running and source effect5 animation/midair finisher,
damage/immunity unchanged. Release before native recovery and stop writes on
cancel/detach. Build/check, back up/install and verify; client movement, pause
and recovery acceptance remains pending. See research/fire-demon-movement-lock-20261024.md.


## 0.5.0 spell adapter extension

See research/spell-layout-v05-20261024.md for the approved scope and source/native
evidence. Hold native Scream Antic1/2 for Fire Demon and Quake Antic for Storm;
charge current native MP Cost once before bypassing their later damage/spend states.
NativeSpellV77 validates/scopes the relevant completion events and effect objects.
BloodthirstyFireEye preserves native focus drain/cancel, replaces only focus
AddHealth with buff activation, and defers finish out of native action iteration.
BloodthirstyBuff owns expiry/global cooldown/token policy. FlameStorm shares
SpellHitLedger with cap5 and the corrected native hurtbox policy. Bake body plus
separate source flame overlay into a new profile/folder and new offline1.5x copy.

## 0.5.1 correction design

The gap is in FireDemonSlash motion ownership and BloodthirstyFireEye presentation.
The original skill1101050 starts shootSpeedX50 at frame5. PlayerEntity.shoot
sets signed velocity; Physics uses0.1 seconds per30Hz source tick, so travel
is5 source pixels/tick until WKEntity.addEff5_2 stops it at tick36:155px maximum.
Restore this controlled progression with swept native body collision; consume
each time interval once so repeated observers cannot duplicate travel. Keep air
effect anchored to the cast root and spawn the finisher at the moved root.
Do not add forced falling, targeting, camera shakes or input-driven movement.

Original buff810001/resources17 loads810001/1.swf symbol ef, a10-frame loop
with five lossless bitmaps. Decode premultiplied ARGB offline and preserve its
shape matrices/registration. Add a separate fireEyeAura clip, rendered at the
hero source root while the existing buff is active; mirror with current facing
and clear with the existing buff lifecycle. The loaded MovieClip runs on the
parent30Hz stage, independently of the child SWF header24Hz. New v051 profile
and original/1.5x folders avoid rewriting prior bakes. No healing rebalance.

Files: FireDemonTimeline/FireDemonSlash plus core tests for source travel;
BloodthirstyBuff/BloodthirstyFireEye/WukongRuntime for aura clock/lifecycle;
fire_eye_assets/bake_character/validators/profile and source checks for artwork;
version/package/docs/evidence for reviewable export and installation.


## 0.5.2 casting overlay

Source Entity.onUpdateAnimationAfter2 attaches the skill1 effect4 armature on top
of the body at (0,0), with shared facing, action clock and unit registration.
The skill1 armature is local DragonBones3.0, four independent bones, 21 ticks:
seven held winding flames at [0,14), then three nested displays at [14,21).
Its two child armatures each last seven ticks; their clocks start on reveal.
The existing body effect4 is17 ticks and remains an unchanged separate clip.
Create fireEyeCast from source body tick min(t,16) plus the complete original
21-tick overlay, above the body. Hold the final body pose for the last four
overlay ticks. Map the composite's full21 ticks to the existing normalized
native focus progress, with no new duration, input, health or Soul ownership.
This explicit timing adaptation preserves the full originally independent
overlay within native charm-dependent charging. Cancellation removes both body
and overlay through the existing presenter selection; no lingering world effect
or post-cancel tail. Existing fireEyeAura remains an independent buff renderer.
Use new v052 profile/original/1.5x folders, retaining all v051 resources.


## 0.5.3 scaled-time casting clock (supersedes0.5.2 progress mapping)

Gap: BloodthirstyFireEye.Progress is zero during Focus Start/Start Slug Anim,
then MP_drained/focusMP_amount drives all21 source ticks. Native MP_drained
increments by1 per interval; it is not a continuous animation clock. This
holds the first frame during startup and stretches source holds across charge
duration. The17/21 source mismatch alone affects the final body pose only.

Use FireEyeCastClock, a production engine-free scaled-time lifecycle clock,
started on first ordinary focus observation (including startup). Sample both
source layers at30Hz using existing fireEyeCast composite, not Soul progress.
At tick21 select original effect4 final body pose, removing completed casting
flames while native focus can continue. A fast native completion or cancel ends
the visual immediately; never delay native completion to finish graphics.
Observe before/after native updates and in existing late/physics observation;
clear on cancellation, death, scene and dispose. Pause freezes Time.time.

Boundary: BloodthirstyFireEye owns clock lifecycle, WukongPresenter consumes
CastTick and hides completed overlay. Remove obsolete native MP-progress
reflection and unused BloodthirstyFireEye native dependency; link the real core
clock into existing production tests. Version/package/docs/build metadata
record0.5.3. Reuse unchanged v052 art; no rebake/profile/variant edits, gameplay
rebalance, input/control or collider changes. Native focus alone starts the buff.


## 0.6.0 nail presentation boundary

Source skill1V472 has separate single-local-bone image overlays for attack1..4,
jumpAttack and effect1, attached above the same-named body by original Entity.
Reuse original held keyframes, hidden frames and transforms. Add seven separate
composite clips: nailAttack1..4, nailAir, nailUp and nailDown. Existing30clips
remain unchanged in content/root space. nailDown uses the original jumpAttack
body retimed10/15, plus effect1 arc rotated180 about(0,-44.5) source pixels.
That center is the native-fit idle-body center: source feet6 - height101/2.
Rotate only effect Draw matrices offline; never rotate/scale the hero collider.

Extract the existing bounded single-bone reader into SingleBoneEffects so
Flame Dash/Storm and the new six source overlays share validation/composition.
Support displayIndex=-1 hiding; preserve current flame pixels/slot labels and
prove all older clips retain registered pixels after the refactor. Complex
Fire Eye/Fire Demon readers are outside this extraction. New v06 profile and
original/1.5x folders avoid overwriting any earlier assets.

WukongPresenter owns visual replacement: suppress only the actual attached
hero normal/alternate/up/down/wall NailSlash mesh submissions with the already
validated forceRenderingOff property. Save/restore each previous value on
constructor failure/dispose. Leave native enabled writes, animators, polygons,
damage, charm FSMs, contacts and beam objects running. NativeV77 owns private
selected-slash/attack-clock reads and enumerates those hero mesh renderers.

Combo source ticks keep their existing shared combo clock and select matching
new nailAttack clip. Other nail attacks use actual native selected slash identity
for up/down/air body selection, and native attack_time/attackDuration to fit the
whole original action inside native timing (including Quick Slash). Capture no
new damage/input/state ownership. Native completion, pogo and interruptions
remain authoritative. Keep fixed offline1.5x appearance and current root facing.

Files: shared/nail asset tools, bake profile/fingerprints/validators and source
tests; NativeV77/Presenter and constructor caller; version/package/docs/evidence.
No nail damage rebalance, reach change, projectile mechanic, spell changes or
new native-combat hook. Source-image checks, registered old-clip comparison,
production checks/Release and package/install validation gate delivery.


## 0.6.1 arc-only presentation boundary

Gap: composite nail sprites cannot follow native charm size without enlarging
the body. Native StartSlash already sets scale from serialized NailSlash.scale;
use actual selected slash.localScale / baseline scale (absolute X/Y) after its
native transaction. Never duplicate the native multiplier table or call an
extra StartSlash. Combo arc openings match existing native window openings,
so scale is initialized before an arc is visible; native air/up/down runs once.

Add7arc-only clips using existing nail_samples Draws and their nail_fx /
nail_down_fx slots. Keep all37existing clips unchanged. New profile flag
nail_separate_arcs and new v061 original/1.5x folders. Same root/canvas and
source timing,105extra ticks; arc image retains transparent/hidden frames.

Presenter adds one child SpriteRenderer above body; choose existing attack1..4,
jumpAttack/effect1 for body, original down retiming10/15. Choose new arc-only
clip on the very same existing nail clock. Apply native X/Y scale to only arc
renderer. Keep its source center fixed: sourcefeet6-height101/2=-44.5, converted
through existing offline artwork scale. Offset child by(1-ratio)*center so
charm scaling does not drag art away from body. Facing/color/visibility follow
body; no arc outside nail states or after cancel/dispose. Existing mesh save/
restore remains unchanged. No root/body/collider resizing; no gameplay hooks.

NativeV77 owns version-gated baseline field read. CharacterAssets/validator
require7new arc clips. Pipeline/test changes prove source layer extraction,
105arc frames and offline scale, unchanged874previous frames at each size,
and native IL demonstrates4charm scales/M animation. Review0/1/both charm
previews and Release against actual references, then package/install closure.
Files: nail_assets/bake/validators/profile/tests, NativeV77/Presenter,
version/package/docs/specs/evidence. Earlier pending mechanics are preserved.


## 0.6.2 presentation boundary

Only presentation is wrong: native downward dash motion and swept damage already
follow the real velocity; Fire Eye currently starts too early. NativeV77 reads
the validated private dashingDown flag through FlameDash.Downward. Add one offline
flameDashDown composite in separate v062 original/1.5x folders. Rotate ONLY the
effect2 flame Draws clockwise90 around source center(0,-44.5), keep the upright
body/timing, unchanged horizontal frames and existing view/aura/arc transforms.
The source coordinate system is Y down. Renderer flipX preserves downward travel
for both facings. No hero/root/collider/gameplay transforms are added.

NativeSpellV77 reads the live drainMP, drainMP_time, MP_drained, focusMP_amount and
drainMP_timer fields. While draining, remaining=(amount-drained)*interval-timer.
Capture scaledTime+remaining once per focus as the presentation deadline, after
native charm selection. Original21/30 seconds of action/effect end there; earlier
startup/wait uses effect4 body tick0 without overlay. If charge is shorter than
the source duration, start in its tail, preserving30Hz instead of stretching it.
No discrete Soul-progress frame clock or fixed normal/charm timing table.
Observe calls cannot restart the deadline; pause uses scaled time. Native cancel,
heal completion, death/scene/detach clears graphics without a tail or buff delay.
Focus FSM/native AddHealth remains authoritative; buff/aura mechanics unchanged.

Files: NativeV77/FlameDash/NativeSpellV77/Core clock/BloodthirstyFireEye/Presenter
for read-only presentation; bake/validators/profile/tests for directional art;
version/package/docs/specs/report for reproducible export and verified install.
Tests cover deadline, startup, short/deep charge, repeats/pause/cancel/recast;
exact original rotations, upright body, exported1.5x and all979old frames.


## 0.6.3 damage and death presentation boundary

Reuse the existing TakeDamage/TakeHealth entry guards: SkillProtects observes
FlameDash and FireDemon at the callback boundary and guards either active owner.
No saved isInvincible writes, timer extensions, dash movement/collision changes
or added damage. End/cancel/death/scene/detach invalidates existing dash ownership.

Re-download official assets/man/2001/manV535.swf over HTTPS, record URL/hash and
extract into a new reference/flash/death folder. It matches the existing archive
and complete65-tick dead clip:30Hz falling/prone body plus ghost ef1 at8..31.
All current offline1.5x pixels can be reused byte-for-byte; no new bake or runtime
appearance scaling. Original files and all earlier variants stay preserved.

Native Die coroutine disables the hero mesh immediately and activates separate
heroDeathPrefab. Presenter currently follows that disabled flag, erasing source
death art. Hook real HeroController.Die before its original iterator executes;
start an idempotent scaled source death clock, capture facing/world anchor, and
show dead independently of native enabled/color. NativeDeathV77 suppresses only
render submissions of native death prefab/Head/Sword visual outputs, preserving
their enabled writes and all FSM/save/shade/Geo/transition actions. Never disable
the death FSM or skip the original iterator. Do not treat survivable hazard
respawn as real death. Restore renderer flags on resume/dispose/failure; scene
or hero teardown clears the clock. Dream deaths also enter from the real hook.

Changes: Runtime guards/death hook, NativeV77 effect lookup, NativeDeathV77 owned
visual suppression, Presenter fixed death layer, Core source clock/tests;
reference download/provenance/source-pixel checks and current docs/version/report.
No changes to baker/current character variant or health/save/respawn timing.


Native v77 evidence refinement: current Hero Death Anim stores Head only;
Blow flings an untracked pooled Corpse Nail Hero. Suppress its exact visual-only
FlingObjectsFromGlobalPool action while death owns presentation, saving/restoring
Enabled; preserve all other actions/events. Legacy Sword output is optional.


## 0.7 neutral spell and directional Dream Nail boundary

The gap lives in neutral Fireball Antic and the native Dream Nail input/charge
FSM. Extend NativeSpellV77 with Forward antic ownership: suppress native Fireball
spawn progression and charge live MP Cost once. FistSkills owns original action
clocks, local source masks, terrain-clamped movement, persistent four afterimages
and their Godslayer/Earthbreaker mimicry. One action owns native control at a
time; cleanup invalidates tokens before restoring input/gravity/animation.
Dream attacks require hasDreamNail; no soul cost, explicit recovery/cooldowns
keep the free attacks bounded. Native basic/awakened Dream impact eligibility is retained; Dream Wielder affects
charge; neutral spell tier/Shaman retain spell balancing. Direction is latched
on press. Charge releases on key-up; full charge waits without auto-repeat.
Only full Godslayer projectiles include a clone of the actual native Dream Effects
Hitbox (tag/layer/FSM), resized to the source contact rectangle and activated
within the real projectile lifetime. Native DREAM IMPACT/SendDreamImpact and
other collider-driven dream recipients stay native; no manual essence/save writes
or room broadcasts. Clones do not acquire this native interaction.

NativeDreamV77 disables/restores only the native Inactive input listener while
custom Dream actions own that key. The native Start antic completion is held for
custom action lifetime, then recovered through native End/Regain Control. Existing
Dream Gate up/down shortcuts are intentionally occupied by the requested attacks.
The source WK2Entity gives birth ticks 12/26/40/52, punch release threshold frame
39 and release tail frame 60, five contact subskills and ape independent back/front
entities. Preserve those body/overlay layers and original30Hz pacing. No fist
mode switch for normal staff attacks and no native body/collider enlargement.

Files: new bounded fist artwork reader/profile and bake/validator additions;
new Core rules/clock/roster and runtime FistSkills/NativeDreamV77; small native
spell/input, Runtime/Presenter integration; source evidence/tests/docs/version.
Prior assets stay read-only; compare registered previous ticks across new canvas.


Final source boundaries: preserve source Godslayer partial10-tick loop; standalone
full Dream trigger needs a scoped kinematic Rigidbody2D/full kinematic contacts
because it no longer inherits the hero body. Ghost Earthbreaker uses independent
terrain-swept native-size bounds and source pose holds, with no physical hero
collider. Compact runtime atlases add validated crop offsets while retaining a
separate complete enlarged version for all original asset comparisons.


## 0.7.1 correction boundary

The gaps live in FistSkills directional Dream acquisition, GodslayerCharge and the fist offline idle-pose selection. Read the live native Spell Control MP Cost and use native TakeMP; reject insufficient Soul before ownership and start/mimic only after successful acquisition/spending. Verify native cost updates rather than duplicate charm constants. Restore automatic source-frame60 release (59 elapsed ticks; Dream Wielder double rate), latching once and preserving the25-tick tail/100ms wave delay. Inspect original clone idle resources/body poses and repair the last two exported poses in new original/1.5x/packed folders. Changes are limited to these rules/adapters, asset profile/generator, meaningful regression coverage and version/evidence/docs. No damage rebalance, native trigger/collider changes or prior-art overwrites.


## 0.7.2 change boundary

The gaps live in FistSkills ghost completion, duplicated Earthbreaker movement
and use of weak FireDemon air-hit recoil. A completed copy currently changes to
None and idles; instead destroy the ghost immediately after its release/landing
tail. Canceling an unreleased copied charge also removes that consumed ghost;
already emitted waves finish independently. Centralize unchanged rise/antic and
1.5x descent (22->33 original pixels/tick) for hero and ghost, preserving terrain
sweeps and consuming blocked travel. Reuse native HitTaker/HealthManager/Recoil
with the original Q Slam Hit L/R Spell magnitude2, horizontal away from the cast
root for body hits and along travel for Godslayer waves. Extend the shared native
spell-hit helper; retain existing Fire Demon/Storm recoil values. Tests cover
copy lifetime boundaries, fast/batched descent and native-style push directions.
No new invulnerability, forced enemy transforms/velocity, altered HP/Soul/masks,
artwork or unrelated skill changes. Files: FistSkills, Core FistRules, NativeV77,
production tests, version/package/docs/spec/evidence/report. Client behavior is
separate from build validation.


## 0.7.3 change boundary

The gaps live in FireDemonSlash.Query's final HitInstance, Runtime's existing
incoming HP guards, the native Dream Nail HERO DAMAGED global transition, and
HeroController.StartRecoil after native TakeDamage has handled HP/death/hazards.
Use native horizontal Spell recoil magnitude2 for the Fire Demon final hit only;
leave air/Flame Storm values intact. Reuse FistRules.PushDirection. Add owned
Earthbreaker to the existing TakeDamage/TakeHealth guard without saved flags.
For owned Fire Ape, temporarily replace only Dream's HERO DAMAGED transition
event, restoring on Finish/Dispose, and replace ordinary StartRecoil with native
damage presentation and the native Invulnerable coroutine (including Stalwart
Shell duration), omitting recoil/freeze/control changes. Native TakeDamage still
handles HP, charms, callbacks, lethal and hazard branches unchanged.

Files: FistSkills/FistRules for action lifetime/defense ownership; Runtime and
NativeV77 for the native reaction boundary; NativeDreamV77 for a scoped exact
transition override; FireDemonSlash for the final hit; linked production tests,
version/package, evidence/contracts/status/report. Consolidate the existing hero
end predicate without changing timing; test exact ends, pause, cancellation and
other skills. No forced landing/enemy transforms, global event suppression,
manual HP deductions, restarted casts/costs/clocks, asset regeneration or commits.
