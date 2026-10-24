# Fire Demon Slash: archived source evidence and damage calculation

This is a source-code study of the archived `v5870.swf` and its accompanying
configuration/artwork, performed on 2026-10-23. It is not an original-game playtest
or a claim that the unfinished Hollow Knight replacement is installed.

## Confirmed execution and collision rules

The source evidence now lives in `reference/flash/fire-demon/`. It includes the
decompiled AS3, the attack-mask SVGs and a SHA256 provenance manifest. The original
SWF files, XML and artwork were not modified. These research files are not Mod
runtime assets.

1. `WKEntity.skill5()` clears the previous two effect entities and saves the
   current skill configuration. `advanceTime()` creates `effect5_1` when the
   character animation reaches frame 5. The cloned first subskill is spawned at
   X=177 times facing direction, Y=-95 relative to the character's position.
2. When that effect is deleted, `WKEntity.addEff5_2()` creates `effect51` with
   the second subskill at the character's then-current position and sets its
   horizontal velocity to zero. **The code trigger is effect completion, not a
   Hollow Knight ground-contact or Quake damage event.** The two source effects
   contain 31 and 20 animation ticks at 30 FPS, respectively.
3. `SkillEntity.getIsAttacking()` stays true while the entity is alive.
   `SkillEntity.getABTextureByActionState()` chooses the original `ab_` mask for
   its effect name and facing. `PlayerEntity.getAttackBp()` holds the last mask
   frame if the visible animation is longer than the mask animation.
4. `PlayerEntity.getCollidedWidth()` checks invulnerability, per-target hit count,
   time since the previous hit, then calls `hitTest()`. The latter uses the attack
   bitmap against the target hurt bitmap with alpha threshold 1. In this source
   both Fire Demon attack masks are single-frame, solid rectangles.
5. Air subskill `1101051` allows **at most 11 hits per target**, with at least
   **100 game milliseconds** between accepted contacts. Finisher `1101052` allows
   **one hit per target**. `alone=0` keys the target's record by source user/entity
   and skill ID. Different targets have independent records. Starting the parent
   skill resets its own and its subskills' count records.
6. These are caps and contact cooldowns, not eleven compulsory timed pulses.
   A target can enter the region later, leave it, be invulnerable or die. Sampling
   affects the attainable count: the online timer is `CurrentFrame * 33`, so
   three frame steps are 99 ms and do not pass a 100 ms check. Do not infer exact
   landed hits from the description's "nine slashes" or the visible streak count.

Key AS3 locations, with line numbers in the saved FFDec output:

| Evidence | File and entry point |
| --- | --- |
| Phase creation and offsets | `as3/viewers/entitys/man/WKEntity.as`: `advanceTime` line 80, `addEff5_1` line 128, `addEff5_2` line 141 |
| Target cap and cooldown | `as3/viewers/entitys/man/PlayerEntity.as`: `getCollidedWidth` line 3685 |
| Mask overlap and hold | Same file: `hitTest` line 3859, `getAttackBp` line 3913 |
| Reset counts for parent and subskills | `as3/models/managers/BattleModelManager.as`: `setAttackedTotalNum` line 1910 |
| Effect stays active and chooses its mask | `as3/viewers/entitys/man/SkillEntity.as`: `getIsAttacking` line 148, `getABTextureByActionState` line 457 |

## Original attack regions

The genuine Flash file `assets/zmxy4/raw/assets/man/2001/1V535.swf` exports
`ab_effect5_1` (sprite 36) and `ab_effect51` (sprite 35). Both place shape 32 using
different matrices. The shape is a rectangle from (-71,-72) to (187,5), in pixels.
The source masks are 50% opaque; alpha threshold 1 still makes the full rectangle
active. The table reports geometric bounds before bitmap rasterization.

| Region | Width × height, source pixels | Bounds relative to effect origin (X min, Y min, X max, Y max) |
| --- | --- | --- |
| Air | approximately 442.95 × 209.90 | (-218.95, -162.92, 224.00, 46.98) |
| Finisher | approximately 262.00 × 231.95 | (-131.95, -194.99, 130.05, 36.96) |

Coordinates are Flash Y-down. After the air spawn offset, its initial region is
approximately X=-41.95..401.00 and Y=-257.92..-48.02 relative to the character
origin when facing right. The effect has its own world position; it is not
automatically a symmetric overlap centered on the moving hero. Native floor
collision and hero body collision are separate from these attack regions.

The 1.5x artwork variant must not automatically multiply these source attack
regions. Mapping original pixels to Hollow Knight world units is a transplant
decision, separate from changing artwork pixels.

## Damage formula from the archived code

Both subskills have `type=1`. `BattleModelManager.calDamage()` dispatches type 1
to **physical damage**, even though the skill looks fiery. It does not dispatch
this skill to the magic-resistance formula.

The base physical calculation (`calPhysicalDamage`, line 864) is:

```text
effective_level = skill.getRealLevel
growth_level = min(effective_level, CommonConfig.skillAddMax)
luck_factor = 1 + roll * (min(1 + attacker_lucky / 500, 1.34) - 1)
coefficient = skillDefault + skillAdd * growth_level + horseSkillAdd * growth_level
raw = (max(effective_attack - effective_physical_defense, 1)
       * luck_factor * coefficient + skillCountAdd[effective_level - 1])
      * resolved_critical_multiplier
base_damage = max(1, ceil(min(raw, 2147483647)))
```

