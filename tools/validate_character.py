#!/usr/bin/env python3
"""Validate the baked character boundary shared by build and packaging."""
import argparse
import hashlib
import json
import math
import re
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path, PurePosixPath

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
CHARACTER = ROOT / "assets/processed/wukong"
SOURCE = ROOT / "assets/zmxy4/animations/2001/manV535"
REQUIRED_CLIPS = ("idle", "walk", "runNormal", "jumpNormal", "jumpTwo", "jumpDown",
                  "jumpAttack", "hurtStand", "dead", "attack1", "attack2", "attack3", "attack4")
SOURCE_FILES = ("skeleton.json", "texture.json", "texture.png")


def require(condition, message):
    if not condition:
        raise ValueError(f"Character manifest: {message}")


def sha256(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def integer(value, name, minimum=0):
    require(type(value) is int and value >= minimum, f"{name} must be an integer >= {minimum}")
    return value


def number(value, name, minimum=0, positive=False):
    require(type(value) in (int, float) and math.isfinite(value)
            and (value > minimum if positive else value >= minimum), f"invalid {name}")
    return value


def object_value(value, name):
    require(isinstance(value, dict), f"{name} must be an object")
    return value


def hash_value(value, name):
    require(isinstance(value, str) and re.fullmatch(r"[0-9a-f]{64}", value), f"invalid {name} SHA-256")


def resource_path(directory, name):
    require(isinstance(name, str) and name and "\\" not in name, "invalid resource path")
    relative = PurePosixPath(name)
    require(not relative.is_absolute() and name == relative.as_posix()
            and all(part not in (".", "..") and ":" not in part for part in relative.parts),
            f"unsafe resource path: {name}")
    path = directory / name
    require(path.resolve().is_relative_to(directory.resolve()), f"resource escapes directory: {name}")
    require(not path.is_symlink() and path.is_file(), f"missing regular resource: {name}")
    return path


def validate_windows(windows, name, duration, count):
    require(isinstance(windows, list) and len(windows) == count,
            f"{name} must have {'two' if count == 2 else 'one'} hit windows")
    previous_end = 0
    for window in windows:
        object_value(window, f"{name} window")
        require(set(window) == {"start_tick", "end_tick"}, f"unsupported {name} window fields")
        start = integer(window.get("start_tick"), "start_tick")
        end = integer(window.get("end_tick"), "end_tick", 1)
        require(previous_end <= start < end <= duration, f"{name} overlapping or invalid hit window")
        previous_end = end


def validate_reach(value):
    reach = number(value, "range_multiplier", positive=True)
    require(0.25 <= reach <= 3, "range_multiplier outside supported native slash range")


def validate_combat(combat, clips):
    """One combat contract for the source profile and materialized manifest."""
    object_value(combat, "combat")
    require(number(combat.get("chain_grace_seconds"), "chain_grace_seconds", positive=True) <= 2,
            "chain_grace_seconds exceeds two seconds")
    stages = combat.get("stages")
    require(isinstance(stages, list) and len(stages) == 4, "exactly four combat stages required")
    for index, stage in enumerate(stages):
        object_value(stage, f"stage {index + 1}")
        require(set(stage) == {"clip", "buffer_open_tick", "range_multiplier", "hit_windows"},
                "unsupported stage fields; custom damage modifiers are not permitted")
        name = f"attack{index + 1}"
        require(stage.get("clip") == name, "combat stages must follow attack1 through attack4")
        duration = clips[name]["duration_ticks"]
        require(integer(stage.get("buffer_open_tick"), "buffer_open_tick") < duration,
                f"{name} buffer starts after stage")
        validate_reach(stage.get("range_multiplier"))
        validate_windows(stage.get("hit_windows"), name, duration, 2 if index == 2 else 1)

    air = object_value(combat.get("air_attack"), "air_attack")
    require(set(air) == {"clip", "hit_windows", "range_multiplier"},
            "unsupported air_attack fields; buffering and custom damage modifiers are not permitted")
    require(air.get("clip") == "jumpAttack", "air_attack must use jumpAttack")
    clip = object_value(clips.get("jumpAttack"), "jumpAttack")
    duration = integer(clip.get("duration_ticks"), "jumpAttack.duration_ticks", 1)
    require(clip.get("loop") is False, "jumpAttack must be nonlooping")
    validate_reach(air.get("range_multiplier"))
    validate_windows(air.get("hit_windows"), "jumpAttack", duration, 1)


@dataclass(frozen=True)
class ValidatedCharacter:
    directory: Path
    manifest: dict
    files: tuple
    frame_count: int


def validate_character(directory=CHARACTER, source_directory=None):
    directory = Path(directory)
    manifest_path = resource_path(directory, "character.json")
    manifest = object_value(json.loads(manifest_path.read_text(encoding="utf-8")), "root")
    require(type(manifest.get("schema_version")) is int and manifest["schema_version"] == 2,
            "unsupported schema_version")
    require(manifest.get("character_id") == "2001" and manifest.get("appearance") == "default_staff",
            "expected default staff Wukong (2001)")
    fps = integer(manifest.get("frame_rate"), "frame_rate", 1)
    require(fps == 30, "expected source frame_rate 30")
    width = integer(manifest.get("canvas_width"), "canvas_width", 1)
    height = integer(manifest.get("canvas_height"), "canvas_height", 1)
    require(width <= 2048 and height <= 2048, "canvas exceeds atlas size limit")
    require(number(manifest.get("root_x"), "root_x") <= width
            and number(manifest.get("root_y"), "root_y") <= height, "root outside canvas")
    require(number(manifest.get("nominal_body_height"), "nominal_body_height", positive=True)
            <= height, "nominal body exceeds canvas")
    sources = object_value(manifest.get("source_hashes"), "source_hashes")
    require(set(sources) == set(SOURCE_FILES), "incomplete source_hashes")
    for name in SOURCE_FILES:
        hash_value(sources[name], name)
        if source_directory is not None:
            require(sha256(resource_path(Path(source_directory), name)) == sources[name],
                    f"source hash mismatch: {name}")
    generator = object_value(manifest.get("generator"), "generator")
    require(type(generator.get("version")) is int and generator["version"] == 1,
            "unsupported generator version")
    require(generator.get("pillow_version") == "11.3.0", "unexpected Pillow version")
    require(generator.get("filler_normalization") == "exact_rgba_0_0_0_1",
            "unknown filler normalization")

    atlases = manifest.get("atlases")
    require(isinstance(atlases, list) and atlases, "atlases must be a nonempty array")
    paths, files, dimensions = set(), [manifest_path], []
    for index, atlas in enumerate(atlases):
        object_value(atlas, f"atlas {index}")
        name = atlas.get("path")
        path = resource_path(directory, name)
        require(path.suffix == ".png" and name.casefold() not in paths,
                f"duplicate or non-PNG atlas: {name}")
        paths.add(name.casefold())
        atlas_width = integer(atlas.get("width"), "atlas.width", 1)
        atlas_height = integer(atlas.get("height"), "atlas.height", 1)
        require(atlas_width <= 2048 and atlas_height <= 2048, "atlas exceeds 2048 pixel limit")
        hash_value(atlas.get("sha256"), name)
        require(sha256(path) == atlas["sha256"], f"atlas hash mismatch: {name}")
        with Image.open(path) as image:
            require(image.format == "PNG" and image.size == (atlas_width, atlas_height),
                    f"atlas dimensions mismatch: {name}")
            require(image.mode == "RGBA", f"atlas must contain RGBA transparency: {name}")
            image.verify()
        with Image.open(path) as image:
            image.load()
        files.append(path)
        dimensions.append((atlas_width, atlas_height))

    clips = object_value(manifest.get("clips"), "clips")
    require(set(REQUIRED_CLIPS) == set(clips), "required clips missing or unexpected clip listed")
    used_atlases, frame_count = set(), 0
    for name, clip in clips.items():
        object_value(clip, f"clip {name}")
        duration = integer(clip.get("duration_ticks"), f"{name}.duration_ticks", 1)
        require(type(clip.get("loop")) is bool, f"{name}.loop must be boolean")
        frames = clip.get("frames")
        require(isinstance(frames, list) and frames, f"{name} has no frames")
        total = 0
        for frame in frames:
            object_value(frame, f"{name} frame")
            atlas_index = integer(frame.get("atlas"), "frame.atlas")
            require(atlas_index < len(atlases), f"{name} references missing atlas")
            used_atlases.add(atlas_index)
            x = integer(frame.get("x"), "frame.x")
            y = integer(frame.get("y"), "frame.y")
            require(integer(frame.get("width"), "frame.width", 1) == width
                    and integer(frame.get("height"), "frame.height", 1) == height,
                    f"{name} frame differs from shared canvas")
            require(x + width <= dimensions[atlas_index][0] and y + height <= dimensions[atlas_index][1],
                    f"{name} frame outside atlas")
            ticks = integer(frame.get("duration_ticks"), "frame.duration_ticks", 1)
            require(ticks == 1, "character schema requires one record per source tick")
            total += ticks
        require(total == duration, f"{name} frame tick total differs from duration")
        frame_count += len(frames)
    require(used_atlases == set(range(len(atlases))), "unreferenced atlas listed")

    validate_combat(manifest.get("combat"), clips)
    return ValidatedCharacter(directory, manifest, tuple(files), frame_count)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--character-dir", type=Path, default=CHARACTER)
    parser.add_argument("--update-development-manifest", action="store_true")
    args = parser.parse_args()
    validated = validate_character(args.character_dir, SOURCE)
    counts = {"clips": len(validated.manifest["clips"]), "frames": validated.frame_count,
              "atlases": len(validated.manifest["atlases"])}
    report = {"schema_version": 1, "status": "passed",
              "verified_at_utc": datetime.now(timezone.utc).isoformat(),
              "manifest_sha256": sha256(args.character_dir / "character.json"),
              "source_hashes_verified": True, "atlas_hashes_and_dimensions_verified": True,
              "frame_bounds_and_ticks_verified": True, "combat_windows_verified": True,
              "counts": counts, "runtime_tested": False}
    report_path = ROOT / "artifacts/character-validation.json"
    report_path.parent.mkdir(parents=True, exist_ok=True)
    report_path.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    if args.update_development_manifest:
        path = ROOT / "data/generated/development-manifest.json"
        development = json.loads(path.read_text(encoding="utf-8"))
        development.update({"animation_baked": True, "character_assets_verified": True,
                            "baked_character": counts, "runtime_tested": False})
        path.write_text(json.dumps(development, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()
