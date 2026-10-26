# 孙悟空角色替换与普通攻击

## Goal

玩家进入《空洞骑士》后能够以《造梦西游4》孙悟空棍系默认外观探索，并使用具有独立动作、节奏和命中判定的四段地面普通攻击。

## Background and Decisions

- 用户已授权创建任务并规划，明确选择“四段棍系连击”，随后确认“地面四连击，保留原有空中与方向攻击规则”，并在最终方案后回复“开始吧”批准实现。
- 当前 C# 入口只输出日志及内嵌素材清单；现有日志记录最小 DLL Release 构建成功，但角色替换、战斗和游戏内加载尚未实现或验收。
- 开发基线为 Hollow Knight 1.5.78.11833 / Modding API v77 / net472。实际客户端版本、平台与游戏内加载结果须在客户端验收时记录。
- 棍系素材为 DragonBones 2.3 / 30 FPS，包含默认外观的嵌套装备部件、基础动作和 attack1–attack4。源普攻配置为 1001010–1001040，其中第三段 attMax=2；原始参数单位与完整 AS3 行为尚未追踪，不把移植实现值称为已还原的原作规格。
- 具体证据、脚本现状和接入约束见 research/ 下的专题记录。

## Requirements

- R1 外观：显示棍系默认孙悟空，支持左右朝向及待机、移动、跳跃、落下、受击和死亡等基础状态；使用稳定的人物比例和脚底锚点。
- R2 连击：仅替换地面水平普通攻击。一次按键触发一段，连续按键依次推进 attack1→attack2→attack3→attack4；每段有明确前摇、命中与收招，允许有限输入缓存，连段超时及中断后回到第一段。
- R3 命中：第一、二、四段各有一次命中机会，第三段有两个独立命中窗口；同一窗口对同一目标最多结算一次，不能叠加原骑士水平斩击造成重复伤害。
- R4 原版交互：空中攻击、上劈和下劈保留原规则，包括下劈弹跳。基础移动、跳跃、冲刺、生命、魂和存档沿用原系统；这些动作期间仍显示孙悟空。
- R5 伤害与反馈：首版每次有效命中使用现有骨钉等级和适用的原版护符修正，不增加自定义伤害倍率；维持原版普通攻击的敌人受击、击退、命中反馈、魂获取和可破坏物交互。
- R6 生命周期：场景切换、死亡重生、重复进出存档或禁用 Mod 后，不能残留额外渲染对象、判定或钩子。资源或初始化失败时恢复原角色的可见性与控制，并记录具体错误。
- R7 交付：提供可重复的动画转换、资源校验、Release 构建和开发包生成流程，包中包含所需加工资源，不混入 API 或游戏 DLL。
- R8 验收：分别记录自动检查、动画预览和实际客户端验收；尚未执行的客户端检查不得标为通过。

## Acceptance Criteria

- [ ] AC1（R1）：启动新游戏或加载存档后显示孙悟空，常规动作、左右翻转和四段攻击中无明显部件缺失、错层、锚点漂移或原骑士本体残影。
- [ ] AC2（R2）：每次有效攻击输入推进一段；单次输入不能无条件自动播完四段；输入缓存有上限；第四段完成、超时、跳跃、冲刺、受击或死亡后按约定重置，且控制可恢复。
- [ ] AC3（R3）：能验证各段命中窗口及第三段双击；同窗口不会因多个碰撞回调重复伤害；不同时发生原骑士水平斩击和自定义伤害。
- [ ] AC4（R4）：空中水平攻击、上劈、下劈与下劈弹跳仍可用；移动、跳跃、冲刺和原版资源/存档流程不被四连击接管。
- [ ] AC5（R5）：改变骨钉等级与适用护符后，普攻伤害/相关效果保持原版对应规则；命中敌人能产生正常反馈与魂，可破坏物仍可交互。
- [ ] AC6（R6）：跨场景、死亡重生、反复进入游戏及禁用/恢复 Mod 后，无重复对象、重复订阅、遗留伤害、角色隐形或永久失控。
- [x] AC7（R7）：从原始归档资源可重新生成带元数据的动画；构建、自动检查与打包流程成功，开发包包含完整依赖资源且无 API/游戏 DLL。
- [x] AC8（R8）：文档提供安装与客户端验收步骤，交付报告标明真实执行结果；没有客户端环境时明确标为待实机验收。

