"""Produce a separate 1.5x mirror of all decoded character/skill PNG assets."""
import argparse
import json
import math
from pathlib import Path

from PIL import Image

from validate_character import ROOT, sha256


def scale_coordinates(value, scale):
    if isinstance(value, list):
        return [scale_coordinates(item, scale) for item in value]
    if isinstance(value, dict):
        return {key: (number * scale if key in ("x", "y", "pX", "pY", "frameX", "frameY", "frameWidth", "frameHeight")
                      and type(number) in (int, float) else scale_coordinates(number, scale))
                for key, number in value.items()}
    return value


def prepare_related_assets(scale=1.5):
    if not math.isfinite(scale) or scale <= 0:
        raise ValueError("Scale must be positive and finite")
    source = ROOT / "assets/zmxy4"
    output = ROOT / "assets/processed/source-variants" / ("all-" + format(scale, "g").replace(".", "p"))
    files = sorted((source / "animations").rglob("*.json")) + sorted(source.rglob("*.png"))
    original_hashes = {p.relative_to(source).as_posix(): sha256(p) for p in files}
    fingerprint = {"scale": scale, "original_sha256": original_hashes, "script_sha256": sha256(Path(__file__))}
    record = output / "resize-report.json"
    if output.exists():
        if record.is_file():
            cached = json.loads(record.read_text(encoding="utf-8"))
            if cached["inputs"] == fingerprint and all(sha256(output / k) == v for k, v in cached["modified_sha256"].items()):
                return cached
        raise ValueError("Existing related-asset variant differs; preserve it and choose another factor/folder")
    output.mkdir(parents=True)
    for path in files:
        destination = output / path.relative_to(source)
        destination.parent.mkdir(parents=True, exist_ok=True)
        if path.suffix == ".png":
            with Image.open(path) as image:
                image = image.convert("RGBA").convert("RGBa").resize((math.ceil(image.width * scale), math.ceil(image.height * scale)), Image.Resampling.BICUBIC).convert("RGBA")
                image.save(destination, compress_level=9)
        else:
            data = json.loads(path.read_text(encoding="utf-8"))
            result = scale_coordinates(data, scale)
            if "SubTexture" in result:
                for old, item in zip(data["SubTexture"], result["SubTexture"]):
                    for axis, size in (("x", "width"), ("y", "height")):
                        item[axis] = round(old[axis] * scale)
                        item[size] = round((old[axis] + old[size]) * scale) - item[axis]
            destination.write_text(json.dumps(result, ensure_ascii=False, sort_keys=True, indent=2) + "\n", encoding="utf-8")
    assert all(sha256(source / k) == v for k, v in original_hashes.items())
    result = {"inputs": fingerprint, "png_count": sum(p.suffix == ".png" for p in files),
              "json_count": sum(p.suffix == ".json" for p in files), "originals_unchanged": True,
              "modified_sha256": {p.relative_to(output).as_posix(): sha256(p) for p in output.rglob("*") if p.is_file()}}
    record.write_text(json.dumps(result, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    return result


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--scale", type=float, default=1.5)
    result = prepare_related_assets(parser.parse_args().scale)
    print(json.dumps({k: v for k, v in result.items() if k not in ("inputs", "modified_sha256")}))
