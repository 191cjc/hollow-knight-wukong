# Fire Demon original damage research

Latest user direction: the down-spell replacement must not reuse native Quake
damage. Investigate whether the archived source game contains its original damage
rules and calculate from those rules before finalizing the replacement.

Completed read-only research:

- Prepared FFDec 26.4.0 and portable Temurin 21.0.8+9 in the enclosing `work/`
  directory. Decompiled only selected relevant classes from the existing SWF.
- Preserved AS3, P-code declaration, original attack-mask SVGs and input/output
  hashes in `reference/flash/fire-demon/`; no archived originals were changed.
- Traced frame-5 air effect creation, its (+177 facing X,-95 Y) offset, finisher
  creation after the air effect deletes, target-keyed count/cooldown and bitmap
  overlap, and physical base damage dispatch. There is no nine-pulse rule.
- Air cap: 11 per target, interval >=100 game ms. Finisher cap: one per target.
  Both source masks are static rectangles independent of the body collider.
- Verified that `SkillConfigVO.skillAdd` is an int slot and the XML loader
  explicitly calls int(text); fractional growth truncates to zero in this archive.
- Added `tools/calculate_fire_demon.py`, Windows wrapper and six arithmetic/input
  tests. All six passed; the wrapper ran successfully. Level 1, attack 100,
  defense/lucky zero, non-critical baseline gives air 59, finisher 357, 11+1 total
  1006. Final target HP changes still depend on further original combat modifiers.

See `docs/FIRE_DEMON_RESEARCH.md` for the complete evidence/limits and transplant
constraints. User-facing report is the enclosing outputs directory's
`WukongKnight-火魔斩原版判定测算.md`.

The earlier uncompiled/uninstalled runtime draft that uses native Quake damage
and nine air pulses is superseded. It is not the source of the new calculator.
No new Mod build or install was performed for this research. Current installed
0.3.0 DLL SHA256 remains
`a8c5a9c8530247b631405fb330cf610abdd53fbeb37686457e88cac35a11205e`.
Implementing an independent source-backed Fire Demon mechanic and mapping source
stats to Hollow Knight remains subsequent runtime work; do not mark it delivered
or claim gameplay acceptance from this research.
