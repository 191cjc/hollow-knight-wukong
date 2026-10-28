# Client follow-up: Flame Dash charm icon

2026-10-28 user request: disable the hitbox Mod and replace Flame Dash's unchanged
native Dashmaster icon. Scope is artwork/load/refresh/restoration and local debug
configuration; retain existing Earthbreaker follow-up, gameplay and charm identity.

Use archived skill1101020/resource189 icon with exact source PNG bytes, preserving
the original. Preparation is integrated into the existing asset batch. Extend the
existing awakening icon owner to31alongside34; no native sprite-array mutation,
equipment/cost edits or new dependency. Embed three resources in0.7.10-dev.

Validation: source/data mapping, PNG preservation/visual review, source whitespace,
full Python/Core/Release/package gates, embedded resource hashes and compiled
two-ID selection/cache/cleanup. Installation backs up the complete previous Mod
while the game is closed and compares every new package file. No commit/push or
task archive requested. Actual inventory/pickup acceptance remains pending.

Completed local verification and installation at 2026-10-28 20:26 +08:00:
- 69 Python checks passed, one Windows symlink-privilege skip; 93 Core checks
  passed; Release compilation and package closure passed.
- The compiled DLL has exactly three expected resources. Both icon hashes match
  their source PNGs; the new icon is an exact copy of the archived original.
  The generated manifest matches its recorded build-input hash (the build restores
  tracked catalogues afterwards). Compiled routing, cache refresh and cleanup pass.
- All 19 installed files match the package. The previous 33 files were backed up
  to work/backups/installed-WukongKnight-before-0.7.10-20261028-202601.zip;
  14 additional diagnostic files were retained. The game was closed.
- DebugMod remains under Mods/Disabled/DebugMod; its active directory is absent
  and ShowHitBoxes is 0. API and save files were not changed.
- CRLF-aware Git whitespace checks pass. No commit or push was performed.
  In-game icon rendering and previous Earthbreaker movement acceptance remain pending.

Subsequent user requests:
- Generate a new charm image in place of the original skill thumbnail. This has
  not run: the built-in image tool is unavailable and no local API key is configured.
  The fallback confirmation is pending; the design and exact proposed prompt are
  preserved in flame-dash-generated-icon-brief.md. The installed icon remains the
  archived original described above.
- Commit all workspace changes and push them to the cloud Git repository. This
  explicitly authorizes including the Earthbreaker and icon follow-ups together
  on feat/fire-eye-charm. Current code and icon inputs were compared to the
  successful 0.7.10 build evidence; no implementation changes followed validation.
