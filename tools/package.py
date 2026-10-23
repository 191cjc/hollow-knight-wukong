#!/usr/bin/env python3
"""Stage only the Mod DLL, instructions and validated runtime character resources."""
import argparse
import json
import shutil
import tempfile
import zipfile
from pathlib import Path

from validate_character import CHARACTER, ROOT, sha256, validate_character

VERSION = "0.3.0-dev"
README = f"""Wukong Knight {VERSION}
Baseline: Hollow Knight 1.5.78.11833 / Modding API v77.
Includes default staff Wukong visuals, a grounded four-stage horizontal attack chain,
and one airborne horizontal staff strike with an authored native hit window.
Up/down and wall attacks retain native mechanics, including down-slash bouncing.
This is a development build. Actual game loading, rendering, combat and compatibility
have NOT been tested in a game client. Compile/reference validation is not client acceptance.

Character schema 2 requires the matching {VERSION} DLL and resources; replace the full directory.
Install the matching Modding API first, then copy this entire WukongKnight directory into
the client's hollow_knight_Data/Managed/Mods/ directory. Keep character/ beside the DLL.
Do not copy SDK, API or Unity reference assemblies from the development project.
Check ModLog.txt for WukongKnight attachment/resource errors after entering a save.

Try one press and then four successive grounded horizontal attack presses; check the
third stage's two damage windows, nail/charm damage, soul gain and breakable objects.
Try airborne horizontal presses while rising and falling; repeated active presses must not
queue a combo, and another strike must respect native cooldown. Check landing, double jump,
directional slashes, down-slash bounce, jump/dash/hit cancellation, facing, movement,
scene changes, death/respawn, save re-entry and disabling the Mod.
Remove/disable WukongKnight to restore the native character. See docs/CLIENT_ACCEPTANCE.md
in the source project for the full pending client checklist.

Processed character graphics derive from archived 4399 ZMXY4 Wukong assets.
Sources and processing rules are recorded in the source project. No game/API/engine DLLs
or raw source archives are included. This local development package is not a public release.
"""


def validate_package(stage):
    """Reject leftover files as well as missing manifest dependencies."""
    stage = Path(stage)
    character = validate_character(stage / "character")
    expected = {"WukongKnight.dll", "README.txt"}
    expected.update("character/" + path.relative_to(character.directory).as_posix()
                    for path in character.files)
    entries = list(stage.rglob("*"))
    if any(path.is_symlink() for path in entries):
        raise ValueError("Package must not contain symbolic links")
    actual = {path.relative_to(stage).as_posix() for path in entries if path.is_file()}
    if actual != expected:
        raise ValueError(f"Package closure mismatch: missing={sorted(expected - actual)}, "
                         f"unexpected={sorted(actual - expected)}")
    if not (stage / "WukongKnight.dll").read_bytes().startswith(b"MZ"):
        raise ValueError("Expected a Windows/.NET PE Mod DLL")
    return sorted(expected)


def stage_package(dll, character_directory, stage):
    dll, stage = Path(dll), Path(stage)
    validated = validate_character(character_directory)
    if not dll.is_file() or not dll.read_bytes().startswith(b"MZ"):
        raise ValueError(f"Missing or invalid built Mod DLL: {dll}")
    stage.parent.mkdir(parents=True, exist_ok=True)
    # Prepare and validate before replacing a previous usable development package.
    with tempfile.TemporaryDirectory(prefix=".wukong-package-", dir=stage.parent) as temporary:
        pending = Path(temporary) / "WukongKnight"
        pending.mkdir()
        shutil.copy2(dll, pending / "WukongKnight.dll")
        (pending / "README.txt").write_text(README, encoding="utf-8")
        for path in validated.files:
            target = pending / "character" / path.relative_to(validated.directory)
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(path, target)
        validate_package(pending)
        if stage.exists():
            shutil.rmtree(stage)
        pending.replace(stage)
    return validate_package(stage)


def write_archive(stage, archive):
    stage, archive = Path(stage), Path(archive)
    files = validate_package(stage)
    with zipfile.ZipFile(archive, "w", zipfile.ZIP_DEFLATED, compresslevel=9) as target:
        for name in files:
            # Stable timestamps and permissions make unchanged packages reproducible.
            item = zipfile.ZipInfo("WukongKnight/" + name, date_time=(1980, 1, 1, 0, 0, 0))
            item.compress_type = zipfile.ZIP_DEFLATED
            item.external_attr = 0o100644 << 16
            target.writestr(item, (stage / name).read_bytes(), compresslevel=9)
    with zipfile.ZipFile(archive) as source:
        expected = ["WukongKnight/" + name for name in files]
        if source.namelist() != expected or source.testzip() is not None:
            raise ValueError("ZIP member/CRC validation failed")
        for name in files:
            if source.read("WukongKnight/" + name) != (stage / name).read_bytes():
                raise ValueError(f"ZIP byte mismatch: {name}")
    return files


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--checks-passed", action="store_true",
                        help="build.sh sets this only after source, Python/core tests and Release build succeed")
    args = parser.parse_args()
    output = ROOT / "artifacts"
    stage = output / "mod/WukongKnight"
    dll = ROOT / "src/WukongKnight/bin/Release/net472/WukongKnight.dll"
    stage_package(dll, CHARACTER, stage)
    archive = output / f"WukongKnight-{VERSION}.zip"
    files = write_archive(stage, archive)
    report = {
        "schema_version": 2, "version": VERSION,
        "package": archive.relative_to(ROOT).as_posix(), "sha256": sha256(archive),
        "dll": dll.relative_to(ROOT).as_posix(), "dll_bytes": dll.stat().st_size,
        "dll_sha256": sha256(dll),
        "implemented": {"character_replacement": True, "grounded_four_stage_combo": True,
                        "single_air_horizontal_attack": True, "active_skills": False},
        "built": args.checks_passed,
        "automatically_verified": {"source_inventory": args.checks_passed,
                                   "character_manifest_and_atlases": True,
                                   "python_tests": args.checks_passed,
                                   "combo_core_tests": args.checks_passed,
                                   "release_build": args.checks_passed,
                                   "package_closure_and_zip_bytes": True},
        "runtime_tested": False, "client_acceptance": "pending",
        "files": [{"path": name, "bytes": (stage / name).stat().st_size,
                   "sha256": sha256(stage / name)} for name in files],
    }
    (output / "build-report.json").write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()
