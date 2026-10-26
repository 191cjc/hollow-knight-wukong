# 客户端验收清单（待执行）

Baseline: Windows / Hollow Knight 1.5.78.11833 / API v77. Earlier 0.2.0-dev
initialization was observed in logs. Current 0.5.1-dev artwork, Flame Dash,
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

## Fire Demon Slash (0.5.1-dev, pending)

- [ ] Up + spell plays the original moving Wukong flashes and real blink gaps, without a duplicate native hero. Down/forward spells and down-slash pogo still work.
- [ ] Unlocks and Soul spending remain native; cast on ground/in air. The replacement has no forced dive-floor interaction. Native Quake damage/graphics must not stack with the replacement.
- [ ] Check fixed air/finisher damage 2/14 or 3/22; with Shaman Stone 3/21 or 5/33. Changing nail upgrades must not change Fire Demon damage.
- [ ] Same target respects 100ms contact cooldown and 11-hit cap; finisher hits once. Multiple colliders do not multiply damage. Actual HP loss still respects native evasion/invulnerability.
- [ ] Air effect stays world anchored after its original frame-5 directional spawn. Finisher starts at tick 36 after air expiry, even while airborne, and ends at tick 56; no dive or ground snap. Control/gravity recover.
- [ ] Air art/hit region use original +177 facing/+95 upward source-pixel spawn and original local mask centers in both directions. Enemies on both sides can be hit while the original mask dimensions remain unchanged.
- [ ] Normal hits, projectiles, spikes and acid cause no HP loss/recoil during preparation, air flashes or finisher. Custom protection releases when the cast ends/cancels or the Mod detaches; native recovery remains native; save invincibility is not changed.
- [ ] Damage/hazards/death/scenes, pause/low FPS, repeated casts and disable/re-enable leave no stale damage, hidden effects or permanently held spell state.

## Fire Demon movement regression (0.5.1-dev, pending)

- [ ] Start on the ground and in midair while already holding left/right; then tap/reverse/hold movement throughout preparation, air flashes and finisher. Only the original signed forward travel occurs during ticks5..36; the air effect stays anchored, and the finisher/body recover at the moved location. Movement inputs must not steer or add drift.
- [ ] Hold a direction across the end: movement resumes after the skill ends. Release it during the skill: no stored sideways motion appears afterward. Jump/dash/nail controls recover normally.
- [ ] Pause/resume during each phase, including held movement on resume. The source clock pauses and input cannot move the hero until recovery.
- [ ] Repeat casts, use low rendering FPS with normal physics, and disable/re-enable or change scenes. No residual input/gravity lock, drift, old velocity or stale damage remains; normal Flame Dash/exploration controls remain available.

## Skill collision and shake regressions (0.5.1-dev, pending)

- [ ] Cast Flame Dash / both Fire Demon phases far from Hornet and Buzzer bodies: sensor overlap must not damage them or consume hit opportunities.
- [ ] Contact real hurtboxes, including legitimate trigger hurtboxes; verify expected damage, evasion and per-target caps. Hornet needle/attack colliders must not damage their boss ancestor.
- [ ] Interactive breakables retain native hit response; hero/corpse/shield/Geo contacts remain excluded.
- [ ] Original relative offsets/masks are restored; character flashes retain source travel and blink gaps. Both facings and airborne finish align correctly.
- [ ] Fire Demon up-spell and Flame Storm down-spell finish without entering unowned damage states or adding native camera shake; other camera events work and scoped patches restore after disable.

## 生命周期与回退

- [ ] 连击中换场、死亡、重生、退出存档并重新进入，无残留伤害、重复对象/订阅、隐形或永久失控。
- [ ] 反复进入存档与场景后仍只有一个孙悟空视图，旧角色对象销毁不会清掉新角色的连击。
- [ ] 禁用 Mod 恢复原骑士显示和正常控制；重新启用不重复注册钩子。
- [ ] 刻意缺失一个图集时，日志明确指出问题并安全保留原骑士；还原完整目录后可重新加载。

## 记录方式

