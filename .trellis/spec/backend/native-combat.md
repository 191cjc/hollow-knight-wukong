# Native Hero and Combo Integration Contract

## 1. Scope / Trigger

Use this when changing character presentation, ground/air attack timing, native hook ownership, hit deduplication or lifecycle cleanup. Current baseline is Hollow Knight 1.5.78.11833 / Modding API v77 / net472. Implementation lives in `src/WukongKnight/NativeV77.cs`, `WukongRuntime.cs`, `WukongPresenter.cs` and `Core/ComboTimeline.cs`.

## 2. Signatures

- Pure clock: `ComboTimeline(ComboStage[] stages, AttackDefinition airAttack, double frameRate, double grace)`. `Press(double now, double timeScale)`, `PressAir(double now, double timeScale)`, `ObserveContact(bool onGround, bool jumping, bool wallSliding)`, `Advance(double now, double nextTimeScale)` and `Cancel()` return ordered ComboEvent records. Events carry `Mode` and immutable `Definition`; `CurrentAttack` exposes the selected definition. `TryHit(long token, int window, int responderId)` owns per-window target identity.
- `Core/AttackTiming.Own(long token, AttackMode actionMode, double authoredDuration, double originalCooldown, double now)` returns the owned cooldown. `TryRelease(long token, double now, bool canceled, out double remainingCooldown)` ignores stale tokens. `NativeV77` applies the policy and restores actual private fields.
- Native On hooks wrap exact pinned signatures for HeroController.Attack/CanAttack/ResetAttacks, NailSlash.StartSlash/FixedUpdate/CancelAttack, DamageEnemies.FixedUpdate/DoDamage, HitTaker.Hit and HealthManager.Hit. Private HookGen hooks exist in the locked MMHOOK DLL; do not invent public game members to make compilation pass.
- Version-sensitive reflection belongs only in NativeV77. Check required fields/methods before enabling replacement.
- Mod initialization/unload owns subscriptions and disposable resources; an attached WukongLifetime owns synchronization and detach callbacks for its current hero instance.

## 3. Contracts

- Owned normal horizontal attacks select four-stage ground combo or single airborne `jumpAttack`; up/down/wall attacks retain native semantics, including pogo. Preserve native HeroController, collision, animator, FSMs and resource/save systems. Do not write velocity, gravity or jump counters to implement the air attack.
- One accepted input starts one stage; at most one follow-up can be buffered during the configured window. Fourth-stage completion, timeout and interruptions reset the chain. Held input must not silently auto-play all four attacks.
- Air has no continuation buffer: one accepted input starts one 10-tick action, with one authored half-open window `[4,7)` at 30 FPS before Quick Slash scaling. Repeated active presses cannot queue another air action. Clear queues created by native Update while the action was owned, including the final rendered frame; a later press after release uses native CanAttack/cooldown. Air start/end/cancel clears ground continuation. Leaving a platform during inactive ground grace also clears continuation.
- Ground and air share one clock, one monotonically increasing token sequence and the same native cleanup owner. Events must identify their original action even when Advance ends one ground stage and starts the next. Never use independent ground/air clocks whose tokens can collide.
- Advance gameplay timing in fixed-step synchronization so rendering at 15 FPS does not skip a short hit window. Visual sampling follows the same scaled source-tick clock; Quick Slash scaling applies consistently.
- Each accepted stage initializes its native DoAttack/Attack transaction once. Capture only its selected normal/alternate StartSlash and activate controlled native hit windows; do not call Attack again at the hit frame or add a parallel custom damage source.
- Synchronize an owned DoDamage entry before its native FSM event: native TAKE DAMAGE precedes HitTaker, so synchronizing only in Hit cannot reject all expired-window interactions. Native source damage/FSMs preserve nail upgrades, applicable charms, soul and scene interactions. Do not add SoulGain manually. Original attack polygons and clash interactions require explicit ownership and cleanup.
- Closing an owned slash must also clear its descendant DamageEnemies contact lists: native CancelAttack only disables polygons/mesh and leaves enteredColliders until a later physics exit. If a close occurs during native iteration, defer the list mutation to the outermost FixedUpdate finally and suppress that source's remaining DoDamage callbacks, including TAKE DAMAGE events. Do not retain suppression into a later native air attack. Unload inside a native iterator retains only these cleanup guards until its synchronous unwind completes. `Core/DeferredContactCleanup.cs` owns this tested policy; private contact-list access belongs in NativeV77.
- Hit identity is the actual responder, not the collider. A stage token plus window ID rejects duplicate targets and stale callbacks; stage3 has two independent target sets. A native HealthManager evasion rejection must not consume an opportunity prematurely or be bypassed by rewriting global enemy invulnerability.
- AttackHook/DoAttackHook are Action notifications, not cancelable filters. AfterAttackHook is before StartSlash in this version. ResetAttacks clears attack flags/time but not attack_cooldown; keep a deliberate owned timing release policy.
- Record the cooldown set by this native DoAttack. Air timing ownership uses `max(authoredDuration, nativeCooldown)`; both completion and cancellation release `max(0, nativeCooldown - elapsed)`. A short air animation must not accelerate native repeat cadence. Ground normal completion retains its deliberate authored-chain release policy. Scope the policy to the owning token.
- Preserve native enabled/visibility writes while suppressing the original body drawing. Source Wukong faces right; cancel inherited root mirroring and apply one explicit facing mapping. Up/down native slash effects remain available with Wukong body fallback poses.
- Controlled ground and air visuals sample the current action's source-tick clock. A new token restarts an attack even if the clip name is unchanged; consecutive jumpAttack actions must not reuse a previous fallback clock.
- Cancel/detach closes owned hit windows, clears queued input and restores only the same hero's owned timing/geometry/rendering. Cover jump/dash/turn/damage/death/scene/control loss, disable, hero replacement and failed initialization. Old callbacks cannot reset a newer native action.
- Separate shared interruptions from contact mode: ground cancels on leaving ground/jumping; air permits ascent/fall and cancels on landing. Native BackOnGround does not ResetAttacks/CancelAttack, so observe landing explicitly before/after Update and before fixed damage dispatch, even if the clock already advanced at that fixed timestamp. A fresh jump input cancels ownership before native double-jump gating. Air up/down+attack cancels ownership before original direction/cooldown processing; ordinary up/down held alone does not create an attack.
- Compilation with newer pinned Unity compile references is not an exact runtime compatibility proof. Only the actual baseline client can establish native FSM, charm, collision and rendering acceptance.

