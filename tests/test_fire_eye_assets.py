"""Regress missing ef artwork against the actual original SWF and JPEXS export."""
import hashlib
import json
from pathlib import Path
import sys
import unittest
import xml.etree.ElementTree as ET

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
from fire_eye_assets import fire_eye_samples, lossless_images
from legacy_dragonbones import Sampler


class FireEyeAssetTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.reference = ROOT / "reference/flash/fire-eye"
        cls.evidence = json.loads((cls.reference / "evidence.json").read_text(encoding="utf-8"))
        active = json.loads((ROOT / "data/character/active-variant.json").read_text(encoding="utf-8"))
        cls.profile = json.loads((ROOT / active["bake_profile"]).read_text(encoding="utf-8"))
        source = ROOT / cls.profile["source_directory"]
        with Image.open(source / "texture.png") as page:
            cls.sampler = Sampler(json.loads((source / "skeleton.json").read_text(encoding="utf-8")),
                                  json.loads((source / "texture.json").read_text(encoding="utf-8")), page, cls.profile)
        cls.original = ROOT / active["source_directory"]
        cls.variant = ROOT / active["output_directory"]
        cls.swf = ROOT / cls.profile["fire_eye_effect_source"]["swf"]
        cls.frames = fire_eye_samples(cls.sampler, cls.swf, cls.reference / "ef.xml")

    def test_real_skill_buff_and_resource_chain(self):
        for name, expected in self.evidence["inputs"].items():
            self.assertEqual(hashlib.sha256((ROOT / name).read_bytes()).hexdigest(), expected)
        def record(name, identity):
            return next(r for r in ET.parse(ROOT / "data/source" / name).getroot() if r.findtext("id") == identity)
        skill = record("skills.xml", "1101040")
        self.assertEqual(skill.findtext("name"), "汲元火眼")
        self.assertIn("810001", skill.findtext("myBuff").split(","))
        self.assertEqual(record("buffs.xml", "81000101").findtext("resourcesId"), "17")
        resource = next(r for r in ET.parse(ROOT / "data/source/resources.xml").getroot()
                        if r.findtext("resourcesId") == "17")
        self.assertIn("810001/1.swf", ET.tostring(resource, encoding="unicode"))

    def test_decoder_matches_all_five_independently_exported_images(self):
        for identity, image in lossless_images(self.swf).items():
            self.assertEqual(hashlib.sha256(image.tobytes()).hexdigest(),
                             self.evidence["extracted_image_pixel_sha256"][str(identity)])
            self.assertIsNotNone(image.getbbox())
            self.assertLess(min(image.getchannel("A").getdata()), 255)

    def test_original_ten_frame_loop_and_registration_are_baked(self):
        manifest = json.loads((self.original / "character.json").read_text(encoding="utf-8"))
        clip = manifest["clips"]["fireEyeAura"]
        self.assertTrue(clip["loop"])
        self.assertEqual(clip["duration_ticks"], 10)
        self.assertEqual([f[0].texture for f in self.frames],
                         [f"fireEye/{i}" for i in (1, 1, 3, 3, 5, 5, 7, 7, 9, 9)])
        for tick, draws in enumerate(self.frames):
            self.assertAlmostEqual(draws[0].matrix.tx, -51.35)
            self.assertAlmostEqual(draws[0].matrix.ty, -150.4)
            frame = clip["frames"][tick]
            with Image.open(self.original / manifest["atlases"][frame["atlas"]]["path"]) as page:
                actual = page.crop((frame["x"], frame["y"], frame["x"] + frame["width"], frame["y"] + frame["height"]))
            expected = self.sampler.render(draws, (manifest["canvas_width"], manifest["canvas_height"]),
                                           (manifest["root_x"], manifest["root_y"]))
            self.assertEqual(actual.tobytes(), expected.tobytes())
        enlarged = json.loads((self.variant / "character.json").read_text(encoding="utf-8"))
        self.assertEqual(enlarged["asset_transform"]["scale"], 1.5)
        self.assertEqual(enlarged["clips"]["fireEyeAura"]["duration_ticks"], 10)

    def test_fire_demon_motion_matches_original_skill_and_physics(self):
        record = next(r for r in ET.parse(ROOT / "data/source/skills.xml").getroot() if r.findtext("id") == "1101050")
        self.assertEqual(record.findtext("shootFrame"), "5")
        self.assertEqual(record.findtext("shootSpeedX"), "50")
        self.assertEqual(record.findtext("shootSpeedY"), "0")
        source = ROOT / "reference/flash/fire-demon/as3"
        player = (source / "viewers/entitys/man/PlayerEntity.as").read_text(encoding="utf-8")
        wk = (source / "viewers/entitys/man/WKEntity.as").read_text(encoding="utf-8")
        physics = (self.reference / "as3/utils/Physics.as").read_text(encoding="utf-8")
        self.assertIn("_loc1_.x = skillConfigVo.shootSpeedX * _direction", player)
        final = wk[wk.index("private function addEff5_2"):wk.index("override protected function onShootByVel")]
        self.assertIn("this._body.velocity.x = 0", final)
        self.assertIn('addSKillEntity("effect51",_loc1_,this.position', final)
        self.assertIn("param4:Number = 0.1", physics)
        self.assertIn("_space.step(deltaTime)", physics)


if __name__ == "__main__":
    unittest.main()
