#!/usr/bin/env python3
"""Stage only the Mod DLL, instructions and validated runtime character resources."""
import argparse
import json
import shutil
import tempfile
import zipfile
from pathlib import Path

from validate_character import CHARACTER, ROOT, sha256, validate_character

VERSION = "0.7.8-dev"
_VARIANT = json.loads((ROOT / "data/character/active-variant.json").read_text(encoding="utf-8"))
ACTIVE_CHARACTER = ROOT / _VARIANT.get("runtime_directory", _VARIANT["output_directory"])
README = f"""Wukong Knight {VERSION}
Baseline: Hollow Knight 1.5.78.11833 / Modding API v77.
Includes default staff Wukong visuals and a grounded four-stage horizontal attack chain.
Wukong artwork is resized offline to 1.5x baseline; no runtime appearance multiplier.
Original project assets are preserved. Native hero collision is unchanged.
Ground/air attacks use their original Wukong staff arcs. Up nail uses the original
rising-strike body/arc; down nail rotates only that arc 180 degrees around the hero center.
Native nail meshes are visually suppressed; damage, reach, charms, Soul and pogo stay native.
Only the independent Wukong arc layer follows the selected native slash scale.
Longnail/Mark of Pride/both give native 1.15x/1.25x/1.4x; body remains offline1.5x.
Arc and body share the same original animation tick and character-center attachment.
The native dash key now plays Wukong's original Flame Dash pose/flame artwork.
Dashmaster becomes Flame Dash: Awakening (烈焰闪·觉醒), retaining its original2notches,
icon, collectible, dash cooldown/downward dash and charm bonuses. In midair hold
only Up and press dash to rise. It shares native aerial dash allowance and permits
one upward use before a real landing; pogo/wall contact/charm toggles do not refill it.
Native normal/Sharp Shadow speed, clock, cooldown, unlocks and collision remain.
Only directional flames rotate offline; the body stays upright. Normal completion
removes only proven owned upward momentum, before native dash-end callbacks.
Each responder along the actual dash path can take one nail-level dash hit.
All incoming HP damage is blocked for the actual active Flame Dash, horizontally,
upward or downward, and protection releases immediately on end/cancel. No saved invincibility
flag is changed. The old Sharp Shadow damage source is temporarily suspended to
prevent duplicate damage. No extra MP cost is added.
Real death uses original Wukong dead:65 source ticks at30 FPS, falling/prone body
and the original ghost at ticks8..31. The matching official bundle was freshly
downloaded/verified; current original/offline1.5x death pixels remain exact.
Native mesh disable/alpha no longer hides the Wukong death animation. Native
Knight shell/debris visuals are suppressed with restoration; death/save/Geo/shade,
dream returns and respawn processing continue through the original iterator.
Air/up/down attacks retain native mechanics, including down-slash bouncing.
Down + Dream Nail summons one independent Afterimage Combo (残影连打) attacker,
consuming native MP Cost once. The player remains free to move/jump/attack/cast.
The clone performs the original71-tick route/hits and leaves four10-second afterimages.
Afterimages mimic Earthbreaker and Godslayer at reduced damage, without dream effects.
Dream Nail is Godslayer Strike (灭神一击): hold to charge, release to punch.
Full charge is source frame39 (1.267s; Dream Wielder 0.633s), releasing a traveling wave.
Only the player's full wave carries the actual native Dream Nail trigger, retaining
thoughts/Soul/dream scenery interactions. Partial punches and clones only damage.
Down + spell casts Earthbreaker Fist (辟地拳); upward launch on ground, then
terrain-limited slam, or direct slam in air. Up + Dream Nail casts Fire Ape Assault
(火猿出击), with original independent back/front fire-ape artwork and local masks.
Fist attacks retain nail-upgrade damage; Dream-key skills require Dream Nail unlock
and have recovery/cooldowns. Godslayer/Earthbreaker ignore Strength and latch direction
at press; moving-awakening Fire Ape follows current position/facing.
Down/up Dream actions spend current native MP Cost once (33; Spell Twister24);
insufficient Soul prevents casting and ghosts cost no extra Soul. Neutral Dream
remains free. Maximum-held Godslayer automatically releases at source frame60
(1.967s, or0.983s with Dream Wielder); earlier full damage begins at frame39.
The last two persistent ghosts use held source punch/kick poses, preserving shape.
After copying Godslayer/Earthbreaker once, each ghost disappears at action end;
unused ghosts retain their10-second lifetime. Earthbreaker falls1.5x faster.
Fist hits now use original Quake-slam horizontal recoil strength2, with body hits
pushing away from the cast root and waves along travel. Native enemy resistance
still applies; damage and Soul costs remain unchanged.
Earthbreaker blocks incoming HP damage for its owned launch/fall/landing action.
Successful Fire Demon/Earthbreaker recovery also calls native QuakeInvuln once:
the original down-spell0.4s protection against ordinary enemy damage. Native expiry
and hazard rules apply. Canceled casts/unlanded timeouts/copies grant no recovery timer.
Fire Ape uses moving-awakening back/front effects following the free player's
position/facing. No punching-body override or forced travel. Prior armor is removed;
incoming HP damage/recoil/hit pause remain native. Death/hazards/scenes clear actors.
These two directional Dream-key actions replace native Dream Gate shortcuts.
New raw/baked/1.5x originals are retained separately. Runtime atlases crop only
transparent margins and preserve per-frame root registration; no extra rescaling.
Up + spell casts Fire Demon Slash with original relative air/finisher regions.
Damage is fixed by spell tier, independent of nail upgrades: 2 x up to 11 + 14,
or upgraded 3 x up to 11 + 22. Shaman Stone gives 3 x 11 + 21 / 5 x 11 + 33.
Air contacts have a 100ms per-target cooldown; the finisher hits each target once
and pushes horizontally away with native down-slam recoil strength2.
Native enemy hit evasion remains authoritative, so actual hits may be fewer.
Native Scream damage/visuals are suppressed; native up-spell unlock/tier and recovery remain.
Each replacement spell charges native MP Cost once (normally 33; Spell Twister 24).
Original effect5 character flashes keep their movement and genuinely invisible frames.
Air effect spawns at original +177 facing/+95 upward source pixels; original mask
centers/dimensions use baseline pixel/world conversion independently of artwork size.
The original skill moves forward5 source pixels/tick from tick5 through tick36,
up to155 source pixels, limited by the native body terrain sweep. Movement inputs
cannot steer it. The final effect/damage use the resulting moved position.
At body tick 36 the air effect expires and the 20-tick finisher begins, even in midair.
There is no forced dive or ground-contact requirement. All custom skills reject enemy sensors
and weapon children as enemy hurtboxes. No inherited Quake start/landing shake is added.
Hero damage guards remain active throughout preparation, air and finisher; they release
on completion/cancel/detach without changing save invincibility.
Neutral quick spell casts Flame Storm, using the original 16-tick spinning body and flames.
Original local contact mask; per-target cap five, 100ms contact interval, native evasion.
Damage per contact is 7/11 by down-spell tier, or 11/17 with Shaman Stone.
Hold spell/focus to perform Jiyuan Fire Eye (汲元火眼) using native focus charge/Soul timing.
The original casting effect4 flames wind upward around the body, followed by
the original nested eye flashes. Both source layers run at the original30 FPS
in the final0.7 seconds before the actual native focus completion. Earlier charge
holds only the opening body pose, without casting flames. Shorter native charges
use the source tail without slowing it. Completion/interruption removes the cast
immediately. Native focus timing,
Soul costs and buff activation remain authoritative.
Completion activates a three-second buff with NO immediate healing.
Jiyuan Fire Eye: Awakening (汲元火眼·觉醒) replaces native Deep Focus, preserving charm34 acquisition
and saved ownership/equipment. It costs2notches and grants6seconds total when
equipped at completion. The former Deep Focus healing/charge tradeoff is removed;
other focus charms retain their native timing. Its generated icon is embedded in the DLL. Real player attack
HP damage heals one HP, globally at most once per second; whiffs/blocked hits do not.
The original independent red flame ef animation loops while the buff is active,
following the hero root/facing. Original registration and offline1.5x art are retained.
Refreshing the buff does not stack it or reset its healing cooldown.
Death, scene transition and disabling the Mod clear the buff.
This is a development build. Actual game loading, rendering, combat and compatibility
have NOT been tested in a game client. Compile/reference validation is not client acceptance.

Install the matching Modding API first, then copy this entire WukongKnight directory into
the client's hollow_knight_Data/Managed/Mods/ directory. Keep character/ beside the DLL.
Do not copy SDK, API or Unity reference assemblies from the development project.
Check ModLog.txt for WukongKnight attachment/resource errors after entering a save.

Try one press and then four successive grounded horizontal attack presses; check the
third stage's two damage windows, nail/charm damage, soul gain and breakable objects.
Check facing, movement, jumping, directional/air slashes, down-slash bounce, jump/dash/hit
cancellation, scene changes, death/respawn, save re-entry and disabling the Mod.
Remove/disable WukongKnight to restore the native character. See docs/CLIENT_ACCEPTANCE.md
in the source project for the full pending client checklist.

Processed character graphics derive from archived 4399 ZMXY4 Wukong assets.
Sources and processing rules are recorded in the source project. No game/API/engine DLLs
or raw source archives are included. This local development package is not a public release.
Diagnostic build: a read-only enemy FSM recorder writes plain text into the
fsm-dump folder beside this DLL (enemy state machines, scene FSM indexes, state and
hit traces). It never changes enemies. Send that folder; delete it any time.
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
    stage_package(dll, ACTIVE_CHARACTER, stage)
    archive = output / f"WukongKnight-{VERSION}.zip"
    files = write_archive(stage, archive)
    report = {
        "schema_version": 2, "version": VERSION,
        "package": archive.relative_to(ROOT).as_posix(), "sha256": sha256(archive),
        "dll": dll.relative_to(ROOT).as_posix(), "dll_bytes": dll.stat().st_size,
        "dll_sha256": sha256(dll),
        "implemented": {"character_replacement": True, "grounded_four_stage_combo": True,
                        "active_skills": True, "flame_dash": True, "upward_flame_dash": True, "awakening_charms": True, "fire_demon_slash": True, "flame_storm": True, "bloodthirsty_fire_eye": True, "afterimage_combo": True, "godslayer_strike": True, "earthbreaker_fist": True, "fire_ape_assault": True, "other_active_skills": False},
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
