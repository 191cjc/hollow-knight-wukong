"""Exercise malformed resource contracts and the exact staged package boundary."""
import copy
import json
import sys
import tempfile
import unittest
import zipfile
from pathlib import Path

from PIL import Image

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "tools"))
from package import stage_package, validate_package, write_archive
from validate_character import REQUIRED_CLIPS, SOURCE_FILES, sha256, validate_character


class CharacterPackageTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        self.character = self.root / "generated"
        self.character.mkdir()
        self.source = self.root / "source"
        self.source.mkdir()
        for name in SOURCE_FILES:
            (self.source / name).write_bytes(name.encode())
        Image.new("RGBA", (8, 8), (255, 120, 0, 255)).save(self.character / "atlas-000.png")
        self.manifest = {
            "schema_version": 1, "character_id": "2001", "appearance": "default_staff",
            "frame_rate": 30, "canvas_width": 4, "canvas_height": 4,
            "root_x": 2.0, "root_y": 3.0, "nominal_body_height": 3.0,
            "source_hashes": {name: sha256(self.source / name) for name in SOURCE_FILES},
            "generator": {"version": 1, "pillow_version": "11.3.0",
                          "filler_normalization": "exact_rgba_0_0_0_1"},
            "atlases": [{"path": "atlas-000.png", "width": 8, "height": 8,
                         "sha256": sha256(self.character / "atlas-000.png")}],
            "clips": {name: {"duration_ticks": 8, "loop": name == "idle",
                             "frames": [{"atlas": 0, "x": 0, "y": 0, "width": 4,
                                         "height": 4, "duration_ticks": 1} for _ in range(8)]}
                      for name in REQUIRED_CLIPS},
            "combat": {"chain_grace_seconds": 0.35, "stages": [
                {"clip": "attack" + str(index), "buffer_open_tick": 1, "range_multiplier": 1.0,
                 "hit_windows": ([{"start_tick": 1, "end_tick": 2},
                                  {"start_tick": 4, "end_tick": 5}] if index == 3
                                 else [{"start_tick": 1, "end_tick": 3}])}
                for index in range(1, 5)]},
        }
        self.write()
        self.dll = self.root / "WukongKnight.dll"
        self.dll.write_bytes(b"MZcompiled-test-fixture")
        self.stage = self.root / "mod/WukongKnight"

    def write(self, manifest=None):
        (self.character / "character.json").write_text(json.dumps(manifest or self.manifest))

    def test_validates_resource_bytes_and_stage_contract(self):
        validated = validate_character(self.character, self.source)
        self.assertEqual(validated.frame_count, len(REQUIRED_CLIPS) * 8)
        self.assertEqual({path.name for path in validated.files}, {"character.json", "atlas-000.png"})
        (self.source / "skeleton.json").write_bytes(b"changed source")
        with self.assertRaisesRegex(ValueError, "source hash mismatch"):
            validate_character(self.character, self.source)

    def test_rejects_invalid_schema_geometry_ticks_and_combat(self):
        mutations = {
            "schema": lambda m: m.update(schema_version=2),
            "boolean_integer": lambda m: m.update(frame_rate=True),
            "root": lambda m: m.update(root_x=5),
            "nan": lambda m: m.update(nominal_body_height=float("nan")),
            "missing_clip": lambda m: m["clips"].pop("jumpAttack"),
            "frame_bounds": lambda m: m["clips"]["idle"]["frames"][0].update(x=6),
            "tick_total": lambda m: m["clips"]["idle"].update(duration_ticks=9),
            "shared_canvas": lambda m: m["clips"]["idle"]["frames"][0].update(width=3),
            "missing_atlas": lambda m: m["clips"]["idle"]["frames"][0].update(atlas=1),
            "window_count": lambda m: m["combat"]["stages"][2]["hit_windows"].pop(),
            "window_overlap": lambda m: m["combat"]["stages"][2]["hit_windows"][1].update(start_tick=1),
            "window_bounds": lambda m: m["combat"]["stages"][0]["hit_windows"][0].update(end_tick=9),
            "stage_order": lambda m: m["combat"]["stages"][0].update(clip="attack4"),
            "damage_modifier": lambda m: m["combat"]["stages"][0].update(damage_multiplier=2),
        }
        for name, mutate in mutations.items():
            with self.subTest(name=name):
                manifest = copy.deepcopy(self.manifest)
                mutate(manifest)
                self.write(manifest)
                with self.assertRaises(ValueError):
                    validate_character(self.character)

    def test_rejects_atlas_hash_and_dimension_changes(self):
        self.manifest["atlases"][0]["width"] = 9
        self.write()
        with self.assertRaisesRegex(ValueError, "dimensions mismatch"):
            validate_character(self.character)
        self.manifest["atlases"][0]["width"] = 8
        self.write()
        (self.character / "atlas-000.png").write_bytes(b"changed atlas")
        with self.assertRaisesRegex(ValueError, "atlas hash mismatch"):
            validate_character(self.character)

    def test_rejects_unsafe_manifest_paths(self):
        for name in ("../atlas-000.png", "/tmp/atlas.png", "a/../../atlas.png",
                     "a\\atlas.png", "C:/atlas.png", "./atlas-000.png"):
            with self.subTest(name=name):
                self.manifest["atlases"][0]["path"] = name
                self.write()
                with self.assertRaises(ValueError):
                    validate_character(self.character)

    def test_staging_uses_only_manifest_resources_and_removes_stale_files(self):
        (self.character / "previews").mkdir()
        (self.character / "previews/idle.gif").write_bytes(b"not runtime")
        self.stage.mkdir(parents=True)
        (self.stage / "UnityEngine.dll").write_bytes(b"stale engine")
        names = stage_package(self.dll, self.character, self.stage)
        self.assertEqual(names, ["README.txt", "WukongKnight.dll",
                                 "character/atlas-000.png", "character/character.json"])
        (self.stage / "Assembly-CSharp.dll").write_bytes(b"accidental game reference")
        with self.assertRaisesRegex(ValueError, "unexpected"):
            validate_package(self.stage)

    def test_missing_resource_does_not_replace_previous_valid_package(self):
        stage_package(self.dll, self.character, self.stage)
        previous = (self.stage / "character/character.json").read_bytes()
        (self.character / "atlas-000.png").unlink()
        with self.assertRaises(ValueError):
            stage_package(self.dll, self.character, self.stage)
        self.assertEqual((self.stage / "character/character.json").read_bytes(), previous)
        validate_package(self.stage)

    def test_archive_is_closed_and_reproducible(self):
        stage_package(self.dll, self.character, self.stage)
        first, second = self.root / "first.zip", self.root / "second.zip"
        write_archive(self.stage, first)
        write_archive(self.stage, second)
        self.assertEqual(first.read_bytes(), second.read_bytes())
        with zipfile.ZipFile(first) as archive:
            self.assertEqual(archive.namelist(), ["WukongKnight/" + path
                                                 for path in validate_package(self.stage)])
            self.assertTrue(all(not name.endswith(".dll") or name.endswith("/WukongKnight.dll")
                                for name in archive.namelist()))

    def test_symbolic_link_resources_are_not_packaged(self):
        real = self.character / "atlas-000.png"
        real.rename(self.root / "outside.png")
        real.symlink_to(self.root / "outside.png")
        with self.assertRaises(ValueError):
            stage_package(self.dll, self.character, self.stage)


if __name__ == "__main__":
    unittest.main()
