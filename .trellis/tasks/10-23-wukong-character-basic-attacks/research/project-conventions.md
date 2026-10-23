# Project Conventions from Existing Code

- Query: Which real conventions should implementation and review follow?
- Scope: internal; current evidence and task-specific review constraints.
- Date: 2026-10-23.

## Existing conventions

- `src/WukongKnight/WukongKnight.csproj:3` targets net472. Preserve nullable annotations, explicit imports, deterministic builds and warnings-as-errors (`:8` through `:11`). SDK version and target runtime are separate.
- Game/API references use explicit HintPath and `Private=false` (`src/WukongKnight/WukongKnight.csproj:17`) so they are not bundled into the Mod.
- The mod namespace is WukongKnight, with block namespaces and four-space indentation (`src/WukongKnight/WukongKnightMod.cs:4`). Use Modding logging through the entry point; missing resources produce a specific error (`:19`).
- `scripts/build.sh:2` uses strict Bash and project-local `.tools` paths, including PROJECT_ROOT rather than repurposing HOME.
- `tools/bootstrap.py` pins downloads in toolchain.lock.json, hashes cached bytes and installs locally. Any new build/renderer dependency needs an explicit version and reproducible preparation command.
- `tools/prepare_assets.py` preserves raw assets and XML strings, re-extracts animation containers for comparison, and generates current-path indexes and validation reports.
- `tools/unpack_animation.py` is the shared unpacker. Reuse it rather than adding a second bundle parser.
- `tools/package.py:12` owns staging and packaging. Extend that flow for generated character resources and package validation.
- Runtime status is explicitly false in the generated development manifest and build report. Separate feature implementation, automatic verification and real client verification when extending those schemas.
- `.gitignore` excludes tools, build products and assets/processed outputs. Commit generator code and configuration as appropriate; package generated runtime assets.

## Relevant specs and gaps

- `.trellis/spec/guides/index.md`, `code-reuse-thinking-guide.md` and `cross-layer-thinking-guide.md` apply to the asset-manifest, runtime and package contracts.
- `.trellis/spec/backend/index.md` and `.trellis/spec/frontend/index.md` currently describe generic templates. Their quality/error/logging documents remain unfilled; do not treat them as actual Mod conventions.
- Filling unrelated web/database conventions is outside this feature.

## Review focus for this feature

- Separate source values from chosen transplant timings and hit windows.
- Use a versioned generated manifest consistently across resource loading, packaging and reports.
- Reuse native attack transactions and original directional/air behavior; do not run native and custom damage for the same hit.
- Restore renderer and control ownership on detach, error and cancellation paths.
- Test risky contracts: legacy transforms, buffered combo timing, duplicate hits and package completeness. Avoid tests that merely restate configuration.
- Game hooks and drawing require actual client acceptance. Compilation, simulated state machines and animation previews alone cannot prove in-game success.