## 4. Validation & Error Matrix

| Condition | Required behavior |
| --- | --- |
| Missing/mistyped private member or required engine API | Log and disable replacement; keep/restore original visibility/control. |
| Unsupported or missing asset manifest | Do not hide the original hero; dispose partial sprites/textures/view. |
| Input outside owned ground/air-horizontal scope | Cancel owned state if needed, call original behavior once. |
| Air action lands, or inactive ground grace leaves a platform | Close/cancel owned air damage or reset ground continuation immediately; no stale continuation after landing. |
| Air action completes before native cooldown | Preserve the remaining native cooldown; do not replay an active press through the native queue. |
| Same responder hit twice in one window | Reject the duplicate; a later valid window may hit again. |
| Native target still evading a hit | Preserve rejection; allow a later callback inside the valid window rather than changing enemy-wide state. |
| Interrupted/stale stage token | Close owned damage and reject old callbacks without touching a newer stage. |
| Closing a slash during native contact traversal | Suppress the remainder of that source's traversal, then clear contacts once the final iterator returns; do not mutate the list from inside Hit. |
| No client available | Report compiled/automatically checked separately; actual gameplay remains pending. |

## 5. Good / Base / Bad Cases

- Base: one press starts attack1, its window opens/closes, then control recovers without automatic attack2.
- Good: four intentional ground inputs yield ordered stages; attack3 can hit the same target once per valid pulse; one airborne horizontal press uses jumpAttack; landing closes it, and downslash retains native control and pogo.
- Bad: repeated DamageEnemies callbacks produce extra hits, old cleanup clears a new airborne attack, or successful compilation is described as verified in-game combat.

## 6. Tests Required

- Link the actual engine-free core into `tests/WukongKnight.Core.Tests`; run it using the local SDK. Assert input buffering/cap, timeout boundaries, fourth-stage reset, cancellation, token/window target ownership, two pulses and Quick Slash clock consistency.
- Extend linked-production checks for one air action/no buffer, exact half-open boundaries, per-responder deduplication, consecutive tokens, ground-air-ground resets, inactive grace on leaving ground, landing/ascent policy and air cooldown remainder. Test queue/replay policies through production code where extracted; retain client acceptance for native input and SpriteRenderer execution.
- Link the production deferred-contact helper into the core tests. Cancel during a reverse-index contact traversal, ensure later targets receive no callback, retain nested-iteration guards until outer exit, and allow the same source to start a later native transaction.
- Verify exact compiled hooks/members against the pinned local DLL, and compile Release with warnings-as-errors. Do not create fake Unity/game stubs as a substitute.
- Client acceptance covers two actual HP losses for stage3, duplicate colliders, native soul/breakables/terrain feedback, nail/charms, directional/air/pogo, low FPS, pause, scenes/death/reload and disable/re-enable.
- Review failure cleanup and partial initialization, including registration/unregistration symmetry; pure core tests do not exercise Unity lifecycles.

## 7. Wrong vs Correct

Wrong: clear `hero.cState.attacking` inside AfterAttackHook to skip the native Slash, then send a custom HitInstance and manually grant soul.

Correct: let the original transaction initialize once; defer only the owned selected Slash until the authored window, use the native hit/feedback chain with scoped deduplication, and release that stage's timing and renderer ownership on every exit. See WukongRuntime/NativeV77 for the concrete adapter, and keep its token guards when adding skills.
