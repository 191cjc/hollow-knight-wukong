"""Falsifiable legacy-pose and output-closure tests (run with pinned Pillow)."""
import copy
import json
from pathlib import Path
import sys
import tempfile
import unittest

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "tools"))
from bake_character import bake_character, validate_generated, write_json
from legacy_dragonbones import Sampler, normalize_filler, timeline_frames, transform


def armature(name, frames, duration=4, display=None, origin=None):
    return {"name": name, "bone": [{"name": "bone", "transform": {"x": 999}}],
            "skin": [{"name": "default", "slot": [{"name": "slot", "parent": "bone", "z": 0,
                "display": display or [{"name": "red", "type": "image", "transform": origin or {}}]}]}],
            "animation": [{"name": "pose", "duration": duration, "autoTween": 0,
                           "timeline": [{"name": "bone", "frame": frames}]}]}


def synthetic(armatures, clips=None, children=None):
    image = Image.new("RGBA", (4, 2), "red")
    for x in range(2, 4):
        for y in range(2):
            image.putpixel((x, y), (0, 0, 255, 255))
    texture = {"SubTexture": [{"name": "red", "x": 0, "y": 0, "width": 2, "height": 2},
                              {"name": "blue", "x": 2, "y": 0, "width": 2, "height": 2}]}
    return Sampler({"version": 2.3, "frameRate": 30, "armature": armatures}, texture, image,
                   {"armature": "res", "clips": clips or ["pose"], "equipment_animation": "1",
                    "child_animations": children or {}})


