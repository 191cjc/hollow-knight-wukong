"""Read only the verified three local armatures of the original casting effect4.

The body and this independently attached overlay use the same source root and
clock. Child animations start at their first visible parent frame (tick14).
No Flash actions or gameplay events are executed by this offline reader.
"""
import json

from PIL import Image
from legacy_dragonbones import Affine, Draw, fields, normalize_filler, selected_frame, transform


def fire_eye_cast_samples(sampler, source):
    skeleton = json.loads((source / "skeleton.json").read_text(encoding="utf-8"))
    if (skeleton.get("version"), skeleton.get("isGlobal"), skeleton.get("frameRate")) != ("3.0", 0, 30):
        raise ValueError("Unexpected Fire Eye casting format")
    names = {"effect4": (4, 21), "重复项目文件夹/元件 2": (1, 7), "悟空-新/元件 1": (1, 7)}
    armatures = {a["name"]: a for a in skeleton["armature"] if a["name"] in names}
    if set(armatures) != set(names):
        raise ValueError("Missing Fire Eye casting armature")
    for name, armature in armatures.items():
        bone_count, duration = names[name]
        fields(armature, "name bone skin animation", "Fire Eye casting armature")
        if len(armature["bone"]) != bone_count or len(armature["skin"]) != 1 or len(armature["animation"]) != 1:
            raise ValueError("Unexpected Fire Eye casting hierarchy")
        bones = {b["name"]: b for b in armature["bone"]}
        for bone in bones.values():
            fields(bone, "name transform", "Fire Eye independent bone")
            transform(bone.get("transform", {}))
        animation = armature["animation"][0]
        fields(animation, "name duration timeline autoTween tweenEasing", "Fire Eye casting animation")
        if animation["duration"] != duration or animation.get("autoTween") or animation.get("tweenEasing") is not None:
            raise ValueError("Unsupported Fire Eye casting duration/tween")
        if {t["name"] for t in animation["timeline"]} != set(bones):
            raise ValueError("Unexpected Fire Eye casting timelines")
        for timeline in animation["timeline"]:
            fields(timeline, "name frame", "Fire Eye casting timeline")
            for frame in timeline["frame"]:
                fields(frame, "duration displayIndex z transform tweenEasing", "Fire Eye casting frame")
                if frame.get("tweenEasing") is not None or frame.get("z", 0) != 0:
                    raise ValueError("Unsupported Fire Eye tween/depth change")
                transform(frame.get("transform", {}))
        for slot in armature["skin"][0]["slot"]:
            fields(slot, "name parent z display", "Fire Eye casting slot")
            if slot["parent"] not in bones:
                raise ValueError("Missing Fire Eye casting bone")
            for display in slot["display"]:
                fields(display, "name type transform", "Fire Eye casting display")
                if display["type"] not in ("image", "armature"):
                    raise ValueError("Unsupported Fire Eye display")
                if display["type"] == "armature" and display["name"] not in armatures:
                    raise ValueError("Unknown Fire Eye child armature")
                transform(display.get("transform", {}))

    atlas = json.loads((source / "texture.json").read_text(encoding="utf-8"))
    with Image.open(source / "texture.png") as image:
        image, _ = normalize_filler(image)
        for item in atlas["SubTexture"]:
            if item.get("rotated") or item.get("frameWidth") or item.get("frameHeight"):
                raise ValueError("Unsupported trimmed/rotated Fire Eye texture")
            x, y, w, h = (item[k] for k in ("x", "y", "width", "height"))
            if min(x, y) < 0 or min(w, h) <= 0 or x+w > image.width or y+h > image.height:
                raise ValueError("Fire Eye texture outside original atlas")
            sampler.images["fireEyeCast/" + item["name"]] = image.crop((x, y, x+w, y+h))

    def sample(name, tick, parent=Affine(), path=(), stack=()):
        if name in stack:
            raise ValueError("Recursive Fire Eye casting armature")
        armature = armatures[name]
        animation = armature["animation"][0]
        bones = {b["name"]: b for b in armature["bone"]}
        timelines = {t["name"]: t for t in animation["timeline"]}
        draws = []
        for slot in sorted(armature["skin"][0]["slot"], key=lambda s: s["z"]):
            frame, child_start = selected_frame(timelines[slot["parent"]], animation["duration"], tick)
            index = frame.get("displayIndex", 0)
            if index == -1:
                continue
            if type(index) is not int or not 0 <= index < len(slot["display"]):
                raise ValueError("Fire Eye casting display index outside slot")
            display = slot["display"][index]
            matrix = parent.then_local(transform(bones[slot["parent"]].get("transform", {}))).then_local(
                transform(frame.get("transform", {}))).then_local(transform(display.get("transform", {})))
            child_path = path + (slot["name"],)
            if display["type"] == "image":
                texture = "fireEyeCast/" + display["name"]
                if texture not in sampler.images:
                    raise ValueError("Missing Fire Eye casting image")
                draws.append(Draw(texture, matrix, 1, child_path))
            else:
                draws.extend(sample(display["name"], tick-child_start, matrix, child_path, stack+(name,)))
        return draws

    body_duration = sampler.animation(sampler.profile["armature"], "effect4")["duration"]
    if body_duration != 17:
        raise ValueError("Unexpected Fire Eye body duration")
    # Keep the complete independent overlay inside native focus charging. The
    # shorter original body holds its last pose while the nested flashes finish.
    return [sampler.sample("effect4", min(tick, body_duration-1)) + sample("effect4", tick)
            for tick in range(21)]
