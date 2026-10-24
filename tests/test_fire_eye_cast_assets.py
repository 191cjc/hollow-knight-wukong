"""Regress the previously omitted casting overlay using the actual source assets."""
import hashlib
import json
from pathlib import Path
import sys
import unittest

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
from fire_eye_cast_assets import fire_eye_cast_samples
from legacy_dragonbones import Sampler


class FireEyeCastAssetTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        active = json.loads((ROOT / "data/character/active-variant.json").read_text(encoding="utf-8"))
        profile = json.loads((ROOT / active["bake_profile"]).read_text(encoding="utf-8"))
        source = ROOT / profile["source_directory"]
        with Image.open(source / "texture.png") as page:
            cls.sampler = Sampler(json.loads((source / "skeleton.json").read_text(encoding="utf-8")),
                                  json.loads((source / "texture.json").read_text(encoding="utf-8")), page, profile)
        cls.frames = fire_eye_cast_samples(cls.sampler, ROOT / profile["fire_eye_cast_source"])
        cls.original = ROOT / active["source_directory"]
        cls.variant = ROOT / active["output_directory"]
        cls.manifest = json.loads((cls.original / "character.json").read_text(encoding="utf-8"))

    @staticmethod
    def cell(directory, manifest, clip, tick):
        f = manifest["clips"][clip]["frames"][tick]
        with Image.open(directory / manifest["atlases"][f["atlas"]]["path"]) as page:
            return page.crop((f["x"], f["y"], f["x"]+f["width"], f["y"]+f["height"]))

    def test_original_attachment_above_body_has_no_extra_offset(self):
        evidence = json.loads((ROOT / "reference/flash/fire-eye/casting/evidence.json").read_text(encoding="utf-8"))
        for relative, digest in evidence["inputs"].items():
            self.assertEqual(hashlib.sha256((ROOT / relative).read_bytes()).hexdigest(), digest)
        source = (ROOT / "reference/flash/fire-eye/casting/Entity.as").read_text(encoding="utf-8")
        attachment = source[source.index("protected function onUpdateAnimationAfter2"):source.index("protected function getSkillAramtureName")]
        self.assertIn('_nowAnimation.addChild(_loc2_.display as DisplayObject)', attachment)
        self.assertIn('_loc2_.animation.timeScale = param1 / 30', attachment)
        self.assertIn('param1.x = 0', attachment)
        self.assertIn('param1.y = 0', attachment)

    def test_all_seven_winding_flames_are_in_front_of_original_body(self):
        self.assertEqual(len(self.frames), 21)
        self.assertFalse(self.manifest["clips"]["fireEyeCast"]["loop"])
        for tick in range(14):
            body = self.sampler.sample("effect4", tick)
            self.assertEqual(self.frames[tick][:-1], body)
            flame = self.frames[tick][-1]
            self.assertEqual(flame.texture, f"fireEyeCast/__dbTextures/effect4/图层 11_{tick//2*2}")
            self.assertEqual(flame.slot_path, ("图层 11",))
        self.assertAlmostEqual(self.frames[0][-1].matrix.tx, -38.05)
        self.assertAlmostEqual(self.frames[0][-1].matrix.ty, -32.3)

    def test_revealed_children_restart_at_tick_fourteen_and_keep_registration(self):
        for tick in range(14, 21):
            body = self.sampler.sample("effect4", min(tick, 16))
            self.assertEqual(self.frames[tick][:len(body)], body)
            overlays = self.frames[tick][len(body):]
            self.assertEqual(len(overlays), 3 if tick < 20 else 1)
            self.assertEqual(overlays[0].texture, f"fireEyeCast/png/buff_{8+(tick-14)//2:05d}.png")
            self.assertAlmostEqual(overlays[0].matrix.tx, -49.35)
            self.assertAlmostEqual(overlays[0].matrix.ty, -150.35)
            if tick < 20:
                for overlay in overlays[1:]:
                    self.assertEqual(overlay.texture, f"fireEyeCast/__dbTextures/悟空-新/元件 1/图层 2_{(tick-14)//2*2}")
        self.assertAlmostEqual(self.frames[14][-2].matrix.tx, 18.2955)
        self.assertAlmostEqual(self.frames[14][-2].matrix.ty, -73.311)
        self.assertAlmostEqual(self.frames[14][-1].matrix.tx, -6.12)
        self.assertAlmostEqual(self.frames[14][-1].matrix.ty, -78.608)

    def test_all_cast_frames_match_original_art_and_offline_one_point_five_scale(self):
        enlarged = json.loads((self.variant / "character.json").read_text(encoding="utf-8"))
        self.assertEqual(enlarged["asset_transform"]["scale"], 1.5)
        for tick, draws in enumerate(self.frames):
            actual = self.cell(self.original, self.manifest, "fireEyeCast", tick)
            expected = self.sampler.render(draws, (self.manifest["canvas_width"], self.manifest["canvas_height"]),
                                           (self.manifest["root_x"], self.manifest["root_y"]))
            self.assertEqual(actual.tobytes(), expected.tobytes())
            self.assertIsNotNone(actual.getbbox())
            scaled = actual.convert("RGBa").transform(
                (enlarged["canvas_width"], enlarged["canvas_height"]), Image.Transform.AFFINE,
                (1/1.5, 0, 0, 0, 1/1.5, 0), Image.Resampling.BICUBIC).convert("RGBA")
            self.assertEqual(self.cell(self.variant, enlarged, "fireEyeCast", tick).tobytes(), scaled.tobytes())


if __name__ == "__main__":
    unittest.main()
