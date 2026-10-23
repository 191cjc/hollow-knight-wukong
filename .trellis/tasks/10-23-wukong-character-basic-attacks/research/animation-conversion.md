# Research: Bounded DragonBones 2.3 character animation baking

- Query: Can the actual `2001/manV535` assets become transparent, consistently anchored Wukong sprites without introducing a full DragonBones runtime into Hollow Knight?
- Scope: mixed; local source-data inspection, PNG inspection, authoritative historical runtime source.
- Date: 2026-10-23.
- Product scope: default staff appearance and four grounded horizontal attacks. Original directional/air attack mechanics remain; their visual mappings must keep the Wukong renderer active. Independent running/aerial attack mechanics are outside this delivery.

## Findings

### Recommendation and evidence level

Use an **offline Python + pinned Pillow converter for this exact export**, producing atlas PNGs plus a small JSON animation manifest. Do not embed DragonBones in the Mod. The observed subset is bounded enough to implement: no parented bones, meshes, IK, rotated/trimmed atlas entries, timeline scale/offset overrides, or enabled tweening. It does require nested armatures, sparse-field defaults, both kinds of pivot, display visibility, alpha, and animation-local hiding.

This is a **source-backed feasibility result, not a rendered proof**. Research decoded the PNG and inspected its pixels, but did not implement a renderer, install dependencies, or generate animation frames. A composed idle and all four attack contact sheets are the first implementation gate; do not consider conversion complete before reviewing them.

### Files found and current code patterns

- `assets/zmxy4/animations/2001/manV535/skeleton.json:1`: entire minified DragonBones 2.3 skeleton, 30 FPS, 23 armatures.
- `assets/zmxy4/animations/2001/manV535/texture.json:1`: entire minified atlas, 35 named rectangles; only `name`, `x`, `y`, `width`, `height` appear. No rotation, trimming, frame, or alternate texture page fields.
- `assets/zmxy4/animations/2001/manV535/texture.png`: 512 by 512 RGBA8, non-interlaced. Viewed directly; contains recognizable default Wukong head, body, staff, blur and effects.
- `tools/unpack_animation.py:88`: the existing unpacker validates AMF entries and writes original JSON/PNG, preserving their contents. Reuse its resulting directory as converter input; do not turn unpacking into animation evaluation.
- `tools/unpack_animation.py:104`: existing signature/JSON validation is not composition validation.
- `src/WukongKnight/WukongKnightMod.cs`: scaffold only; no current sprite playback contract to preserve.
- `tools/package.py`: development packaging needs extending later to include processed character assets.
- `docs/SKILL_RESEARCH.md:33`: animation `evtMohu_*` names are untraced game events, not established damage events.
- `reference/flash/v5870_strings.txt:35296`, `:37323`: the original Flash program contains both `ObjectDataParser` and `Object3DataParser` names, consistent with a later runtime loading legacy 2.3 data. This does not identify an exact original runtime commit.

Input SHA-256 values inspected:

| Input | SHA-256 |
| --- | --- |
| skeleton.json | `559d25a2e54f3b5710fa1d755f9a4978d77b4b81f7e171f29c4a23d82903a4e6` |
| texture.json | `f1cc3f24baf6ac889941383cd4ea8d8db2575c3c72945949f845e8d45cf52a57` |
| texture.png | `bf817e5670c95ede72039bbbef7bde0b46074415012910fa7f429b33f85747de` |

### Actual armature and appearance structure

The main `res` armature has 24 bones and 24 slots. **None of the 64 bones across all 23 armatures has a bone parent**. A slot's `parent` still identifies its owning bone. Main frame transforms are therefore armature-global poses; adding a main bind-pose transform to a raw frame transform would double the pose.

The main skin references 18 equipment sub-armatures, including `装备/fashion_wq1`, `装备/fashion_yf8`, head/body/limb pieces and four placeholder pieces. Both main slots `wq1` and `wq12` reference the staff armature; `wq12` is alpha-zero in all requested ordinary clips. Rendering all slots without alpha gives two staffs.

Every image display name resolves in the 35 atlas names, and every armature display name resolves in the 23 armature names. No missing texture or externally fetched appearance part was found.

Each equipment armature has a single bone and a single image slot. It has two animations whose names are **JSON numbers**, not strings:

- `1`: one-frame duration, one timeline; visible default equipment image.
- `0`: one-frame duration, no timeline; the legacy parser's hiding rule makes the piece invisible.

