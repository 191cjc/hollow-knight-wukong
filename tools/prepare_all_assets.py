"""Prepare all related size variants and the complete staff animation package."""
import json

from bake_character import bake_character
from resize_character import resize_character
from resize_related_assets import prepare_related_assets
from validate_character import ROOT


def main():
    related = prepare_related_assets(1.5)
    profile = json.loads((ROOT / "data/character/active-variant.json").read_text(encoding="utf-8"))
    original = ROOT / profile["source_directory"]
    bake_character(output=original, previews=False, profile_path=ROOT / profile.get("bake_profile", "data/character/wukong-staff-complete.json"))
    variant = resize_character(original, ROOT / profile["output_directory"], profile["scale"])
    print(json.dumps({"related_pngs": related["png_count"], "related_jsons": related["json_count"],
                      "clips": len(variant["clips"]), "frames": sum(len(c["frames"]) for c in variant["clips"].values()),
                      "atlases": len(variant["atlases"]), "originals_unchanged": True}))


if __name__ == "__main__":
    main()
