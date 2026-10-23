"""Bounded DragonBones 2.3 global-pose sampler for the archived Wukong export.

This is an offline, held-keyframe compositor, not a general DragonBones runtime.
The observed legacy semantics and pinned historical references are documented in
the task's research/animation-conversion.md. No historical implementation code is
copied here. Coordinates remain source pixels (+y down) until Unity import.
"""
from dataclasses import dataclass
import math

from PIL import Image


def number(data, key, default=0):
    value = data[key] if key in data else default
    if isinstance(value, bool) or not isinstance(value, (int, float)) or not math.isfinite(value):
        raise ValueError(f"Unsupported non-finite/non-numeric {key}: {value!r}")
    return value


def fields(data, allowed, label):
    unknown = set(data) - set(allowed.split())
    if unknown:
        raise ValueError(f"Unsupported {label} fields: {sorted(unknown)}")


@dataclass(frozen=True)
class Affine:
    a: float = 1
    b: float = 0
    c: float = 0
    d: float = 1
    tx: float = 0
    ty: float = 0

    def point(self, x, y):
        return self.a * x + self.c * y + self.tx, self.b * x + self.d * y + self.ty

    def then_local(self, other):
        """Compose self * other (apply the local transform, then this one)."""
        tx, ty = self.point(other.tx, other.ty)
        return Affine(self.a * other.a + self.c * other.b,
                      self.b * other.a + self.d * other.b,
                      self.a * other.c + self.c * other.d,
                      self.b * other.c + self.d * other.d, tx, ty)

    def inverse_pillow(self):
        det = self.a * self.d - self.b * self.c
        if abs(det) < 1e-10:
            raise ValueError("Singular source transform")
        return (self.d / det, -self.c / det,
                (self.c * self.ty - self.d * self.tx) / det,
                -self.b / det, self.a / det,
                (self.b * self.tx - self.a * self.ty) / det)


def transform(raw):
    fields(raw, "x y scX scY skX skY pX pY", "transform")
    sx, sy = number(raw, "scX", 1), number(raw, "scY", 1)
    kx, ky = math.radians(number(raw, "skX")), math.radians(number(raw, "skY"))
    return Affine(sx * math.cos(ky), sx * math.sin(ky),
                  -sy * math.sin(kx), sy * math.cos(kx),
                  number(raw, "x"), number(raw, "y"))


def normalize_filler(image):
    """Only the exact export filler changes; preserve colored alpha=1 edges."""
    result = image.convert("RGBA")
    pixels = list(result.getdata())
    count = pixels.count((0, 0, 0, 1))
    result.putdata([(0, 0, 0, 0) if p == (0, 0, 0, 1) else p for p in pixels])
    return result, count


def timeline_frames(timeline, duration):
    """Repair only the final duration, just as the old-data parser does."""
    result = []
    position = 0
    raw_frames = timeline.get("frame", [])
    for index, frame in enumerate(raw_frames):
        length = duration - position if index == len(raw_frames) - 1 else number(frame, "duration", 1)
        if int(length) != length or length <= 0:
            raise ValueError("Timeline exceeds its animation or has invalid duration")
        result.append((position, position + int(length), frame))
        position += int(length)
    return result


def selected_frame(timeline, duration, tick):
    frames = timeline_frames(timeline, duration)
    for index, (start, end, frame) in enumerate(frames):
        if start <= tick < end:
            # Child animation clock restarts on a display change or hidden -> shown,
            # not at every keyframe if the same display stays visible.
            visible_start = start
            display = frame.get("displayIndex", 0)
            for prev_start, _, previous in reversed(frames[:index]):
                if (previous.get("displayIndex", 0) != display or previous.get("hide", False)
                        or number(previous.get("colorTransform", {}), "aM", 100) == 0):
                    break
                visible_start = prev_start
            return frame, visible_start
    raise ValueError(f"No timeline frame at tick {tick}")


@dataclass(frozen=True)
class Draw:
    texture: str
    matrix: Affine
    alpha: float
    slot_path: tuple


