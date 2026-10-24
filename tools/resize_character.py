"""Resize every baked animation frame offline, preserving the original assets."""
import argparse
import copy
import json
import math
from pathlib import Path
import tempfile

from PIL import Image

from validate_character import CHARACTER, ROOT, sha256, validate_character

PROFILE = ROOT / "data/character/active-variant.json"


def resize_character(source, output, scale):
    source, output = Path(source).resolve(), Path(output).resolve()
    if (source == output or source.is_relative_to(output) or output.is_relative_to(source)
            or output == CHARACTER.resolve() or output.is_relative_to((ROOT / "assets/zmxy4").resolve())):
        raise ValueError("Output must be a separate variant folder; original assets are read-only")
    if type(scale) not in (int, float) or not math.isfinite(scale) or scale <= 0:
        raise ValueError("Scale must be positive and finite")
    original = validate_character(source)
    manifest = copy.deepcopy(original.manifest)
    if "asset_transform" in manifest:
        raise ValueError("Start from original baked assets, not an already resized variant")
    width = math.ceil(manifest["canvas_width"] * scale)
    height = math.ceil(manifest["canvas_height"] * scale)
    if max(width, height) > 2048:
        raise ValueError("Resized frame exceeds the 2048 pixel atlas limit")
    transform = {"type": "offline_pixel_resize", "scale": scale, "resampling": "bicubic",
                 "source_manifest_sha256": sha256(source / "character.json"),
                 "script_sha256": sha256(Path(__file__)), "reference_body_height": manifest["nominal_body_height"]}
    if output.exists():
        cached = validate_character(output)
        if cached.manifest.get("asset_transform") == transform:
            return cached.manifest
        raise ValueError("Output already exists with different data; choose a new variant folder")
    pages = []
    try:
        for page in manifest["atlases"]:
            with Image.open(source / page["path"]) as image:
                pages.append(image.copy())
        columns, rows = 2048 // width, 2048 // height
        capacity = columns * rows
        cells, indices = [], {}
        for clip in manifest["clips"].values():
            for frame in clip["frames"]:
                key = tuple(frame[k] for k in ("atlas", "x", "y", "width", "height"))
                if key not in indices:
                    atlas, x, y, w, h = key
                    cell = pages[atlas].crop((x, y, x + w, y + h))
                    # Premultiplied alpha avoids dark fringes at transparent edges.
                    cell = cell.convert("RGBa").transform(
                        (width, height), Image.Transform.AFFINE,
                        (1 / scale, 0, 0, 0, 1 / scale, 0), Image.Resampling.BICUBIC,
                    ).convert("RGBA")
                    indices[key] = len(cells)
                    cells.append(cell)
                index = indices[key]
                local = index % capacity
                frame.update(atlas=index // capacity, x=local % columns * width,
                             y=local // columns * height, width=width, height=height)
        # Keep the baseline body-height calibration, so runtime fitting does not
        # cancel the enlarged pixels. There is no runtime appearance multiplier.
        manifest.update(canvas_width=width, canvas_height=height,
                        root_x=manifest["root_x"] * scale, root_y=manifest["root_y"] * scale,
                        feet_offset_pixels=manifest.get("feet_offset_pixels", 6) * scale,
                        asset_transform=transform, atlases=[])
        output.parent.mkdir(parents=True, exist_ok=True)
        with tempfile.TemporaryDirectory(prefix=".wukong-resize-", dir=output.parent) as scratch:
            pending = Path(scratch) / "variant"
            pending.mkdir()
            for start in range(0, len(cells), capacity):
                count = min(capacity, len(cells) - start)
                page = Image.new("RGBA", (min(count, columns) * width, math.ceil(count / columns) * height))
                for local, cell in enumerate(cells[start:start + count]):
                    page.paste(cell, (local % columns * width, local // columns * height))
                name = f"atlas-{len(manifest['atlases']):03d}.png"
                page.save(pending / name, compress_level=9)
                manifest["atlases"].append({"path": name, "width": page.width, "height": page.height,
                                           "sha256": sha256(pending / name)})
            (pending / "character.json").write_text(json.dumps(manifest, ensure_ascii=False, sort_keys=True, indent=2) + "\n", encoding="utf-8")
            validate_character(pending)
            pending.rename(output)
        return manifest
    finally:
        for page in pages:
            page.close()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", type=Path)
    parser.add_argument("--output", type=Path)
    parser.add_argument("--scale", type=float)
    args = parser.parse_args()
    profile = json.loads(PROFILE.read_text(encoding="utf-8"))
    source = args.source or ROOT / profile["source_directory"]
    scale = args.scale if args.scale is not None else profile["scale"]
    output = args.output
    if output is None:
        output = (ROOT / profile["output_directory"] if args.scale is None else
                  ROOT / "assets/processed/variants" / ("wukong-" + format(scale, "g").replace(".", "p")))
    result = resize_character(source, output, scale)
    print(json.dumps({"output": str(output.resolve()), "scale": scale,
                      "canvas": [result["canvas_width"], result["canvas_height"]],
                      "atlases": len(result["atlases"]), "originals_unchanged": True}))


if __name__ == "__main__":
    main()
