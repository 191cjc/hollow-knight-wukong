#!/usr/bin/env python3
"""Validate archived inputs and generate development catalogues. No game execution."""
import hashlib
import json
import shutil
import struct
import subprocess
import tempfile
import xml.etree.ElementTree as ET
import zlib
from datetime import datetime, timezone
from pathlib import Path

from unpack_animation import unpack

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "data/source"
GENERATED = ROOT / "data/generated"


def load(path):
    return json.loads(path.read_text(encoding="utf-8"))


def write_json(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def require(condition, message):
    if not condition:
        raise ValueError(message)


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def relative(path):
    return path.relative_to(ROOT).as_posix()


def png_info(path):
    raw = path.read_bytes()
    require(raw[:8] == b"\x89PNG\r\n\x1a\n", f"PNG signature: {path}")
    offset, compressed, dimensions, ended = 8, bytearray(), None, False
    while offset < len(raw):
        size = struct.unpack_from(">I", raw, offset)[0]
        kind = raw[offset + 4:offset + 8]
        data = raw[offset + 8:offset + 8 + size]
        crc = struct.unpack_from(">I", raw, offset + 8 + size)[0]
        require(zlib.crc32(kind + data) & 0xffffffff == crc, f"PNG CRC: {path}")
        if kind == b"IHDR":
            dimensions = list(struct.unpack_from(">II", data))
        if kind == b"IDAT":
            compressed.extend(data)
        offset += size + 12
        if kind == b"IEND":
            ended = True
            break
    require(ended and offset == len(raw) and dimensions, f"PNG structure: {path}")
    require(bool(zlib.decompress(compressed)), f"PNG empty IDAT: {path}")
    return dimensions


def records(name):
    result = []
    for record in ET.parse(SOURCE / name).getroot():
        result.append({node.tag: node.text or "" for node in record})
    ids = [item["id"] for item in result]
    require(len(ids) == len(set(ids)), f"Duplicate IDs in {name}")
    return result


def main():
    downloads = load(SOURCE / "manifests/downloads.json")
    expected = load(SOURCE / "manifests/validation.json")
    for entry in downloads:
        path = ROOT / "assets/zmxy4/raw" / entry["path"]
        require(path.stat().st_size == entry["size"] and digest(path) == entry["sha256"], f"Source hash: {path}")
    require(len(downloads) == expected["source_files"], "Source file count changed")
    raw_files = list((ROOT / "assets/zmxy4/raw").rglob("*"))
    require(sum(p.is_file() for p in raw_files) == len(downloads), "Unlisted raw files")
    provenance = load(ROOT / "reference/flash/provenance.json")
    for entry in provenance:
        path = ROOT / "reference/flash" / entry["path"]
        require(path.stat().st_size == entry["size"] and digest(path) == entry["sha256"], f"Reference hash: {path}")

    animation_root = ROOT / "assets/zmxy4/animations"
    catalogue = []
    for previous in load(SOURCE / "manifests/animations.json"):
        source_relative = Path(previous["path"]).relative_to("exported/animations")
        skeleton = animation_root / source_relative
        data = load(skeleton)
        source_bundle = ROOT / "assets/zmxy4/raw/assets/man" / source_relative.parent.with_suffix(".swf")
        # Re-extract to a temporary location and compare all outputs with the archive.
        with tempfile.TemporaryDirectory(prefix="wukong-animation-") as tmp:
            output = Path(tmp)
            extracted = unpack(source_bundle, output)
            require(len(extracted) == 3, f"Unexpected bundle contents: {source_bundle}")
            for item in extracted:
                require((output / item["name"]).read_bytes() == (skeleton.parent / item["name"]).read_bytes(), f"Extracted mismatch: {skeleton.parent}")
        armatures = [{"name": a["name"], "animations": [
            {"name": str(x["name"]), "duration_frames": x["duration"]}
            for x in a.get("animation", [])]} for a in data["armature"]]
        require(data["frameRate"] == previous["frameRate"], f"Frame rate changed: {skeleton}")
        catalogue.append({"bundle": relative(source_bundle), "skeleton": relative(skeleton),
                          "files": [relative(skeleton.parent / item["name"]) for item in extracted],
                          "dragonbones_version": str(data["version"]), "frame_rate": data["frameRate"],
                          "armatures": armatures})
    require(len(catalogue) == expected["animation_bundles"], "Animation count changed")

    asset_root = ROOT / "assets/zmxy4"
    pngs = {relative(p): png_info(p) for p in sorted(asset_root.rglob("*.png"))}
    require(len(pngs) == expected["png_files"], "PNG count changed")
    for path in animation_root.rglob("*.json"):
        load(path)
    audio_catalogue = []
    decoder = shutil.which("ffmpeg")
    probe = shutil.which("ffprobe")
    for entry in load(SOURCE / "manifests/audio.json"):
        path = ROOT / "assets/zmxy4" / entry["path"]
        require(path.is_file() and path.stat().st_size > 0, f"Missing audio: {path}")
        metadata = {"symbol": entry["symbol"], "path": relative(path)}
        if decoder and probe:
            subprocess.run([decoder, "-v", "error", "-xerror", "-i", str(path), "-f", "null", "-"], check=True, capture_output=True)
            info = json.loads(subprocess.check_output([probe, "-v", "error", "-show_entries", "stream=codec_name,sample_rate,channels:format=duration", "-of", "json", str(path)]))
            metadata["probe"] = info
        audio_catalogue.append(metadata)
    require(len(audio_catalogue) == expected["mp3_files"], "Audio count changed")

    skills = records("skills.xml")
    buffs = records("buffs.xml")
    roles = records("roles.xml")
    for name in ("resources.xml", "awakenings.xml"):
        ET.parse(SOURCE / name)
    require(len(skills) == expected["skills"] and len(buffs) == 222, "Source configuration count changed")
    by_id = {skill["id"]: skill for skill in skills}
    base_skills = []
    for role in roles:
        for index in range(1, 6):
            action = f"effect{index}"
            skill_id = role.get(action)
            if skill_id and skill_id != "0":
                require(skill_id in by_id, f"Missing role skill {skill_id}")
                base_skills.append({"role_id": role["id"], "source_action": action,
                                    "skill_id": skill_id, "name": by_id[skill_id]["name"],
                                    "implementation": "not_started"})

    inventory = []
    for base in (ROOT / "assets/zmxy4", SOURCE, ROOT / "reference/flash"):
        for path in sorted(base.rglob("*")):
            if path.is_file():
                inventory.append({"path": relative(path), "size": path.stat().st_size, "sha256": digest(path)})
    summary = {"source_files": len(downloads), "animation_bundles": len(catalogue),
               "png_files": len(pngs), "mp3_files": len(audio_catalogue), "skill_records": len(skills),
               "buff_records": len(buffs), "role_ids": [r["id"] for r in roles],
               "catalogue_scope": "archived_source_files", "runtime_tested": False}
    write_json(GENERATED / "development-manifest.json", summary)
    write_json(GENERATED / "skills.json", {"schema_version": 1, "note": "Raw source strings; units and timing semantics are not normalized.", "records": skills, "base_skills": base_skills})
    write_json(GENERATED / "animations.json", catalogue)
    write_json(GENERATED / "audio.json", audio_catalogue)
    write_json(GENERATED / "inventory.json", inventory)
    report = {"verified_at_utc": datetime.now(timezone.utc).isoformat(), "status": "passed",
              "checks": {"source_sha256": True, "reference_sha256": True,
                         "animation_reextract_matches": True, "png_crc_and_idat": True,
                         "audio_full_decode": bool(decoder and probe), "xml_parse": True},
              "counts": summary, "png_dimensions": pngs}
    write_json(ROOT / "artifacts/validation.json", report)

    lines = ["# 素材索引", "", "由 `python3 tools/prepare_assets.py` 从实际文件生成。此处记录原始骨骼；默认棍系外观的烘焙与预览见 [动画处理说明](CHARACTER_ASSETS.md)。动作名称不直接等于命中判定。", "",
             "## 动画包", "", "| 角色 / 包 | 格式 / FPS | 骨架数 |", "|---|---|---|"]
    for item in catalogue:
        name = Path(item["skeleton"]).parent.relative_to("assets/zmxy4/animations").as_posix()
        lines.append(f"| [{name}](../{item['skeleton']}) | DragonBones {item['dragonbones_version']} / {item['frame_rate']} | {len(item['armatures'])} |")
    lines += ["", "## 主角色动作", ""]
    for item in catalogue:
        for armature in item["armatures"]:
            if armature["name"] == "res":
                lines += [f"- `{Path(item['skeleton']).parent}`：" + "、".join(f"`{a['name']}` ({a['duration_frames']} 帧)" for a in armature["animations"])]
    lines += ["", "## 角色配置指向的技能", "", "以下仅记录原游戏角色配置中的动作标签与技能 ID；空洞骑士中的实现均未开始。", "",
              "| 角色 ID | 动作 | 技能 ID | 名称 |", "|---|---|---|---|"]
    lines += [f"| {s['role_id']} | {s['source_action']} | {s['skill_id']} | {s['name']} |" for s in base_skills]
    lines += ["", "## 可检索数据", "", "- `data/generated/animations.json`：全部骨架与动作名。",
              "- `data/generated/skills.json`：97 条原始技能配置字符串及角色基础技能索引。",
              "- `data/generated/audio.json`：14 段音效及音频探测结果。",
              "- `data/generated/inventory.json`：归档输入和解包结果的大小、SHA-256。",
              "- `data/source/manifests/`：原素材包清单，路径仍按旧归档记录；上面的生成清单使用当前项目路径。", ""]
    (ROOT / "docs/ASSET_INDEX.md").write_text("\n".join(lines), encoding="utf-8")
    print(json.dumps({"validation": "passed", "audio_full_decode": bool(decoder and probe), **summary}, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
