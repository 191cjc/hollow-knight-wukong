"""Exercise offline resizing against the actual original character package."""
import json
import math
from pathlib import Path
import sys
import tempfile
import unittest

from PIL import Image

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "tools"))
from resize_character import resize_character
from validate_character import CHARACTER, sha256, validate_character


class CharacterResizeTests(unittest.TestCase):
    def test_pixels_grow_without_changing_sources_timing_or_baseline_calibration(self):
        original = validate_character(CHARACTER)
        before = {p: sha256(p) for p in original.files}
        with tempfile.TemporaryDirectory() as temporary:
            output = Path(temporary) / "large"
            result = resize_character(CHARACTER, output, 1.5)
            validate_character(output)
            self.assertEqual(before, {p: sha256(p) for p in original.files})
            self.assertEqual(result["combat"], original.manifest["combat"])
            self.assertEqual(result["nominal_body_height"], original.manifest["nominal_body_height"])
            self.assertEqual(result["feet_offset_pixels"], 9)
            for axis in ("x", "y"):
                self.assertEqual(result["root_" + axis], original.manifest["root_" + axis] * 1.5)
            for axis in ("width", "height"):
                self.assertEqual(result["canvas_" + axis], math.ceil(original.manifest["canvas_" + axis] * 1.5))
            # The real atlas must split at this size instead of exceeding the engine limit.
            self.assertGreater(len(result["atlases"]), 1)
            self.assertTrue(all(max(p["width"], p["height"]) <= 2048 for p in result["atlases"]))
            for name in original.manifest["clips"]:
                old_clip, new_clip = original.manifest["clips"][name], result["clips"][name]
                self.assertEqual(old_clip["duration_ticks"], new_clip["duration_ticks"])
                self.assertEqual(old_clip["loop"], new_clip["loop"])
                for clip, directory, manifest in ((old_clip, CHARACTER, original.manifest), (new_clip, output, result)):
                    frame = clip["frames"][0]
                    page = directory / manifest["atlases"][frame["atlas"]]["path"]
                    with Image.open(page) as image:
                        box = image.crop((frame["x"], frame["y"], frame["x"] + frame["width"], frame["y"] + frame["height"])).getbbox()
                    if directory == CHARACTER:
                        previous_box = box
                    else:
                        self.assertIsNotNone(box)
                        for i in range(4):
                            self.assertAlmostEqual(box[i], previous_box[i] * 1.5, delta=3)

    def test_repeated_runs_and_clean_outputs_are_byte_identical(self):
        with tempfile.TemporaryDirectory() as temporary:
            first, second = Path(temporary) / "a", Path(temporary) / "b"
            resize_character(CHARACTER, first, 1.5)
            before = {p.name: p.read_bytes() for p in first.iterdir()}
            resize_character(CHARACTER, first, 1.5)
            resize_character(CHARACTER, second, 1.5)
            self.assertEqual(before, {p.name: p.read_bytes() for p in first.iterdir()})
            self.assertEqual(before, {p.name: p.read_bytes() for p in second.iterdir()})

    def test_invalid_factors_and_overlapping_paths_leave_originals_untouched(self):
        before = {p: sha256(p) for p in validate_character(CHARACTER).files}
        with tempfile.TemporaryDirectory() as temporary:
            for factor in (0, -1, float("nan"), float("inf"), 100):
                with self.assertRaises(ValueError):
                    resize_character(CHARACTER, Path(temporary) / "invalid", factor)
            for output in (CHARACTER, CHARACTER / "variant", CHARACTER.parent):
                with self.assertRaises(ValueError):
                    resize_character(CHARACTER, output, 1.5)
        self.assertEqual(before, {p: sha256(p) for p in before})

    def test_different_jobs_cannot_overwrite_or_rescale_a_variant(self):
        with tempfile.TemporaryDirectory() as temporary:
            output = Path(temporary) / "variant"
            resize_character(CHARACTER, output, 1.5)
            before = {p.name: p.read_bytes() for p in output.iterdir()}
            with self.assertRaisesRegex(ValueError, "already exists"):
                resize_character(CHARACTER, output, 2)
            with self.assertRaisesRegex(ValueError, "already resized"):
                resize_character(output, Path(temporary) / "twice", 1.5)
            self.assertEqual(before, {p.name: p.read_bytes() for p in output.iterdir()})


if __name__ == "__main__":
    unittest.main()
