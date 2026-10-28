#!/usr/bin/env python3
"""Preserve and package the archived original Flame Dash skill icon for charm31."""
import csv
import hashlib
import json
from pathlib import Path
import shutil
import xml.etree.ElementTree as ET

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "assets/zmxy4/raw/assets/icon/skill/1101020.png"
OUTPUT = ROOT / "assets/processed/charms/flame-dash"


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def prepare():
    with (ROOT / "data/source/skills.csv").open(encoding="utf-8-sig", newline="") as stream:
        skill = next(row for row in csv.DictReader(stream) if row["id"] == "1101020")
    resources = ET.parse(ROOT / "data/source/resources.xml").getroot()
    resource = next(row for row in resources if row.findtext("resourcesId") == "189")
    if skill["name"] != "烈焰闪" or skill["resourceId"] != "189" or resource.findtext("normal") != SOURCE.name:
        raise ValueError("Archived Flame Dash icon identity changed")
    source_hash = digest(SOURCE)
    with Image.open(SOURCE) as image:
        image.load()
        if image.format != "PNG" or image.size != (65, 65):
            raise ValueError("Expected archived 65px Flame Dash PNG")
        icon = image.convert("RGBA")
    OUTPUT.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(SOURCE, OUTPUT / "icon.png")
    if digest(OUTPUT / "icon.png") != source_hash or digest(SOURCE) != source_hash:
        raise ValueError("Original Flame Dash artwork bytes changed")
    preview = Image.new("RGB", (560, 260), "#171b23")
    draw = ImageDraw.Draw(preview)
    draw.text((20, 16), "FLAME DASH: AWAKENING / CHARM 31", fill="#f2e9d5")
    for left, background in ((20, "#171b23"), (300, "#eee9df")):
        draw.rectangle((left, 50, left + 240, 240), fill=background)
        preview.paste(icon.resize((128, 128), Image.Resampling.NEAREST), (left + 8, 65), icon.resize((128, 128), Image.Resampling.NEAREST))
        preview.paste(icon, (left + 160, 95), icon)
    preview.save(OUTPUT / "preview.png")
    report = {"schema_version": 1, "skill_id": 1101020, "resource_id": 189, "charm_id": 31,
              "source": SOURCE.relative_to(ROOT).as_posix(), "source_sha256": source_hash,
              "processing": "exact archived PNG copy; native charm bounds control UI size",
              "dimensions": list(icon.size),
              "files": {name: digest(OUTPUT / name) for name in ("icon.png", "preview.png")}}
    (OUTPUT / "manifest.json").write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    return report


if __name__ == "__main__":
    print(json.dumps(prepare(), ensure_ascii=False, indent=2))