The configured addition falls back to its final table value beyond the table
length, and real skill level can include buffs and a global cap. The supplied
calculator intentionally restricts input to levels 1..30 covered by this archive.
The attack and defense inputs are already resolved effective stats, not naked
equipment attributes. Normal hits use critical multiplier 1. Critical selection
and its multiplier involve additional attacker and target attributes.

### A real XML-versus-code discrepancy

The XML has air `skillDefault=0.3407`, `skillAdd=0.0135`; finisher
`skillDefault=2.075`, `skillAdd=0.075`. However, `SkillConfigVO.as` line 39 declares
`skillAdd:int`, also verified in the exported P-code declaration. The XML loader
`VoBasic.buildFormXML()` explicitly converts an `int` field with `int(text)`.
Therefore **this archived loading path truncates both growth values to zero**.
`horseSkillAdd=0` in both records. The loaded coefficients are consequently 0.3407
and 2.075 for this base calculation. The level-dependent flat additions still
grow, so higher levels still inflict much more damage.

This is the behavior derived from the archived SWF/XML pair, not proof that every
release of the source game behaves identically. Restoring decimal growth would
be an intentional correction; it must not be described as reproducing this code.
At attack 100, defense 0, level 1, changing the loader to retain those decimals
would give 60 per air hit and 364 for the finisher (1024 for 11+1 hits), versus
the archived-code result of 59 and 357 (1006).

## Example calculations

Assumptions: effective attack 100, physical defense 0, lucky 0, normal hits,
no buffs/equipment damage modifiers, and all 11 air contacts plus the finisher
accepted. Each hit rounds upward separately, before summing.

| Skill level | Air damage per hit | Finisher | Full-contact base total |
| --- | --- | --- | --- |
| 1 | 59 | 357 | 1006 |
| 10 | 814 | 4887 | 13841 |
| 30 | 8013 | 48078 | 136221 |

For level 1, the explicit calculation is:

```text
air = ceil(100 * 0.3407 + 24) = 59
finisher = ceil(100 * 2.075 + 149) = 357
full contact = 11 * 59 + 357 = 1006
eight air contacts + finisher = 8 * 59 + 357 = 829
```

These are source-game units and base damage, not proposed Hollow Knight HP losses.
For example, the source role starts at attack 15; the same level-1 calculation
then gives 30 per air hit, 181 for the finisher, and 511 total for 11+1 contacts.
Directly copying the large fixed additions into Hollow Knight would bypass its
very different attack/HP progression.

## What the calculation does not claim

`PlayerEntity.onHurt()` applies more logic around the base formula: invulnerability
and dodge, critical rolls, `onCalDamage()` modifiers, Wukong skill-4/combo damage
bonuses, possible real-damage splitting, shields, target-specific rules and other
Buff/equipment effects. The calculator deliberately models the verified base
physical function with resolved stats; it does not predict final HP loss for an
arbitrary original-game save without those additional inputs.

The original Buff `6000301` is type 61, named Fire Demon Slash super armor, with
configured time 1967. A name alone is not evidence for complete invulnerability;
do not turn this into immunity to all Hollow Knight hazards.

## Reproduction

The calculator uses only Python's standard library and the preserved XML:

```powershell
python tools/calculate_fire_demon.py --attack 100 --defense 0 --level 1
python tools/calculate_fire_demon.py --attack 100 --level 1 --air-hits 8
python -m unittest discover -s tests -p test_fire_demon_calculation.py -v
```

The decompiler used was JPEXS FFDec 26.4.0 (official GitHub release) with a portable
Temurin 21 JRE, both kept in the enclosing workspace's `work/build-tools/`.
No Flash program or downloaded source-game code was executed. Re-export using
the original files and compare hashes in `reference/flash/fire-demon/evidence.json`:

```powershell
java -jar ffdec.jar -selectclass 'viewers.entitys.man.WKEntity,viewers.entitys.man.PlayerEntity,viewers.entitys.man.SkillEntity,models.managers.BattleModelManager,models.managers.ManResourceManager,models.vo.SkillConfigVO,models.vo.UserVO,models.proxys.SkillProxy,com.game.utils.VoBasic' -export script OUTPUT reference/flash/v5870.swf
java -jar ffdec.jar -selectclass 'models.vo.SkillConfigVO' -format script:pcode -export script PCODE_OUTPUT reference/flash/v5870.swf
java -jar ffdec.jar -selectid '35,36' -format sprite:svg -export sprite MASK_OUTPUT assets/zmxy4/raw/assets/man/2001/1V535.swf
java -jar ffdec.jar -swf2xml assets/zmxy4/raw/assets/man/2001/1V535.swf SHAPES.xml
```

## Hollow Knight implementation constraint

The user's corrected requirement is to replace the native down-spell damage
logic completely. The earlier uninstalled draft that retained native Quake fall,
slam and pillar damage, and hardcoded nine air pulses, is superseded by these
findings. A finished replacement needs separate source-backed regions,
per-target caps/cooldowns, independent finisher damage, and cancellation ownership.
Disable native Quake damage sources during the owned skill so they cannot stack
with the replacement. The native input/ability and Soul transaction may be kept
independently of the native damage objects.

At the research checkpoint the installed Mod remained 0.3.0-dev. Subsequent
0.4.0-dev work implemented, built and installed the independent damage mapping;
see `FIRE_DEMON_SLASH.md` and `artifacts/build-report.json`. Original-game gameplay
and the new Hollow Knight mechanic have not yet been playtested.
