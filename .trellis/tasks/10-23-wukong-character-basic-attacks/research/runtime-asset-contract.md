# Runtime Asset Contract v1

Agreed implementation boundary for the parallel asset, runtime and integration workers. Changes require coordinating with the other owners first.

## Files and paths

- Checked-in bake profile and combat configuration: `data/character/wukong-staff.json` (asset worker owns it).
- Generated output: `assets/processed/wukong/character.json`, `atlas-000.png` etc. Previews go into `assets/processed/wukong/previews/` and are not runtime dependencies.
- Staged output: `artifacts/mod/WukongKnight/character/character.json` with atlas pages beside it. Runtime resolves `character/character.json` relative to its own assembly directory.
- Imaging environment: `.tools/python/bin/python`, prepared by bootstrap using pinned Pillow. Integration worker owns dependencies/bootstrap, asset worker owns converter/profile.
- Unity compile references: `.tools/unity-reference/lib/net45/` (integration worker prepares from locked UnityEngine.Modules archive); `UnityReferenceDir` MSBuild property overrides this default. API references remain under existing `HollowKnightApiDir`.

## JSON structure

Field names are snake_case. All rectangles/root coordinates use PNG top-left/y-down pixels. Arrays and object keys are deterministic, with no build timestamp inside generated asset bytes.

```json
{
  "schema_version": 1,
  "character_id": "2001",
  "appearance": "default_staff",
  "frame_rate": 30,
  "canvas_width": 256,
  "canvas_height": 256,
  "root_x": 128.0,
  "root_y": 192.0,
  "nominal_body_height": 80.0,
  "source_hashes": {"skeleton.json": "...", "texture.json": "...", "texture.png": "..."},
  "generator": {"version": 1, "pillow_version": "...", "filler_normalization": "exact_rgba_0_0_0_1"},
  "atlases": [{"path": "atlas-000.png", "width": 2048, "height": 2048, "sha256": "..."}],
  "clips": {
    "attack1": {
      "duration_ticks": 12,
      "loop": false,
      "frames": [{"atlas": 0, "x": 0, "y": 0, "width": 256, "height": 256, "duration_ticks": 1}]
    }
  },
  "combat": {
    "chain_grace_seconds": 0.35,
    "stages": [
      {"clip": "attack1", "buffer_open_tick": 2, "hit_windows": [{"start_tick": 2, "end_tick": 4}], "range_multiplier": 1.0},
      {"clip": "attack2", "buffer_open_tick": 2, "hit_windows": [{"start_tick": 2, "end_tick": 5}], "range_multiplier": 1.0},
      {"clip": "attack3", "buffer_open_tick": 3, "hit_windows": [{"start_tick": 3, "end_tick": 5}, {"start_tick": 8, "end_tick": 10}], "range_multiplier": 1.0},
      {"clip": "attack4", "buffer_open_tick": 5, "hit_windows": [{"start_tick": 5, "end_tick": 8}], "range_multiplier": 1.0}
    ]
  }
}
```

The numeric canvas/atlas/root examples are illustrative; the converter computes a common padded canvas over the chosen clips and retains its virtual source origin. `nominal_body_height` measures the default idle body excluding staff/effects, for a constant view scale against the existing hero collider; do not rescale each animation independently.

Emit every source tick initially, with one same-sized fixed cell per frame and a common root coordinate. The example lists one frame for brevity; real frame duration totals must equal duration_ticks. Required clips: idle, walk, runNormal, jumpNormal, jumpTwo, jumpDown, jumpAttack, hurtStand, dead, attack1, attack2, attack3, attack4.

Combat example windows are an initial transplant tuning profile, **not original-game hit timing evidence**. Asset owner reviews the real composed poses and may adjust these values and reach multipliers before final runtime validation, informing runtime/integration owners. All windows are half-open [start_tick,end_tick), integral and within clip duration; third stage has exactly two nonoverlapping windows, other stages one. No damage multiplier field: reuse the native nail/charm damage transaction.

## Consumer rules

- Runtime validates schema, required clips, nonempty frames, tick totals, stage count/window constraints and atlas integrity before hiding the native body. Sprite rectangle Y and normalized pivot are converted independently at the Unity boundary.
- Core combo logic reads durations/windows from this manifest and uses a single clock scaled consistently for Quick Slash; at most one input may be buffered during an active stage. A stage token and hit-window ID define ownership and per-target deduplication.
- The adapter intercepts only grounded horizontal native attacks; other directions/air pass through. Up/down native slash effects remain available while Wukong body pose falls back explicitly.
- Package copies only this manifest and its referenced atlas pages into character/, verifies hashes, and excludes previews and all game/API/engine DLLs. Runtime source may use API Newtonsoft.Json without packaging a second copy.
- New build/status reports separate feature implementation from actual runtime testing. Never infer runtime_tested from successful compilation or metadata validation.
