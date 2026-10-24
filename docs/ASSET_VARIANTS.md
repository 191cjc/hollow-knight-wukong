# Offline Character Size Variants

Original archived artwork stays in `assets/zmxy4/`. The earlier 13-clip unscaled
bake stays in `assets/processed/wukong/`. Never resize either folder in place.

Run `scripts\prepare-all-assets.bat` on Windows to prepare the complete set:

| Location | Contents |
| --- | --- |
| `assets/processed/source-variants/all-1p5/` | Separate 1.5x copies of all 19 decoded PNGs and 16 matching skeletal/atlas JSON files, including staff, fist, additional forms and icons |
| `assets/processed/wukong-complete-original/` | Unscaled bake of all 21 main staff clips plus the source-backed Flame Dash clip |
| `assets/processed/variants/wukong-complete-1p5/` | Active 1.5x runtime artwork: 22 clips, 611 tick records, 13 atlas pages |

`tools/resize_related_assets.py` scales image pixels, skeleton/pivot coordinates,
and atlas rectangles in the mirror. Timings, angles and dimensionless bone scales
are preserved. Its `resize-report.json` records both original and modified hashes.
Raw containers and audio are preserved as originals; there is no meaningful 1.5x
image resize for these formats. The runtime package is baked from the unscaled
sources and enlarged once, so the mirror does not cause a second enlargement.

`data/character/active-variant.json` selects the original input, the separate output
folder and the offline pixel factor used for packaging. The current selection is
`assets/processed/variants/wukong-complete-1p5/`, at 1.5 times the original artwork size.
This replaces the previous 1.25 runtime appearance multiplier; it is not 1.5 times
the already enlarged 0.2.1 appearance.

Run on Windows:

```bat
scripts\resize-character.bat
scripts\resize-character.bat --scale 2
scripts\resize-character.bat --scale 1.75 --output assets/processed/variants/wukong-complete-1p75
```

The batch entry locates the pinned local Python environment. Alternatively, set
`WUKONG_PYTHON` to Python with Pillow 11.3.0 installed. The cross-platform command is:

```sh
python tools/prepare_all_assets.py
python tools/resize_related_assets.py --scale 2
```

Every character resize processes all clips from the selected original bake.
Each unique frame is resampled independently using bicubic filtering and
premultiplied alpha. Pages are repacked within 2048x2048 pixels, so neighboring
frames cannot bleed into each other. Frame rectangles, common canvas, pivots,
feet offset and atlas hashes are updated. Animation clocks and combat settings
remain identical to the original.

The source body-height reference remains unchanged: it is the baseline
pixel-to-world calibration. Updating that reference to the enlarged body height
would automatically fit the artwork back down and cancel the enlargement.
Runtime retains the original coordinate/facing adaptation but applies no
additional appearance scale multiplier. The 1.5 enlargement is in the PNG pixels.
Native hero colliders, native slash artwork and attack reach are unchanged.

An identical repeat run reuses validated output. A different job cannot overwrite
an existing variant: choose another folder. An already resized variant is rejected
as input to prevent accidental cumulative scaling. To package a different variant,
update `active-variant.json` and rebuild; generating it alone does not activate it.
For complete character variants, give an explicit new output folder: older
`wukong-1p5` variants are deliberately preserved and cannot be overwritten by a
different input bake. `prepare-all-assets.bat` prepares the current configured
runtime variant and the complete 1.5x source mirror.

The project build prepares the active variant before packaging. Only that variant's
manifest and referenced PNGs are installed alongside the Mod DLL. Originals and
previous variants remain in the project. A deployment backs up the installed Mod
before replacing it; no API, game assembly or save files are modified.

For 0.4.0-dev, the selected profile is `wukong-staff-fire-demon.json`, with 27
runtime clips. Its preserved original bake is `wukong-fire-demon-v04-original`;
the 1.5x copy is `variants/wukong-fire-demon-v04-1p5`. Earlier complete and draft
Fire Demon bakes remain separate. The five new clips keep body, world air effect
and finisher separate. `prepare-all-assets.bat` follows the active configuration.