Normalize animation lookup keys to strings so `"1"` can select numeric `1`. Choose equipment animation `1` explicitly in the bake profile. Do not choose `0` as the first sorted numeric animation, and do not fall back from its empty timeline to bind-pose visibility. A nested armature lacking the parent's clip name can use an explicit profile selection; equipment is static, so no equipment clock synchronization is needed here.

Useful exact equipment data:

| Piece | Child bone translation | Child image display translation | Atlas size |
| --- | --- | --- | --- |
| `fashion_wq1` | `(45, 34)` | `(-5, -60)` | `10 x 120` |
| `fashion_yf8` | `(24, 24)` | `(-32, -32)` | `64 x 64` |
| `fashion_yf6` | `(10, 10)` | `(-12, -12)` | `24 x 24` |
| `fashion_yf11` | `(15, 12)` | `(-17, -14)` | `34 x 28` |

The source includes substantial offsets inside equipment armatures. Ignoring child bone transforms or treating parent slot translation as a leaf texture pivot disconnects equipment from the body.

### Available clips and timings

All durations below are source ticks at 30 FPS, not measured Hollow Knight timings. All ordinary body timelines in each row share the listed keyframe durations; the invisible `wq12` timeline is an exporter exception described below.

| Clip | Duration ticks | Seconds | Ordinary body keyframe durations | Suggested bake behavior |
| --- | ---: | ---: | --- | --- |
| idle | 22 | 0.733333 | 4, 3, 4, 4, 3, 4 | loop |
| walk | 24 | 0.8 | 6, 6, 6, 6 | loop |
| runNormal | 12 | 0.4 | 3, 3, 3, 3 | loop |
| jumpNormal | 35 | 1.166667 | 35 | single held pose |
| jumpTwo | 12 | 0.4 | 3, 3, 3, 3 | source loop; Mod may stop when state ends |
| jumpDown | 35 | 1.166667 | 35 | single held pose |
| hurtStand | 49 | 1.633333 | 49 | single held pose; gameplay controls exit |
| dead | 65 | 2.166667 | 2, 2, 2, 2, 57 | once, hold final pose |
| attack1 | 12 | 0.4 | 2, 2, 8 | once |
| attack2 | 15 | 0.5 | 2, 3, 10 | once |
| attack3 | 18 | 0.6 | 3, 2, 2, 2, 2, 7 | once |
| attack4 | 20 | 0.666667 | 2, 3, 2, 13 | once |

`runAttack` (15 ticks) and `jumpAttack` (10 ticks) also exist. Baking `jumpAttack` as a visual asset is possible without implementing new air attack mechanics. Up/down/air/dash/wall/bench/focus/spell poses must have explicit playback fallbacks in the Mod; no matching source clip should be invented. Reusing a baked Wukong pose/clip for an unsupported state must never re-enable the original knight renderer.

`loop` is explicitly 0 for idle, walk, runNormal and jumpTwo; missing loop parses as 1 in the compatible legacy parser. Gameplay state duration and combo windows belong in a separate reviewed configuration. The animation manifest should retain the raw duration and rational FPS to avoid cumulative rounding drift.

### Exact legacy parsing semantics

The best reference is **DragonBonesAS tag v4.1, commit `8ca37348a56728d0386327e9255c86a62c9ca5a5`**, which contains a dedicated old-data parser. Its `ObjectDataParser` explicitly routes versions 2.3 and 3.0 to `Object3DataParser`. It also matches the parser class names found in the original SWF strings. Do not interpret source version 2.3 as requiring the unmodified V2.3 runtime: that earliest raw object parser lacks robust sparse-field defaults used by this export.

Authoritative contracts at that commit:

| Contract | Evidence and implication |
| --- | --- |
| Version dispatch | `src/dragonBones/objects/ObjectDataParser.as:70`, cases at 80–82: 2.3/3.0 use Object3DataParser. |
| Global data default | `Object3DataParser.as:47`: only `isGlobal == "0"` means local. Absent `isGlobal` means global. |
| Transform defaults | `Object3DataParser.as:479`: absent x/y/skX/skY/pX/pY become 0; absent scX/scY become 1. Angles are degrees converted to radians. Preserve negative scales. |
| Null versus missing | `Object3DataParser.as:519` and `:542`: explicit null is false for booleans and NaN for numbers; a missing key uses the supplied default. Python `dict.get(...) or default` is incorrect for distinguishing zero/negative/absent/null. |
| Loop default | `Object3DataParser.as:250`: absent loop -> 1. |
| Frame display default | `Object3DataParser.as:378`: absent displayIndex -> 0; -1 means hidden. |
| Visibility | `Object3DataParser.as:374`: `hide` defaults false and hide=1 suppresses the display. |
| Z order | `Object3DataParser.as:381` plus `DBDataUtil.as:210`: source-global frame z is an absolute order, converted internally to slot-relative z; do not add source slot.z again. Absent z means unchanged. |
| Last-frame repair | `Object3DataParser.as:456`: positions accumulate, then the last frame duration is set to animation duration minus its position. |
| Missing timeline | `DBDataUtil.as:336`: absent bone timelines enter the hide map. Empty equipment animation 0 must hide its image. |
| Color | `Object3DataParser.as:500`: multipliers are percent, offsets are channel integers; absent color is identity. |

**Tweening is resolved, not an open general-runtime requirement.** In the entire asset, every animation has autoTween=0 or explicit null, both false under the parser. Frame easing is either missing (legacy sentinel 10, auto) or explicit null (NaN). At `animation/TimelineState.as:401`, with autoTween false, both NaN and sentinel 10 disable interpolation. Therefore these requested clips **hold their keyframe pose until the next boundary**. A bounded converter should implement this rule and fail if a future asset requests active tweening, rather than silently interpolate or claim generic DragonBones support.

The exporter has oversized single-keyframe `wq12` durations, for example walk=337 ticks despite its 24-tick clip and attack1=286 despite its 12-tick clip. These are real source anomalies. The legacy last-frame repair handles them. Validate/repair the final keyframe only; do not extend the clip or reject the known source because raw timeline sums differ.

The v4.1 AS parser rounds frame durations to integer milliseconds. A converter should declare whether it follows that exact clock or preserves source rational 1/30-second ticks. Recommendation: preserve source ticks for the new Mod and use keyframe pose comparisons for runtime-reference validation; expect at most small boundary differences against the historical rounded-ms clock. Do not describe rational-tick playback as a byte-identical reproduction of the Flash clock.

### Affine transforms, pivots and root anchor

Use source coordinates (+x right, +y down) throughout offline composition. For a raw transform with angles converted to radians, the forward matrix is:

`a = scX*cos(skY); b = scX*sin(skY); c = -scY*sin(skX); d = scY*cos(skX); tx=x; ty=y`.

That is a full affine matrix; using one rotation plus width/height scaling loses independent skX/skY. `attack3` includes staff scX=-3.42/scY=0.21 and frames where the body scale changes sign; preserve those deliberate poses. Do not smooth across the sign changes.

There are **two different pivots**:

1. Frame transform pX/pY is a bone tween-pivot offset added to its slot's display translation before the bone transform.
2. Display transform pX/pY is the image's registration pivot; texture-local pixels start at `(-pX, -pY)` before display/bone transformation.

The slot contract is visible in the pinned V3.0.1 runtime `Slot.as:262`: origin x/y plus parent tweenPivot, then parent transform. Its `NativeFactory.as:117` draws the image at negative display pivot. The v4.1 old-data parser preserves both data fields separately (`Object3DataParser.as:234` and `:437`). Do not subtract frame pX/pY from the bone's absolute x/y. For image displays in this observed source, display transforms contain translations/pivots only; compose translation and the registration pivot, not a second scale/rotation that the source does not provide.

For a visible top-level slot, start from the raw selected keyframe matrix, then its display translation plus the selected frame pX/pY. For a nested equipment display, recurse into child animation 1, apply the child bone pose and its leaf display translation, then subtract the leaf image registration pivot. Keep the child's image at its own registration point; do not center-crop every part. Static nested equipment can be flattened once as a cached local image/draw list before applying the main slot's affine transform.

There is **no named root/foot bone**. Use a virtual armature origin `(0,0)` as the stable reference across every clip. Compute the union of all visible transformed part corners across all selected clips, pad it, and use a common canvas translation. Store that root pixel in metadata. Do not recenter each frame or set each sprite pivot from its nontransparent bounding box; that produces foot sliding and makes staff reach move the hero.