记录客户端版本/API/平台、测试日期、操作步骤、日志、实际结果与失败复现。尤其记录第三段是否真实造成两次 HP 损失以及对应魂/反馈。发现问题时保留当前 ZIP 的 SHA-256，便于与 `artifacts/build-report.json` 对照。

当前所有游戏内项目均为待验收。完成测试后，应在状态文档中区分“测试通过的客户端组合”和“未验证组合”，不能仅把编译/模拟测试结果转换为游戏兼容结论。


## Spell layout 0.5.1-dev (pending)

- [ ] Up + spell invokes Fire Demon only; both up-spell tiers, both facings,
  original flashes/midair finish, full-cast immunity and movement hold/recovery.
- [ ] Down + spell invokes Flame Storm only; original spin/flames, local range
  near Hornet/Buzzer, no distant sensor hits, contact cap/100ms/native evasion.
- [ ] Test normal/upgraded spell tiers with/without Shaman; nail upgrades cannot
  alter either spell. Verify one MP Cost (33/24 with Spell Twister) per cast;
  native Scream/Quake must not stack damage or consume extra Soul.
- [ ] Hold focus through Fire Eye action: native charge/Soul timing, no immediate
  heal. Complete at full HP as well as injured; cancellation never grants a buff.
- [ ] Real nail, beam, spell and Flame Dash damage heals one HP while active;
  whiffs, protected enemies and scenery do not. Multi-target/multi-hit attacks
  share one heal per second. Check five-second expiry and pause/unpause.
- [ ] Refresh duration without bypassing cooldown. Test Quick Focus, Deep Focus,
  Shape of Unn, insufficient Soul, focus release/rehold and dream focus.
- [ ] Incoming damage/scene/death/disable/reload cleans up action/buff/input and
  effect suppression; other native healing continues working.

Automated checks and frame preview do not establish these client results.

## 0.5.1 source travel and Jiyuan Fire Eye visual (pending)

- [ ] Both facing directions: Fire Demon moves forward by the original source
  progression, stops before terrain and finishes at the moved root. Check midair,
  walls, slopes, moving platforms, held/reversed input and low FPS. The air effect
  remains anchored; no native Scream damage, shake or forced drop appears.
- [ ] Successful focus completion starts the original red flame loop. Verify
  movement, facing, attacks, Quick/Deep Focus, refresh, five-second expiry, pause,
  death, scene change and disable. Cancelling an uncompleted charge grants no aura.
- [ ] No instant heal; actual damage still heals exactly one HP at most once/sec
  globally for five seconds. Check multiple enemies and repeated Storm contacts.


## 0.5.2 Jiyuan casting overlay (pending)

- [ ] Start focus facing both directions: original flames wind from the feet
  upward during the charge, then original eye flashes appear. The independent
  five-second aura begins only on successful completion.
- [ ] Release early, take damage, change scene or disable: no casting flame or
  eye flash remains; an interrupted charge grants no new aura/healing buff.
- [ ] Quick/Deep Focus retain native charge duration and Soul cost. Test focus
  release/rehold, Shape of Unn and refresh while the prior buff is still active.
- [ ] Preserve five seconds of healing on actual enemy HP loss, one HP at most
  once per second globally, with no completion heal. Check pause/resume as well.


## 0.6.2 end-aligned casting pace (supersedes0.5.3; pending)

- [ ] Without focus charms, startup/early charge show the opening body without
  flames; the original30 FPS casting action/effect end at native completion.
- [ ] Deep Focus delays the source window to the final0.7seconds without slowing
  or repeating the winding flames; Quick Focus/Unn use the source tail when short.
- [ ] Native completion/Soul cost remain unchanged. No artwork completion delay.
- [ ] Pause during startup/flames/recovery, release/rehold quickly, take damage,
  change scenes or disable: clocks reset/clear and no previous source tick leaks.
- [ ] Native completion still starts the independent five-second aura/heal buff;
  no immediate heal, one HP per real attack damage at most once/sec globally.


## 0.6.0 original nail arcs (pending)

