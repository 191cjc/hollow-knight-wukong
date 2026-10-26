# Wukong Knight

Wukong character Mod for Hollow Knight, based on archived 4399 ZMXY4 artwork.
Development version **0.7.5-dev** includes staff visuals, the grounded four-stage
combo, Flame Dash, Fire Demon Slash, Flame Storm, Jiyuan Fire Eye (汲元火眼),
Afterimage Combo and the three Dream-key fist skills.
All originals and earlier bakes/variants are preserved. Active artwork is baked
offline to 1.5x; native hero collision and nail reach retain their native size.
Ground/air nail attacks now use original Wukong staff arcs. Up nail uses the
original rising-strike action and arc; down nail rotates only that arc 180 degrees
around the character center, with an upright airborne body. Native damage,
charms, Soul, clashes and pogo remain authoritative. The independent arc layer
follows actual native charm reach (Longnail1.15x, Mark of Pride1.25x, both1.4x);
body and staff stay at their existing offline1.5x appearance.

- **Neutral quick spell:** summons one independent Afterimage Combo (残影连打)
  attacker that leaves four ten-second ghosts. The hero acts freely; ghosts mimic
  Earthbreaker/Godslayer with reduced damage.
- **Dream Nail:** damaging Godslayer Strike (灭神一击). Hold to charge, release to
  punch; a fully charged wave retains native Dream Nail effects (1.267s charge,
  or0.633s with Dream Wielder).
- **Down + Dream Nail:** Earthbreaker Fist (辟地拳), a terrain-limited ground/air slam.
- **Up + Dream Nail:** moving-awakening Fire Ape Assault (火猿出击), with original
  back/front effects following the free hero. Normal incoming damage/recoil applies.
- **Up + spell:** Fire Demon Slash, with original moving flashes, relative masks,
  midair finisher at the source-driven forward position, full-cast protection and input lock.
- **Down + spell:** Flame Storm, with the original spinning action and eight-image
  flame overlay; nearby source-mask contacts, at most five hits per target.
- **Hold spell/focus:** Jiyuan Fire Eye (汲元火眼). Native focus timing/Soul drain
  shows original winding flames/eye flashes at30 FPS in the final0.7s of the actual native charge (short charges use the source tail), then activates five seconds of healing on real
  player attack damage: one HP, globally at most once per second. Original red flame aura; no instant heal.
- **Dash:** Flame Dash retains native travel/cooldown/collision, adds path damage and blocks incoming HP damage throughout each actual dash; Dashmaster downward dashes use downward flames with the body upright.

Fire Demon uses the up-spell unlock/tier; Storm uses the down-spell unlock/tier.
Fixed spell damage is independent of nail upgrades and respects Shaman Stone.
Native up/down spell damage is replaced; each cast charges the current native
Soul cost once (including Spell Twister). See [spell controls](docs/SPELL_LAYOUT.md),
[Fire Demon](docs/FIRE_DEMON_SLASH.md) and [client checks](docs/CLIENT_ACCEPTANCE.md).
Directional/air nail attacks and pogo retain native behavior.
The new fist actions occupy individual slots; ordinary staff attacks stay available.
Dream-key actions require Dream Nail and replace Dream Gate shortcuts. Down/up
Dream spend the native spell Soul cost once (33; Spell Twister24); insufficient
Soul prevents casting. Neutral Godslayer remains free and automatically fires at
source maximum charge (1.967s, Dream Wielder0.983s). Last two ghosts use original
held punch/kick poses, preserving proportions. Copies are consumed at action end;
Earthbreaker descent is1.5x faster. Fist hits use native down-slam horizontal recoil
strength2, respecting enemy recoil rules and preserving other spell values.
See [fist skills](docs/FIST_SKILLS.md) for source, balance and pending client checks.

Actual gameplay acceptance is **pending**. Automated tests, artwork review and
compilation are recorded separately in `artifacts/build-report.json`.

源码仓库：https://github.com/191cjc/hollow-knight-wukong

## 构建

开发基线为 Hollow Knight `1.5.78.11833`、Modding API `v77`、C# `net472`。Linux x64，CPython 3.12–3.14：

```bash
python3 tools/bootstrap.py
bash scripts/build.sh
```

`bootstrap.py` 把固定 .NET SDK、API、Unity 编译引用和 Pillow 环境准备到 `.tools/`。SDK/API/Unity 归档散列见 `toolchain.lock.json`；Pillow `11.3.0` 的二进制轮子散列见 `tools/requirements-image.txt`。不修改游戏安装。

构建依次完成：原始素材散列与重解包校验、动画烘焙/缓存校验、角色清单与图集校验、Python 测试、无引擎 C# 连击测试、Release 编译、开发包闭包校验。`ffmpeg`/`ffprobe` 可用于完整音频解码；缺少时在素材报告中明确记录跳过。

| 输出 | 用途 |
|---|---|
| `artifacts/mod/WukongKnight/` | 安装整个目录，必须保留 `character/` |
| `artifacts/WukongKnight-0.7.5-dev.zip` | DLL、说明、角色清单与引用的加工图集 |
| `assets/processed/wukong/previews/` | 动画 GIF、关键姿势联系表，不进入开发包 |
| `artifacts/validation.json` | 归档输入、解包、PNG、音频与配置检查 |
| `artifacts/character-validation.json` | 加工图集、帧范围、时序与连击窗口检查 |
| `artifacts/build-report.json` | 包内文件散列及实现/编译/自动检查/实机状态 |

Current package: `0.7.5-dev`; older packages are retained for rollback.

## 安装与验收

