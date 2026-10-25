"""Original 2006 body and independent held local overlays, at source 30 Hz.

The only extra color operation is the archived body's own RGB transform. All
normal staff input files and generated folders remain untouched.
"""
from dataclasses import replace
import json
from PIL import Image
from legacy_dragonbones import Affine, Draw, Sampler, fields, normalize_filler, selected_frame, transform


class FistEffects:
    def __init__(self, sampler, source, prefix, stem=''):
        load = lambda name: json.loads((source / (stem + name)).read_text(encoding='utf-8'))
        data = load('skeleton.json')
        self.global_sampler = None
        self.prefix = prefix
        self.scales = {}
        if str(data.get('version')) == '2.3' and str(data.get('isGlobal', 1)) != '0':
            for arm in data['armature']:
                for animation in arm['animation']:
                    scale = animation.pop('scale', 1)
                    if not isinstance(scale, (int, float)) or not 0 < scale <= 5:
                        raise ValueError('Unsupported original fist animation scale')
                    self.scales[arm['name']] = scale
            names = {a['name']: 'unnamed' for a in data['armature']}
            profile = dict(armature='effect4', clips=['effect4'], equipment_animation='1', child_animations=names, rgb_color_transforms=True, linear_tween=True)
            with Image.open(source / (stem + 'texture.png')) as page:
                self.global_sampler = Sampler(data, load('texture.json'), page, profile)
            for name, image in self.global_sampler.images.items(): sampler.images[prefix + name] = image
            return
        if (data.get('version'), data.get('isGlobal'), data.get('frameRate')) != ('3.0', 0, 30):
            raise ValueError('Unexpected original fist overlay format')
        self.armatures = {a['name']: a for a in data['armature']}
        self.prefix = prefix
        for arm in self.armatures.values():
            fields(arm, 'name bone skin animation', 'fist effect armature')
            if len(arm['skin']) != 1 or len(arm['animation']) != 1:
                raise ValueError('Unexpected fist skins/animations')
            for bone in arm['bone']:
                fields(bone, 'name transform', 'independent fist bone')
                transform(bone.get('transform', {}))
            animation = arm['animation'][0]
            if animation.get('autoTween') or animation.get('tweenEasing') is not None:
                raise ValueError('Active fist overlay tween')
            for timeline in animation['timeline']:
                for frame in timeline['frame']:
                    fields(frame, 'duration displayIndex z transform tweenEasing colorTransform', 'fist overlay frame')
                    if frame.get('tweenEasing') not in (None, 0) or frame.get('z', 0) != 0 or (frame.get('tweenEasing') == 0 and frame.get('duration', 1) != 1):
                        raise ValueError('Active fist tween/depth')
                    transform(frame.get('transform', {}))
                    color = frame.get('colorTransform', {})
                    if any(color.get(k, v) != v for k,v in dict(rM=100,gM=100,bM=100,rO=0,gO=0,bO=0,aO=0).items()):
                        raise ValueError('Unsupported local fist RGB transform')
        atlas = load('texture.json')
        with Image.open(source / (stem + 'texture.png')) as page:
            page, _ = normalize_filler(page)
            for item in atlas['SubTexture']:
                if item.get('rotated') or item.get('frameWidth') or item.get('frameHeight'):
                    raise ValueError('Trimmed/rotated fist texture')
                x, y, w, h = (item[k] for k in ('x', 'y', 'width', 'height'))
                if min(x, y) < 0 or min(w, h) <= 0 or x+w > page.width or y+h > page.height:
                    raise ValueError('Fist texture outside atlas')
                sampler.images[prefix + item['name']] = page.crop((x, y, x+w, y+h))

    def sample(self, name, tick, parent=Affine(), path=(), stack=()):
        if self.global_sampler is not None:
            return [replace(d, texture=self.prefix+d.texture) for d in self.global_sampler.sample(name, tick/self.scales[name], name, parent)]
        if name in stack:
            raise ValueError('Recursive fist effect')
        arm = self.armatures[name]
        animation = arm['animation'][0]
        tick = tick % animation['duration'] if animation.get('loop', 1) == 0 else min(tick, animation['duration']-1)
        bones = {b['name']: b for b in arm['bone']}
        timelines = {t['name']: t for t in animation['timeline']}
        result = []
        for slot in sorted(arm['skin'][0]['slot'], key=lambda s: s['z']):
            if slot['parent'] not in timelines: continue
            frame, child_start = selected_frame(timelines[slot['parent']], animation['duration'], tick)
            index = frame.get('displayIndex', 0)
            if index == -1: continue
            if type(index) is not int or not 0 <= index < len(slot['display']):
                raise ValueError('Invalid fist display index')
            display = slot['display'][index]
            matrix = parent.then_local(transform(bones[slot['parent']].get('transform', {}))).then_local(
                transform(frame.get('transform', {}))).then_local(transform(display.get('transform', {})))
            child_path = path + (slot['name'],)
            if display['type'] == 'image':
                result.append(Draw(self.prefix + display['name'], matrix, frame.get('colorTransform', {}).get('aM', 100)/100, child_path))
            elif display['type'] == 'armature':
                result.extend(self.sample(display['name'], tick-child_start, matrix, child_path, stack+(name,)))
            else:
                raise ValueError('Unknown fist display type')
        return result


def fist_samples(sampler, root, source):
    body_source = root / source['body']
    profile = dict(sampler.profile, clips=['idle', 'effect1', 'effect2', 'effect4', 'effect5'], rgb_color_transforms=True)
    with Image.open(body_source / 'texture.png') as page:
        body = Sampler(json.loads((body_source / 'skeleton.json').read_text(encoding='utf-8')),
                       json.loads((body_source / 'texture.json').read_text(encoding='utf-8')), page, profile)
    for name, image in body.images.items(): sampler.images['fistBody/' + name] = image
    def pose(name, tick):
        return [replace(d, texture='fistBody/' + d.texture) for d in body.sample(name, tick)]
    fx = FistEffects(sampler, root / source['effects'], 'fistFx/')
    ape = FistEffects(sampler, root / source['ape'], 'fistApe/', 'skill5_')
    def composite(name, duration):
        return [pose(name, t) + fx.sample(name, t) for t in range(duration)]
    result = {
        'afterimageCombo': composite('effect4', 71),
        'godslayerCharge': composite('effect2', 84),
        'earthbreaker': [fx.sample('effect1_0', t) + pose('effect1', t) + fx.sample('effect1', t) for t in range(32)],
        # Original ape is a distinct back layer plus roar/front layer around body.
        'fireApe': [ape.sample('effect5_0', t) + pose('effect5', t) + fx.sample('effect5_1', t) for t in range(105)],
        'godslayerWave': [fx.sample('effect2_1', t) for t in range(9)],
        'godslayerPunch': [fx.sample('effect2_2', t) for t in range(10)],
        'fistIdle': [pose('idle', t) for t in range(18)],
    }
    # Original release jumps to source frame60 (1-based) for both charge tiers.
    result['godslayerRelease'] = result['godslayerCharge'][59:]
    # Birth ticks39/51 are deliberately stretched transition drawings. Persistent
    # ghosts use the following held punch/kick poses, preserving source proportions.
    idle_ticks = sampler.profile.get('afterimage_idle_ticks', [11,25,39,51])
    if (not isinstance(idle_ticks, list) or len(idle_ticks) != 4 or
            any(type(t) is not int or not 0 <= t < 71 for t in idle_ticks)):
        raise ValueError('Expected four original afterimage idle ticks')
    for index, tick in enumerate(idle_ticks, 1):
        result['afterimageIdle' + str(index)] = [pose('effect4', tick)]
    return result
