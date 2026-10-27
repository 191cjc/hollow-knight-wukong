"""Upward flames preserve the upright source body and all previously shipped pixels."""
from functools import lru_cache
import json
from pathlib import Path
import sys
import unittest

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
from bake_character import flame_dash_samples, flame_dash_up_samples
from legacy_dragonbones import Sampler
from validate_character import validate_character


@lru_cache(maxsize=8)
def page(path):
    with Image.open(path) as image:
        return image.convert("RGBA")


def cell(directory, manifest, frame):
    image = page(directory / manifest["atlases"][frame["atlas"]]["path"])
    cropped = image.crop((frame["x"], frame["y"], frame["x"] + frame["width"], frame["y"] + frame["height"]))
    if "atlas_packing" in manifest:
        image = Image.new("RGBA", (manifest["canvas_width"], manifest["canvas_height"]))
        image.paste(cropped, (frame["source_x"], frame["source_y"]))
        return image
    return cropped


class UpDashAssetTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.active = json.loads((ROOT / "data/character/active-variant.json").read_text())
        profile = json.loads((ROOT / cls.active["bake_profile"]).read_text())
        source = ROOT / profile["source_directory"]
        with Image.open(source / "texture.png") as texture:
            cls.sampler = Sampler(json.loads((source / "skeleton.json").read_text()),
                                  json.loads((source / "texture.json").read_text()), texture, profile)
        cls.horizontal = flame_dash_samples(cls.sampler, ROOT / profile["flame_dash_effect_source"])
        cls.up = flame_dash_up_samples(cls.sampler, ROOT / profile["flame_dash_effect_source"],
                                       profile["flame_dash_up_center_pixels"])
        cls.original = ROOT / cls.active["source_directory"]
        cls.full = ROOT / cls.active["output_directory"]
        cls.packed = ROOT / cls.active["runtime_directory"]

    @classmethod
    def tearDownClass(cls):
        page.cache_clear()

    def test_up_turns_flames_opposite_to_down_with_upright_body(self):
        self.assertEqual(len(self.up), 12)
        for old, new in zip(self.horizontal, self.up):
            self.assertEqual(len(old), len(new))
            for a, b in zip(old, new):
                if a.slot_path != ("flame_dash_fx",):
                    self.assertEqual(a, b)
                    continue
                self.assertEqual((a.texture, a.color), (b.texture, b.color))
                for point in ((0, 0), (10, 20), (-35, 90)):
                    x, y = a.matrix.point(*point)
                    ux, uy = b.matrix.point(*point)
                    self.assertAlmostEqual(ux, y + 44.5)
                    self.assertAlmostEqual(uy, -x - 44.5)

    def test_up_source_and_offline_enlarged_pixels(self):
        original = validate_character(self.original).manifest
        full = validate_character(self.full).manifest
        packed = validate_character(self.packed).manifest
        self.assertEqual((original["clips"]["flameDashUp"]["duration_ticks"],
                          original["clips"]["flameDashUp"]["loop"]), (12, original["clips"]["flameDash"]["loop"]))
        for tick, draws in enumerate(self.up):
            expected = self.sampler.render(draws, (original["canvas_width"], original["canvas_height"]),
                                           (original["root_x"], original["root_y"]))
            self.assertEqual(cell(self.original, original, original["clips"]["flameDashUp"]["frames"][tick]).tobytes(), expected.tobytes())
            enlarged = expected.convert("RGBa").transform(
                (full["canvas_width"], full["canvas_height"]), Image.Transform.AFFINE,
                (1 / 1.5, 0, 0, 0, 1 / 1.5, 0), Image.Resampling.BICUBIC).convert("RGBA")
            self.assertEqual(cell(self.full, full, full["clips"]["flameDashUp"]["frames"][tick]).tobytes(), enlarged.tobytes())
            self.assertEqual(cell(self.packed, packed, packed["clips"]["flameDashUp"]["frames"][tick]).tobytes(), enlarged.tobytes())

    def test_all_1559_old_ticks_preserve_pixels_at_both_sizes(self):
        for old_dir, new_dir in ((ROOT / "assets/processed/wukong-fist-v074-original", self.original),
                                 (ROOT / "assets/processed/variants/wukong-fist-v074-1p5", self.full)):
            old = validate_character(old_dir).manifest
            new = validate_character(new_dir).manifest
            self.assertEqual(sum(c["duration_ticks"] for c in old["clips"].values()), 1559)
            for key in ("canvas_width", "canvas_height", "root_x", "root_y", "nominal_body_height", "combat"):
                self.assertEqual(new[key], old[key], key)
            self.assertEqual(new.get("feet_offset_pixels", 6), old.get("feet_offset_pixels", 6))
            seen = set()
            for name, clip in old["clips"].items():
                self.assertEqual((new["clips"][name]["duration_ticks"], new["clips"][name]["loop"]),
                                 (clip["duration_ticks"], clip["loop"]))
                for tick, frame in enumerate(clip["frames"]):
                    other = new["clips"][name]["frames"][tick]
                    pair = tuple(frame[k] for k in ("atlas", "x", "y", "width", "height")) + tuple(other[k] for k in ("atlas", "x", "y", "width", "height"))
                    if pair in seen:
                        continue
                    seen.add(pair)
                    self.assertEqual(cell(old_dir, old, frame).tobytes(), cell(new_dir, new, other).tobytes(), (name, tick))
            page.cache_clear()


if __name__ == "__main__":
    unittest.main()
