"""Bounded reader for archived local3.0 held image overlays (one bone/slot)."""
import json

from PIL import Image
from legacy_dragonbones import Draw, fields, normalize_filler, selected_frame, transform


class SingleBoneEffects:
    def __init__(self, sampler, source, prefix="flame/"):
        skeleton = json.loads((source / "skeleton.json").read_text(encoding="utf-8"))
        if (skeleton.get("version"), str(skeleton.get("isGlobal")), skeleton.get("frameRate")) != ("3.0", "0", 30):
            raise ValueError("Unexpected single-bone overlay format")
        self.armatures = {a["name"]: a for a in skeleton["armature"]}
        self.prefix = prefix
        atlas = json.loads((source / "texture.json").read_text(encoding="utf-8"))
        with Image.open(source / "texture.png") as image:
            image, _ = normalize_filler(image)
            for item in atlas["SubTexture"]:
                if item.get("rotated") or item.get("frameWidth") or item.get("frameHeight"):
                    raise ValueError("Trimmed/rotated overlay texture is unsupported")
                x, y, w, h = (item[k] for k in ("x", "y", "width", "height"))
                if min(x, y) < 0 or min(w, h) <= 0 or x+w > image.width or y+h > image.height:
                    raise ValueError("Overlay texture outside original atlas")
                sampler.images[prefix + item["name"]] = image.crop((x, y, x+w, y+h))
        self.images = sampler.images

    def frames(self, name, slot_name):
        armature = self.armatures[name]
        if len(armature["bone"]) != 1 or len(armature["skin"]) != 1 or len(armature["skin"][0]["slot"]) != 1:
            raise ValueError("Overlay must remain a single local bone/slot")
        bone = armature["bone"][0]
        fields(bone, "name transform", "independent overlay bone")
        slot = armature["skin"][0]["slot"][0]
        if slot["parent"] != bone["name"] or len(armature["animation"]) != 1:
            raise ValueError("Unexpected overlay parent/animation")
        animation = armature["animation"][0]
        if animation["name"] != name or animation.get("autoTween") or len(animation["timeline"]) != 1:
            raise ValueError("Unexpected overlay animation/tween")
        timeline = animation["timeline"][0]
        if timeline["name"] != bone["name"]:
            raise ValueError("Unexpected overlay timeline")
        for frame in timeline["frame"]:
            fields(frame, "duration displayIndex transform z tweenEasing", "held overlay frame")
            if frame.get("tweenEasing") is not None or frame.get("z", 0) != 0:
                raise ValueError("Active overlay tween/depth change is unsupported")
        frames = []
        for tick in range(animation["duration"]):
            frame, _ = selected_frame(timeline, animation["duration"], tick)
            index = frame.get("displayIndex", 0)
            if index == -1:
                frames.append([])
                continue
            if type(index) is not int or not 0 <= index < len(slot["display"]):
                raise ValueError("Invalid overlay display index")
            display = slot["display"][index]
            if display["type"] != "image" or self.prefix + display["name"] not in self.images:
                raise ValueError("Missing/non-image single-bone display")
            matrix = transform(bone.get("transform", {})).then_local(transform(frame.get("transform", {}))).then_local(
                transform(display.get("transform", {})))
            frames.append([Draw(self.prefix + display["name"], matrix, 1, (slot_name,))])
        return frames
