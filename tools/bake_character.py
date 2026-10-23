"""Bake the archived default staff Wukong into deterministic runtime atlases.

Run with .tools/python/bin/python tools/bake_character.py. Source files remain
read-only. The profile owns transplant timings; source animation events are not
executed or interpreted as combat windows.
"""
import argparse
from hashlib import sha256
import json
import math
from pathlib import Path

import PIL
from PIL import Image, ImageDraw

from legacy_dragonbones import Sampler
from validate_character import REQUIRED_CLIPS, sha256 as file_hash, validate_character, validate_combat


PROJECT_ROOT = Path(__file__).resolve().parent.parent
GENERATOR_VERSION = 1


def read_json(path):
    return json.loads(path.read_text(encoding="utf-8"))


def write_json(path, data):
    path.write_text(json.dumps(data, indent=2, sort_keys=True, ensure_ascii=False) + "\n", encoding="utf-8")


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


def bake_character(project_root=PROJECT_ROOT, output=None, force=False, previews=True):
    project_root = Path(project_root)
    profile_path = project_root / "data/character/wukong-staff.json"
    profile = read_json(profile_path)
    if (profile["profile_version"] != 1 or profile["filler_normalization"] != "exact_rgba_0_0_0_1"
            or tuple(profile["clips"]) != REQUIRED_CLIPS):
        raise ValueError("Unsupported bake profile")
    source = project_root / profile["source_directory"]
    output = Path(output) if output is not None else project_root / "assets/processed/wukong"
    hashes = {name: file_hash(source / name) for name in ("skeleton.json", "texture.json", "texture.png")}
    code_hashes = {name: file_hash(Path(__file__).parent / name) for name in ("bake_character.py", "legacy_dragonbones.py", "validate_character.py")}
    inputs = {"sources": hashes, "profile": file_hash(profile_path), "code": code_hashes, "pillow": PIL.__version__}
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
    bounds = [sampler.bounds(draws) for frames in samples.values() for draws in frames]
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
        animation = sampler.animation(profile["armature"], name)
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
    manifest = {"schema_version": 2, "character_id": profile["character_id"], "appearance": profile["appearance"],
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
