"""Known AS3 arithmetic cases, independent of Unity and the visual draft."""
import math
from pathlib import Path
import sys
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "tools"))
from calculate_fire_demon import base_hit, calculate, load_stages


class FireDemonCalculationTests(unittest.TestCase):
    def test_level_one_rounds_each_hit_before_total(self):
        result = calculate(100)
        self.assertEqual(result["air_damage_per_hit"], 59)
        self.assertEqual(result["finisher_damage"], 357)
        self.assertEqual(result["total_if_requested_hits_connect"], 1006)
        self.assertNotEqual(1006, math.ceil(11 * (100 * .3407 + 24) + 100 * 2.075 + 149))

    def test_flat_table_uses_level_minus_one(self):
        self.assertEqual(calculate(100, level=10)["total_if_requested_hits_connect"], 13841)
        self.assertEqual(calculate(100, level=30)["total_if_requested_hits_connect"], 136221)

    def test_loaded_growth_is_an_int_in_archived_code(self):
        stages = load_stages()
        self.assertEqual(stages["air"]["xml_skill_add"], .0135)
        self.assertEqual(stages["finisher"]["xml_skill_add"], .075)
        self.assertEqual(stages["air"]["loaded_skill_add"], 0)
        self.assertEqual(stages["finisher"]["loaded_skill_add"], 0)

    def test_defense_clamps_attack_part_before_flat_add(self):
        result = calculate(10, defense=100)
        self.assertEqual(result["air_damage_per_hit"], 25)
        self.assertEqual(result["finisher_damage"], 152)

    def test_luck_caps_and_crit_multiplies_flat_part_too(self):
        stage = load_stages()["air"]
        self.assertEqual(base_hit(stage, 100, 0, 1, lucky=500, random_roll=1), 70)
        self.assertEqual(base_hit(stage, 100, 0, 1, critical_multiplier=2), 117)
        self.assertEqual(base_hit(stage, 100, 0, 1, lucky=500, random_roll=0), 59)

    def test_misses_reduce_total_and_invalid_inputs_are_rejected(self):
        self.assertEqual(calculate(100, air_hits=8)["total_if_requested_hits_connect"], 829)
        self.assertEqual(calculate(100, air_hits=0)["total_if_requested_hits_connect"], 357)
        for kwargs in ({"level": 0}, {"level": 31}, {"air_hits": 12}, {"attack": float("nan")}, {"defense": -1}):
            args = {"attack": 100, **kwargs}
            with self.assertRaises(ValueError):
                calculate(**args)


if __name__ == "__main__":
    unittest.main()
