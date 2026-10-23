# 素材索引

由 `python3 tools/prepare_assets.py` 从实际文件生成。此处记录原始骨骼；默认棍系外观的烘焙与预览见 [动画处理说明](CHARACTER_ASSETS.md)。动作名称不直接等于命中判定。

## 动画包

| 角色 / 包 | 格式 / FPS | 骨架数 |
|---|---|---|
| [2001/manV535](../assets/zmxy4/animations/2001/manV535/skeleton.json) | DragonBones 2.3 / 30 | 23 |
| [2001/skill1V472](../assets/zmxy4/animations/2001/skill1V472/skeleton.json) | DragonBones 3.0 / 30 | 12 |
| [2001/skill5](../assets/zmxy4/animations/2001/skill5/man_skeleton.json) | DragonBones 3.0 / 30 | 3 |
| [2006/manV535](../assets/zmxy4/animations/2006/manV535/skeleton.json) | DragonBones 2.3 / 30 | 21 |
| [2006/skill1V530](../assets/zmxy4/animations/2006/skill1V530/skeleton.json) | DragonBones 2.3 / 30 | 34 |
| [2006/skill5](../assets/zmxy4/animations/2006/skill5/skill5_skeleton.json) | DragonBones 3.0 / 30 | 3 |
| [2011/manV535](../assets/zmxy4/animations/2011/manV535/skeleton.json) | DragonBones 2.3 / 30 | 16 |
| [2011/skillV530](../assets/zmxy4/animations/2011/skillV530/skeleton.json) | DragonBones 2.3 / 30 | 11 |

## 主角色动作

- `assets/zmxy4/animations/2001/manV535`：`idle` (22 帧)、`walk` (24 帧)、`runNormal` (12 帧)、`runAttack` (15 帧)、`attack1` (12 帧)、`attack2` (15 帧)、`attack3` (18 帧)、`attack4` (20 帧)、`hurtStand` (49 帧)、`dead` (65 帧)、`jumpNormal` (35 帧)、`jumpTwo` (12 帧)、`jumpAttack` (10 帧)、`jumpDown` (35 帧)、`effect1` (15 帧)、`effect2` (73 帧)、`effect3` (16 帧)、`effect4` (17 帧)、`effect5` (60 帧)、`ride` (60 帧)、`runNormal1` (14 帧)
- `assets/zmxy4/animations/2006/manV535`：`idle` (18 帧)、`walk` (24 帧)、`runNormal` (12 帧)、`runAttack` (15 帧)、`attack1` (9 帧)、`attack2` (7 帧)、`attack3` (8 帧)、`attack4` (14 帧)、`attack5` (15 帧)、`hurtStand` (50 帧)、`dead` (65 帧)、`jumpNormal` (35 帧)、`jumpTwo` (12 帧)、`jumpAttack` (15 帧)、`jumpDown` (35 帧)、`effect1` (32 帧)、`effect2` (84 帧)、`effect21` (114 帧)、`effect22` (84 帧)、`effect3` (74 帧)、`effect4` (71 帧)、`effect5` (105 帧)、`ride` (60 帧)、`runNormal1` (14 帧)
- `assets/zmxy4/animations/2011/manV535`：`idle` (36 帧)、`hurtStand` (18 帧)、`walk_r` (18 帧)、`walk_l` (18 帧)、`dead` (52 帧)、`attack1` (20 帧)、`effect1` (160 帧)

## 角色配置指向的技能

以下仅记录原游戏角色配置中的动作标签与技能 ID；空洞骑士中的实现均未开始。

| 角色 ID | 动作 | 技能 ID | 名称 |
|---|---|---|---|
| 2001 | effect1 | 1101010 | 升龙斩 |
| 2001 | effect2 | 1101020 | 烈焰闪 |
| 2001 | effect3 | 1101030 | 烈焰风暴 |
| 2001 | effect4 | 1101040 | 汲元火眼 |
| 2001 | effect5 | 1101050 | 火魔斩 |
| 2006 | effect1 | 1102010 | 辟地拳 |
| 2006 | effect2 | 1102020 | 灭神一击 |
| 2006 | effect3 | 1102030 | 擒魔爪 |
| 2006 | effect4 | 1102040 | 残影连打 |
| 2006 | effect5 | 1102050 | 火猿出击 |
| 2011 | effect1 | 1311010 | 烈火轰雷 |

## 可检索数据

- `data/generated/animations.json`：全部骨架与动作名。
- `data/generated/skills.json`：97 条原始技能配置字符串及角色基础技能索引。
- `data/generated/audio.json`：14 段音效及音频探测结果。
- `data/generated/inventory.json`：归档输入和解包结果的大小、SHA-256。
- `data/source/manifests/`：原素材包清单，路径仍按旧归档记录；上面的生成清单使用当前项目路径。