Use a single constant visual alignment offset and pixels-per-unit in the Mod, calibrated against the existing hero collider/feet. The source origin is near the grounded feet, but exact ground alignment has not been rendered or measured. Preserve source in-pose offsets, including death poses extending below origin. Unity's y-up conversion belongs at the import/renderer boundary. If PNG metadata uses a top-left root `(rx, ry)` on height H, Unity normalized pivot is `(rx/W, 1-ry/H)`; atlas Sprite.Create rectangle Y is converted from top-left separately.

### Display state, effects and alpha details

In idle/walk/runNormal/attack1–4/jumpNormal/jumpTwo/jumpDown, main timelines for `ef1`, `huaban`, `hurteye`, and `mohu` are absent: hide all four. `hurtStand` adds hurteye. `dead` adds hurteye and ef1. Missing timelines must not retain visibility from a previously baked/played clip.

For dead's ef1, source frames are hidden for ticks [0,8), display 0 for [8,32), hidden for [32,65). Display 0 is nested `特效元件/11111`, with eight successive textures lasting 3 ticks each, then hidden at tick 24 of its 25-tick child clip. Reset the child clock when the parent display becomes visible; sampling the child from parent time zero would show the wrong ghost frame. All child effect image pivots are explicit and substantially different; do not use texture center as a substitute.

The asset's only nonidentity main color transforms are alpha multipliers 0 and 80; RGB multipliers remain 100 and all offsets are zero. The requested base/attack clips use alpha0 for wq12 and identity elsewhere. A recursive composition should multiply inherited alpha; full RGB color-transform implementation is unnecessary for this bounded profile if unsupported changes fail validation. All main z values are static in the ordinary requested clips; handle source z explicitly and use stable slot declaration order for ties.

A non-obvious PNG finding: the atlas uses **RGBA `(0,0,0,1)` filler inside subtexture rectangles**, not exact transparent zero. For example fashion_yf8 has 2,081 alpha1 pixels and 1,862 alpha255 pixels; staff has 465 alpha1 pixels and 675 alpha255 pixels. The four 2x2 hair/extra-cloth/earring placeholders consist entirely of `(0,0,0,1)`. A naive alpha>0 content bound is the entire rectangle and these placeholders appear nonempty.

Recommendation: make exact `(0,0,0,1) -> (0,0,0,0)` filler normalization an explicit, deterministic bake-profile setting and record the changed pixel count; preserve all other semitransparent edge pixels. This is a deliberate export cleanup, not an established legacy parser rule. Keep source files unchanged. Do not threshold arbitrary dark/low-alpha colored pixels or make opaque blacks transparent. Preview edges on light and dark/checker backgrounds; use alpha-aware resampling to avoid dark halos.

### Minimal repeatable converter contract

Suggested implementation deliverable (names are design suggestions, no implementation exists):

- Dedicated tool, e.g. `tools/bake_character.py`, reading the existing extracted three-file directory and a checked-in default appearance profile.
- Python 3.12-compatible Pillow as the only new bake dependency, pinned in a tool requirements file; Pillow is absent in the current inspected environment. NumPy is unnecessary for this bounded affine compositor. Add a reproducible installation/bootstrap command during implementation; no dependency was installed in research.
- Strict input/schema/profile checks before evaluating frames: version 2.3, FPS 30, all display refs resolved, no parented bones/meshes/unsupported blend/tween/color/timeline features; validate selected clips and static child selection explicitly. Use a recursion stack to detect cycles.
- Evaluate one pose per source tick, or one pose per distinct keyframe interval with integer duration metadata. Prefer initially emitting every source tick because its simplicity makes validation easier; deduplication can follow without changing timing.
- Build one shared padded canvas/root anchor for all selected character clips, then pack fixed-size cells deterministically into one or more atlas pages. Bound each page size, e.g. 2048 by 2048, and split deterministically rather than assuming every frame fits one page.
- Transparent RGBA PNG pages; manifest records schema version, source hashes, appearance profile, converter/dependency versions, source FPS, clip loop/once policy, ordered frame rects, durations/ticks, fixed root pixel, global alignment transform, atlas hashes, optional named event records. Use sorted iteration and no timestamps in deterministic asset bytes.
- Keep animation data separate from damage windows/hitboxes. An animation's colored pixels and atlas rectangles are neither the player collider nor a combat hitbox.
- Generate a small preview/contact sheet or animated preview for idle, walk/run, jumps, hurt/dead and four attacks, with root crosshair/ground line. Generated previews are review artifacts, not runtime dependency.
- Build verification recomputes/validates manifests, rect bounds, nonempty required poses, tick totals and hashes; packaging copies exactly the generated runtime pages/manifest.

