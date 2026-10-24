"""Verify all related artwork and the real source flame overlay are present."""
import json
from pathlib import Path
import sys
import unittest

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
from prepare_all_assets import main as prepare_all
from validate_character import REQUIRED_CLIPS, sha256, validate_character


class FlameDashAssetTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        prepare_all()

    def test_all_decoded_pngs_and_skeletons_have_separate_variants(self):
        source = ROOT / "assets/zmxy4"
        output = ROOT / "assets/processed/source-variants/all-1p5"
        report = json.loads((output / "resize-report.json").read_text(encoding="utf-8"))
        pngs = list(source.rglob("*.png"))
        self.assertEqual(report["png_count"], len(pngs))
        self.assertEqual(report["json_count"], len(list((source / "animations").rglob("*.json"))))
        for relative, original_hash in report["inputs"]["original_sha256"].items():
            self.assertEqual(sha256(source / relative), original_hash)
        for p in pngs:
            with Image.open(p) as original, Image.open(output / p.relative_to(source)) as modified:
                self.assertAlmostEqual(modified.width, original.width * 1.5, delta=1)
                self.assertAlmostEqual(modified.height, original.height * 1.5, delta=1)

    def test_complete_character_contains_source_skills_and_a_visible_flame_cycle(self):
        profile = json.loads((ROOT / "data/character/active-variant.json").read_text(encoding="utf-8"))
        variant = ROOT / profile["output_directory"]
        data = validate_character(variant).manifest
        self.assertEqual(len(data["clips"]), 27)
        self.assertTrue(set(REQUIRED_CLIPS) <= set(data["clips"]))
        self.assertTrue(all("effect" + str(i) in data["clips"] for i in range(1, 6)))
        hashes = set()
        for frame in data["clips"]["flameDash"]["frames"]:
            with Image.open(variant / data["atlases"][frame["atlas"]]["path"]) as page:
                cell = page.crop((frame["x"], frame["y"], frame["x"] + frame["width"], frame["y"] + frame["height"]))
                self.assertIsNotNone(cell.getbbox())
                hashes.add(cell.tobytes())
        self.assertEqual(len(hashes), 6)
        self.assertEqual(data["asset_transform"]["scale"], 1.5)


if __name__ == "__main__":
    unittest.main()