- Check four intentional ground combo stages and stage3's two native hit windows.
  Each stage must show its corresponding original Wukong arc without a white
  native arc underneath; cancel by jump/dash/hit/turn to check immediate cleanup.
- Check airborne horizontal attacks, wall attacks, normal/Quick Slash pacing,
  both facings and repeated attacks. Up nail must use the source rising-strike
  action and arc. Down nail must keep an upright body with only the upward arc
  rotated180 about the fixed character center; no pivot jumping or full-body flip.
- Verify nail upgrades, applicable damage/reach charms, Soul, breakables, clashes,
  wall/terrain interactions, down pogo and invulnerability behave as before.
  Artwork follows offline1.5x size; damage reach deliberately remains native.
- Check spell/focus/dash visuals and all prior mechanics, scene changes, death,
  save re-entry and Mod disable/re-enable. Native nail meshes must restore on
  detach and after failed initialization. No API or save changes are required.


## 0.6.1 charm arc sizes (pending)

- Test neither charm, Longnail, Mark of Pride and both: Wukong arc should follow
  native1/1.15/1.25/1.4range while body/staff size stays fixed. Both is1.4, not
  the multiplicative product1.4375. Bench equip/unequip must apply on next attack.
- Check all4combo stages (including stage3 second window), air/up/down/wall,
  both facings and Quick Slash. Arc must share its body clock and fixed center.
- Verify normal native damage/reach/charms/Soul/pogo; no new damage transaction.
  Cancel by jump/dash/hit/turn, swap scene/die and disable/re-enable; no stale arc
  may remain during spells/focus/idle or after detach. Character size must never
  change with nail charms. Existing spell/focus/dash checks still apply.


## 0.6.2 Dashmaster downward presentation (pending)

- [ ] Equip Dashmaster, jump and down-dash with both left/right facings. Flames
  trail upward and point along the downward dash; body stays upright.
- [ ] Alternate horizontal/downward dashes; no direction leaks or rotated aura.
- [ ] Check walls/floors, shadow dash/Sharp Shadow, path damage, pause and cancel.


## 0.6.3 dash immunity and source death (pending)

- [ ] Horizontal/downward Flame Dash rejects enemy contact/projectiles and hazards
  during the active dash; damage works immediately after end/cancel. Check both
  facings, shadow dash/Sharp Shadow, pause, scene and Mod disable.
- [ ] Real death shows original Wukong fall/prone pose and rising ghost at30Hz,
  with no invisible body, Knight shell/head/nail overlay or repeated ghost.
- [ ] Ordinary and dream/boss deaths retain native camera/fade/Soul/Geo/shade/save/
  return behavior. Survivable spike/acid falls use native hazard recovery.
- [ ] Respawn/scene/disable restores native visibility and leaves no frozen corpse,
  invulnerability, old source time or altered saved state.


## 0.7 fist skills pending

- Neutral quick spell: source71ticks, one native MP Cost, no native projectile;
  four ghost births and ten-second expiry/recast, forward terrain stops.
- Dream press/hold/release: partial damages only; full1.267s (Wielder0.633s)
  damages and retains native thoughts/Soul/dream scenery interactions. Hold past
  full and verify automatic release at1.967s (Wielder0.983s), with exactly one
  wave/tail and no repeat while held. Try static NPCs/scenery and moving enemies.
- Down/up Dream Soul: below33 cannot start; exactly33 spends once. Equip Spell
  Twister and repeat below/exactly24; unequip and verify33 immediately. Ghosts do
  not multiply cost; neutral Dream remains free at zero Soul. Test interruptions.
- Last two persistent ghosts: stable punch/kick proportions at offline1.5x; no
  flattened orange transition drawing. First two and the main combo stay intact.
- Copied Godslayer/Earthbreaker ghosts disappear at the end of their release/
  landing action, without returning to idle or copying a second time. Early-charge
  interruption removes consumed ghosts; emitted waves finish independently. Unused
  ghosts still expire at ten seconds, and a late-starting copy may finish first.
- Earthbreaker descent is1.5x faster for hero/copies, preserving antic/rise/landing
  poses and terrain clamping. Check air casts, ceilings, thin platforms and pause.
