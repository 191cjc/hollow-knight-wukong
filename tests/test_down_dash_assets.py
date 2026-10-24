"""Regress Dashmaster direction without rotating the hero or changing horizontal art."""
import json
from pathlib import Path
import sys
import unittest

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'tools'))
from bake_character import flame_dash_samples, flame_dash_down_samples
from legacy_dragonbones import Sampler


class DownDashAssetTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.active = json.loads((ROOT / 'data/character/active-variant.json').read_text(encoding='utf-8'))
        profile = json.loads((ROOT / cls.active['bake_profile']).read_text(encoding='utf-8'))
        source = ROOT / profile['source_directory']
        with Image.open(source / 'texture.png') as image:
            cls.sampler = Sampler(json.loads((source / 'skeleton.json').read_text(encoding='utf-8')),
                                  json.loads((source / 'texture.json').read_text(encoding='utf-8')), image, profile)
        cls.horizontal = flame_dash_samples(cls.sampler, ROOT / profile['flame_dash_effect_source'])
        cls.down = flame_dash_down_samples(cls.sampler, ROOT / profile['flame_dash_effect_source'],
                                          profile['flame_dash_down_center_pixels'])

    def test_flames_turn_down_around_fixed_center_body_stays_upright(self):
        self.assertEqual(len(self.down), 12)
        for old, new in zip(self.horizontal, self.down):
            self.assertEqual(len(old), len(new))
            for a, b in zip(old, new):
                if a.slot_path != ('flame_dash_fx',):
                    self.assertEqual(a, b)
                    continue
                self.assertEqual(a.texture, b.texture)
                for point in ((0, 0), (10, 20), (-35, 90)):
                    x, y = a.matrix.point(*point)
                    dx, dy = b.matrix.point(*point)
                    self.assertAlmostEqual(dx, -y - 44.5)
                    self.assertAlmostEqual(dy, x - 44.5)

    def test_down_export_matches_source_and_offline_enlargement(self):
        folder = ROOT / self.active['source_directory']
        variant = ROOT / self.active['output_directory']
        manifest = json.loads((folder / 'character.json').read_text(encoding='utf-8'))
        scaled = json.loads((variant / 'character.json').read_text(encoding='utf-8'))
        def cell(directory, m, tick):
            f = m['clips']['flameDashDown']['frames'][tick]
            with Image.open(directory / m['atlases'][f['atlas']]['path']) as page:
                return page.crop((f['x'], f['y'], f['x']+f['width'], f['y']+f['height']))
        size = (manifest['canvas_width'], manifest['canvas_height'])
        root = (manifest['root_x'], manifest['root_y'])
        for tick, draws in enumerate(self.down):
            expected = self.sampler.render(draws, size, root)
            self.assertEqual(cell(folder, manifest, tick).tobytes(), expected.tobytes())
            enlarged = expected.convert('RGBa').transform(
                (scaled['canvas_width'], scaled['canvas_height']), Image.Transform.AFFINE,
                (1/1.5, 0, 0, 0, 1/1.5, 0), Image.Resampling.BICUBIC).convert('RGBA')
            self.assertEqual(cell(variant, scaled, tick).tobytes(), enlarged.tobytes())


if __name__ == '__main__':
    unittest.main()