class Sampler:
    def __init__(self, skeleton, texture, image, profile):
        fields(skeleton, "armature name frameRate version isGlobal", "skeleton")
        if str(skeleton.get("version")) != "2.3" or skeleton.get("frameRate") != 30:
            raise ValueError("Only the 2.3 / 30 FPS export is supported")
        if str(skeleton.get("isGlobal", "1")) == "0":
            raise ValueError("Local bone transforms are unsupported")
        self.profile = profile
        self.armatures = self._names(skeleton["armature"])
        self.textures = self._names(texture["SubTexture"])
        image, self.normalized_pixels = normalize_filler(image)
        self.images = {}
        for name, item in self.textures.items():
            fields(item, "name x y width height", "atlas rectangle")
            x, y, w, h = (number(item, k) for k in ("x", "y", "width", "height"))
            if any(int(v) != v for v in (x, y, w, h)) or min(x, y) < 0 or min(w, h) <= 0:
                raise ValueError("Invalid atlas rectangle")
            if x + w > image.width or y + h > image.height:
                raise ValueError("Atlas rectangle outside source PNG")
            self.images[name] = image.crop((x, y, x + w, y + h))
        self._validate()

    @staticmethod
    def _names(items):
        result = {str(item["name"]): item for item in items}
        if len(result) != len(items):
            raise ValueError("Duplicate name after legacy numeric-name normalization")
        return result

    def animation(self, armature, clip):
        try:
            return self._names(self.armatures[armature]["animation"])[str(clip)]
        except KeyError as error:
            raise ValueError(f"Missing animation {armature}:{clip}") from error

    def _validate(self):
        for armature in self.armatures.values():
            fields(armature, "name bone skin animation", "armature")
            bones = self._names(armature["bone"])
            for bone in bones.values():
                fields(bone, "name transform", "bone (parented bones are unsupported)")
                transform(bone.get("transform", {}))
            if len(armature["skin"]) != 1:
                raise ValueError("Expected exactly one default skin")
            slots = armature["skin"][0]["slot"]
            self._names(slots)
            for slot in slots:
                fields(slot, "name parent z display", "slot")
                if slot["parent"] not in bones:
                    raise ValueError("Slot parent bone is missing")
                for display in slot["display"]:
                    fields(display, "name type transform", "display")
                    kind = display["type"]
                    source = self.images if kind == "image" else self.armatures if kind == "armature" else {}
                    if display["name"] not in source:
                        raise ValueError(f"Unresolved/unsupported display: {display['name']}")
                    raw = display.get("transform", {})
                    transform(raw)
                    if any(number(raw, key, default) != default for key, default in
                           (("scX", 1), ("scY", 1), ("skX", 0), ("skY", 0))):
                        raise ValueError("Only translated/pivoted display origins are supported")
            for animation in armature["animation"]:
                fields(animation, "name duration timeline frame autoTween tweenEasing loop", "animation")
                if animation.get("autoTween", True):
                    raise ValueError("Active auto tween is unsupported")
                duration = number(animation, "duration")
                if duration <= 0 or int(duration) != duration:
                    raise ValueError("Invalid animation duration")
                timelines = animation.get("timeline", [])
                self._names(timelines)
                for timeline in timelines:
                    fields(timeline, "name frame", "timeline (time scale/offset unsupported)")
                    if timeline["name"] not in bones:
                        raise ValueError("Timeline bone is missing")
                    for _, _, frame in timeline_frames(timeline, duration):
                        fields(frame, "duration transform z displayIndex colorTransform tweenEasing hide event", "frame")
                        if frame.get("tweenEasing", 10) not in (None, 10):
                            raise ValueError("Active keyframe tween is unsupported")
                        transform(frame.get("transform", {}))
                        color = frame.get("colorTransform", {})
                        fields(color, "aM rM gM bM aO rO gO bO", "color transform")
                        for channel in "rgb":
                            if number(color, channel + "M", 100) != 100 or number(color, channel + "O") != 0:
                                raise ValueError("RGB color transforms are unsupported")
                        if number(color, "aO") != 0 or not 0 <= number(color, "aM", 100) <= 100:
                            raise ValueError("Unsupported alpha transform")
        for clip in self.profile["clips"]:
            self.animation(self.profile["armature"], clip)

    def sample(self, clip, tick, armature=None, parent=Affine(), alpha=1.0, path=(), stack=()):
        armature = armature or self.profile["armature"]
        if armature in stack:
            raise ValueError(f"Cyclic armature reference: {stack + (armature,)}")
        animation = self.animation(armature, clip)
        duration = int(animation["duration"])
        tick = tick % duration if animation.get("loop", 1) == 0 else min(tick, duration - 1)
        timelines = self._names(animation.get("timeline", []))
        selected = []
        for order, slot in enumerate(self.armatures[armature]["skin"][0]["slot"]):
            timeline = timelines.get(slot["parent"])
            if not timeline or not timeline.get("frame"):
                continue  # Legacy hide-map: absent timeline never draws the bind pose.
            frame, child_start = selected_frame(timeline, duration, tick)
            index = frame.get("displayIndex", 0)
            if frame.get("hide", False) or index == -1:
                continue
            if not isinstance(index, int) or not 0 <= index < len(slot["display"]):
                raise ValueError("Display index out of range")
            opacity = alpha * number(frame.get("colorTransform", {}), "aM", 100) / 100
            if opacity == 0:
                continue
            selected.append((number(frame, "z", slot.get("z", 0)), order,
                             slot, frame, index, child_start, opacity))
        result = []
        for _, _, slot, frame, index, child_start, opacity in sorted(selected, key=lambda row: row[:2]):
            display = slot["display"][index]
            raw, origin = frame.get("transform", {}), display.get("transform", {})
            matrix = parent.then_local(transform(raw)).then_local(Affine(
                tx=number(origin, "x") + number(raw, "pX"),
                ty=number(origin, "y") + number(raw, "pY")))
            child_path = path + (slot["name"],)
            if display["type"] == "image":
                matrix = matrix.then_local(Affine(tx=-number(origin, "pX"), ty=-number(origin, "pY")))
                if self.images[display["name"]].getbbox():
                    result.append(Draw(display["name"], matrix, opacity, child_path))
            else:
                child_name = display["name"]
                if child_name.startswith("装备/"):
                    child_clip = self.profile["equipment_animation"]
                else:
                    try:
                        child_clip = self.profile["child_animations"][child_name]
                    except KeyError as error:
                        raise ValueError(f"No explicit child animation for {child_name}") from error
                result.extend(self.sample(child_clip, tick - child_start, child_name,
                                          matrix, opacity, child_path, stack + (armature,)))
        return result

    def bounds(self, draws):
        points = []
        for draw in draws:
            image = self.images[draw.texture]
            points.extend(draw.matrix.point(x, y) for x, y in
                          ((0, 0), (image.width, 0), (0, image.height), (image.width, image.height)))
        if not points:
            raise ValueError("No visible image bounds")
        return (min(p[0] for p in points), min(p[1] for p in points),
                max(p[0] for p in points), max(p[1] for p in points))

    def render(self, draws, size, root):
        output = Image.new("RGBA", size)
        for draw in draws:
            source = self.images[draw.texture]
            matrix = Affine(tx=root[0], ty=root[1]).then_local(draw.matrix)
            xmin, ymin, xmax, ymax = self.bounds([draw])
            left, top = math.floor(xmin + root[0]) - 2, math.floor(ymin + root[1]) - 2
            right, bottom = math.ceil(xmax + root[0]) + 2, math.ceil(ymax + root[1]) + 2
            local = Affine(tx=-left, ty=-top).then_local(matrix)
            # Explicit premultiplied alpha prevents RGB in transparent texels from
            # bleeding dark outlines into rotated/scaled semitransparent edges.
            part = source.convert("RGBa").transform((right - left, bottom - top),
                Image.Transform.AFFINE, local.inverse_pillow(), Image.Resampling.BICUBIC).convert("RGBA")
            if draw.alpha != 1:
                part.putalpha(part.getchannel("A").point(lambda a: round(a * draw.alpha)))
            output.alpha_composite(part, (left, top))
        return output
