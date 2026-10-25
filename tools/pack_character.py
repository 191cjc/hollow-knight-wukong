"""Crop transparent atlas margins offline, retaining the common source root.

Each cell includes the root, so native Sprite.Create pivots remain inside it.
Original and resized source directories are read-only. No pixel resampling occurs.
"""
import copy
import json
import math
from pathlib import Path
from PIL import Image
from validate_character import sha256, validate_character


def pack_character(source, output):
    source, output = Path(source).resolve(), Path(output).resolve()
    if source == output or source.is_relative_to(output) or output.is_relative_to(source):
        raise ValueError('Packed output must be a separate folder')
    original = validate_character(source)
    fingerprint = dict(source_manifest_sha256=sha256(source/'character.json'), script_sha256=sha256(Path(__file__)))
    if output.exists():
        cached = validate_character(output).manifest
        if cached.get('atlas_packing') == fingerprint: return cached
        raise ValueError('Existing packed folder differs; choose a new folder')
    manifest = copy.deepcopy(original.manifest)
    images, cells, mapping = [], [], {}
    try:
        for a in manifest['atlases']:
            with Image.open(source/a['path']) as image: images.append(image.copy())
        for clip in manifest['clips'].values():
            for frame in clip['frames']:
                key = tuple(frame[k] for k in ('atlas','x','y','width','height'))
                if key in mapping: continue
                a,x,y,w,h=key
                image=images[a].crop((x,y,x+w,y+h))
                box=image.getbbox() or (math.floor(manifest['root_x']), math.floor(manifest['root_y']), math.ceil(manifest['root_x'])+1, math.ceil(manifest['root_y'])+1)
                # One transparent gutter protects FullRect bilinear boundaries.
                left=max(0,min(box[0]-1,math.floor(manifest['root_x'])-1))
                top=max(0,min(box[1]-1,math.floor(manifest['root_y'])-1))
                right=min(w,max(box[2]+1,math.ceil(manifest['root_x'])+1))
                bottom=min(h,max(box[3]+1,math.ceil(manifest['root_y'])+1))
                cropped=image.crop((left,top,right,bottom))
                mapping[key]=len(cells)
                cells.append(dict(image=cropped, source_x=left,source_y=top))
        # Deterministic decreasing-height shelf packing with a 2048px maximum.
        pages=[]
        for cell in sorted(cells,key=lambda c:(-c['image'].height,-c['image'].width)):
            w,h=cell['image'].size
            chosen=None
            for index,page in enumerate(pages):
                for shelf in page['shelves']:
                    if h<=shelf['height'] and shelf['x']+w<=2048:
                        chosen=(index,page,shelf);break
                if chosen:break
                used=sum(s['height'] for s in page['shelves'])
                if used+h<=2048:
                    shelf=dict(x=0,y=used,height=h);page['shelves'].append(shelf);chosen=(index,page,shelf);break
            if chosen is None:
                page=dict(shelves=[dict(x=0,y=0,height=h)],cells=[])
                pages.append(page);chosen=(len(pages)-1,page,page['shelves'][0])
            index,page,shelf=chosen
            cell.update(atlas=index,x=shelf['x'],y=shelf['y']);shelf['x']+=w;page['cells'].append(cell)
        output.mkdir(parents=True)
        manifest['atlases']=[]
        for index,page in enumerate(pages):
            image=Image.new('RGBA',(max(s['x'] for s in page['shelves']),sum(s['height'] for s in page['shelves'])))
            for cell in page['cells']:image.paste(cell['image'],(cell['x'],cell['y']))
            name=f'atlas-{index:03d}.png';image.save(output/name,compress_level=9)
            manifest['atlases'].append(dict(path=name,width=image.width,height=image.height,sha256=sha256(output/name)))
        for clip in manifest['clips'].values():
            for frame in clip['frames']:
                key=tuple(frame[k] for k in ('atlas','x','y','width','height'))
                c=cells[mapping[key]]
                frame.update(atlas=c['atlas'],x=c['x'],y=c['y'],width=c['image'].width,height=c['image'].height,source_x=c['source_x'],source_y=c['source_y'])
        manifest['atlas_packing']=fingerprint
        (output/'character.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
        return validate_character(output).manifest
    finally:
        for image in images:image.close()
