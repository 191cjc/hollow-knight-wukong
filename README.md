# Wukong Knight

《空洞骑士》孙悟空角色 Mod，参考 4399 网页版《造梦西游4》。当前开发版本为 **0.3.0-dev**：包含默认棍系外观、基础动作显示、地面水平四段普攻和单段空中水平棍击，以及可重复的动画烘焙、检查与打包流程。

**尚未在游戏客户端验收。** 自动检查、动画预览和编译结果不能证明游戏内加载、命中、护符、魂获取及场景恢复正常。实际检查结果见 `artifacts/build-report.json`，实机项目见 [客户端验收](docs/CLIENT_ACCEPTANCE.md)。

本次范围：地面一次按键出一段，连续输入最多形成四段连击，第三段有两个命中窗口。空中水平攻击使用单段 `jumpAttack`，重复按键不缓存连击，下一次攻击遵守原生冷却；落地关闭空中判定。上劈、下劈、贴墙攻击及下劈弹跳保留原有机制。主动技能、拳系、独立跑攻和空中多段连击未实现。

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
| `artifacts/WukongKnight-0.3.0-dev.zip` | DLL、说明、角色清单与引用的加工图集 |
| `assets/processed/wukong/previews/` | 动画 GIF、关键姿势联系表，不进入开发包 |
| `artifacts/validation.json` | 归档输入、解包、PNG、音频与配置检查 |
| `artifacts/character-validation.json` | 加工图集、帧范围、时序与连击窗口检查 |
| `artifacts/build-report.json` | 包内文件散列及实现/编译/自动检查/实机状态 |

本次使用 `0.3.0-dev`。角色清单为 schema 2，必须与本版 DLL 成套替换；旧 DLL/新清单或新 DLL/旧清单的组合会拒绝初始化并保留原骑士。旧版本完整目录可另行保留用于回退。

## 安装与验收

在匹配基线的客户端安装对应平台的 Modding API，将整个 `artifacts/mod/WukongKnight/` 复制至实际的 `hollow_knight_Data/Managed/Mods/`。Proton 与 Linux 原生客户端应各自确认路径、API 平台和游戏版本。保留 `WukongKnight.dll` 旁的 `character/character.json` 及图集。

进入存档后检查 `ModLog.txt`。资源或所需运行时接口不可用时，Mod 记录错误并保留/恢复原骑士。测试外观、四连击、单段空中棍击、方向攻击、护符、魂、落地/跳跃取消、死亡、换场和禁用恢复的完整步骤见 [客户端验收](docs/CLIENT_ACCEPTANCE.md)。移除或禁用本 Mod 即可回退。

## 动画与素材

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
