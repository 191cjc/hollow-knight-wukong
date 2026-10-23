# 造梦西游4网页版：孙悟空角色与技能资源

> 本文件保留原始素材包说明。项目迁移后：`sources/assets/` → `assets/zmxy4/raw/assets/`；`exported/animations/` → `assets/zmxy4/animations/`；`exported/audio/` → `assets/zmxy4/audio/`；`config/` → `data/source/`；`manifests/` → `data/source/manifests/`。下文命令按旧归档布局编写，当前命令请看根目录 README。

来源：4399 官方公开游戏静态资源。整理日期：2026-10-23。
游戏入口：https://www.4399.com/flash/zmhj.htm?g=4
入口引用的游戏文件版本：v5870.swf；资源清单日期：20261019_1。

## 已整理内容

- 28 个原始资源文件，下载 URL、大小和 SHA-256 见 manifests/downloads.json。
- 8 组解包后的动画资源：骨骼 JSON、图集 JSON、PNG 纹理各 8 个。
- 11 张技能图标，位于 sources/assets/icon/skill。
- 14 段可直接播放的 MP3 动作音效，位于 exported/audio/se2001。
- 97 条相关技能配置，含普通攻击、子技能、觉醒变体和附加形态技能；97 条不等于 97 种独立招式。
- 与所选技能关联的 Buff 配置、觉醒配置、资源索引，以及 3 个 Buff 原始 SWF。

棍系五技能：升龙斩、烈焰闪、烈焰风暴、汲元火眼、火魔斩。
拳系五技能：辟地拳、灭神一击、擒魔爪、残影连打、火猿出击。
当前配置称“汲元火眼”；旧版攻略中的名称为“嗜血火眼”。

## 目录与使用

- exported/animations/2001：棍系基础动作与技能特效。
- exported/animations/2006：拳系基础动作与技能特效。
- exported/animations/2011：配置中的附加形态资源。
- exported/audio：解出的动作音效。
- sources/assets：保留官方原始文件名和目录的资源。
- config/skills.csv：可用表格软件查看的技能索引。
- manifests/animations.json：每个骨架内的动作名称。
- tools/unpack_animation.py：使用 Python 标准库解开原始动画包的工具。

可重复解包：

```sh
python3 tools/unpack_animation.py sources/assets/man extracted-again
```

## 覆盖范围与尚待处理的部分

已确认棍系与拳系主骨架都包含 effect1 到 effect5 五个技能动作，以及走、跑、跳、普攻等基础动作。
骨骼数据格式为 DragonBones 2.3/3.0。PNG 纹理图集内含分离的角色部件或特效图片，尚未烘焙为完整角色逐帧动画。
用于空洞骑士时，需要烘焙透明 PNG 动画序列，或接入能读取这些旧版格式的动画运行库，并重新实现招式逻辑。

尚未逐项验证所有觉醒和运行时代码组合特效的视觉完整性，也未在空洞骑士中测试。
本包不包含全部装备或时装；音效包 se2006.swf 本身没有 DefineSound 音频条目。
Buff 特效仍保留为原始 SWF。

## 验证与素材权属

28 个下载文件均校验 SHA-256；所有 PNG 已检查签名、区块 CRC 和压缩数据；JSON 均能解析；14 个 MP3 均检查到有效音频帧头。
具体结果见 manifests/validation.json。上述格式检查不等于完整游戏效果验收。
素材版权属于原权利人；从公开地址下载不代表获得再分发授权，公开发布 Mod 前需确认使用许可。
