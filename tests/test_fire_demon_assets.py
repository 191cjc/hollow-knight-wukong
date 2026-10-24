"""Check real Fire Demon source sampling and separation of world effects/body."""
import json
from pathlib import Path
import sys
import unittest

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
from fire_demon_assets import fire_demon_samples
from legacy_dragonbones import Sampler


class FireDemonAssetTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        profile = json.loads((ROOT / "data/character/wukong-staff-fire-demon.json").read_text(encoding="utf-8"))
        source = ROOT / profile["source_directory"]
        with Image.open(source / "texture.png") as page:
            cls.sampler = Sampler(json.loads((source / "skeleton.json").read_text(encoding="utf-8")),
                                  json.loads((source / "texture.json").read_text(encoding="utf-8")), page, profile)
        cls.samples = fire_demon_samples(cls.sampler, ROOT / profile["fire_demon_effect_source"])

    def test_legacy_body_compatibility_clip_keeps_its_original_bake(self):
        air = self.samples["fireDemonAir"]
        self.assertEqual(len(air), 38)
        for draws in air:
            self.assertTrue(any(d.slot_path[0] == "yf8" for d in draws), "Missing torso during the held native antic")
            self.assertFalse(any(d.texture.startswith("fireDemon/") for d in draws), "World effect was attached to body artwork")
        # At source tick 20 the body teleports >100px right/up. Internal body
        # rotations still move individual image origins, so test the gross travel.
        raw = self.sampler.bounds([d for d in self.sampler.sample("effect5", 20) if d.slot_path[0] == "yf8"])
        baked = self.sampler.bounds([d for d in air[20] if d.slot_path[0] == "yf8"])
        self.assertGreater(raw[0] - baked[0], 100)
        self.assertLess(raw[1] - baked[1], -100)
        self.assertLess(abs((baked[0] + baked[2]) / 2), 50, "Source teleport remained in the body pose")

    def test_independent_effect_lifetimes_and_finisher_body(self):
        for name, ticks in (("fireDemonAirEffect", 31), ("fireDemonImpact", 20)):
            frames = self.samples[name]
            self.assertEqual(len(frames), ticks)
            self.assertTrue(any(frames))
            self.assertTrue(all(d.texture.startswith("fireDemon/") for draws in frames for d in draws))
            self.assertGreater(len({tuple(draws) for draws in frames}), 1, "Source effect was frozen")
        self.assertEqual(len(self.samples["fireDemonDive"]), 1)
        self.assertEqual(len(self.samples["fireDemonLand"]), 21)
        self.assertTrue(all(self.samples["fireDemonLand"]))

    def test_original_effect5_keeps_moving_character_and_real_blink_gaps(self):
        # The playable source presentation uses this untouched clip, not the
        # old travel-normalized fireDemonAir compatibility clip above.
        first = self.sampler.sample("effect5", 8)
        second = self.sampler.sample("effect5", 20)
        a = self.sampler.bounds([d for d in first if d.slot_path[0] == "yf8"])
        b = self.sampler.bounds([d for d in second if d.slot_path[0] == "yf8"])
        self.assertGreater(a[0], 90)
        self.assertLess(b[1], -200)
        self.assertGreater(abs(b[1] - a[1]), 70, "Original character flash travel was normalized away")
        for tick in (12, 24, 28, 35, 36):
            self.assertFalse(self.sampler.sample("effect5", tick), "A genuine blink gap was filled with a held body pose")

    def test_packaged_source_body_frames_match_original_sampling(self):
        active = json.loads((ROOT / "data/character/active-variant.json").read_text(encoding="utf-8"))
        original = ROOT / active["source_directory"]
        manifest = json.loads((original / "character.json").read_text(encoding="utf-8"))
        self.assertEqual(manifest["clips"]["effect5"]["duration_ticks"], 60)
        size = (manifest["canvas_width"], manifest["canvas_height"])
        root = (manifest["root_x"], manifest["root_y"])
        for tick in (8, 12, 20, 32):
            item = manifest["clips"]["effect5"]["frames"][tick]
            with Image.open(original / manifest["atlases"][item["atlas"]]["path"]) as page:
                actual = page.convert("RGBA").crop((item["x"], item["y"], item["x"] + item["width"], item["y"] + item["height"]))
            expected = self.sampler.render(self.sampler.sample("effect5", tick), size, root)
            self.assertEqual(actual.tobytes(), expected.tobytes(), "Baked moving character differs from original source frame")


if __name__ == "__main__":
    unittest.main()
