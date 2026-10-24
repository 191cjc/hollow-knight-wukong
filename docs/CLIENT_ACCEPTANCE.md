# 客户端验收清单（待执行）

Baseline: Windows / Hollow Knight 1.5.78.11833 / API v77. Earlier 0.2.0-dev
initialization was observed in logs. Current 0.4.4-dev artwork, Flame Dash,
Fire Demon Slash, collision and combat still need gameplay acceptance. All
gameplay items remain unchecked and `runtime_tested=false` until actual results
are recorded. Build/install verification alone does not complete this checklist.

## 安装前

1. 记录游戏版本、操作系统、Linux 原生/Proton、Modding API 版本和平台。开发基线为 Hollow Knight 1.5.78.11833 / API v77；其他组合不能从编译结果推断兼容。
2. 确认客户端具备实际使用的 Unity Core、Physics2D、ImageConversion、Audio 模块及 `Renderer.forceRenderingOff` 等接口。公开 Unity 2021.3.33 包只是编译引用，不安装到游戏中。
3. 安装对应平台 API，把完整的 `artifacts/mod/WukongKnight/` 放入实际 `hollow_knight_Data/Managed/Mods/`，保留 DLL 旁的 `character/character.json` 与全部引用图集。不要复制 `.tools/` 中的 DLL。
4. 启动、进入存档并检查 `ModLog.txt` 的 Wukong Knight 日志。缺资源或缺运行时接口应记录初始化/附着错误并保留原骑士。日志中的 enabled 不代表验收通过。

## 外观与探索

- [ ] 新游戏和已有存档均能显示默认棍系孙悟空，身体/服饰/棍子完整，比例与脚底原点稳定。
- [ ] 左右转向只翻转一次；待机、走/跑、跳跃、二段跳、下落、受击与死亡无错误跳帧或部件缺失。
- [ ] 爬墙、冲刺、超级冲刺、聚集、施法、坐凳、过场和伤害闪烁的姿势回退与可见性合理。
- [ ] 原骑士移动、碰撞、生命、魂、升级和存档仍正常。
- [ ] 0.2.2-dev：悟空外观通过离线素材处理为原始大小的 1.5 倍，脚底对齐；碰撞仍与原骑士一致，狭窄通道和受击边界未放大。

## 普攻与原生交互

- [ ] 地面水平按一次仅出一段；松开不重置连段。连续四次有效输入按 attack1–attack4 顺序执行，第四段之后回到第一段。
- [ ] 一段期间至多缓存一次后续输入；过早输入不积累四段。上一段结束后约 0.35 秒内可续接，超时从第一段开始。
- [ ] 第一/二/四段每窗口每目标一次有效命中；第三段两窗口对同一目标可分别扣血，不因多碰撞体/重复回调额外命中。
- [ ] 0.2.1-dev：四段普攻的每个命中窗口均出现原角色的斩击弧光，第三段两次命中各播放一次；左右朝向、护符变体及中断清理正常。
- [ ] 单敌人、多敌人、不同骨钉等级与适用护符均检查伤害、击退、音效、魂、clash 和可破坏物。
- [ ] Quick Slash 同步缩放整段动画、命中和收招；范围护符作用于原生范围，不能出现一段中动画与判定脱节。
- [ ] 空中水平攻击、上劈、下劈保持原生规则，下劈弹跳可用于敌人、尖刺或可弹跳对象；孙悟空身体持续显示。
- [ ] 普攻可被跳跃/冲刺/受击取消；转向、方向攻击、失去控制或特殊状态会关闭旧判定，不留下攻击锁。

## Flame Dash (0.3.0-dev, pending)

- [ ] The original dash key plays all six source flame images, mirrors correctly, and returns to the correct body pose without showing the original dash burst.
- [ ] Native ability unlock, distance, cooldown, wall stops, downward Dashmaster movement and shadow-dash invulnerability remain functional.
- [ ] An enemy loses HP once per dash, including enemies with multiple colliders; a later dash can hit again. Check different nail levels and native invulnerability.
- [ ] Sharp Shadow does not cause a second hit; Sharp Shadow plus Dashmaster preserves its damage interaction. No extra soul or MP cost is introduced.
- [ ] Ordinary dash can still be interrupted by damage; no unrequested armor/invulnerability was added. No damage continues after recoil, hazards, death or scene transitions.
- [ ] Pause, low frame rate, rapid consecutive dashes and disable/re-enable do not leave stale damage, invisible native effects or duplicate Wukong views.

