"""Verify original staff arcs, hidden ticks, downward rotation and exported pixels."""
import hashlib
import json
from pathlib import Path
import sys
import unittest

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
from legacy_dragonbones import Sampler
from nail_assets import nail_samples, nail_arc_samples
from single_bone_effects import SingleBoneEffects


class NailAssetTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        active = json.loads((ROOT / "data/character/active-variant.json").read_text(encoding="utf-8"))
        profile = json.loads((ROOT / active["bake_profile"]).read_text(encoding="utf-8"))
        source = ROOT / profile["source_directory"]
        with Image.open(source / "texture.png") as page:
            cls.sampler = Sampler(json.loads((source / "skeleton.json").read_text(encoding="utf-8")),
                                  json.loads((source / "texture.json").read_text(encoding="utf-8")), page, profile)
        cls.effects = SingleBoneEffects(cls.sampler, ROOT / profile["nail_effect_source"], "nail/")
        cls.clips = nail_samples(cls.sampler, ROOT / profile["nail_effect_source"], profile["nail_rotation_center_pixels"])
        cls.arcs = nail_arc_samples(cls.sampler, ROOT / profile["nail_effect_source"], profile["nail_rotation_center_pixels"])
        cls.center = profile["nail_rotation_center_pixels"]
        cls.original = ROOT / active["source_directory"]
        cls.variant = ROOT / active["output_directory"]
        cls.manifest = json.loads((cls.original / "character.json").read_text(encoding="utf-8"))
        cls.scaled = json.loads((cls.variant / "character.json").read_text(encoding="utf-8"))
        cls.pages = {}

    @classmethod
    def tearDownClass(cls):
        for page in cls.pages.values():
            page.close()

    def cell(self, directory, manifest, name, tick):
        frame = manifest["clips"][name]["frames"][tick]
        path = directory / manifest["atlases"][frame["atlas"]]["path"]
        if path not in self.pages:
            self.pages[path] = Image.open(path).convert("RGBA")
        return self.pages[path].crop((frame["x"], frame["y"], frame["x"]+frame["width"], frame["y"]+frame["height"]))

    def test_original_display_schedule_and_hidden_frames(self):
        # Independently transcribed source image indices; -1 must never select
        # Python's last display accidentally during anticipation/recovery.
        schedules = {
            "attack1": [-1]*4 + [0]*2 + [1]*2 + [2]*2 + [-1]*2,
            "attack2": [-1]*5 + [0]*2 + [1]*2 + [2]*2 + [3]*2 + [-1]*2,
            "attack3": [-1]*3 + [0]*2 + [1]*2 + [2]*2 + [3]*2 + [4]*2 + [-1]*5,
            "attack4": [-1]*5 + [0]*2 + [1]*2 + [2]*2 + [-1]*9,
            "jumpAttack": [-1]*4 + [0]*2 + [1]*2 + [2]*2,
            "effect1": [-1]*2 + [0]*2 + [1]*2 + [2]*2 + [3]*2 + [4]*2 + [5]*2 + [-1],
        }
        for name, schedule in schedules.items():
            frames = self.effects.frames(name, "nail_fx")
            displays = self.effects.armatures[name]["skin"][0]["slot"][0]["display"]
            self.assertEqual(len(frames), len(schedule))
            for tick, index in enumerate(schedule):
                with self.subTest(name=name, tick=tick):
                    if index < 0:
                        self.assertEqual(frames[tick], [])
                    else:
                        self.assertEqual(len(frames[tick]), 1)
                        self.assertEqual(frames[tick][0].texture, "nail/" + displays[index]["name"])

    def test_source_body_under_arc_and_no_new_combat_windows(self):
        evidence = json.loads((ROOT / ".trellis/tasks/10-23-wukong-character-basic-attacks/research/nail-source-v06-evidence.json").read_text(encoding="utf-8"))
        for relative, digest in evidence["inputs"].items():
            self.assertEqual(hashlib.sha256((ROOT / relative).read_bytes()).hexdigest(), digest)
        mapping = {"nailAttack1": "attack1", "nailAttack2": "attack2", "nailAttack3": "attack3",
                   "nailAttack4": "attack4", "nailAir": "jumpAttack", "nailUp": "effect1"}
        for name, source in mapping.items():
            overlay = self.effects.frames(source, "nail_fx")
            for tick, draws in enumerate(self.clips[name]):
                self.assertEqual(draws, self.sampler.sample(source, tick) + overlay[tick])
            self.assertFalse(self.manifest["clips"][name]["loop"])
        self.assertEqual([s["clip"] for s in self.manifest["combat"]["stages"]],
                         ["attack1", "attack2", "attack3", "attack4"])

    def test_down_arc_rotates_about_fixed_character_center_body_stays_upright(self):
        up = self.effects.frames("effect1", "nail_fx")
        self.assertEqual(self.center, [0, -44.5])
        for tick, draws in enumerate(self.clips["nailDown"]):
            body = self.sampler.sample("jumpAttack", tick*10//15)
            self.assertEqual(draws[:len(body)], body)
            overlay = draws[len(body):]
            self.assertEqual(len(overlay), len(up[tick]))
            for original, rotated in zip(up[tick], overlay):
                self.assertEqual(original.texture, rotated.texture)
                for point in ((0, 0), (10, 20), (-35, 90)):
                    before = original.matrix.point(*point)
                    after = rotated.matrix.point(*point)
                    self.assertAlmostEqual(after[0], 2*self.center[0] - before[0])
                    self.assertAlmostEqual(after[1], 2*self.center[1] - before[1])

    def test_all_new_exported_frames_match_original_sampling_and_offline_scale(self):
        self.assertEqual(sum(len(frames) for frames in self.clips.values()), 105)
        self.assertEqual(self.scaled["asset_transform"]["scale"], 1.5)
        for name, frames in self.clips.items():
            for tick, draws in enumerate(frames):
                actual = self.cell(self.original, self.manifest, name, tick)
                expected = self.sampler.render(draws, (self.manifest["canvas_width"], self.manifest["canvas_height"]),
                                               (self.manifest["root_x"], self.manifest["root_y"]))
                self.assertEqual(actual.tobytes(), expected.tobytes(), (name, tick))
                scaled = actual.convert("RGBa").transform(
                    (self.scaled["canvas_width"], self.scaled["canvas_height"]), Image.Transform.AFFINE,
                    (1/1.5, 0, 0, 0, 1/1.5, 0), Image.Resampling.BICUBIC).convert("RGBA")
                self.assertEqual(self.cell(self.variant, self.scaled, name, tick).tobytes(), scaled.tobytes(), (name, tick))

    def test_arc_layers_recompose_original_body_and_keep_hidden_ticks_empty(self):
        names = {"nailArc1": "nailAttack1", "nailArc2": "nailAttack2", "nailArc3": "nailAttack3",
                 "nailArc4": "nailAttack4", "nailArcAir": "nailAir", "nailArcUp": "nailUp", "nailArcDown": "nailDown"}
        size = (self.manifest["canvas_width"], self.manifest["canvas_height"])
        root = (self.manifest["root_x"], self.manifest["root_y"])
        self.assertEqual(sum(len(frames) for frames in self.arcs.values()), 105)
        for name, frames in self.arcs.items():
            self.assertFalse(self.manifest["clips"][name]["loop"])
            for tick, draws in enumerate(frames):
                self.assertTrue(all(d.slot_path in (("nail_fx",), ("nail_down_fx",)) for d in draws))
                actual = self.cell(self.original, self.manifest, name, tick)
                expected = self.sampler.render(draws, size, root)
                self.assertEqual(actual.tobytes(), expected.tobytes(), (name, tick))
                if not draws:
                    self.assertIsNone(actual.getbbox())
                composite = self.clips[names[name]][tick]
                body = [d for d in composite if d.slot_path not in (("nail_fx",), ("nail_down_fx",))]
                self.assertEqual(Image.alpha_composite(self.sampler.render(body, size, root), actual).tobytes(),
                                 self.cell(self.original, self.manifest, names[name], tick).tobytes(), (name, tick))
                scaled = actual.convert("RGBa").transform(
                    (self.scaled["canvas_width"], self.scaled["canvas_height"]), Image.Transform.AFFINE,
                    (1/1.5, 0, 0, 0, 1/1.5, 0), Image.Resampling.BICUBIC).convert("RGBA")
                self.assertEqual(self.cell(self.variant, self.scaled, name, tick).tobytes(), scaled.tobytes(), (name, tick))


if __name__ == "__main__":
    unittest.main()
