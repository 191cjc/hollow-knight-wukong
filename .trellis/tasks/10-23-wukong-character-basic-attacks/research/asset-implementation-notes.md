# Asset implementation and visual review

Date: 2026-10-23. Scope: default staff Wukong, bounded offline animation conversion.

## Implemented boundary

- `tools/legacy_dragonbones.py` samples the actual global-pose DragonBones 2.3 / 30 FPS subset. It intentionally rejects parented bones, meshes, display scale/rotation, active tweening, timeline scale/offset and nonidentity RGB transforms rather than silently approximating a larger runtime.
- Frame transforms replace raw global bind poses. Frame pivots add to display translation; image display pivots subtract from image registration. Independent skews, negative scales, nested child offsets, absolute frame z, stable tie order, display hiding and inherited alpha are preserved.
- Missing bone timelines hide their slots. Numeric equipment animation `1` is selected explicitly; empty animation `0` remains hidden. Nested death-effect time starts at its parent display becoming visible, not at the parent clip's initial tick.
- The final timeline keyframe gets the clip duration minus its start position. This repairs the real hidden `wq12` walk duration of 337 ticks to 24 without extending the clip.
- Only exact source pixels `(0,0,0,1)` become transparent in an in-memory copy. 5,515 atlas pixels normalize; other low-alpha colored pixels and opaque black remain intact. Four 2x2 equipment placeholders become empty. Original archived files are unchanged.
- Compositing uses full affine matrices and premultiplied-alpha bicubic sampling. No DragonBones runtime or copied historical implementation code is shipped.
- `tools/bake_character.py` generates the v1 JSON contract, full-canvas RGBA atlas cells, review contact sheets, GIFs and light/dark mirrored edge samples. Build/package/generator cache validation share `tools/validate_character.py` (integration owner).

## Output and scaling

- Output: `assets/processed/wukong/character.json`, `atlas-000.png`, `previews/`.
- Required clips: idle, walk, runNormal, jumpNormal, jumpTwo, jumpDown, jumpAttack, hurtStand, dead, attack1 through attack4.
- All 329 source ticks are represented individually at duration 1. Identical complete RGBA frames share a fixed-size cell after SHA-256 and exact byte equality checks; holds preserve their full timing.
- 52 unique cells, one 1848x1582 atlas, bounded by the configured 2048 maximum dimension. Raw RGBA atlas pixels occupy approximately 11.15 MiB before Unity loading overhead.
- Every cell is 231x226 with common top-left-coordinate source root `(119,174)`. The canvas is the padded union of transformed image corners across every selected clip, including death effects; no frame is centered individually.
- `nominal_body_height=101` pixels is measured from idle body alpha after excluding staff/effect slots. Staff reach and the ghost do not change view scale.
- Default source facing is right (+x). Source poses can turn during the third attack; those are source animation transforms rather than changes to the controller's facing.
- Idle visible bounds are `(75,79,170,180)` (right/bottom exclusive). The foot edge is 6 pixels below the virtual source root. Runtime owner has been told to use a single upward `6 / pixelsPerUnit` alignment correction if matching collider feet; all animations must share it.
- Unity must convert PNG frame rectangle Y separately from the normalized root pivot. Source timing preserves rational source ticks rather than historical rounded millisecond boundaries.

## Visual review performed

Viewed the actual generated `overview.png`, `attacks-contact.png`, `edges-facing.png`, `runNormal-contact.png`, `jumpTwo-contact.png` and `dead-contact.png`. The main session independently reviewed idle, overview and attacks.

- Default head, clothes, limbs and single staff compose coherently; no duplicated alpha-zero second staff or stray default effects are visible.
- Idle/run and attack foot anchors use one coordinate, preserving authored pose motion. JumpTwo rotates the full figure and staff coherently with its source frame pivot pY=22.
- The death corpse remains below/around the authored source origin while the ghost begins at tick8 and changes texture every three ticks; effects fit the common canvas.
- Light/dark backgrounds and mirrored idle show preserved edges, including the staff; no rectangular alpha1 placeholders remain.
- Attack3 compressed staff poses at ticks5/9 are source deformations (`scX=±3.42`, `scY=.21`, independent skew), not omitted equipment. Its ticks7/9 turn backward and must not supply forward horizontal hit windows.
- Attack4's actual source poses show a forward body/arm strike with the staff held behind. No invented forward staff pose or untraced blur event has been added. Gameplay range should be checked against this in the client.

## Transplant combat profile

The checked-in `data/character/wukong-staff.json` is the single configuration source, copied into the generated runtime manifest. Timings below are reviewed **transplant design values**, not claims about original-game damage events:

| Stage | Clip ticks | Startup | Active windows | Recovery | Buffer opens |
|---|---:|---|---|---|---:|
| 1 | 12 | [0,4) | [4,7) | [7,12) | 4 |
| 2 | 15 | [0,5) | [5,8) | [8,15) | 5 |
| 3 | 18 | [0,3) | [3,5), [11,14) | inter-window [5,11), final [14,18) | 3 |
| 4 | 20 | [0,5) | [5,8) | [8,20) | 5 |

First/second/third active forward staff poses begin at ticks4/5/3+11 respectively; fourth stage's forward leaning strike begins at tick5. All windows are half-open. The stage3 second window is intentionally after the backward spin and sufficiently separated for native hit invulnerability review. Runtime must still prove the two HP-loss transactions on a real client.

The initial native slash reach multiplier remains 1.0 for every stage; there is no damage multiplier. This retains the native horizontal shape and charm range behavior rather than deriving damage colliders from image alpha or claiming unverified source hitboxes. In-client reach/offset calibration remains pending. Chain grace is 0.35 seconds. `evtMohu_12_0_6,7,10,11` is listed as an ignored source event, never used as a damage window.

## Checks executed

```bash
.tools/python/bin/python -m unittest discover -s tests -p 'test_animation_bake.py' -v
.tools/python/bin/python tools/bake_character.py
.tools/python/bin/python tools/bake_character.py --validate-only
```

15 asset tests pass. Coverage includes independent affine inversion with negative/skewed scaling; real pixel mirror placement; global-vs-bind transforms and both pivots; exact held frame boundaries and final-duration repair; numeric child selection and missing/hidden timelines; inherited alpha; absolute z and stable tie order; nested effect clock reset; exact filler cleanup; unsupported features/cycle failures; real source visibility/placeholder/death/jump contracts; clean regeneration byte equality; uncropped per-cell pixel bounds; malformed atlas rectangles/hashes; and multi-page splitting with a lowered 512 limit.

Two clean output directories yield identical manifest/atlas bytes. Code, profile, source and Pillow version participate in a deterministic cache fingerprint. Cached output is fully validated before reuse; there are no generated timestamps inside runtime asset bytes.

This validates offline assets and contract behavior. It does not validate Unity display scale, attack contacts, enemy HP, native charm interactions or the third attack's double damage in an actual Hollow Knight client.
