"""Check the freshly downloaded death resource against original and enlarged runtime frames."""
import hashlib
import json
from pathlib import Path
import sys
import tempfile
import unittest

from PIL import Image

ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'tools'))
from legacy_dragonbones import Sampler
from unpack_animation import unpack


class DeathArtworkTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.source=ROOT/'reference/flash/death'
        cls.active=json.loads((ROOT/'data/character/active-variant.json').read_text(encoding='utf-8'))
        profile=json.loads((ROOT/cls.active['bake_profile']).read_text(encoding='utf-8'))
        decoded=cls.source/'decoded'
        with Image.open(decoded/'texture.png') as image:
            cls.sampler=Sampler(json.loads((decoded/'skeleton.json').read_text(encoding='utf-8')),
                                json.loads((decoded/'texture.json').read_text(encoding='utf-8')),image,profile)

    def test_downloaded_bundle_and_original_ghost_schedule(self):
        evidence=json.loads((self.source/'provenance.json').read_text(encoding='utf-8'))
        self.assertEqual(hashlib.sha256((self.source/'manV535.swf').read_bytes()).hexdigest(),evidence['sha256'])
        with tempfile.TemporaryDirectory() as tmp:
            unpack(self.source/'manV535.swf',Path(tmp))
            for name,digest in evidence['decoded'].items():
                self.assertEqual(hashlib.sha256((Path(tmp)/name).read_bytes()).hexdigest(),digest)
                self.assertEqual((Path(tmp)/name).read_bytes(),(self.source/'decoded'/name).read_bytes())
        self.assertEqual(self.sampler.animation('res','dead')['duration'],65)
        for tick in range(65):
            ghost=[d for d in self.sampler.sample('dead',tick) if d.slot_path[0]=='ef1']
            self.assertEqual(bool(ghost),8<=tick<32,(tick,'original ghost window'))

    def test_all_death_frames_match_download_and_offline_1p5_pixels(self):
        pages={}
        def cell(folder,m,tick):
            f=m['clips']['dead']['frames'][tick];p=folder/m['atlases'][f['atlas']]['path']
            if p not in pages:pages[p]=Image.open(p).convert('RGBA')
            return pages[p].crop((f['x'],f['y'],f['x']+f['width'],f['y']+f['height']))
        original=ROOT/self.active['source_directory'];variant=ROOT/self.active['output_directory']
        m=json.loads((original/'character.json').read_text(encoding='utf-8'))
        v=json.loads((variant/'character.json').read_text(encoding='utf-8'))
        self.assertFalse(m['clips']['dead']['loop'])
        try:
            for tick in range(65):
                expected=self.sampler.render(self.sampler.sample('dead',tick),(m['canvas_width'],m['canvas_height']),(m['root_x'],m['root_y']))
                self.assertEqual(cell(original,m,tick).tobytes(),expected.tobytes(),tick)
                enlarged=expected.convert('RGBa').transform((v['canvas_width'],v['canvas_height']),Image.Transform.AFFINE,
                    (1/1.5,0,0,0,1/1.5,0),Image.Resampling.BICUBIC).convert('RGBA')
                self.assertEqual(cell(variant,v,tick).tobytes(),enlarged.tobytes(),tick)
        finally:
            for page in pages.values():page.close()


if __name__=='__main__':unittest.main()
