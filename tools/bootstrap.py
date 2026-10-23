#!/usr/bin/env python3
"""Install the pinned Linux build tools locally; never modify the game."""
import hashlib
import json
import platform
import shutil
import subprocess
import sys
import tarfile
import urllib.request
import venv
import zipfile
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TOOLS = ROOT / ".tools"
LOCK = json.loads((ROOT / "toolchain.lock.json").read_text())


def download(spec, algorithm):
    cache = TOOLS / "downloads"
    cache.mkdir(parents=True, exist_ok=True)
    target = cache / spec["url"].rsplit("/", 1)[-1]
    if not target.exists():
        print(f"Downloading {target.name}", flush=True)
        part = target.with_suffix(target.suffix + ".part")
        request = urllib.request.Request(spec["url"], headers={"User-Agent": "WukongKnight-dev-setup"})
        with urllib.request.urlopen(request, timeout=120) as source, part.open("wb") as dest:
            shutil.copyfileobj(source, dest)
        part.replace(target)
    digest = hashlib.new(algorithm)
    with target.open("rb") as source:
        for chunk in iter(lambda: source.read(1024 * 1024), b""):
            digest.update(chunk)
    if digest.hexdigest() != spec[algorithm]:
        raise ValueError(f"Hash mismatch: {target}. Remove it and retry.")
    print(f"Verified {algorithm}: {target.name}", flush=True)
    return target


def setup_sdk():
    spec = LOCK["sdk"]
    dest = TOOLS / "dotnet"
    marker = dest / ".wukong-toolchain.json"
    if marker.exists() and json.loads(marker.read_text()) == spec:
        return
    archive = download(spec, "sha512")
    dest.mkdir(parents=True, exist_ok=True)
    with tarfile.open(archive) as source:
        source.extractall(dest, filter="data")
    marker.write_text(json.dumps(spec, indent=2) + "\n")


def setup_api():
    spec = LOCK["api"]
    dest = TOOLS / "hollow-knight-api-v77"
    marker = dest / ".wukong-toolchain.json"
    if marker.exists() and json.loads(marker.read_text()) == spec:
        return
    archive = download(spec, "sha256")
    dest.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(archive) as source:
        for item in source.infolist():
            if not (dest / item.filename).resolve().is_relative_to(dest.resolve()):
                raise ValueError("Unsafe API archive path")
        source.extractall(dest)
    marker.write_text(json.dumps(spec, indent=2) + "\n")


def setup_unity_reference():
    """Prepare compiler inputs, never files for redistribution."""
    spec = LOCK["unity_reference"]
    dest = TOOLS / "unity-reference"
    marker = dest / ".wukong-toolchain.json"
    required = ("UnityEngine.dll", "UnityEngine.CoreModule.dll",
                "UnityEngine.ImageConversionModule.dll", "UnityEngine.Physics2DModule.dll")
    if (marker.exists() and json.loads(marker.read_text()) == spec
            and all((dest / "lib/net45" / name).is_file() for name in required)):
        return
    archive = download(spec, "sha256")
    dest.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(archive) as source:
        for item in source.infolist():
            target = (dest / item.filename).resolve()
            if not target.is_relative_to(dest.resolve()) or "\\" in item.filename:
                raise ValueError("Unsafe Unity reference archive path")
            # Only engine compiler references from the one selected target framework.
            if (item.filename.startswith("lib/net45/UnityEngine")
                    and item.filename.endswith(".dll")
                    and Path(item.filename).parent.as_posix() == "lib/net45"):
                target.parent.mkdir(parents=True, exist_ok=True)
                with source.open(item) as src, target.open("wb") as dst:
                    shutil.copyfileobj(src, dst)
    if not all((dest / "lib/net45" / name).is_file() for name in required):
        raise ValueError("Unity reference archive lacks required net45 modules")
    marker.write_text(json.dumps(spec, indent=2) + "\n")


def setup_image_environment():
    if not (3, 12) <= sys.version_info[:2] <= (3, 14):
        raise ValueError("The image tool lock supports CPython 3.12-3.14 on Linux x64")
    requirements = ROOT / "tools/requirements-image.txt"
    dest = TOOLS / "python"
    python = dest / "bin/python"
    marker = dest / ".wukong-requirements.sha256"
    expected = hashlib.sha256(requirements.read_bytes()).hexdigest()
    if python.is_file() and marker.is_file() and marker.read_text().strip() == expected:
        check = subprocess.run([str(python), "-c", "import PIL; assert PIL.__version__ == '11.3.0'"],
                               capture_output=True)
        if check.returncode == 0:
            return
    if not python.is_file():
        venv.EnvBuilder(with_pip=True).create(dest)
    subprocess.run([str(python), "-m", "pip", "install", "--disable-pip-version-check",
                    "--require-hashes", "--only-binary=:all:", "--no-deps",
                    "-r", str(requirements)], cwd=ROOT, check=True)
    marker.write_text(expected + "\n")


def main():
    if platform.system() != "Linux" or platform.machine() not in ("x86_64", "AMD64"):
        raise SystemExit("This bootstrap currently pins linux-x64. See README for manual setup.")
    with ThreadPoolExecutor(max_workers=4) as pool:
        jobs = [pool.submit(setup_sdk), pool.submit(setup_api),
                pool.submit(setup_unity_reference), pool.submit(setup_image_environment)]
        for job in jobs:
            job.result()
    subprocess.run([str(TOOLS / "dotnet/dotnet"), "--version"], cwd=ROOT, check=True)
    print("Local SDK, API/Unity compiler references and pinned image environment ready.")
    print("No game files were changed; engine/API compiler references must not be packaged.")


if __name__ == "__main__":
    main()
