# 离线加工资源

默认棍系孙悟空的加工输出位于 `wukong/`，由固定版本 Pillow 离线生成：

```bash
python3 tools/bootstrap.py
.tools/python/bin/python tools/bake_character.py
.tools/python/bin/python tools/validate_character.py
```

`character.json` 与引用图集是运行时资源；`previews/` 中 GIF/联系表仅用于审阅。13 个动作共享画布、根坐标和缩放，保留源文件、配置与工具散列。生成结果不进入 Git，可通过原始输入重新生成。

原始素材保持在 `assets/zmxy4/`，不被转换器覆盖。处理规则与支持范围见 [动画处理说明](../../docs/CHARACTER_ASSETS.md)，游戏内显示和战斗仍待客户端验收。
