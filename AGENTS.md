<!-- TRELLIS:START -->
# Trellis Instructions

These instructions are for AI assistants working in this project.

This project is managed by Trellis. The working knowledge you need lives under `.trellis/`:

- `.trellis/workflow.md` — development phases, when to create tasks, skill routing
- `.trellis/spec/` — package- and layer-scoped coding guidelines (read before writing code in a given layer)
- `.trellis/workspace/` — per-developer journals and session traces
- `.trellis/tasks/` — active and archived tasks (PRDs, research, jsonl context)

If a Trellis command is available on your platform (e.g. `/trellis:finish-work`, `/trellis:continue`), prefer it over manual steps. Not every platform exposes every command.

If you're using Codex or another agent-capable tool, additional project-scoped helpers may live in:
- `.agents/skills/` — reusable Trellis skills
- `.codex/agents/` — optional custom subagents

Managed by Trellis. Edits outside this block are preserved; edits inside may be overwritten by a future `trellis update`.

<!-- TRELLIS:END -->

## Local Testing Installation

The user has authorized installing future Mod updates directly into
`D:\SteamLibrary\steamapps\common\Hollow Knight\hollow_knight_Data\Managed\Mods\WukongKnight`
after building and checking the changes. This authorization persists; do not ask again
for routine Mod updates. Back up the previous Mod files, apply updates while the game
is closed, and verify the installed files against the built package.

For artwork edits, preserve original archived and baked assets. Generate modified
assets in separate variant folders through reusable offline scripts. The user
prefers pixel changes over additional runtime appearance scaling. The current
variant is 1.5 times the original artwork, selected by `data/character/active-variant.json`.

The complete artwork batch is `scripts/prepare-all-assets.bat`. All decoded image
variants live in `assets/processed/source-variants/all-1p5`; the active complete
runtime variant is selected by `data/character/active-variant.json` (currently
`assets/processed/variants/wukong-presentation-v062-1p5`). Flame Dash is
the original dash key plus original flame art and once-per-target along-path
damage. Preserve native dash movement/cooldown/collision and avoid double damage
from Sharp Shadow. Up + spell is Fire Demon Slash with independent fixed spell
damage and source contact masks/caps; suppress native Scream damage. Down + spell
is Flame Storm (original effect3 body/flames, local mask/cap5). Both spend native
MP Cost exactly once. Held focus is Jiyuan Fire Eye (汲元火眼): native charge/Soul drain,
then five seconds of one-HP healing on actual player attack HP loss, at most once
per second globally. See `docs/SPELL_LAYOUT.md` and `docs/FIRE_DEMON_SLASH.md`.
Other prepared skill artwork is not yet playable mechanics.

Native nail meshes are now visually replaced by seven original Wukong composites
(nailAttack1..4/nailAir/nailUp/nailDown). Presenter saves/restores only the five
actual hero NailSlash mesh forceRenderingOff flags. Native enabled writes,
polygons, damage/charms, Soul and pogo remain active. Do not disable slash objects
or resize colliders. Down arc alone rotates offline around source (0,-44.5).

v061 separates7arc-only nailArc clips from the existing body poses; keep all
earlier composites/assets. Only the independent arc renderer follows the actual
selected native NailSlash.localScale / serialized scale X/Y ratio. Do not add a
second charm table, invoke StartSlash for visuals, enlarge the body, or modify
colliders. Center compensation preserves source(0,-44.5) during range changes.


v062 FlameDash.Downward reads native dashingDown; flameDashDown is an offline
clockwise90 flame-only composite with upright body. Never rotate view/root/aura.
FireEyeCastClock.Observe(casting,remainingSeconds,scaledNow) captures native drain
deadline once; negative ticks show only effect4 opening body, source21ticks end
at native completion. Short charges use the source tail at30Hz; startup has no
casting flames. See current Native Combat contract superseding v053 alignment.


v063 Flame Dash has full incoming HP-damage guards for its actual active native
dash via Runtime.SkillProtects, shared with Fire Demon. Never set saved
isInvincible or retain protection after dash end/cancel. Real Die starts source
dead(65ticks/30Hz/ghost8..31) despite native mesh disable; fixed anchor/facing.
NativeDeathV77 owns render flags/debris visual spawn only, and restores on cleanup.
Keep the original death iterator/FSM progression and save/Geo/shade/respawn intact.
Current v062 character art is reused byte-for-byte; fresh verified original death
archive/decoded copies live in reference/flash/death, not overwriting old assets.
