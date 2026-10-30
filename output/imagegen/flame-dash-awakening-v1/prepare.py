"""Rebuild transparent Flame Dash charm variants without changing the original."""
import json
from pathlib import Path
import sys

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[3]
DIRECTORY = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT / "tools"))
from prepare_charm_icon import digest, extract_icon, preview


def main():
    source = DIRECTORY / "original.png"
    source_hash = digest(source)
    icon, crop, extraction = extract_icon(source, size=256, padding=16)
    icon.save(DIRECTORY / "icon.png")
    large, _, _ = extract_icon(source, size=1024, padding=64)
    large.save(DIRECTORY / "icon-1024.png")
    for edge in (48, 64):
        icon.resize((edge, edge), Image.Resampling.LANCZOS).save(DIRECTORY / f"icon-{edge}.png")

    sheet = preview(icon)
    draw = ImageDraw.Draw(sheet)
    draw.rectangle((0, 0, sheet.width, 117), fill="#171b23")
    font_path = "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"
    draw.text((40, 28), "FLAME DASH: AWAKENING", fill="#f2e9d5", font=ImageFont.truetype(font_path, 28))
    draw.text((40, 70), "Ivory shell / ember core / dark and light preview", fill="#c7b9a4", font=ImageFont.truetype(font_path, 18))
    sheet.save(DIRECTORY / "preview.png")

    preserved = json.loads((DIRECTORY / "preserved-inputs.json").read_text())
    assert all(digest(ROOT / name) == expected for name, expected in preserved.items())
    assert digest(source) == source_hash
    assert icon.mode == "RGBA" and icon.getchannel("A").getextrema() == (0, 255)
    for box in ((0, 0, 256, 1), (0, 255, 256, 256), (0, 0, 1, 256), (255, 0, 256, 256)):
        assert icon.crop(box).getchannel("A").getbbox() is None

    names = ("original.png", "prompt.txt", "prepare.py", "icon.png", "icon-1024.png", "icon-48.png", "icon-64.png", "preview.png")
    manifest = {
        "schema_version": 1,
        "title": "Flame Dash: Awakening / 烈焰闪·觉醒",
        "generation": {"mode": "user-authorized bundled CLI", "model": "gpt-image-2.5-flare", "operation": "image edit with style reference", "size": [1024, 1024], "quality": "high"},
        "style_reference": "assets/processed/charms/fire-eye-sigil/icon.png",
        "processing": {"extraction": extraction, "crop": crop, "canvas": [256, 256], "padding": 16, "resample": "LANCZOS"},
        "existing_inputs_unchanged": True,
        "runtime_integration": "preview asset only",
        "files": {name: digest(DIRECTORY / name) for name in names},
    }
    (DIRECTORY / "manifest.json").write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n")
    print(json.dumps({"extraction": extraction, "alpha": icon.getchannel("A").getextrema(), "crop": crop, "preserved_inputs": len(preserved), "files": list(names)}))


if __name__ == "__main__":
    main()
