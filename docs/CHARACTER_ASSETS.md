# 默认棍系角色动画处理

运行时使用离线烘焙的透明 PNG 图集，不在游戏中运行 DragonBones。原始素材保持不变，开发包只收录 `character.json` 与其中引用的加工图集。

## 输入与输出

- 输入：`assets/zmxy4/animations/2001/manV535/{skeleton.json,texture.json,texture.png}`。
- 配置：`data/character/wukong-staff.json`，默认装备动画 `1`、公共画布与四段连击的移植用时序。
- 生成器：`tools/bake_character.py`、`tools/legacy_dragonbones.py`。
- 输出：`assets/processed/wukong/character.json`、`atlas-000.png` 等图集，以及 `previews/`。
- 最终清单校验：`tools/validate_character.py`，由生成器缓存检查、构建和打包共同复用。

13 个动作：idle、walk、runNormal、jumpNormal、jumpTwo、jumpDown、jumpAttack、hurtStand、dead、attack1–attack4，共 329 个源 tick，30 FPS。重复像素帧复用同一图集单元，清单仍逐 tick 记录帧，保持同一画布、根坐标和人物比例。

生成清单不包含构建时间戳；输入散列包括源素材、配置、生成器/采样器/校验器代码与 Pillow 版本。输入未改变且清单、图集校验通过时复用缓存。当前输出尺寸、根坐标和单元数量由命令打印，详情以实际清单为准。

## 旧格式规则与边界

本次针对归档的旧 DragonBones 2.3 数据实现有限转换，参考固定的 DragonBonesAS 历史解析器研究，不声称支持任意版本。支持实际使用的全局骨骼姿势、嵌套装备、仿射变换/负缩放、帧与显示项两种枢轴、Z 顺序、可见性及颜色/透明度；未支持的新特性应明确失败。

源动作关闭补间，因此按关键帧保持采样，不自行平滑。使用精确的源 tick 时钟，不声称与历史 Flash 毫秒取整时钟逐字节相同。缺失时间轴和隐藏装备动画不能回退成可见绑定姿势。超长末关键帧按源动作总长度修复。

仅在加工副本中把 **RGBA(0,0,0,1)** 精确填充值清为透明，不用高阈值删除半透明边缘。所有帧固定原点，不逐帧居中，也不因武器伸长而缩小人物。

## 命中窗口

`combat` 属于本次移植设计。源 `evtMohu_*` 等事件尚未追踪，不能据此声称复刻原作命中时刻。四段源时长为 12/15/18/20 tick；具体窗口和输入缓存开放 tick 见配置。窗口采用半开区间 `[start_tick,end_tick)`，每段为 1/1/2/1 个窗口。

每个窗口沿用原生骨钉及适用护符的结算，不添加独立伤害倍率。配置中的 `range_multiplier` 用于原生水平斩击伸距。运行时只接管地面水平攻击；上/下劈与空中攻击沿用原版规则，孙悟空身体使用明确的姿势映射，上/下方向由保留的原版斩击效果表达。

## 复现与检查

```bash
python3 tools/bootstrap.py
.tools/python/bin/python tools/bake_character.py
.tools/python/bin/python tools/validate_character.py
.tools/python/bin/python -m unittest discover -s tests -p 'test_*.py'
```

强制重新生成并保留预览：

```bash
.tools/python/bin/python tools/bake_character.py --force
```

只检查已生成的资源：

```bash
.tools/python/bin/python tools/bake_character.py --validate-only
```

`previews/overview.png` 展示动作关键姿势；`attacks-contact.png`、各动作 `*-contact.png` 和 GIF 可用于检查部件、层级、朝向、公共原点和攻击姿势。它们证明素材组成与视觉采样情况，不证明游戏内碰撞、伤害或角色显示。

清单校验覆盖协议版本、13 个必需动作、固定画布/根点、逐 tick 总量、图集尺寸/散列/PNG 解码、矩形边界、四段顺序和窗口。开发包另校验精确文件闭包、禁止多余 DLL/预览、ZIP 字节一致性。源文件校验和 8 组动画重新解包比较仍由 `tools/prepare_assets.py` 执行。

原始素材的来源与散列见 `data/source/manifests/`。历史解析器证据与转换风险见任务研究 `research/animation-conversion.md`；视觉审阅见任务 `research/visual-review.md`。
