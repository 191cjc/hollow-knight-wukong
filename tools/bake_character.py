"""Bake the archived default staff Wukong into deterministic runtime atlases.

Run with .tools/python/bin/python tools/bake_character.py. Source files remain
read-only. The profile owns transplant timings; source animation events are not
executed or interpreted as combat windows.
"""
import argparse
from dataclasses import replace
from hashlib import sha256
import json
import math
from pathlib import Path

import PIL
from PIL import Image, ImageDraw

from legacy_dragonbones import Affine, Sampler
from validate_character import OPTIONAL_CLIPS, REQUIRED_CLIPS, sha256 as file_hash, validate_character


PROJECT_ROOT = Path(__file__).resolve().parent.parent
GENERATOR_VERSION = 1


def read_json(path):
    return json.loads(path.read_text(encoding="utf-8"))


def write_json(path, data):
    path.write_text(json.dumps(data, indent=2, sort_keys=True, ensure_ascii=False) + "\n", encoding="utf-8")


def validate_combat(combat, clips):
    if not 0 < combat["chain_grace_seconds"] <= 2 or len(combat["stages"]) != 4:
        raise ValueError("Invalid combo grace/stage count")
    for index, stage in enumerate(combat["stages"]):
        if set(stage) != {"clip", "buffer_open_tick", "hit_windows", "range_multiplier"}:
            raise ValueError("Unsupported stage fields (damage modifiers are not permitted)")
        if stage["clip"] != f"attack{index + 1}":
            raise ValueError("Combo stages are out of order")
        duration = clips[stage["clip"]]["duration_ticks"]
        opening = stage["buffer_open_tick"]
        if not isinstance(opening, int) or not 0 <= opening < duration:
            raise ValueError("Buffer opening outside stage")
        if not 0.25 <= stage["range_multiplier"] <= 3:
            raise ValueError("Invalid native slash range multiplier")
        windows = stage["hit_windows"]
        if len(windows) != (2 if index == 2 else 1):
            raise ValueError("Expected 1/1/2/1 hit windows")
        previous_end = 0
        for window in windows:
            start, end = window["start_tick"], window["end_tick"]
            if not isinstance(start, int) or not isinstance(end, int) or not previous_end <= start < end <= duration:
                raise ValueError("Overlapping/out-of-range hit windows")
            previous_end = end


def validate_generated(output):
    """Validate the materialized manifest/page closure; used on cache hits too."""
    return validate_character(output).manifest


