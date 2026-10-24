# Offline Size Variants: 0.2.2-dev

User requirements: resize the artwork rather than adding a runtime enlargement;
use 1.5 times the original baseline, preserve original assets, keep edited assets
in separate folders, and provide reusable batch scripts for future operations.
The user has already authorized direct updates to the installed WukongKnight Mod.

`assets/processed/wukong` and archived sources remain unchanged. The new variant
is generated into `assets/processed/variants/wukong-1p5`. The reusable script
processes all 329 tick frames (52 distinct cells), synchronizes canvas/pivots/feet
offset and repacks two atlas pages. Reference body height remains 101 pixels to
preserve the existing world-coordinate calibration. The additional runtime 1.25
appearance multiplier is removed. Collision, original slash effects and combat
timings remain unchanged.

`scripts/resize-character.bat` and `tools/resize_character.py` process the active
profile or a supplied factor/output. Original inputs cannot be overwritten,
different existing variants cannot be replaced, and already resized inputs are
rejected. Repeated runs and clean outputs are byte-identical.

Validation completed: 26 Python tests passed, one pre-existing Windows symlink
privilege test skipped; 10 actual combo-core tests passed; Release compilation
completed without warnings/errors; package closure/CRC/hash checks passed.
The pixel preview was inspected for idle, run and attack3, with original and
enlarged artwork aligned to the same floor. Both installed atlas pages and the
Mod DLL were verified against the built package. The previous installed Mod was
backed up. No API/game assemblies or save files were modified. Visual size,
collision behavior and combat still await user gameplay confirmation.
