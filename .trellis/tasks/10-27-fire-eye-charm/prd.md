# Jiyuan Fire Eye duration and replacement charm

## Goal

Make Jiyuan Fire Eye a three-second buff by default, with a two-notch charm extending it to six seconds, and provide an original icon matching Hollow Knight's charm artwork.

## Background

- The user approved creating this task and planning on 2026-10-27.
- The latest user request replaces the existing native charm that increases focus healing (Deep Focus), preserving its native acquisition route and save identity. This supersedes both adding a new charm and automatically granting it on save entry.
- Current production behavior is a five-second buff in `src/WukongKnight/Core/BloodthirstyBuff.cs`; native focus completion activates it in `src/WukongKnight/BloodthirstyFireEye.cs`.
- The current Mod already replaces native focus healing, including Deep Focus's immediate heal, with damage-triggered healing. Native charge/drain timing is currently retained. The pinned DLL confirms Deep Focus uses native charm34; notch accounting reads `charmCost_34` through `PlayerData.GetInt`.
- Planning is based on clean checkpoint `187fca8`, which includes the Afterimage/Storm input swap and read-only enemy FSM recorder. Preserve those features and the existing unfinished Storm attribution work.

## Requirements

1. Without the replacement charm equipped, successful ordinary focus grants three scaled gameplay seconds of Jiyuan Fire Eye.
2. Repurpose Deep Focus in its existing inventory position and acquisition route. Do not add another charm ID, introduce custom acquisition, or auto-grant an uncollected charm. Existing ownership/equipment persist through the native save.
3. The replacement costs two charm notches. When equipped at successful buff activation, it grants six seconds total. Preserve the buff's real-damage healing trigger, one-HP amount, shared one-second cooldown, refresh semantics, and cleanup rules.
4. Replace the charm's displayed name, description and icon to explain the Fire Eye duration effect. Proposed name: 火眼之印 / Fire Eye Sigil. Remove Deep Focus's former healing/charge tradeoff as part of replacing its effect; preserve other charms' native modifiers.
5. Produce a new raster charm icon consistent with Hollow Knight's hand-drawn charm UI style, using a flame/eye motif. Keep generated originals and final processed resources in separate locations. Preserve existing character archives/bakes/variants.
6. Disabling the Mod or failing initialization restores the native charm presentation, cost and behavior, while preserving native ownership/equipment data. Keep package contents explicit and reproducible.
7. Publish the finished charm image through a publicly reachable preview URL and provide the transparent PNG. The user explicitly requested public preview on 2026-10-27; publishing this image is authorized.

## Acceptance Criteria

- [x] AC1: Three-second and six-second buff boundaries are exact half-open scaled-time intervals. Refresh replaces expiry, never stacks time or resets the global healing cooldown.
- [ ] AC2: The native Deep Focus collectible remains the acquisition route; an uncollected charm remains uncollected, and previously owned/equipped saves keep that identity.
- [ ] AC3: Charm UI, equip accounting and overcharm decisions consistently use two notches; the new name/description/icon appear in the existing slot.
- [ ] AC4: Equipping the replacement selects six seconds and unequipping selects three seconds for subsequent activations. Other focus/charm timing, Soul costs and all existing attack/skill mechanics retain their established contracts except the explicitly replaced Deep Focus effect.
- [ ] AC5: Initialization failure, hero replacement, scene transitions and Mod disable restore only owned mutations. Native save flags are not rewritten to fake ownership or equipment.
- [x] AC6: Generated icon is visually reviewed at inventory size and has clean transparency; package/resource validation includes the final asset. Applicable core tests, Python package checks and pinned-reference Release build pass; actual client acceptance is recorded separately.
- [x] AC7: A public preview URL opens the finished image, with a direct transparent PNG link; verify HTTP success and rendered content, and explain if the link is temporary.

## Out of Scope

- New charm IDs or SFCore dependency, merchants, new pickups, automatic acquisition, extra charm effects, changes to Fire Eye source casting/aura artwork, or enemy-interruption implementation.

## Validation and Remaining Prerequisites

- The user explicitly approved the imagegen CLI/API fallback. Credentials are read in memory from local Codex configuration without logging secrets. The user most recently specified gpt-image-2.5-flare. After configuring a separate private service environment, generation succeeded through the bundled CLI; no secret is stored in task artifacts.
- Exact focus-action, notch-counting and icon evidence is recorded in `research/native-integration.md`. Real native Spell Control wiring and inventory presentation require client checks; compile/policy tests cannot establish them.
- The user approved the final plan with “开始”; the task is in progress on feat/fire-eye-charm.

## Implementation verification

AC1/AC6/AC7 are verified by automated checks, visual review and public HTTP/byte checks. AC2–AC5 are implemented and independently reviewed; their actual native-client matrix remains pending. See research/final-validation.json and research/check.md. No client gameplay, installation or save/UI acceptance is inferred from compilation.