## Out of Scope

- 五个主动技能、拳系/双流派切换、觉醒、全套装备与皮肤。
- 独立跑攻与空中普攻机制；移动中发起的地面水平攻击仍使用本次四连击。
- 修改原版探索移动、地图、升级、存档或完整复刻造梦西游的资源和战斗系统。
- 承诺已准确还原未追踪的 AS3 时钟、动画事件、取消窗口或原作全部数值。
- 自动安装到用户游戏目录、公开发布、提交远端或泛化支持其他游戏/API 版本。

## Review Status

最终方案已获用户批准，任务处于 in_progress。AC7/AC8 已有完整构建日志、包闭包检查及安装/待实机文档作为证据；AC1–AC6 涉及实际客户端行为，仍保留未勾选。客户端版本核验属于实机验收前置检查，不阻塞按既定开发基线实现。


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


## Authorized 0.5.0 scope (2026-10-24)

The user requests a baseline commit first, Fire Demon on up + spell,
Bloodthirsty Fire Eye replacing held-focus instant healing, and Flame Storm on
down + spell. They authorize recommended decisions without questions and will
review/test later. This supersedes earlier skill exclusions/mapping. Preserve
source artwork and prior variants, 1.5x offline appearance, native hero collision,
prior Fire Demon source presentation/immunity/movement fix and enemy hurtbox rules.

- [x] Baseline workspace committed before implementation: a07b2ac.
- [ ] Up spell is Fire Demon, down spell is original Flame Storm action/flames.
- [ ] Focus action completes without instant HP gain; real attack damage heals
  one HP during the next five scaled seconds, globally at most once per second.
- [ ] Repeatable source/art/core/build checks and stopped-game backup/install.
- [ ] Actual client timing, input, Soul, immunity, damage, charm and cleanup review.

Design/plan/evidence: research/spell-layout-v05-20261024.md and docs/SPELL_LAYOUT.md.

## Authorized 0.5.1 corrections

Restore Fire Demon Slash source-authored forward travel and the final strike at
the resulting position, retaining input lock, full-cast immunity, source art,
fixed damage, facing and terrain collision. Add the missing original independent
Jiyuan Fire Eye (汲元火眼) buff visual while retaining the requested five-second
actual-damage healing policy. Preserve every existing source and size variant,
build/check, and back up/install directly with the game stopped. Gameplay review
remains pending.


## 0.5.2 missing Jiyuan casting effect

Restore the original flame winding around Wukong during Fire Eye casting,
including its nested end flashes, separately from the existing five-second
buff aura. Preserve archived inputs, all earlier art, native focus eligibility,
charge/Soul/charm/cancel behavior and the existing damage-heal policy. Bake new
original and offline 1.5x variant folders and install the checked update directly.
Client visual acceptance remains pending; parent task remains in_progress.


## 0.5.3 Fire Eye early-frame pacing correction

The user reports the beginning appears slowed after restoring the casting
overlay. Restore the original30Hz pacing and synchronized body/overlay startup.
Retain original assets/1.5x scale, native focus spending/completion/cancel/charm
rules, persistent aura and the five-second actual-damage healing policy.
Build/check, back up and install directly; client pacing acceptance pending.


## 0.6.0 original Wukong nail visuals

Replace native Knight slash arcs with the corresponding original Wukong staff
arcs for all four combo stages and aerial horizontal attacks. Up nail uses the
original effect1 rising-strike body and arc. Down nail uses the same arc rotated
180degrees around the character center; keep the hero upright. Preserve native
nail damage/upgrades, charms, Soul, contacts/clashes, attack timing, down-pogo
and terrain interaction. All spell/focus/dash mechanics remain as implemented.
Preserve all original/archive/older variants; generate new unscaled/1.5x folders
using batch pipeline, build/check and back up/install directly. Gameplay pending.
This explicitly supersedes the earlier preference for native Knight slash art.


## 0.6.1 native charm range for Wukong arcs

Follow original game charm enlargement behavior. Original NailSlash.StartSlash
scales its baseline X/Y by1.15(Longnail),1.25(Mark of Pride),1.4(both). Pride also
selects its M animation; range still comes from parameters. Reuse native scale
for original Wukong arcs while preserving the current offline1.5x body. Ground,
air, up/down/wall attacks must track range; no collider/damage/spell changes.
Preserve archived and all earlier baked/variant assets, build/check and directly
back up/install while stopped. Actual client acceptance remains pending.