## Fire Demon Slash (0.4.4-dev, pending)

- [ ] Down + spell plays the original moving Wukong flashes and real blink gaps, without a duplicate native hero. Up/neutral spells and down-slash pogo still work.
- [ ] Unlocks and Soul spending remain native; cast on ground/in air. The replacement has no forced dive-floor interaction. Native Quake damage/graphics must not stack with the replacement.
- [ ] Check fixed air/finisher damage 2/14 or 3/22; with Shaman Stone 3/21 or 5/33. Changing nail upgrades must not change Fire Demon damage.
- [ ] Same target respects 100ms contact cooldown and 11-hit cap; finisher hits once. Multiple colliders do not multiply damage. Actual HP loss still respects native evasion/invulnerability.
- [ ] Air effect stays world anchored after its original frame-5 directional spawn. Finisher starts at tick 36 after air expiry, even while airborne, and ends at tick 56; no dive or ground snap. Control/gravity recover.
- [ ] Air art/hit region use original +177 facing/+95 upward source-pixel spawn and original local mask centers in both directions. Enemies on both sides can be hit while the original mask dimensions remain unchanged.
- [ ] Normal hits, projectiles, spikes and acid cause no HP loss/recoil during preparation, air flashes or finisher. Custom protection releases when the cast ends/cancels or the Mod detaches; native recovery remains native; save invincibility is not changed.
- [ ] Damage/hazards/death/scenes, pause/low FPS, repeated casts and disable/re-enable leave no stale damage, hidden effects or permanently held spell state.

## Fire Demon movement regression (0.4.4-dev, pending)

- [ ] Start on the ground and in midair while already holding left/right; then tap/reverse/hold movement throughout preparation, air flashes and finisher. The physical hero root and skill origins remain stable; authored character flashes still move.
- [ ] Hold a direction across the end: movement resumes after the skill ends. Release it during the skill: no stored sideways motion appears afterward. Jump/dash/nail controls recover normally.
- [ ] Pause/resume during each phase, including held movement on resume. The source clock pauses and input cannot move the hero until recovery.
- [ ] Repeat casts, use low rendering FPS with normal physics, and disable/re-enable or change scenes. No residual input/gravity lock, drift, old velocity or stale damage remains; normal Flame Dash/exploration controls remain available.

## Skill collision and shake regressions (0.4.4-dev, pending)

- [ ] Cast Flame Dash / both Fire Demon phases far from Hornet and Buzzer bodies: sensor overlap must not damage them or consume hit opportunities.
- [ ] Contact real hurtboxes, including legitimate trigger hurtboxes; verify expected damage, evasion and per-target caps. Hornet needle/attack colliders must not damage their boss ancestor.
- [ ] Interactive breakables retain native hit response; hero/corpse/shield/Geo contacts remain excluded.
- [ ] Original relative offsets/masks are restored; character flashes retain source travel and blink gaps. Both facings and airborne finish align correctly.
- [ ] Both down-spell tiers finish without entering Quake Down/Land or adding native EnemyKillShake/BigShake; other camera events work and scoped patches restore after disable.

## 生命周期与回退

- [ ] 连击中换场、死亡、重生、退出存档并重新进入，无残留伤害、重复对象/订阅、隐形或永久失控。
- [ ] 反复进入存档与场景后仍只有一个孙悟空视图，旧角色对象销毁不会清掉新角色的连击。
- [ ] 禁用 Mod 恢复原骑士显示和正常控制；重新启用不重复注册钩子。
- [ ] 刻意缺失一个图集时，日志明确指出问题并安全保留原骑士；还原完整目录后可重新加载。

## 记录方式

记录客户端版本/API/平台、测试日期、操作步骤、日志、实际结果与失败复现。尤其记录第三段是否真实造成两次 HP 损失以及对应魂/反馈。发现问题时保留当前 ZIP 的 SHA-256，便于与 `artifacts/build-report.json` 对照。

当前所有游戏内项目均为待验收。完成测试后，应在状态文档中区分“测试通过的客户端组合”和“未验证组合”，不能仅把编译/模拟测试结果转换为游戏兼容结论。
