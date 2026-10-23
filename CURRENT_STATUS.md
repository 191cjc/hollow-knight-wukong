# 当前项目状态：孙悟空外观与地面四段普攻

更新日期：2026-10-23（Asia/Shanghai）。开发版本：`0.2.0-dev`。

## 当前阶段

本次目标已从资源准备推进到 **默认棍系外观、基础动作显示和地面水平四段连击的代码实现与集成验收**。离线资源、测试、编译和开发包可在服务器检查；实际游戏内加载、显示、命中与生命周期仍需客户端验收。

**不能据此宣称孙悟空已经在实机可玩。** 服务器没有已确认的 Hollow Knight 安装。最终执行结果与各文件散列见 `artifacts/build-report.json`；`runtime_tested` 保持 `false`。安装与实机项目见 [客户端验收](docs/CLIENT_ACCEPTANCE.md)。

## 本次范围与实现

| 部分 | 当前内容 |
|---|---|
| 动画转换 | 从 2001/manV535 默认棍系素材离线生成 13 个动作，30 FPS、329 个源 tick；固定画布与根点 |
| 加工图集 | 公共画布 231×226，根点 (119,174)；52 个精确去重单元，单页 1848×1582；参数以实际清单为准 |
| 角色显示 | 外部清单/图集校验后附着孙悟空视图，隐藏原骑士本体绘制，保留控制器/FSM，并映射基础/特殊状态 |
| 连击核心 | 单输入一段、至多一个缓存、四段顺序、0.35 秒续接宽限、Quick Slash 时钟缩放、窗口去重与取消令牌 |
| 原生攻击适配 | 仅接管地面水平普通攻击，复用原生 NailSlash 事务，在配置窗口管理选定判定；第三段两个窗口 |
| 原有攻击 | 空中水平攻击、上/下劈及下劈弹跳保留原生规则，身体仍使用孙悟空姿势映射 |
| 生命周期 | 单一附着/取消/移除流程，清理视图、所选判定、缓存、订阅及本次拥有的状态；错误保留/恢复原骑士 |
| 构建打包 | 原始素材重解包比较、共享清单校验、Python/C# 检查、Release 编译、开发包闭包与 ZIP 字节检查 |

这些是代码实现/离线资源状态，不是客户端通过记录。碰撞、敌人 HP、魂、护符、可破坏物与下劈交互必须在游戏中逐项验证。

当前攻击配置经过离线姿势审阅：

| 段 | 总 tick | 输入缓存开放 tick | 命中窗口（半开区间） |
|---|---:|---:|---|
| attack1 | 12 | 4 | [4,7) |
| attack2 | 15 | 5 | [5,8) |
| attack3 | 18 | 3 | [3,5)、[11,14) |
| attack4 | 20 | 5 | [5,8) |

时序属于本次移植设计，未声称还原原作 AS3 命中时钟。没有自定义伤害倍率，沿用骨钉及适用护符的原生结算。动画名和 `evtMohu_*` 等源事件不能直接证明命中规则。

## 保留的素材与研究

| 内容 | 数量/位置 |
|---|---|
| 原始素材 | 28 文件，`assets/zmxy4/raw/`；保留 URL/大小/SHA-256 |
| 骨骼动画 | 8 组原始 JSON/PNG，`assets/zmxy4/animations/` |
| 技能图标和纹理 | 共 19 张归档 PNG |
| 音效 | 14 段 MP3，`assets/zmxy4/audio/se2001/` |
| 配置 | 97 条技能、222 条 Buff、角色 2001/2006/2011，`data/source/` |
| Flash 研究 | 原始 SWF/配置包/字符串索引，`reference/flash/`；未完成主程序 AS3 调用链反编译 |
| 加工配置/输出 | `data/character/wukong-staff.json`、`assets/processed/wukong/` |

8 组素材并未全部转换。本次仅处理 2001 默认棍系外观，覆盖 idle/walk/runNormal/jumpNormal/jumpTwo/jumpDown/jumpAttack/hurtStand/dead/attack1–4。

原始素材/配置的完整说明见 [素材索引](docs/ASSET_INDEX.md)、[动画处理](docs/CHARACTER_ASSETS.md)、[技能研究](docs/SKILL_RESEARCH.md) 和 [原始归档说明](docs/ORIGINAL_ASSET_PACKAGE.md)。

## 构建环境与复现