The bake tool should fail visibly when input leaves the supported profile. Do not silently drop a new slot, pick an unrelated child animation, reset pivots to zero, or implement missing features with accidental newer DragonBones defaults.

### Alternatives and trade-offs

| Path | Concrete compatibility evidence | Cost/risk | Decision |
| --- | --- | --- | --- |
| Bounded Python + Pillow bake | Every required local reference resolves; parentless global poses and disabled tweens are proven; nested equipment is static | Need implement correct affine/pivot/alpha/visibility composition and visually validate it | Recommended main path |
| Historical AS runtime + NativeFactory | v4.1 has explicit 2.3 parser; NativeFactory draws source texture pivots | Requires a reproducible AIR/Flash-capable compiler/renderer and exporter harness, absent here; integrating into Unity does not follow automatically | Optional offline reference oracle, not a dependency for shipping Mod |
| Historical JavaScript runtime | Official JS tags V2.4.1 and V3.0.1 exist | Must verify sparse defaults and renderer adapter/canvas semantics; no matching export harness is present | Do not assume easier/compatible merely because JSON parses |
| Modern DragonBones runtime | No direct validation against these files | Schema conversion and compatibility work, plus more runtime surface | No justification for this first delivery |

The real prototype gate is whether the composed default body/staff is coherent and feet stay fixed with the intended registration. If it fails despite matching the documented old-data math, inspect that narrow contract against the historical runtime or original SWF before expanding the converter's supported feature set.

### Meaningful validation cases

1. Resolve all names and assert exact missing-timeline hiding. Idle must have no hurt eyes, death ghost, blur, or skateboard. Switching dead -> idle must reset hidden state.
2. Numeric equipment animation 1 displays; animation 0 produces no image; the four 2x2 filler-only pieces are normalized to empty rather than treated as missing source assets.
3. Default staff image preserves child `(45,34)` and leaf `(-5,-60)` offsets. Compare a known staff pivot against a body hand in idle and attack1; verify no duplicate wq12 staff.
4. Inspect attack1 at ticks 0,1,2,3,4,11 and attack2 at 0,1,2,4,5,14: held poses change exactly at boundaries, with no invented interpolation.
5. Inspect attack3 at ticks 0,3,5,7,9,11,17, especially the -3.42/0.21 staff deformation and positive/negative body scales. Verify no singular transform is interpolated through a flip.
6. Inspect jumpTwo at ticks 0,3,6,9; its staff frame pivot has pY=22. This catches treating frame pivot as texture pivot or ignoring it.
7. Walk's hidden wq12 raw duration337 becomes24 after final-frame repair. Clip end and loops must remain 24 ticks; attack durations remain12/15/18/20.
8. Dead ef1 visibility changes at ticks8 and32; child textures progress in 3-tick intervals starting when shown. Hurt eyes appear only in hurt/dead.
9. Root crosshair and ground line remain at one common pixel over idle/run/attack; mirrored playback changes facing without jumping the origin. Extreme staff/death/effect bounds must not clip atlas cell edges.
10. Deterministic regeneration in two clean output directories yields identical atlas/manifest bytes for the same dependency version/profile. Assert every runtime page appears in the packaged artifact.
11. On the actual client, check scale/feet against hero collider, death/respawn/scene transitions, and Wukong appearance during all retained directional/air attacks and unsupported-state fallbacks. Offline validation cannot replace these checks.

### External references, pinned versions and licensing