- Fist hits use native Quake-slam horizontal recoil magnitude2: targets on either
  side of body casts move away, passing waves continue pushing forward, and ghosts
  do not stack manual velocity. Check Hornet/Buzzers and naturally recoil-resistant
  bosses; no forced displacement. Recheck Fire Demon/Storm.
- Down Dream: ground launch then slam; direct air slam, ceiling/floor/platform
  contact, bottomless timeout and recovery; ghosts use their own swept motion.
- Up Dream: both ape layers, all local punches/roar, source forward travel and
  recovery/cooldown. Nonlethal hits must deduct normal HP without canceling,
  displacing or restarting Fire Ape. Check native Stalwart Shell post-hit duration;
  lethal damage, spikes/acid, scenes and disable must still terminate it.
- Direction changes after press must not select another action. Movement input
  must not drift the hero. Verify pause, slow frames, interruption/death/scene,
  disable/re-enable, keyboard/controller, locked Dream Nail and previous skills.
- Hornet and Buzzers outside actual masks must take no damage. Multiple child
  colliders must respect per-target source caps. Ghost hits never grant extra
  dream effects. Dream Gate shortcuts are intentionally occupied by the new keys.


0.7.3 additions (not runtime-tested):
- Fire Demon final hit pushes nearby targets away horizontally with native slam
  strength, including left/right targets and midair casts. Native recoil-resistant
  bosses retain their resistance. Air contacts/Flame Storm remain unchanged.
- Earthbreaker blocks contact/projectile and direct HP damage for launch, fall and
  landing tail; damage resumes immediately after finish/cancel/timeout. Repeat
  casts and surviving ghost copies must not extend player immunity.
- Fire Ape remains damageable, retains the source action/clock and one Soul cost
  through a nonlethal hit, and recovers control at the original source end. Damage
  afterward must cancel ordinary Godslayer again. No persisted armor after scene/
  death/hazard/cancel/detach. Recheck HUD/blue health/overcharm/damage charms.


0.7.4 supersedes the earlier locked-body Afterimage and armored Ape checks:
- While running/jumping/falling, neutral spell summons the moving combo actor
  without resetting player speed, gravity, facing or body animation. Move away,
  attack or cast while it completes; its hits/ghosts remain at its own positions.
- Four trail ghosts keep distinct source birth positions, stable held poses,
  ten-second idle life and one-time Godslayer/Earthbreaker mimic expiry. Recast
  replaces the actor/old ghosts, with no extra wave/Ape/hero cancellation.
- Up Dream: move/jump/turn/attack/cast throughout moving-awakening Ape; back Ape
  follows behind body, front roar ahead, with no duplicate locked punching body.
- Ordinary hits must deduct HP and knock/stun the player normally: no armor or
  broad immunity. Ape/clone effects may continue independently. Death, spikes/acid,
  scene transitions and Mod disable clear all actors. Damage resumes normally
  after other protected skills end. Recheck native damage charms and HUD.
- Check insufficient/exact33andSpellTwister24Soul, successful casts charged once,
  no duplicate active Ape or duplicate same-frame payment, separate cooldowns,
  live local Hornet/Buzzer hurtboxes, native enemy recoil and pause/slow frames.


## 0.7.5 native down-spell recovery protection (pending)

- Complete Fire Demon on ground/in air and Earthbreaker after real landing: input
  and ordinary motion return, and ordinary enemy contact/projectiles are ignored
  for about0.4s afterward. The original full-action protection must stay continuous.
- After the native timer expires, ordinary damage/recoil works again. Repeated
  observers, pause/unpause and stale callbacks must not refresh it.
- A canceled/failed cast, unlanded timeout, copied Earthbreaker landing, death,
  hazard/scene change or Mod teardown must not grant an extra recovery timer.
- Compare spikes/acid and other hazard behavior with native Quake recovery: this
  new tail follows the game's native rules rather than the full-action HP guard.
- Check both spell tiers/charms, keyboard/controller, concurrent detached combo/
  moving Ape, Godslayer, staff attacks/pogo, dash/focus/death and previous skills.