| 依赖 | 固定版本/边界 |
|---|---|
| .NET SDK | 10.0.402，项目 `.tools/dotnet/` |
| Mod 目标框架 | net472，游戏不需要安装 .NET 10 |
| Hollow Knight / API | 1.5.78.11833 / v77 Linux，当前开发基线 |
| 框架引用 | Microsoft.NETFramework.ReferenceAssemblies 1.0.3 |
| Unity 编译引用 | UnityEngine.Modules 2021.3.33 的 net45 模块，仅编译；不等同客户端精确版本 |
| 图像处理 | 项目 `.tools/python/`，Pillow 11.3.0，轮子 SHA-256 固定 |

```bash
python3 tools/bootstrap.py
bash scripts/build.sh
```

SDK/API/Unity 的版本和归档散列在 `toolchain.lock.json`；Pillow 锁在 `tools/requirements-image.txt`。API 与 Unity 编译引用允许用 MSBuild 的 `HollowKnightApiDir` / `UnityReferenceDir` 覆盖，见 README。所有游戏/API/Unity 引用均不随 Mod 打包，不引入 PlayMaker 编译依赖。

构建保留原有检查：28 个原始文件及研究归档散列、8 组动画容器重解包逐字节比较、PNG CRC/IDAT、XML/JSON、97 条技能与 222 条 Buff 的索引检查；有 ffmpeg/ffprobe 时对 14 段音频完整解码。

新增检查涵盖旧版骨骼的变换/枢轴/隐藏/透明度与确定性烘焙，清单/图集/窗口校验，缓存/边界/取消/双窗口去重的实际连击核心，以及开发包完整性。客户端效果不属于上述自动检查的证明范围。

## 产物与验证记录

- `assets/processed/wukong/previews/`：GIF、动作联系表、公共原点/朝向审阅图，不进入运行时开发包。
- `artifacts/mod/WukongKnight/`：DLL、README、`character/character.json` 与引用图集。
- `artifacts/WukongKnight-0.2.0-dev.zip`：本次开发包；本地旧的 0.1.0-dev 是原脚手架包，不应作为当前版本使用。
- `artifacts/validation.json`：原始素材校验及可选音频解码状态。
- `artifacts/character-validation.json`：资源协议、尺寸、散列、逐 tick 总量和窗口检查。
- `artifacts/build-report.json`：区分 implemented、built、automatically_verified 与 runtime_tested/client_acceptance。

2026-10-23 已实际运行 `python3 tools/bootstrap.py` 与完整 `bash scripts/build.sh`，构建日志为 `artifacts/build.log`：

- 原始素材、研究归档散列、8 组动画重新解包、PNG/JSON/XML 和 14 段音频完整解码均通过。
- 最终角色清单校验通过：13 动作、329 个逐 tick 记录、1 张图集、公共根点及 1/1/2/1 命中窗口。
- **23 项 Python 测试通过**（15 项转换/烘焙、8 项清单/打包）；**10 项无引擎 C# 检查通过**（含取消时的接触列表安全清理），链接实际生产核心源码。
- `net472` Release 编译通过，**0 警告、0 错误**；DLL 为 **39,936 字节**。
- 开发 ZIP 为 **532,705 字节**，只有 DLL、README、角色清单与单张引用图集；包内闭包、ZIP CRC/字节比较通过。
- ZIP SHA-256：`761fc0564c5f68bec1c4be13cf1c5aeb99a78f95ad72a1197005418e0d32a1ea`。
- DLL SHA-256：`438285a885006b01109dccd773f5d8c994c3d9dd19447e711c5e5005ed039c04`。

独立审查修复了取消后原生接触列表仍可能造成残留伤害的问题：仅清理所接管斩击的记录，原生遍历期间延后清空，并在 FSM 事件前同步命中窗口。

以上属于服务器自动检查和构建记录；客户端验收仍为 pending，`runtime_tested=false`。后续代码或资源变更后，应以重新构建的报告和散列为准。

## 待办与范围外

首要待办是按 [客户端验收清单](docs/CLIENT_ACCEPTANCE.md) 测试加载、人物比例/原点、命中、原生反馈与恢复；尤其第三段真实两次 HP 损失、多碰撞体去重、不同骨钉/护符、魂、可破坏物、换场/重生/禁用。

五个主动技能、拳系/切换、觉醒/换装、独立跑攻与空中连击未实现。未来实现原作技能仍需追踪 AS3 的单位、输入、伤害、取消与 Buff 语义。本次不自动安装游戏；按用户要求将开发源码上传至 GitHub 仓库，尚无正式发行版本。

素材来自 4399 公开游戏资源，URL 与散列见 `data/source/manifests/downloads.json`、`reference/flash/provenance.json`。素材版权属于原权利人；加工开发包包含生成的角色图集，不含原始归档及游戏/API/Unity DLL。当前为研究开发版本。