def checker(size):
    background = Image.new("RGB", size, (220, 220, 220))
    draw = ImageDraw.Draw(background)
    for y in range(0, size[1], 12):
        for x in range(0, size[0], 12):
            if (x // 12 + y // 12) % 2:
                draw.rectangle((x, y, x + 11, y + 11), fill=(175, 175, 175))
    return background


def preview_frame(frame, root, label):
    result = checker(frame.size)
    draw = ImageDraw.Draw(result)
    draw.line((0, root[1], frame.width, root[1]), fill=(65, 100, 140))
    result.paste(frame, mask=frame.getchannel("A"))
    draw = ImageDraw.Draw(result)
    draw.line((root[0] - 3, root[1], root[0] + 3, root[1]), fill=(230, 30, 60))
    draw.line((root[0], root[1] - 3, root[0], root[1] + 3), fill=(230, 30, 60))
    draw.rectangle((0, 0, result.width, 15), fill=(30, 30, 30))
    draw.text((4, 2), label, fill="white")
    return result


def write_previews(output, rendered, root):
    output.mkdir(parents=True, exist_ok=True)
    attack_rows = []
    overview = []
    for name, frames in rendered.items():
        chosen = []
        seen = set()
        for tick, frame in enumerate(frames):
            fingerprint = sha256(frame.tobytes()).digest()
            if fingerprint not in seen:
                seen.add(fingerprint)
                chosen.append((tick, frame))
        width, height = frames[0].size
        columns = min(6, len(chosen))
        sheet = Image.new("RGB", (columns * width, math.ceil(len(chosen) / columns) * height), "#222222")
        for index, (tick, frame) in enumerate(chosen):
            sheet.paste(preview_frame(frame, root, f"{name} tick {tick}"),
                        (index % columns * width, index // columns * height))
        sheet.save(output / f"{name}-contact.png")
        if name.startswith("attack"):
            attack_rows.append(sheet)
        overview.append(preview_frame(frames[0], root, name))
        animation = [preview_frame(frame, root, name) for frame in frames]
        # GIF clocks are 10 ms; rounded cumulative boundaries preserve total time.
        durations = [(round((i + 1) * 100 / 30) - round(i * 100 / 30)) * 10 for i in range(len(frames))]
        animation[0].save(output / f"{name}.gif", save_all=True, append_images=animation[1:],
                          duration=durations, loop=0, disposal=2, optimize=False)
    attacks = Image.new("RGB", (max(row.width for row in attack_rows), sum(row.height for row in attack_rows)), "#222222")
    position = 0
    for row in attack_rows:
        attacks.paste(row, (0, position))
        position += row.height
    attacks.save(output / "attacks-contact.png")
    width, height = overview[0].size
    sheet = Image.new("RGB", (4 * width, math.ceil(len(overview) / 4) * height), "#222222")
    for index, frame in enumerate(overview):
        sheet.paste(frame, (index % 4 * width, index // 4 * height))
    sheet.save(output / "overview.png")
    # Edge inspection on solid light/dark grounds, including mirrored facing.
    idle = rendered["idle"][0]
    sheet = Image.new("RGB", (width * 4, height))
    for i, color in enumerate(("#fafafa", "#161616", "#fafafa", "#161616")):
        frame = idle if i < 2 else idle.transpose(Image.Transpose.FLIP_LEFT_RIGHT)
        background = Image.new("RGB", frame.size, color)
        background.paste(frame, mask=frame.getchannel("A"))
        sheet.paste(background, (i * width, 0))
    sheet.save(output / "edges-facing.png")


def flame_dash_samples(sampler, source):
    return flame_overlay_samples(sampler, source, "effect2", 4, 12, "flame_dash_fx")


def flame_dash_down_samples(sampler, source, center):
    """Rotate only flames clockwise in source Y-down coordinates; body stays upright."""
    if len(center) != 2 or any(not math.isfinite(v) for v in center):
        raise ValueError("Invalid downward dash center")
    cx, cy = center
    turn = Affine(a=0, b=1, c=-1, d=0, tx=cx+cy, ty=cy-cx)
    frames = flame_dash_samples(sampler, source)
    return [[replace(d, matrix=turn.then_local(d.matrix)) if d.slot_path == ("flame_dash_fx",) else d
             for d in frame] for frame in frames]


def flame_storm_samples(sampler, source):
    return flame_overlay_samples(sampler, source, "effect3", 0, 16, "flame_storm_fx")


def flame_overlay_samples(sampler, source, name, start, ticks, slot_name):
    """Preserve original flame ordering while sharing the held image reader."""
    from single_bone_effects import SingleBoneEffects
    overlay = SingleBoneEffects(sampler, source).frames(name, slot_name)
    if not 0 <= start < start + ticks <= len(overlay):
        raise ValueError("Flame sample range outside source animation")
    return [overlay[start + tick] + sampler.sample(name, start + tick) for tick in range(ticks)]


def bake_character(project_root=PROJECT_ROOT, output=None, force=False, previews=True, profile_path=None):
    project_root = Path(project_root)
    profile_path = Path(profile_path) if profile_path else project_root / "data/character/wukong-staff.json"
    profile = read_json(profile_path)
    if (profile["profile_version"] != 1 or profile["filler_normalization"] != "exact_rgba_0_0_0_1"
            or not set(REQUIRED_CLIPS) <= set(profile["clips"]) <= set(REQUIRED_CLIPS + OPTIONAL_CLIPS)):
        raise ValueError("Unsupported bake profile")
    source = project_root / profile["source_directory"]
    output = Path(output) if output is not None else project_root / "assets/processed/wukong"
    hashes = {name: file_hash(source / name) for name in ("skeleton.json", "texture.json", "texture.png")}
    code_hashes = {name: file_hash(Path(__file__).parent / name) for name in ("bake_character.py", "legacy_dragonbones.py", "validate_character.py")}
    inputs = {"sources": hashes, "profile": file_hash(profile_path), "code": code_hashes, "pillow": PIL.__version__}
    if profile.get("flame_dash_effect_source"):
        inputs["flame_sources"] = {name: file_hash(project_root / profile["flame_dash_effect_source"] / name)
                                  for name in ("skeleton.json", "texture.json", "texture.png")}
    if profile.get("flame_storm_effect_source"):
        inputs["flame_storm_sources"] = {name: file_hash(project_root / profile["flame_storm_effect_source"] / name)
                                        for name in ("skeleton.json", "texture.json", "texture.png")}
    if profile.get("fire_demon_effect_source"):
        inputs["fire_demon_sources"] = {name: file_hash(project_root / profile["fire_demon_effect_source"] / name)
                                      for name in ("man_skeleton.json", "man_texture.json", "man_texture.png")}
        inputs["fire_demon_code"] = file_hash(Path(__file__).parent / "fire_demon_assets.py")
    if profile.get("fire_eye_effect_source"):
        inputs["fire_eye_sources"] = {key: file_hash(project_root / value)
                                     for key, value in profile["fire_eye_effect_source"].items()}
        inputs["fire_eye_code"] = file_hash(Path(__file__).parent / "fire_eye_assets.py")
    if profile.get("fire_eye_cast_source"):
        inputs["fire_eye_cast_sources"] = {name: file_hash(project_root / profile["fire_eye_cast_source"] / name)
                                           for name in ("skeleton.json", "texture.json", "texture.png")}
        inputs["fire_eye_cast_code"] = file_hash(Path(__file__).parent / "fire_eye_cast_assets.py")
    if any(profile.get(key) for key in ("flame_dash_effect_source", "flame_storm_effect_source", "nail_effect_source")):
        inputs["single_bone_code"] = file_hash(Path(__file__).parent / "single_bone_effects.py")
    if profile.get("nail_effect_source"):
        inputs["nail_sources"] = {name: file_hash(project_root / profile["nail_effect_source"] / name)
                                  for name in ("skeleton.json", "texture.json", "texture.png")}
        inputs["nail_code"] = file_hash(Path(__file__).parent / "nail_assets.py")
    if profile.get("fist_source"):
        inputs["fist_sources"] = {str(p.relative_to(project_root)): file_hash(p)
            for d in profile["fist_source"].values() for p in sorted((project_root / d).glob("*")) if p.is_file()}
        inputs["fist_code"] = file_hash(Path(__file__).parent / "fist_assets.py")
    fingerprint = sha256(json.dumps(inputs, sort_keys=True).encode()).hexdigest()
    if not force and (output / "character.json").exists():
        try:
            cached = validate_generated(output)
            if cached["generator"]["input_sha256"] == fingerprint and (not previews or (output / "previews/overview.png").exists()):
                return cached
        except (OSError, ValueError, KeyError, TypeError):
            pass  # Rebuild a stale or damaged generated cache.
    with Image.open(source / "texture.png") as image:
        sampler = Sampler(read_json(source / "skeleton.json"), read_json(source / "texture.json"), image, profile)
    samples = {name: [sampler.sample(name, tick) for tick in range(sampler.animation(profile["armature"], name)["duration"])]
               for name in profile["clips"]}
    animations = {name: sampler.animation(profile["armature"], name) for name in profile["clips"]}
    if profile.get("flame_dash_effect_source"):
        samples["flameDash"] = flame_dash_samples(sampler, project_root / profile["flame_dash_effect_source"])
        animations["flameDash"] = {"duration": 12, "loop": 0}
        if profile.get("flame_dash_down_center_pixels"):
            samples["flameDashDown"] = flame_dash_down_samples(sampler, project_root / profile["flame_dash_effect_source"],
                                                            profile["flame_dash_down_center_pixels"])
            animations["flameDashDown"] = {"duration": 12, "loop": 0}
    if profile.get("flame_storm_effect_source"):
        samples["flameStorm"] = flame_storm_samples(sampler, project_root / profile["flame_storm_effect_source"])
        animations["flameStorm"] = {"duration": 16, "loop": 0}
    if profile.get("fire_demon_effect_source"):
        from fire_demon_assets import fire_demon_samples
        extra = fire_demon_samples(sampler, project_root / profile["fire_demon_effect_source"])
        samples.update(extra)
        animations.update({name: {"duration": len(frames), "loop": 1} for name, frames in extra.items()})
    if profile.get("fire_eye_effect_source"):
        from fire_eye_assets import fire_eye_samples
        eye = profile["fire_eye_effect_source"]
        samples["fireEyeAura"] = fire_eye_samples(sampler, project_root / eye["swf"], project_root / eye["timeline"])
        animations["fireEyeAura"] = {"duration": 10, "loop": 0}
    if profile.get("fire_eye_cast_source"):
        from fire_eye_cast_assets import fire_eye_cast_samples
        samples["fireEyeCast"] = fire_eye_cast_samples(sampler, project_root / profile["fire_eye_cast_source"])
        animations["fireEyeCast"] = {"duration": 21, "loop": 1}
    if profile.get("nail_effect_source"):
        from nail_assets import nail_samples, nail_arc_samples
        extra = nail_samples(sampler, project_root / profile["nail_effect_source"], profile["nail_rotation_center_pixels"])
        if profile.get("nail_separate_arcs"):
            extra.update(nail_arc_samples(sampler, project_root / profile["nail_effect_source"], profile["nail_rotation_center_pixels"]))
        samples.update(extra)
        animations.update({name: {"duration": len(frames), "loop": 1} for name, frames in extra.items()})
    if profile.get("fist_source"):
        from fist_assets import fist_samples
        extra = fist_samples(sampler, project_root, profile["fist_source"])
        samples.update(extra)
        animations.update({name: {"duration": len(frames), "loop": 1} for name, frames in extra.items()})
    bounds = [sampler.bounds(draws) for frames in samples.values() for draws in frames if draws]
    if not bounds:
        raise ValueError("No visible character frames")
    padding = profile["canvas_padding"]
    left, top = math.floor(min(b[0] for b in bounds)) - padding, math.floor(min(b[1] for b in bounds)) - padding
    right, bottom = math.ceil(max(b[2] for b in bounds)) + padding, math.ceil(max(b[3] for b in bounds)) + padding
    # Include the source root in the cell even for an unusual all-airborne profile.
    left, top, right, bottom = min(left, 0), min(top, 0), max(right, 1), max(bottom, 1)
    size, root = (right - left, bottom - top), (-left, -top)
    pose_cache = {}
    rendered = {}
    for name, frames in samples.items():
        rendered[name] = []
        for draws in frames:
            key = tuple(draws)
            if key not in pose_cache:
                pose_cache[key] = sampler.render(draws, size, root)
            rendered[name].append(pose_cache[key])
    body = [draw for draw in samples["idle"][0] if draw.slot_path[0] not in ("wq1", "wq12", "ef1", "mohu", "huaban")]
    body_image = sampler.render(body, size, root)
    body_bounds = body_image.getbbox()
    if not body_bounds:
        raise ValueError("Default idle body is empty")
    body_height = body_bounds[3] - body_bounds[1]
    maximum = profile["atlas_max_size"]
    columns, rows = maximum // size[0], maximum // size[1]
    if min(columns, rows) <= 0:
        raise ValueError("Common canvas exceeds atlas limit")
    # One manifest frame per tick, but exact equal pixels share a full-size cell.
    # Equality is verified as well as hashed; duplicate holds cost no texture RAM.
    unique, frame_indices, known = [], {}, {}
    for name, frames in rendered.items():
        frame_indices[name] = []
        for image in frames:
            data = image.tobytes()
            key = sha256(data).digest()
            if key in known:
                index = known[key]
                if unique[index].tobytes() != data:
                    raise ValueError("Unexpected pixel SHA-256 collision")
            else:
                index = len(unique)
                known[key] = index
                unique.append(image)
            frame_indices[name].append(index)
    capacity = rows * columns
    output.mkdir(parents=True, exist_ok=True)
    atlases = []
    for start in range(0, len(unique), capacity):
        count = min(capacity, len(unique) - start)
        page = Image.new("RGBA", (min(count, columns) * size[0], math.ceil(count / columns) * size[1]))
        for local, image in enumerate(unique[start:start + count]):
            page.paste(image, (local % columns * size[0], local // columns * size[1]))
        path = f"atlas-{len(atlases):03d}.png"
        page.save(output / path, optimize=False, compress_level=9)
        atlases.append({"path": path, "width": page.width, "height": page.height, "sha256": file_hash(output / path)})
    # Remove only our obsolete atlas pages after a successful new page bake.
    expected = {atlas["path"] for atlas in atlases}
    for old in output.glob("atlas-*.png"):
        if old.name not in expected:
            old.unlink()
    clips = {}
    for name, indices in frame_indices.items():
        animation = animations[name]
        frames = []
        for index in indices:
            cell = index % capacity
            frames.append({"atlas": index // capacity, "x": cell % columns * size[0], "y": cell // columns * size[1],
                           "width": size[0], "height": size[1], "duration_ticks": 1})
        clips[name] = {"duration_ticks": animation["duration"], "loop": animation.get("loop", 1) == 0, "frames": frames}
    validate_combat(profile["combat"], clips)
    ignored_events = sorted({frame["event"] for name in profile["clips"]
        for timeline in [sampler.animation(profile["armature"], name)] + sampler.animation(profile["armature"], name).get("timeline", [])
        for frame in timeline.get("frame", []) if frame.get("event")})
    manifest = {"schema_version": 1, "character_id": profile["character_id"], "appearance": profile["appearance"],
                "frame_rate": 30, "canvas_width": size[0], "canvas_height": size[1], "root_x": root[0], "root_y": root[1],
                "nominal_body_height": body_height, "source_hashes": hashes,
                "generator": {"version": GENERATOR_VERSION, "pillow_version": PIL.__version__,
                              "filler_normalization": profile["filler_normalization"], "normalized_pixel_count": sampler.normalized_pixels,
                              "input_sha256": fingerprint, "profile_sha256": inputs["profile"], "code_hashes": code_hashes,
                              "clock": "rational_source_ticks", "sampling": "held_keyframes",
                              "unique_cells": len(unique), "ignored_source_events": ignored_events},
                "atlases": atlases, "clips": clips, "combat": profile["combat"]}
    write_json(output / "character.json", manifest)
    if previews:
        write_previews(output / "previews", rendered, root)
    validate_generated(output)
    return manifest


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, help="Generated destination (default: assets/processed/wukong)")
    parser.add_argument("--force", action="store_true", help="Bake even if the validated fingerprint matches")
    parser.add_argument("--no-previews", action="store_true", help="Skip contact sheets and GIF review artifacts")
    parser.add_argument("--validate-only", action="store_true", help="Validate already generated manifest/pages")
    args = parser.parse_args()
    manifest = validate_generated(args.output or PROJECT_ROOT / "assets/processed/wukong") if args.validate_only else bake_character(
        output=args.output, force=args.force, previews=not args.no_previews)
    print(json.dumps({"clips": len(manifest["clips"]), "ticks": sum(c["duration_ticks"] for c in manifest["clips"].values()),
                      "canvas": [manifest["canvas_width"], manifest["canvas_height"]],
                      "root": [manifest["root_x"], manifest["root_y"]],
                      "unique_cells": manifest["generator"]["unique_cells"], "atlas_pages": len(manifest["atlases"])}))


if __name__ == "__main__":
    main()
