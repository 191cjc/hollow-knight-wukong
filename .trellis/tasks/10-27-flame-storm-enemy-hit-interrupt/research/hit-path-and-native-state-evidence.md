> Planning update (2026-10-27): the user selected attack cancellation plus each enemy's native default behavior and requested a development version. The revised ../prd.md, ../design.md and ../implement.md are authoritative. Earlier hurt-animation and research-only descriptions below are historical; no product implementation has started.

# Flame Storm interruption: baseline evidence

Baseline: `main@cadb864`, version `0.7.6-dev`. Planning only; no product code changed.

## Confirmed integration boundary

- `src/WukongKnight/FlameStorm.cs:75`: fixed-step skill dispatch. It resolves actual local hurtboxes with `NativeV77.SkillTarget`, checks native hit evasion and spends its existing responder contact budget before invoking the native hit wrapper.
- `src/WukongKnight/FlameStorm.cs:93`: the current successful contact does not verify actual HP loss or force an enemy state. Contact-ledger acceptance alone is insufficient proof of damage.
- `src/WukongKnight/NativeV77.cs:181`: `SpellHit` dispatches TAKE DAMAGE before `HitTaker.Hit`; synchronous native callbacks can cancel the skill, destroy targets or unload the Mod. Its ownership check must remain effective before any later interruption effect.
- `src/WukongKnight/WukongRuntime.cs:435`: the existing `HealthManager.Hit` hook captures HP around the actual original dispatch for Fire Eye healing. A future interruption design must likewise distinguish actual nonfatal HP loss from contact, invincibility and death, and attribute the exact Flame Storm source/transaction.
- `src/WukongKnight/Core/SpellHitLedger.cs:31`: contact tokens, per-responder caps and minimum 0.1-second spacing remain authoritative. Rejected damage must not create additional contact retries or expand the existing damage budget.
- `src/WukongKnight/Core/FlameStormRules.cs:7`: the source action lasts 16 ticks at 30 Hz; the current hit cap is five. Do not extend its clock to implement enemy reaction.
- `src/WukongKnight/FlameStorm.cs:99`: Dream recovery and the successful native QuakeInvuln tail belong to the player skill and are independent of enemy reactions.

## Native evidence and limitations

- Existing local read-only IL notes `.tools/runtime-inspect/health.txt:119` show `HealthManager.NonFatalHit`: alternate hit animation playback and default 0.2-second hit evasion are separate native paths. Neither proves that an enemy AI stopped its attack or entered an AI hurt state.
- Existing native metadata lists `sendHitTo`, `hasAlternateHitAnimation`, `alternateHitAnimation`, and `stunControlFSM`. Their presence is not evidence of a universal interruption API. Target-specific serialized state machines are still needed.
- `.tools/runtime-inspect/native.txt:584` records the native `HealthManager.Hit` damage dispatch. Existing actual-native introspection tools and compile DLLs are available locally; they do not contain a verified catalog of scene/prefab enemy hurt states.
- The previous assessment in `.trellis/tasks/10-23-wukong-character-basic-attacks/research/control-swap-v076-20261026.md:36` explicitly left forced hurt unimplemented. It recommends verified enemy adapters plus native fallback, including attack-residue and phase handling.

## Design constraints established for later planning

1. Attribute a hit to the current Flame Storm source and token, verify nonfatal actual HP loss, then recheck skill/target ownership before applying a supported reaction.
2. Keep version-sensitive reflection and native-state access in a dedicated v77 adapter rather than adding string-based FSM mutation directly to the skill query loop.
3. A support contract needs enemy identity, exact FSM/structure, eligible source states, a validated hurt entry and recovery path, and attack-specific cleanup. A state named Hurt is insufficient. Unknown layouts fall back to existing damage/recoil.
4. Ordinary enemies and bosses follow the same user requirement. Do not substitute a boss stagger/phase event for a normal hurt response or promise unverified broad coverage.
5. Do not globally alter enemy invulnerability, stun thresholds, speed, movement, colliders or other skill hits. Do not indiscriminately destroy enemy projectiles or children.
6. The user explicitly chose to restart hurt on every actual damaging contact, including contacts during an existing hurt reaction. Preserve the original damage cadence and native rejection rules. No product implementation or task activation before final planning approval.

## Pending evidence collection

Inspect the actual baseline enemy prefabs/FSMs before choosing initial supported reactions. Record where each artifact came from; do not infer serialized state layout from C# member names. Automated pure-policy tests can verify gating, ownership and fallbacks, while attack cancellation, hurt animation, cleanup and recovery require client acceptance.

## Available environment inspected

The current Linux checkout has pinned API/compile DLLs and a built `.tools/runtime-inspect/` utility. The project `work/` directory is absent. Existing local artifacts stop at older 0.3 development builds and are not the latest 0.7.6 client/package evidence. No actual enemy prefab/state-machine catalog was found in the inspected project locations; historical Windows install paths are documentation, not locally inspected assets.
