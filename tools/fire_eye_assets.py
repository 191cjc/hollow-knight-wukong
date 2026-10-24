"""Decode the archived Jiyuan Fire Eye ef symbol without executing Flash code.

This deliberately supports only the five verified lossless images and the simple
single-depth ten-frame timeline in buff810001. Registration comes from the
preserved JPEXS shape/matrix export; unsupported source changes fail the bake.
"""
import struct
import xml.etree.ElementTree as ET
import zlib

from PIL import Image
from legacy_dragonbones import Affine, Draw


def lossless_images(source):
    raw = source.read_bytes()
    if raw[:3] != b"CWS":
        raise ValueError("Expected the archived compressed Fire Eye SWF")
    data = zlib.decompress(raw[8:])
    if len(data) + 8 != struct.unpack_from("<I", raw, 4)[0]:
        raise ValueError("Truncated Fire Eye SWF")
    offset = (5 + 4 * (data[0] >> 3) + 7) // 8 + 4
    images = {}
    while offset < len(data):
        header = struct.unpack_from("<H", data, offset)[0]
        offset += 2
        code, length = header >> 6, header & 63
        if length == 63:
            length = struct.unpack_from("<I", data, offset)[0]
            offset += 4
        payload = data[offset:offset + length]
        offset += length
        if len(payload) != length:
            raise ValueError("Truncated Fire Eye tag")
        if code == 36:  # DefineBitsLossless2: premultiplied ARGB, bitmapFormat5.
            identity, fmt, width, height = struct.unpack_from("<HBHH", payload)
            if fmt != 5 or (width, height) != (92, 170) or identity in images:
                raise ValueError("Unsupported Fire Eye bitmap")
            image = Image.frombytes("RGBA", (width, height), zlib.decompress(payload[7:]), "raw", "ARGB")
            image.putdata([tuple(min(255, channel * 255 // a) for channel in (r, g, b)) + (a,)
                           if a else (0, 0, 0, 0) for r, g, b, a in image.getdata()])
            images[identity] = image
    if set(images) != {1, 3, 5, 7, 9}:
        raise ValueError("Missing original Fire Eye image")
    return images


def fire_eye_samples(sampler, source, timeline):
    images = lossless_images(source)
    tags = ET.parse(timeline).getroot()
    symbols = tags.find("item[@type='SymbolClassTag']")
    if [n.text for n in symbols.find("names")] != ["ef"] or symbols.find("tags/item").text != "11":
        raise ValueError("Unexpected Fire Eye symbol")
    sprite = tags.find("item[@spriteId='11']")
    if sprite.get("frameCount") != "10":
        raise ValueError("Unexpected Fire Eye duration")
    shapes = {}
    for identity, image in images.items():
        shape = tags.find(f"item[@shapeId='{identity + 1}']")
        fills = shape.findall(".//item[@type='FILLSTYLE']")
        if len(fills) != 2 or fills[1].get("bitmapId") != str(identity):
            raise ValueError("Unexpected Fire Eye bitmap shape")
        matrix = fills[1].find("bitmapMatrix")
        if matrix.get("hasRotate") != "false" or float(matrix.get("scaleX")) != 20 or float(matrix.get("scaleY")) != 20:
            raise ValueError("Unsupported Fire Eye bitmap matrix")
        bounds = shape.find("shapeBounds")
        x, y = (float(matrix.get(k)) / 20 for k in ("translateX", "translateY"))
        if (float(bounds.get("Xmax")) - float(bounds.get("Xmin")),
                float(bounds.get("Ymax")) - float(bounds.get("Ymin"))) != (image.width * 20, image.height * 20):
            raise ValueError("Fire Eye shape no longer matches its bitmap")
        key = f"fireEye/{identity}"
        sampler.images[key] = image
        shapes[identity + 1] = Draw(key, Affine(tx=x, ty=y), 1, ("fire_eye_aura",))
    current = None
    frames = []
    for tag in sprite.find("subTags"):
        if tag.get("type") == "PlaceObject2Tag":
            if tag.get("depth") != "1" or tag.get("placeFlagHasColorTransform") != "false":
                raise ValueError("Unsupported Fire Eye timeline placement")
            matrix = tag.find("matrix")
            if matrix is not None and (matrix.get("hasScale") != "false" or matrix.get("hasRotate") != "false"
                                       or matrix.get("translateX") != "0" or matrix.get("translateY") != "0"):
                raise ValueError("Unsupported Fire Eye sprite transform")
            current = shapes[int(tag.get("characterId"))]
        elif tag.get("type") == "ShowFrameTag" and current is not None:
            frames.append([current])
        else:
            raise ValueError("Unsupported Fire Eye timeline tag")
    if len(frames) != 10:
        raise ValueError("Incomplete Fire Eye timeline")
    return frames
