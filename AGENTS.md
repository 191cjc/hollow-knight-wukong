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
`assets/processed/variants/wukong-fire-demon-v04-1p5`). Flame Dash is
the original dash key plus original flame art and once-per-target along-path
damage. Preserve native dash movement/cooldown/collision and avoid double damage
from Sharp Shadow. Down + spell is Fire Demon Slash with independent fixed spell
damage and source contact masks/caps; suppress native Quake damage. See
`docs/FIRE_DEMON_SLASH.md`. Other prepared skill artwork is not yet playable mechanics.
