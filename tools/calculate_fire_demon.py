"""Calculate the archived AS3 Fire Demon Slash base damage, without running Flash.

This models BattleModelManager.calPhysicalDamage, not the entire target HP-loss
pipeline. Source evidence and limitations: docs/FIRE_DEMON_RESEARCH.md.
"""
from __future__ import annotations

import argparse
import json
import math
from pathlib import Path
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
INT_MAX = 2147483647


def load_stages(source: Path = ROOT / "data/source/skills.xml") -> dict:
    records = {r.findtext("id"): r for r in ET.parse(source).getroot()}
    result = {}
    for name, skill_id in (("air", "1101051"), ("finisher", "1101052")):
        r = records[skill_id]
        if r.findtext("type") != "1" or float(r.findtext("horseSkillAdd")) != 0:
            raise ValueError("Archived physical/no-horse model no longer matches source")
        growth = float(r.findtext("skillAdd"))
        # SkillConfigVO.skillAdd is an int slot, and VoBasic.buildFormXML
        # explicitly calls int(text). Do not silently use the XML decimal.
        loaded_growth = int(growth)
        if loaded_growth != 0:
            raise ValueError("Nonzero growth needs a verified CommonConfig.skillAddMax")
        result[name] = {
            "skill_id": int(skill_id),
            "skill_default": float(r.findtext("skillDefault")),
            "xml_skill_add": growth,
            "loaded_skill_add": loaded_growth,
            "flat_by_level": [float(v) for v in r.findtext("skillCountAdd").split(",")],
            "max_hits_per_target": int(r.findtext("attMax")),
            "interval_ms": int(r.findtext("attInterval")),
        }
    return result


def base_hit(stage: dict, attack: float, defense: float, level: int,
             lucky: float = 0, random_roll: float = 0.5,
             critical_multiplier: float = 1) -> int:
    """Resolved stats in, integer pre-modifier physical damage out.

    critical_multiplier=1 means a normal hit. The caller can supply the already
    resolved original critical multiplier; this function does not roll a crit.
    """
    values = (attack, defense, lucky, random_roll, critical_multiplier)
    if not all(math.isfinite(v) for v in values):
        raise ValueError("Stats must be finite")
    if min(attack, defense, lucky) < 0 or not 0 <= random_roll <= 1:
        raise ValueError("Stats must be nonnegative and random_roll in [0, 1]")
    if critical_multiplier < 1:
        raise ValueError("Critical multiplier must be at least one")
    if type(level) is not int or not 1 <= level <= len(stage["flat_by_level"]):
        raise ValueError("Use a skill level represented by the archived table (1..30)")
    if stage["loaded_skill_add"] != 0:
        raise ValueError("This model requires the archived zero loaded growth")
    luck_factor = random_roll * (min(1 + lucky / 500, 1.34) - 1) + 1
    damage = (max(attack - defense, 1) * luck_factor * stage["skill_default"]
              + stage["flat_by_level"][level - 1]) * critical_multiplier
    return max(1, math.ceil(min(damage, INT_MAX)))


def calculate(attack: float, defense: float = 0, level: int = 1,
              air_hits: int = 11, lucky: float = 0,
              random_roll: float = 0.5, critical_multiplier: float = 1) -> dict:
    stages = load_stages()
    if type(air_hits) is not int or not 0 <= air_hits <= stages["air"]["max_hits_per_target"]:
        raise ValueError("Air hits must be an integer between 0 and 11")
    damage = {
        name: base_hit(stage, attack, defense, level, lucky, random_roll,
                       critical_multiplier)
        for name, stage in stages.items()
    }
    return {
        "model": "archived-as3-physical-base-before-buffs",
        "inputs": {"attack": attack, "defense": defense, "skill_level": level,
                   "air_hits": air_hits, "finisher_hits": 1, "lucky": lucky,
                   "random_roll": random_roll, "critical_multiplier": critical_multiplier},
        "air_damage_per_hit": damage["air"],
        "finisher_damage": damage["finisher"],
        "total_if_requested_hits_connect": air_hits * damage["air"] + damage["finisher"],
        "stages": stages,
        "limitations": [
            "Full-contact base-damage calculation; hit caps are not guaranteed hits.",
            "No dodge, invulnerability, shields, equipment, buff or later damage modifiers.",
            "The archived int skillAdd slot truncates both XML decimal growth values to zero.",
            "Source game units; no Hollow Knight damage balance mapping is applied.",
        ],
    }


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--attack", type=float, required=True)
    parser.add_argument("--defense", type=float, default=0)
    parser.add_argument("--level", type=int, default=1)
    parser.add_argument("--air-hits", type=int, default=11)
    parser.add_argument("--lucky", type=float, default=0)
    parser.add_argument("--random-roll", type=float, default=0.5)
    parser.add_argument("--critical-multiplier", type=float, default=1)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    try:
        result = calculate(args.attack, args.defense, args.level, args.air_hits,
                           args.lucky, args.random_roll, args.critical_multiplier)
    except ValueError as error:
        parser.error(str(error))
    content = json.dumps(result, ensure_ascii=False, indent=2) + "\n"
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(content, encoding="utf-8")
    print(content, end="")


if __name__ == "__main__":
    main()