Primary source base: [DragonBonesAS v4.1 commit](https://github.com/DragonBones/DragonBonesAS/tree/8ca37348a56728d0386327e9255c86a62c9ca5a5).

- [ObjectDataParser.as](https://github.com/DragonBones/DragonBonesAS/blob/8ca37348a56728d0386327e9255c86a62c9ca5a5/src/dragonBones/objects/ObjectDataParser.as#L70): version routing.
- [Object3DataParser.as](https://github.com/DragonBones/DragonBonesAS/blob/8ca37348a56728d0386327e9255c86a62c9ca5a5/src/dragonBones/objects/Object3DataParser.as): old-format globals/defaults, timelines, display/color parsing.
- [DBDataUtil.as](https://github.com/DragonBones/DragonBonesAS/blob/8ca37348a56728d0386327e9255c86a62c9ca5a5/src/dragonBones/utils/DBDataUtil.as): raw-global pose conversion, absolute z conversion, missing-timeline hiding.
- [TimelineState.as](https://github.com/DragonBones/DragonBonesAS/blob/8ca37348a56728d0386327e9255c86a62c9ca5a5/src/dragonBones/animation/TimelineState.as#L401): disabled auto tween + sentinel10/NaN produces held poses.
- [NativeFactory.as](https://github.com/DragonBones/DragonBonesAS/blob/8ca37348a56728d0386327e9255c86a62c9ca5a5/src/dragonBones/factories/NativeFactory.as): native bitmap drawing and registration pivots.
- [NativeSlot.as](https://github.com/DragonBones/DragonBonesAS/blob/8ca37348a56728d0386327e9255c86a62c9ca5a5/src/dragonBones/display/NativeSlot.as): matrix assignment and display color/visibility.
- [v4.1 LICENSE](https://github.com/DragonBones/DragonBonesAS/blob/8ca37348a56728d0386327e9255c86a62c9ca5a5/LICENSE): MIT; copyright 2012–2013 DragonBones team and other contributors. Include notice/license if copying or translating substantial implementation portions. This license does not license the game artwork.

Supplemental pinned sources actually inspected:

- AS V3.0.1 `304698a85c88a3aebf33423f3f1786cd75665b71`, [Slot.as:262](https://github.com/DragonBones/DragonBonesAS/blob/304698a85c88a3aebf33423f3f1786cd75665b71/src/dragonBones/Slot.as#L262): adds frame tweenPivot to slot display translation. [NativeFactory.as:117](https://github.com/DragonBones/DragonBonesAS/blob/304698a85c88a3aebf33423f3f1786cd75665b71/src/dragonBones/factorys/NativeFactory.as#L117): draws at negative image pivot. MIT license at this commit.
- AS V2.3 `c88d483950173f16e00e6d350465625f6d70fe3a`, [TransformUtil.as:30](https://github.com/DragonBones/DragonBonesAS/blob/c88d483950173f16e00e6d350465625f6d70fe3a/src/dragonBones/utils/TransformUtil.as#L30): forward affine formula. `ObjectDataParser.as` at this commit uses bare Number conversions, making it a weaker sparse-export reference than the later explicit legacy parser. MIT license (`MIT-LICENSE.txt`).
- Official JS tags discovered through GitHub API: V2.4.1 `5d1eeae0baf29cab45003b3a51b220e14a05f3e2`; V3.0.1 `7351419f61b98e9977c1d9e5e37388640941c53c`. These were discovery results only; their execution/export path was not validated.

### Related specs

- `.trellis/workflow.md`: planning/research persistence and review gates.
- `.trellis/spec/backend/index.md` and `quality-guidelines.md`: present but generic unfilled templates; no C#/DragonBones-specific enforceable contract exists there yet.
- `.trellis/spec/guides/index.md`: cross-layer contracts and reuse pre-modification guidance. The atlas/manifest/Unity pivot contract should be captured as a real project spec when implementation establishes it.

## Caveats / Not Found

- No complete composed frame, converter implementation, Pillow install or game execution was performed during research. Source texture visualization alone does not prove a correct assembled character.
- The exact original game's embedded DragonBones source/version and its external fashion-selection code were not decompiled. Explicit equipment animation1 is a proposed default appearance profile supported by local data, not proof of all original skin logic.
- Old-runtime contract references deliberately mix the v4.1 dedicated legacy parser with pinned earlier Slot/NativeFactory matrix/pivot implementations where directly inspected. Do not claim the original SWF is byte-identical to any reference commit.
- The historical runtime rounds to integer milliseconds; proposed new playback preserves source ticks. Record this small timing adaptation.
- `evtMohu_12_0_6,7,10,11` in attack3 is an original game event. Its blur/special-effect behavior was not traced and is not a hit-window specification. The base body/staff poses can be baked without executing it; omit/retain it in metadata explicitly.
- Ground alignment, visible size relative to the knight, visual facing, and directional/air fallback mappings require preview/client validation. There are no source clips named for Hollow Knight up-slash, down-slash, wall-slide, bench, focus or spells.
