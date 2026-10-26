"""Original fist color/clocks, independent effects and lossless packed registration."""
import copy
import hashlib
import json
from pathlib import Path
import sys
import tempfile
import unittest
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'tools'))
from legacy_dragonbones import Sampler
from fist_assets import fist_samples
from validate_character import validate_character


def cell(folder,manifest,frame,reconstruct=False):
    with Image.open(folder/manifest['atlases'][frame['atlas']]['path']) as page:
        image=page.crop((frame['x'],frame['y'],frame['x']+frame['width'],frame['y']+frame['height']))
    if reconstruct and 'atlas_packing' in manifest:
        canvas=Image.new('RGBA',(manifest['canvas_width'],manifest['canvas_height']))
        canvas.paste(image,(frame['source_x'],frame['source_y']));return canvas
    return image


class FistAssetTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        active=json.loads((ROOT/'data/character/active-variant.json').read_text())
        cls.profile=json.loads((ROOT/active['bake_profile']).read_text())
        source=ROOT/cls.profile['source_directory']
        with Image.open(source/'texture.png') as page:
            cls.sampler=Sampler(json.loads((source/'skeleton.json').read_text()),json.loads((source/'texture.json').read_text()),page,cls.profile)
        cls.samples=fist_samples(cls.sampler,ROOT,cls.profile['fist_source'])
        cls.raw=ROOT/active['output_directory'];cls.packed=ROOT/active['runtime_directory']
        cls.original=ROOT/active['source_directory']
        cls.manifest=json.loads((cls.original/'character.json').read_text())

    def test_original_downloads_and_decoded_sources_are_preserved(self):
        evidence=json.loads((ROOT/'reference/flash/fist/provenance.json').read_text())
        for name,expected in evidence['inputs'].items():
            self.assertEqual(hashlib.sha256((ROOT/name).read_bytes()).hexdigest(),expected,name)

    def test_original_skill_clocks_and_release_jump(self):
        self.assertEqual({k:len(self.samples[k]) for k in ('afterimageCombo','godslayerCharge','godslayerRelease','earthbreaker','fireApe','godslayerWave','godslayerPunch')},
                         dict(afterimageCombo=71,godslayerCharge=84,godslayerRelease=25,earthbreaker=32,fireApe=105,godslayerWave=9,godslayerPunch=10))
        self.assertEqual(self.samples['godslayerRelease'],self.samples['godslayerCharge'][59:])
        self.assertTrue(any(d.texture.startswith('fistApe/') for f in self.samples['fireApe'] for d in f))
        self.assertTrue(any(d.texture.startswith('fistFx/') for f in self.samples['fireApe'] for d in f))
        self.assertTrue(any(d.color != (1,1,1,0,0,0) for f in self.samples['afterimageCombo'] for d in f))

    def test_moving_ape_has_source_back_front_effects_without_body(self):
        for name,prefix in [('fireApeAwakenedBack','fistApe/'),('fireApeAwakenedFront','fistFx/')]:
            frames=self.samples[name]
            self.assertEqual(len(frames),105)
            self.assertTrue(any(frames))
            self.assertTrue(all(d.texture.startswith(prefix) for f in frames for d in f))
            for tick,frame in enumerate(frames):
                source=[d for d in self.samples['fireApe'][tick] if d.texture.startswith(prefix)]
                self.assertEqual(frame,source,(name,tick))
        source=(ROOT/'reference/flash/fist/WK2Entity.as').read_text()
        self.assertIn('if(skill5Awake1 && currentActionState == 75)',source)
        self.assertIn('_effect5_1.updateDirection(this.direction)',source)
        self.assertIn('_effect5_2.updateDirection(this.direction)',source)

    def test_every_previous_clip_retains_original_pixels(self):
        old_folder=ROOT/'assets/processed/wukong-fist-v071-original'
        old=json.loads((old_folder/'character.json').read_text())
        self.assertEqual([(self.manifest[k]) for k in ('canvas_width','canvas_height','root_x','root_y','nominal_body_height','combat')],
                         [(old[k]) for k in ('canvas_width','canvas_height','root_x','root_y','nominal_body_height','combat')])
        seen=set()
        for name,clip in old['clips'].items():
            new=self.manifest['clips'][name]
            self.assertEqual((new['duration_ticks'],new['loop']),(clip['duration_ticks'],clip['loop']))
            for tick,f in enumerate(clip['frames']):
                pair=tuple(f[k] for k in ('atlas','x','y','width','height'))+tuple(new['frames'][tick][k] for k in ('atlas','x','y','width','height'))
                if pair in seen:continue
                seen.add(pair)
                self.assertEqual(cell(old_folder,old,f).tobytes(),cell(self.original,self.manifest,new['frames'][tick]).tobytes(),(name,tick))

    def test_persistent_afterimages_use_unsquashed_held_source_poses(self):
        # Birth39/51 are orange stretched smears; persistent clones need the next
        # held punch/kick drawings, not a stretch applied to those transition art.
        from dataclasses import replace
        source=ROOT/self.profile['fist_source']['body']
        profile=dict(self.profile,clips=['effect4'],rgb_color_transforms=True)
        with Image.open(source/'texture.png') as page:
            body=Sampler(json.loads((source/'skeleton.json').read_text()),json.loads((source/'texture.json').read_text()),page,profile)
        for index,tick in enumerate((11,25,40,53),1):
            expected=[replace(d,texture='fistBody/'+d.texture) for d in body.sample('effect4',tick)]
            self.assertEqual(self.samples['afterimageIdle'+str(index)],[expected])
        # Configurable future selections must reject negative/out-of-range ticks.
        old=self.sampler.profile
        try:
            for ticks in ([11,25,40], [11,25,-1,53], [11,25,40,71], [11,25,40,True]):
                self.sampler.profile=dict(old,afterimage_idle_ticks=ticks)
                with self.assertRaises(ValueError):fist_samples(self.sampler,ROOT,self.profile['fist_source'])
        finally:self.sampler.profile=old

    def test_all_new_source_frames_equal_direct_source_composition(self):
        size=(self.manifest['canvas_width'],self.manifest['canvas_height'])
        root=(self.manifest['root_x'],self.manifest['root_y'])
        for clip,frames in self.samples.items():
            for tick,draws in enumerate(frames):
                actual=cell(self.original,self.manifest,self.manifest['clips'][clip]['frames'][tick])
                expected=self.sampler.render(draws,size,root)
                self.assertEqual(actual.tobytes(),expected.tobytes(),(clip,tick))

    def test_packed_pixels_reconstruct_every_unique_enlarged_source_frame(self):
        raw=json.loads((self.raw/'character.json').read_text());packed=validate_character(self.packed).manifest
        seen=set()
        for name,clip in raw['clips'].items():
            for i,f in enumerate(clip['frames']):
                key=tuple(f[k] for k in ('atlas','x','y','width','height'))
                if key in seen:continue
                seen.add(key)
                a=cell(self.raw,raw,f);b=cell(self.packed,packed,packed['clips'][name]['frames'][i],True)
                self.assertEqual(a.tobytes(),b.tobytes(),(name,i))
        raw_pixels=sum(a['width']*a['height'] for a in raw['atlases'])
        packed_pixels=sum(a['width']*a['height'] for a in packed['atlases'])
        self.assertLess(packed_pixels,raw_pixels/4)
        self.assertEqual(raw['nominal_body_height'],packed['nominal_body_height'])
        self.assertEqual(packed['asset_transform']['scale'],1.5)

    def test_opt_in_rgb_and_linear_tween_use_source_values(self):
        # Independent known solid pixels/affine midpoint, not a second renderer.
        arm=dict(name='res',bone=[dict(name='b')],skin=[dict(name='default',slot=[dict(name='s',parent='b',z=0,display=[dict(name='red',type='image',transform={})])])],
                 animation=[dict(name='test',duration=4,autoTween=0,timeline=[dict(name='b',frame=[dict(duration=2,tweenEasing=0,transform=dict(x=0),colorTransform=dict(rM=45,gM=45,bM=45,rO=140,gO=61,bO=0)),dict(duration=2,transform=dict(x=4),colorTransform=dict(rM=45,gM=45,bM=45,rO=140,gO=61,bO=0))])])])
        data=dict(version=2.3,frameRate=30,armature=[arm]);atlas=dict(SubTexture=[dict(name='red',x=0,y=0,width=2,height=2)])
        profile=dict(armature='res',clips=['test'],child_animations={},equipment_animation='1',rgb_color_transforms=True,linear_tween=True)
        s=Sampler(data,atlas,Image.new('RGBA',(2,2),'red'),profile)
        d=s.sample('test',1)[0];self.assertEqual(d.matrix.tx,2)
        self.assertEqual(s.render([d],(8,4),(0,0)).getpixel((2,0)),(255,61,0,255))
        profile['rgb_color_transforms']=False
        with self.assertRaises(ValueError):Sampler(data,atlas,Image.new('RGBA',(2,2),'red'),profile)


if __name__=='__main__':unittest.main()