## 0.6.2 downward dash and end-aligned Fire Eye

Dashmaster downward dashes must display downward Flame Dash flames for either
facing. Jiyuan Fire Eye casting action/effect must align its end to the native
focus completion instead of starting at native focus entry. Preserve source
animation speed, original art and previous variants, native dash mechanics,
focus cost/completion/cancellation and the five-second independent buff aura.
Build, check, back up and directly install for later client acceptance.


## 0.6.3 Flame Dash immunity and original Wukong death

Flame Dash must prevent incoming HP damage for its entire active native dash,
including downward dashes, then release immediately. Download the matching
original ZMXY4 Wukong death resource and display its complete death action/effect
instead of the Knight death body. Preserve source and current offline1.5x art,
native death/save/shade/Geo/dream/respawn processing and all prior mechanics.
Build/check/back up/install directly for later client acceptance.


## 0.7 fist skill layout

Current workspace must first be committed (checkpoint e44de07). Replace neutral
Vengeful Spirit/Shade Soul with original Wukong Afterimage Combo. Dream Nail
becomes a damaging charge-and-release Godslayer Strike; only fully charged hits
carry the original Dream Nail interactions. Down + Dream Nail uses Earthbreaker
Fist and up + Dream Nail uses Fire Ape Assault. Preserve all existing staff/nail,
up/down spells, focus, dash immunity and death behavior. Use original complete
fist body/effects, preserved archives and separate offline 1.5x variants.
Native save/progression/HP/Soul/scene systems stay authoritative. The four
afterimages should mimic Godslayer Strike and Earthbreaker as in the source.
Build/check/back up/install directly; gameplay acceptance remains pending.


## 0.7.1 fist corrections

Earthbreaker and Fire Ape require and spend the native spell Soul cost once per successful player cast. Mimic ghosts cost no extra Soul. Restore unsquashed proportions for the last two persistent afterimages through offline art generation. Godslayer must force a full release at original frame60 rather than waiting indefinitely, while preserving earlier key-up release/full-tier behavior and native Dream interactions. Preserve original/previous assets, build/check/back up/install directly; runtime acceptance remains pending.


## 0.7.2 copied ghost expiry and fist knockback

A ghost must disappear after its copied Godslayer/Earthbreaker action completes,
instead of returning to idle until its original ten-second expiry. Speed up
Earthbreaker descent. Add enemy knockback like native down-spell slam to the fist
attacks and their copies, including Fire Ape, to reduce contact collisions while
attacking. Retain native enemy recoil/resistance, resource/damage/mask rules and
all artwork. Build/check/back up/install directly; client acceptance pending.


## 0.7.3 skill defense and Fire Demon finisher

Fire Demon Slash final hit must push enemies horizontally with native down-slam
strength while retaining its source-relative airborne finisher. Earthbreaker must
prevent incoming HP damage throughout the owned player action. Fire Ape must
retain native HP damage but resist ordinary hit cancellation/recoil during its
owned action. Death, hazards, scene changes and teardown remain authoritative.
Preserve Soul costs, damage, masks, actors and artwork; build/check/back up/install
directly, with gameplay acceptance still pending.


## 0.7.4 free-body summoned skills

Neutral spell summons one independent Afterimage Combo attacker. It follows the
original combo route and leaves the four existing persistent/mimicking afterimages;
the player retains normal animation, movement, attacks, gravity and vulnerability.
Fire Ape uses source moving-awakening behavior: back/front effects follow current
player position and direction while the player remains free. Remove all prior
Fire Ape armor. Preserve Soul costs, source clocks/masks/damage/knockback, other
skills and original/previous assets. Build/check/back up/install directly for
later client acceptance; no new commit/push is requested.


## 0.7.5 native down-spell recovery protection

Confirm whether native down spell grants post-action invulnerability. If present,
give the same native recovery protection to successful Fire Demon Slash and player
Earthbreaker finishes. Preserve their current full-action immunity, every other
skill, resource/damage/movement rules and all artwork. Build/check/back up/install
directly for later client review; no commit/push requested.