在匹配基线的客户端安装对应平台的 Modding API，将整个 `artifacts/mod/WukongKnight/` 复制至实际的 `hollow_knight_Data/Managed/Mods/`。Proton 与 Linux 原生客户端应各自确认路径、API 平台和游戏版本。保留 `WukongKnight.dll` 旁的 `character/character.json` 及图集。

进入存档后检查 `ModLog.txt`。资源或所需运行时接口不可用时，Mod 记录错误并保留/恢复原骑士。测试外观、四连击、方向/空中攻击、护符、魂、取消、死亡、换场和禁用恢复的完整步骤见 [客户端验收](docs/CLIENT_ACCEPTANCE.md)。移除或禁用本 Mod 即可回退。

## 动画与素材

Run `scripts\prepare-all-assets.bat` on Windows to generate the complete set:
19 PNGs and 16 matching JSONs in `assets/processed/source-variants/all-1p5/`,
and the selected57-clip/1349-tick fist variant. Full enlarged canvases live in
`assets/processed/variants/wukong-fist-v071-1p5/`; the separate
`wukong-fist-v071-1p5-packed/` runtime folder uses12compact atlas pages.
Originals and earlier bakes remain
in separate folders. See [asset variants](docs/ASSET_VARIANTS.md) and
[Flame Dash](docs/FLAME_DASH.md) for source evidence and implementation rules.

```text
assets/zmxy4/raw/          28 个归档原始素材，保持不变
assets/zmxy4/animations/   8 组原始骨骼、纹理和图集 JSON
assets/zmxy4/audio/        14 段 MP3
data/source/              原始技能、Buff、角色配置及来源清单
data/character/           默认棍系烘焙配置和移植用连击时序
assets/processed/wukong/  加工图集、character.json 和审阅预览
src/WukongKnight/         资源/视图、连击核心与原生攻击适配器
tests/                    转换、清单/开发包、无引擎连击检查
reference/flash/          原始主程序、配置包与研究材料
```

处理规则、旧版 DragonBones 的支持边界和复现命令见 [动画处理说明](docs/CHARACTER_ASSETS.md)。更多资源与研究见 [素材索引](docs/ASSET_INDEX.md)、[技能研究](docs/SKILL_RESEARCH.md) 和 [当前状态](CURRENT_STATUS.md)。

```bash
# 原始素材校验与索引；不需要 Pillow
python3 tools/prepare_assets.py

# 加工资源与可视预览；输入不变时复用经验证的缓存
.tools/python/bin/python tools/bake_character.py
.tools/python/bin/python tools/validate_character.py
```

## 编译引用覆盖

公开 `UnityEngine.Modules 2021.3.33` 仅用于编译，**不代表客户端 Unity 精确版本匹配**。客户端需实际提供所用模块/成员；例如替换显示依赖 `Renderer.forceRenderingOff`。引用 DLL 均设为 `Private=false`，不会随 Mod 打包。

使用自己的兼容 API/Managed 引用时，可将 MSBuild 属性交给构建脚本：

```bash
bash scripts/build.sh \
  -p:HollowKnightApiDir=/absolute/path/to/api-managed \
  -p:UnityReferenceDir=/absolute/path/to/compatible-managed
```

API 目录需要所引用的 `Assembly-CSharp`、`MMHOOK_Assembly-CSharp`、MonoMod 和 Newtonsoft DLL；Unity 目录需要 facade 与 Core、Physics2D、ImageConversion、Audio 等模块。不同游戏/API/引擎版本需重新核对签名并实机验收。

## 来源

素材来自 4399 公开游戏资源，归档日期为 2026-10-23。URL、大小与 SHA-256 见 `data/source/manifests/downloads.json`、`reference/flash/provenance.json`。

素材版权属于原权利人。当前处于研究开发阶段，尚无正式发行版本；开发包包含本次加工的角色图集，不含原始资源归档、游戏/API/Unity DLL。公开下载不等于获得再分发许可。

0.5.0 keeps movement input and physical velocity locked for the entire Fire
Demon cast, then restores through native spell recovery. Original moving
flashes, airborne finisher, full-cast protection and damage stay intact.
Movement/pause/recovery gameplay checks remain pending.


0.6.3 displays the original65-tick Wukong falling/prone death and ghost effect,
independently of the native mesh's death visibility. Official manV535.swf was
freshly downloaded and verified against the existing original; all current art
pixels remain unchanged. Native death/save/Geo/shade/dream/respawn logic continues.
See docs/DEATH_PRESENTATION.md for source and pending client checks.


0.7.3 adds native slam-strength horizontal recoil to the Fire Demon final hit,
full owned-action Earthbreaker HP protection, and Fire Ape hit interruption
resistance while retaining normal native HP damage and post-hit cooldown.
Death/hazards/scenes remain authoritative. Artwork and Soul costs are unchanged.


0.7.4 changes Afterimage Combo into one independently moving attacker that leaves
the existing four ghosts while the hero remains free. Fire Ape now uses source
moving-awakening effects following live hero position/direction, with no forced
body action/travel. Prior Ape armor is removed; native incoming damage/recoil
remain intact. Original/previous assets are retained in separate variant folders.


0.7.5 gives successful Fire Demon Slash and player Earthbreaker recovery the
original down-spell QuakeInvuln timer (live native default0.4s). Current full-action
protection stays intact; after recovery, native ordinary-damage/expiry/hazard rules
apply. Interrupted casts, unlanded timeouts and copied ghosts grant no timer.
All v074 artwork is reused byte-for-byte. Client timing/combat acceptance is pending.
