"""Compare new spell frames to archived body/flame sources and original SWF mask."""
import hashlib
import json
from pathlib import Path
import sys
import unittest
import xml.etree.ElementTree as ET

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
from bake_character import flame_storm_samples
from legacy_dragonbones import Sampler


class SpellArtworkTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.profile = json.loads((ROOT / "data/character/wukong-staff-spells-v05.json").read_text(encoding="utf-8"))
        source = ROOT / cls.profile["source_directory"]
        with Image.open(source / "texture.png") as page:
            cls.sampler = Sampler(json.loads((source / "skeleton.json").read_text(encoding="utf-8")),
                                  json.loads((source / "texture.json").read_text(encoding="utf-8")), page, cls.profile)
        cls.storm = flame_storm_samples(cls.sampler, ROOT / cls.profile["flame_storm_effect_source"])
        active = json.loads((ROOT / "data/character/active-variant.json").read_text(encoding="utf-8"))
        cls.directory = ROOT / active["source_directory"]
        cls.manifest = json.loads((cls.directory / "character.json").read_text(encoding="utf-8"))

    def assert_baked(self, name, tick, draws):
        manifest = self.manifest
        frame = manifest["clips"][name]["frames"][tick]
        with Image.open(self.directory / manifest["atlases"][frame["atlas"]]["path"]) as page:
            actual = page.convert("RGBA").crop((frame["x"], frame["y"], frame["x"] + frame["width"], frame["y"] + frame["height"]))
        expected = self.sampler.render(draws, (manifest["canvas_width"], manifest["canvas_height"]),
                                       (manifest["root_x"], manifest["root_y"]))
        self.assertEqual(actual.tobytes(), expected.tobytes())

    def test_storm_has_all_eight_flames_and_original_spinning_body(self):
        self.assertEqual(len(self.storm), 16)
        self.assertEqual(len({d[0].texture for d in self.storm}), 8)
        for tick, draws in enumerate(self.storm):
            self.assertEqual(draws[0].slot_path, ("flame_storm_fx",))
            self.assertEqual(draws[1:], self.sampler.sample("effect3", tick))
            self.assert_baked("flameStorm", tick, draws)
        self.assertEqual(self.manifest["clips"]["flameStorm"]["duration_ticks"], 16)

    def test_eye_keeps_original_seventeen_tick_action(self):
        self.assertEqual(self.manifest["clips"]["effect4"]["duration_ticks"], 17)
        for tick in range(17):
            self.assert_baked("effect4", tick, self.sampler.sample("effect4", tick))

    def test_source_mask_is_local_rectangle_with_original_transform(self):
        directory = ROOT / "reference/flash/flame-storm"
        evidence = json.loads((directory / "evidence.json").read_text())
        for name, expected in evidence["inputs"].items():
            self.assertEqual(hashlib.sha256((ROOT / name).read_bytes()).hexdigest(), expected)
        xml = ET.parse(directory / "ab_effect3.xml").getroot()
        symbols = xml.find(".//item[@type='SymbolClassTag']")
        names = [n.text for n in symbols.find("names")]
        self.assertEqual(symbols.find("tags")[names.index("ab_effect3")].text, "39")
        shape = xml.find(".//item[@shapeId='32']/shapeBounds")
        matrix = xml.find(".//item[@spriteId='39']//matrix")
        x0, x1, y0, y1 = [float(shape.get(k)) / 20 for k in ("Xmin", "Xmax", "Ymin", "Ymax")]
        sx, sy = float(matrix.get("scaleX")), float(matrix.get("scaleY"))
        actual = dict(x=(x0+x1)/2*sx+float(matrix.get("translateX"))/20,
                      y=-((y0+y1)/2*sy+float(matrix.get("translateY"))/20),
                      width=(x1-x0)*sx, height=(y1-y0)*sy)
        for key, value in actual.items():
            self.assertAlmostEqual(value, evidence["unity_region_right"][key], places=6)
        self.assertLess(actual["width"], 500, "Skill range999 was mistaken for a room-wide hurtbox")


if __name__ == "__main__":
    unittest.main()
