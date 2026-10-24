"""Bounded reader for the archived skill5 local, parentless DragonBones effects."""
import json
from dataclasses import replace
from PIL import Image
from legacy_dragonbones import Affine, Draw, normalize_filler, selected_frame, transform


def fire_demon_samples(sampler, source):
    skeleton = json.loads((source / 'man_skeleton.json').read_text(encoding='utf-8'))
    atlas = json.loads((source / 'man_texture.json').read_text(encoding='utf-8'))
    if skeleton['version'] != '3.0' or skeleton['isGlobal'] != 0 or skeleton['frameRate'] != 30:
        raise ValueError('Unexpected skill5 format')
    armatures = {a['name']: a for a in skeleton['armature']}
    if set(armatures) != {'effect5_1', 'effect51', '悟空-新/元件 2'}:
        raise ValueError('Unexpected skill5 armatures')
    for a in armatures.values():
        if any('parent' in b for b in a['bone']) or len(a['skin']) != 1 or len(a['animation']) != 1:
            raise ValueError('Only the verified independent skill5 bones are supported')
        for timeline in a['animation'][0]['timeline']:
            if any(f.get('tweenEasing') is not None for f in timeline['frame']):
                raise ValueError('Active skill5 tweening is unsupported')
    with Image.open(source / 'man_texture.png') as page:
        page, _ = normalize_filler(page)
        for item in atlas['SubTexture']:
            if item.get('rotated') or item.get('frameWidth') or item.get('frameHeight'):
                raise ValueError('Unsupported trimmed/rotated skill5 texture')
            x, y, w, h = (item[k] for k in ('x', 'y', 'width', 'height'))
            sampler.images['fireDemon/' + item['name']] = page.crop((x, y, x+w, y+h))

    def effect(name, tick, parent=Affine(), stack=()):
        if name in stack: raise ValueError('Recursive skill5 armature')
        a = armatures[name]; animation = a['animation'][0]
        tick = min(max(tick, 0), animation['duration']-1)
        bones = {b['name']: b for b in a['bone']}
        timelines = {t['name']: t for t in animation['timeline']}
        result = []
        for slot in a['skin'][0]['slot']:
            frame, child_start = selected_frame(timelines[slot['parent']], animation['duration'], tick)
            display_index = frame.get('displayIndex', 0)
            if display_index == -1: continue
            display = slot['display'][display_index]
            matrix = parent.then_local(transform(bones[slot['parent']].get('transform', {}))).then_local(
                transform(frame.get('transform', {}))).then_local(transform(display.get('transform', {})))
            if display['type'] == 'image':
                result.append(Draw('fireDemon/'+display['name'], matrix, 1, ('fire_demon_fx', slot['name'])))
            elif display['type'] == 'armature':
                result.extend(effect(display['name'], tick-child_start, matrix, stack+(name,)))
            else: raise ValueError('Unsupported skill5 display')
        return result

    animation = sampler.animation(sampler.profile['armature'], 'effect5')
    torso = next(t for t in animation['timeline'] if t['name'] == 'yf8')
    idle = sampler.animation(sampler.profile['armature'], 'idle')
    idle_torso = next(t for t in idle['timeline'] if t['name'] == 'yf8')
    reference = selected_frame(idle_torso, idle['duration'], 0)[0]['transform']
    last_visible = []
    def body(tick):
        nonlocal last_visible
        draws = sampler.sample('effect5', tick)
        if not any(d.slot_path[0] == 'yf8' for d in draws): return last_visible
        raw = selected_frame(torso, animation['duration'], tick)[0]['transform']
        offset = Affine(tx=reference['x']-raw['x'], ty=reference['y']-raw['y'])
        last_visible = [replace(d, matrix=offset.then_local(d.matrix)) for d in draws]
        return last_visible

    # Remove the source animation's baked world travel, since native physics owns it.
    # Keep a visible pose through the original teleport/blink gaps in the air combo.
    # The source effect is a separate world entity. Keep it out of the body clip
    # so it does not drift with the native antic/dive or enlarge the hit geometry.
    air = [body(t) for t in range(38)]
    return {'fireDemonAir': air, 'fireDemonDive': [body(37)],
            'fireDemonAirEffect': [effect('effect5_1', t) for t in range(31)],
            'fireDemonLand': [body(min(39+t, 59)) for t in range(21)],
            'fireDemonImpact': [effect('effect51', t) for t in range(20)]}
