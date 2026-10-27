#!/usr/bin/env python3
"""Prepare a generated white-matte charm as a separate transparent UI asset."""
import argparse
from collections import deque
import hashlib
import json
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]


def digest(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def extract_icon(source, size=256, padding=16):
    image = Image.open(source).convert("RGBA")
    if image.getchannel("A").getextrema()[0] < 255:
        # Native transparent output already has the correct edge colors/alpha.
        # Matte removal would damage its semitransparent ivory contours.
        return fit_icon(image, size, padding, "native_alpha")
    pixels = image.load()
    width, height = image.size
    background = set()
    queue = deque((x, y) for x in range(width) for y in (0, height - 1))
    queue.extend((x, y) for y in range(height) for x in (0, width - 1))
    while queue:
        x, y = queue.popleft()
        if not (0 <= x < width and 0 <= y < height) or (x, y) in background:
            continue
        red, green, blue, alpha = pixels[x, y]
        if alpha and min(red, green, blue) < 245:
            continue
        background.add((x, y))
        queue.extend(((x-1, y), (x+1, y), (x, y-1), (x, y+1)))
    for x, y in background:
        pixels[x, y] = (0, 0, 0, 0)
    # Remove the white matte only on neutral antialiased outer contour pixels.
    # Enclosed ivory details cannot touch the edge-connected background.
    fringe = set()
    for x, y in background:
        for nx, ny in ((x-1, y), (x+1, y), (x, y-1), (x, y+1)):
            if 0 <= nx < width and 0 <= ny < height and (nx, ny) not in background:
                fringe.add((nx, ny))
    for x, y in fringe:
        red, green, blue, alpha = pixels[x, y]
        if max(red, green, blue) - min(red, green, blue) < 15 and min(red, green, blue) > 120:
            pixels[x, y] = (0, 0, 0, min(alpha, 255-min(red, green, blue)))
    return fit_icon(image, size, padding, "edge_connected_white")


def fit_icon(image, size, padding, extraction):
    box = image.getbbox()
    if box is None:
        raise ValueError("Generated source has no foreground")
    foreground = image.crop(box)
    foreground.thumbnail((size-2*padding, size-2*padding), Image.Resampling.LANCZOS)
    result = Image.new("RGBA", (size, size))
    result.alpha_composite(foreground, ((size-foreground.width)//2, (size-foreground.height)//2))
    return result, box, extraction


def preview(icon):
    result = Image.new("RGB", (960, 600), "#171b23")
    draw = ImageDraw.Draw(result)
    font_path = Path("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf")
    font = ImageFont.truetype(str(font_path), 28) if font_path.is_file() else ImageFont.load_default()
    small = ImageFont.truetype(str(font_path), 18) if font_path.is_file() else font
    draw.text((40, 28), "FIRE EYE SIGIL", font=font, fill="#f2e9d5")
    draw.text((40, 70), "2 notches  /  Fire Eye: 3s > 6s", font=small, fill="#c7b9a4")
    for index, color in enumerate(("#171b23", "#eee9df")):
        left = index*480
        draw.rectangle((left+24, 118, left+456, 580), fill=color)
        result.paste(icon, (left+112, 140), icon)
        for x, edge in ((left+100, 96), (left+280, 64)):
            sample = icon.resize((edge, edge), Image.Resampling.LANCZOS)
            result.paste(sample, (x, 440), sample)
            draw.text((x, 550), f"{edge}px", font=small,
                      fill="#c7b9a4" if index == 0 else "#3b3431")
    return result


def prepare(source, output):
    source, output = Path(source).resolve(), Path(output).resolve()
    if output == source.parent or source.is_relative_to(output):
        raise ValueError("Source original and output must be separate")
    source_hash = digest(source)
    output.mkdir(parents=True, exist_ok=True)
    icon, crop, extraction = extract_icon(source)
    icon.save(output/"icon.png", optimize=False)
    preview(icon).save(output/"preview.png", optimize=False)
    if digest(source) != source_hash:
        raise ValueError("Generated original changed during preparation")
    manifest = {
        "schema_version": 1,
        "source": str(source.relative_to(ROOT)) if source.is_relative_to(ROOT) else str(source),
        "source_sha256": source_hash,
        "processing": {"extraction": extraction, "edge_connected_white_threshold": 245, "crop": crop,
                       "canvas": [256, 256], "padding": 16, "resample": "LANCZOS"},
        "files": {name: digest(output/name) for name in ("icon.png", "preview.png")},
    }
    (output/"manifest.json").write_text(json.dumps(manifest, indent=2)+"\n")
    return manifest


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", type=Path)
    parser.add_argument("--output", type=Path, default=ROOT/"assets/processed/charms/fire-eye-sigil")
    args = parser.parse_args()
    print(json.dumps(prepare(args.source, args.output), indent=2))


if __name__ == "__main__":
    main()