class LegacyPoseTests(unittest.TestCase):
    def test_global_frame_does_not_add_bind_pose_and_two_pivots_differ(self):
        part = armature("res", [{"duration": 4, "transform": {"x": 10, "y": 20, "pX": 3, "pY": 4}}],
                        origin={"x": 5, "y": 6, "pX": 1, "pY": 2})
        sampler = synthetic([part])
        draw = sampler.sample("pose", 0)[0]
        # Frame pivot ADDS at display translation; display pivot SUBTRACTS from
        # image registration. The unrelated bind x=999 must have no effect.
        self.assertEqual(draw.matrix.point(0, 0), (17, 28))
        self.assertEqual(sampler.render([draw], (32, 40), (0, 0)).getpixel((17, 28)), (255, 0, 0, 255))

    def test_independent_skew_and_negative_scale_survive_affine_inverse(self):
        matrix = transform({"scX": -3.42, "scY": 0.21, "skX": 84.82, "skY": 69.59, "x": 3, "y": 9})
        a, c, tx, b, d, ty = matrix.inverse_pillow()
        x, y = matrix.point(7, 11)
        self.assertAlmostEqual(a * x + c * y + tx, 7)
        self.assertAlmostEqual(b * x + d * y + ty, 11)
        sampler = synthetic([armature("res", [{"duration": 4, "transform": {"x": 3, "scX": -1}}])])
        image = sampler.render(sampler.sample("pose", 0), (5, 4), (0, 0))
        self.assertEqual(image.getbbox(), (1, 0, 3, 2))

    def test_keyframe_holds_and_final_duration_repair(self):
        frames = [{"duration": 2, "transform": {"x": 2}}, {"duration": 999, "transform": {"x": 9}}]
        sampler = synthetic([armature("res", frames)])
        self.assertEqual([sampler.sample("pose", t)[0].matrix.tx for t in range(4)], [2, 2, 9, 9])
        self.assertEqual([(a, b) for a, b, _ in timeline_frames({"frame": frames}, 4)], [(0, 2), (2, 4)])
        with self.assertRaises(ValueError):
            timeline_frames({"frame": [{"duration": 5}, {"duration": 1}]}, 4)

    def test_numeric_child_selection_nested_offsets_and_empty_animation_hiding(self):
        main = armature("res", [{"duration": 4, "transform": {"x": 10}}],
                        display=[{"name": "装备/part", "type": "armature", "transform": {"x": -5}}])
        child = armature("装备/part", [{"duration": 1, "transform": {"x": 45, "y": 34}}], 1,
                         origin={"x": -5, "y": -60})
        child["animation"][0]["name"] = 1
        child["animation"].append({"name": 0, "duration": 1, "autoTween": None})
        sampler = synthetic([main, child])
        self.assertEqual(sampler.sample("pose", 0)[0].matrix.point(0, 0), (45, -26))
        self.assertEqual(sampler.sample("0", 0, "装备/part"), [])

    def test_hidden_display_missing_timeline_and_alpha_inheritance(self):
        main = armature("res", [{"duration": 4, "colorTransform": {"aM": 80}}],
                        display=[{"name": "child", "type": "armature", "transform": {}}])
        child = armature("child", [{"duration": 4, "colorTransform": {"aM": 50}}])
        sampler = synthetic([main, child], children={"child": "pose"})
        draw = sampler.sample("pose", 0)[0]
        self.assertAlmostEqual(draw.alpha, 0.4)
        self.assertEqual(sampler.render([draw], (4, 4), (0, 0)).getpixel((0, 0))[3], 102)
        for frame in ({"duration": 4, "displayIndex": -1}, {"duration": 4, "hide": 1},
                      {"duration": 4, "colorTransform": {"aM": 0}}):
            main["animation"][0]["timeline"][0]["frame"] = [frame]
            self.assertEqual(synthetic([main, child], children={"child": "pose"}).sample("pose", 0), [])
        main["animation"][0]["timeline"] = []
        self.assertEqual(synthetic([main, child]).sample("pose", 0), [])

    def test_absolute_frame_z_and_stable_tie_order(self):
        part = armature("res", [{"duration": 4, "z": 10}])
        part["bone"].append({"name": "second", "transform": {}})
        slot = part["skin"][0]["slot"][0]
        slot["z"] = 100  # Must not be added again to absolute frame.z=10.
        part["skin"][0]["slot"].append({"name": "blue", "parent": "second", "z": 0,
            "display": [{"name": "blue", "type": "image", "transform": {}}]})
        part["animation"][0]["timeline"].append({"name": "second", "frame": [{"duration": 4, "z": 11}]})
        sampler = synthetic([part])
        self.assertEqual(sampler.render(sampler.sample("pose", 0), (4, 4), (0, 0)).getpixel((0, 0)), (0, 0, 255, 255))
        part["animation"][0]["timeline"][1]["frame"][0]["z"] = 10
        sampler = synthetic([part])
        self.assertEqual(sampler.sample("pose", 0)[-1].texture, "blue")

    def test_effect_clock_starts_when_parent_display_appears(self):
        main = armature("res", [{"duration": 2, "displayIndex": -1}, {"duration": 4},
                                {"duration": 2, "displayIndex": -1}], 8,
                        display=[{"name": "effect", "type": "armature", "transform": {}}])
        child = armature("effect", [{"duration": 3}, {"duration": 1, "displayIndex": 1}], 4,
                         display=[{"name": "red", "type": "image", "transform": {}},
                                  {"name": "blue", "type": "image", "transform": {}}])
        sampler = synthetic([main, child], children={"effect": "pose"})
        self.assertEqual(sampler.sample("pose", 0), [])
        self.assertEqual([sampler.sample("pose", t)[0].texture for t in range(2, 6)], ["red", "red", "red", "blue"])
        self.assertEqual(sampler.sample("pose", 6), [])

    def test_exact_filler_cleanup_preserves_other_low_alpha_pixels(self):
        source = Image.new("RGBA", (4, 1))
        pixels = [(0, 0, 0, 1), (2, 0, 0, 1), (0, 0, 0, 2), (0, 0, 0, 255)]
        source.putdata(pixels)
        cleaned, count = normalize_filler(source)
        self.assertEqual(count, 1)
        self.assertEqual(list(cleaned.getdata()), [(0, 0, 0, 0)] + pixels[1:])
        self.assertEqual(list(source.getdata()), pixels)

    def test_unsupported_features_fail_instead_of_silent_approximation(self):
        base = armature("res", [{"duration": 4}])
        cases = []
        for mutate in (lambda a: a["bone"][0].update(parent="root"),
                       lambda a: a["animation"][0].update(autoTween=1),
                       lambda a: a["animation"][0]["timeline"][0].update(scale=2),
                       lambda a: a["animation"][0]["timeline"][0]["frame"][0].update(tweenEasing=0),
                       lambda a: a["skin"][0]["slot"][0]["display"][0].update(type="mesh")):
            item = copy.deepcopy(base)
            mutate(item)
            cases.append(item)
        for item in cases:
            with self.subTest(item=item), self.assertRaises(ValueError):
                synthetic([item])
        cycle = armature("res", [{"duration": 4}], display=[{"name": "res", "type": "armature", "transform": {}}])
        with self.assertRaisesRegex(ValueError, "Cyclic"):
            synthetic([cycle], children={"res": "pose"}).sample("pose", 0)


class ArchivedAssetTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.profile = json.loads((ROOT / "data/character/wukong-staff.json").read_text())
        source = ROOT / cls.profile["source_directory"]
        with Image.open(source / "texture.png") as image:
            cls.sampler = Sampler(json.loads((source / "skeleton.json").read_text()),
                                  json.loads((source / "texture.json").read_text()), image, cls.profile)

    def test_real_missing_timelines_and_invisible_second_staff(self):
        for name in ("idle", "walk", "runNormal", "attack1", "attack2", "attack3", "attack4"):
            paths = {draw.slot_path[0] for draw in self.sampler.sample(name, 0)}
            self.assertFalse(paths & {"ef1", "huaban", "hurteye", "mohu", "wq12"})
            self.assertIn("wq1", paths)
        self.assertIn("hurteye", {d.slot_path[0] for d in self.sampler.sample("hurtStand", 0)})

    def test_real_placeholder_cleanup_and_exporter_duration_anomaly(self):
        for piece in ("yf8_hair", "yf4a", "yf3_piaodai", "yf8_erhuan"):
            image = self.sampler.images[f"__dbTextures/装备/fashion_{piece}/图层 3_0"]
            self.assertEqual(image.size, (2, 2))
            self.assertIsNone(image.getbbox())
        timeline = next(t for t in self.sampler.animation("res", "walk")["timeline"] if t["name"] == "wq12")
        self.assertEqual(timeline["frame"][0]["duration"], 337)
        self.assertEqual(timeline_frames(timeline, 24)[0][:2], (0, 24))

    def test_real_death_ghost_boundaries_and_clock(self):
        def ghost(tick):
            return [d.texture for d in self.sampler.sample("dead", tick) if d.slot_path[0] == "ef1"]
        self.assertEqual(ghost(7), [])
        self.assertEqual(ghost(8), ["特效元件/yj_11111-0_0"])
        self.assertEqual(ghost(10), ghost(8))
        self.assertEqual(ghost(11), ["特效元件/yj_11111-0_3"])
        self.assertEqual(ghost(29), ["特效元件/yj_11111-0_21"])
        self.assertEqual(ghost(32), [])

    def test_real_jump_frame_pivot_is_kept_as_slot_translation(self):
        draw = next(d for d in self.sampler.sample("jumpTwo", 0) if d.slot_path[0] == "wq1")
        # Hand-computed composition: bone(12.95,-25.65), frame pivot(-.6,22),
        # parent display(-45.3,-35.3), child bone(45,34), leaf(-5,-60).
        expected = transform({"scX": -1, "x": 12.95, "y": -25.65, "skX": 155.72, "skY": 155.72}).point(-5.9, -39.3)
        self.assertAlmostEqual(draw.matrix.tx, expected[0])
        self.assertAlmostEqual(draw.matrix.ty, expected[1])

    def test_real_air_attack_holds_three_poses_at_authored_startup_boundary(self):
        animation = self.sampler.animation("res", "jumpAttack")
        self.assertEqual(animation["duration"], 10)
        poses = [self.sampler.sample("jumpAttack", tick) for tick in range(10)]
        self.assertEqual(poses[0], poses[1])
        self.assertEqual(poses[2], poses[3])
        self.assertTrue(all(pose == poses[4] for pose in poses[4:]))
        self.assertNotEqual(poses[0], poses[2])
        self.assertNotEqual(poses[2], poses[4])
        self.assertEqual(self.profile["combat"]["air_attack"], {
            "clip": "jumpAttack", "hit_windows": [{"start_tick": 4, "end_tick": 7}],
            "range_multiplier": 1.0})

    def test_clean_bakes_are_byte_identical_and_cells_are_not_clipped(self):
        with tempfile.TemporaryDirectory() as directory:
            first, second = Path(directory) / "a", Path(directory) / "b"
            manifest = bake_character(output=first, previews=False)
            bake_character(output=second, previews=False)
            self.assertEqual({p.name: p.read_bytes() for p in first.iterdir()},
                             {p.name: p.read_bytes() for p in second.iterdir()})
            self.assertEqual(len(manifest["clips"]), 13)
            self.assertEqual(manifest["schema_version"], 2)
            self.assertEqual(manifest["generator"]["version"], 1)
            self.assertEqual(manifest["combat"], self.profile["combat"])
            self.assertEqual(manifest["clips"]["jumpAttack"]["duration_ticks"], 10)
            self.assertFalse(manifest["clips"]["jumpAttack"]["loop"])
            self.assertEqual(len(manifest["clips"]["jumpAttack"]["frames"]), 10)
            self.assertEqual(sum(c["duration_ticks"] for c in manifest["clips"].values()), 329)
            self.assertEqual((manifest["canvas_width"], manifest["canvas_height"],
                              manifest["root_x"], manifest["root_y"]), (231, 226, 119, 174))
            self.assertEqual(manifest["generator"]["unique_cells"], 52)
            self.assertLess(manifest["generator"]["unique_cells"], sum(len(c["frames"]) for c in manifest["clips"].values()))
            old = copy.deepcopy(manifest)
            old["schema_version"] = 1
            old["combat"].pop("air_attack")
            write_json(first / "character.json", old)
            # An old schema cache must be rebuilt even when its fingerprint matches.
            self.assertEqual(bake_character(output=first, previews=False), manifest)
            self.assertEqual((first / "character.json").read_bytes(), (second / "character.json").read_bytes())
            pages = [Image.open(first / a["path"]) for a in manifest["atlases"]]
            try:
                for name, clip in manifest["clips"].items():
                    self.assertEqual(clip["duration_ticks"], self.sampler.animation("res", name)["duration"])
                    for frame in clip["frames"]:
                        x, y, w, h = (frame[k] for k in ("x", "y", "width", "height"))
                        bounds = pages[frame["atlas"]].crop((x, y, x + w, y + h)).getbbox()
                        self.assertIsNotNone(bounds)
                        self.assertGreaterEqual(min(bounds[:2]), 2)
                        self.assertLessEqual(bounds[2], w - 2)
                        self.assertLessEqual(bounds[3], h - 2)
                bad = copy.deepcopy(manifest)
                bad["clips"]["idle"]["frames"][0]["x"] = manifest["atlases"][0]["width"]
                write_json(first / "character.json", bad)
                with self.assertRaisesRegex(ValueError, "outside atlas"):
                    validate_generated(first)
                write_json(first / "character.json", manifest)
                page = first / manifest["atlases"][0]["path"]
                page.write_bytes(page.read_bytes() + b"damaged")
                with self.assertRaisesRegex(ValueError, "hash mismatch"):
                    validate_generated(first)
            finally:
                for page in pages:
                    page.close()

    def test_small_atlas_limit_splits_pages_without_losing_frame_references(self):
        with tempfile.TemporaryDirectory() as directory:
            project = Path(directory)
            (project / "data/character").mkdir(parents=True)
            profile = copy.deepcopy(self.profile)
            profile["source_directory"] = str(ROOT / profile["source_directory"])
            profile["atlas_max_size"] = 512
            write_json(project / "data/character/wukong-staff.json", profile)
            manifest = bake_character(project_root=project, previews=False)
            self.assertGreater(len(manifest["atlases"]), 1)
            for atlas in manifest["atlases"]:
                self.assertLessEqual(max(atlas["width"], atlas["height"]), 512)
            seen = {f["atlas"] for c in manifest["clips"].values() for f in c["frames"]}
            self.assertEqual(seen, set(range(len(manifest["atlases"]))))


if __name__ == "__main__":
    unittest.main()
