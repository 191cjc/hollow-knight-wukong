# Research: Controlled single airborne horizontal staff attack

- Query: Extend the existing ground four-combo into one independently timed airborne horizontal `jumpAttack`, while retaining native air movement, directional/wall attacks, pogo, nail/charm damage and cleanup ownership.
- Scope: internal production source and exact pinned API v77 DLL IL; no client execution and no animation-parser or packaging redesign.
- Date: 2026-10-23
- Baseline: committed source `9517499`; Hollow Knight 1.5.78.11833 / Modding API v77 / net472. Source anchors below describe that baseline before this feature is implemented.

## Findings

### Files found and related specs

| File | Relevant responsibility |
| --- | --- |
| `src/WukongKnight/WukongRuntime.cs:59` | Pre/post native Update observation, owned input, eligibility, native attack capture, fixed-step windows and release. |
| `src/WukongKnight/WukongRuntime.cs:269` | Deferred native contact iteration, pre-FSM DoDamage synchronization and owned responder deduplication. |
| `src/WukongKnight/NativeV77.cs:12` | Version/type-checked private timer, queue, contact and input access. |
| `src/WukongKnight/NativeV77.cs:62` | Per-token native duration/cooldown ownership and release. |
| `src/WukongKnight/Core/ComboTimeline.cs:39` | Engine-free source-tick clock, input sequencing, monotonic serial and per-window target identity. |
| `src/WukongKnight/WukongPresenter.cs:62` | State priority, controlled animation clock and fallback clip clock. |
| `src/WukongKnight/CharacterAssets.cs:99` | Strict runtime combat decoder, currently exactly four ground stages only. |
| `tests/WukongKnight.Core.Tests/Program.cs:10` | Ten checks link actual production core/cleanup source. |
| `.trellis/spec/backend/native-combat.md` | Native transaction, fixed synchronization, dedupe, lifecycle and deferred-contact contract; ground-only eligibility needs an explicit feature extension. |
| `.trellis/spec/backend/character-assets.md` | Existing shared profile/manifest/runtime contract; requires a matching airborne combat definition. |
| `.trellis/tasks/10-23-wukong-character-basic-attacks/research/runtime-implementation-notes.md` | Implemented ownership policies and exact prior IL evidence, including why DoAttack may be invoked for a buffered ground stage. |
| `.trellis/tasks/10-23-wukong-character-basic-attacks/research/quality-review.md` | Important stale-contact regression and production helper; preserve this fix rather than introducing a second hit system. |
| `.tools/runtime-inspect/{controller,update,review}.txt` | Existing exact-API IL dumps, read for input, direction, timing and damage order. |
| `.tools/runtime-inspect/air.txt` | Additional read-only dump generated during this research: Move, HeroJump, DoDoubleJump, BackOnGround and CanDoubleJump. Ignored inspection output, not required runtime payload. |

### Exact native input/direction/timer evidence

All native statements below come from `.tools/hollow-knight-api-v77/Assembly-CSharp.dll`, SHA-256 `0890edcd1b60ae22ea9c4a2d7c16056795b321f0efbb078d447e06730c0e784b`, from the pinned v77 release. Existing `.tools/runtime-inspect/Program.cs` uses Mono.Cecil to print the actual IL. The important evidence is included here so the research remains usable without an ignored dump.

| Native method and IL offsets | Established behavior and implication |
| --- | --- |
| `CanAttack`, IL_0001–0077; `controller.txt:429` | Checks `attack_cooldown > 0`, attacking/dashing/death/hazards, relinquished control and several ActorStates. There is **no onGround, jumping, falling or doubleJumping restriction**. Do not weaken this native gate to admit the new aerial action. |
| `LookForQueueInput`, IL_0101–0126 and IL_021D–0248; `review.txt:1651` and `1745` | A fresh attack press calls CanAttack, then DoAttack; a rejection creates the short native queue. A held queued input can call DoAttack only while the queue is within `ATTACK_QUEUE_STEPS` and CanAttack passes. No custom air combo buffer is necessary. |
| `DoAttack`, IL_0000–000B; `review.txt:1763` | Wrapper emits the ModHooks notification, then orig_DoAttack. It does **not** call CanAttack itself. Buffered ground stages already rely on this fact; do not use DoAttack to start unsolicited repeated air attacks. |
| `orig_DoAttack`, IL_0013–0039; `controller.txt:476` | Writes cooldown from `ATTACK_COOLDOWN_TIME_CH` or `ATTACK_COOLDOWN_TIME`, depending on Quick Slash, before calling Attack. Preserve this recorded transaction's cooldown. |
| `orig_DoAttack`, IL_003F–00C2; `controller.txt:494` | Positive vertical input chooses upward first; negative chooses downward except ActorStates 1/2, where it chooses normal; neutral chooses normal. It then starts the corresponding terrain-thunk coroutine. Preserve this direction selection rather than synthesizing an extra transaction. |
| `Attack`, IL_005F–00F3; `update.txt:396` | WallSliding selects wallSlash first. Otherwise normal direction alternates the existing normalSlash/alternateSlash without testing grounded/airborne. Thus the same capture/window adapter works in air. |
| `Attack`, IL_0809–0845; `update.txt:932` | AfterAttack is before selected StartSlash; Dreamshield SLASH follows. Call the original Attack once per accepted aerial attack and capture only normal/alternate StartSlash, just as ground already does. Do not call a second Attack at the authored hit frame. |
| `orig_Update`, IL_0330–0370; `update.txt:1458` | While attacking and not dashing, increments attack_time; resets at attackDuration. The current per-token `attackDuration=float.MaxValue` ownership is still required to prevent early native completion. |
| `orig_Update`, IL_081B–0834; `update.txt:1849` | Native Update decrements attack_cooldown each frame. ResetAttacks does not do this. |
| `ResetAttacks`, IL_0000–0046; `controller.txt:405` | Clears attack/up/down/nail-charge flags and attack_time; **does not reset attack_cooldown**. The token-scoped timer restoration remains necessary. |
| `FixedUpdate`, IL_023D–0244 and IL_041B–0441; `review.txt:541` and `691` | Native Move still executes while attacking and Jump/DoubleJump advance from their own flags. The new attack should not write rigidbody velocity, gravity, jump counters or ability flags. |
| `FixedUpdate`, IL_024A–02C2; `review.txt:545` | Original turn handling is allowed after ATTACK_RECOVERY_TIME and calls native CancelAttack after FlipSprite. Existing token-aware cancel/reset hooks can retain this. |
| `BackOnGround`, IL_0069–00FD; `air.txt:588` | Clears falling/landing state and sets onGround=true, but calls neither ResetAttacks nor CancelAttack. **Landing cancellation must be explicit in the shared pre/post Update and fixed observation path**. Relying only on ResetAttacks leaves an aerial pulse active after landing. |
| `CanDoubleJump`, IL_007B–0086; `air.txt:678` | Rejects attacking=true. The existing pre-native jump-press cancellation can clear only the owned attack before the same native input is processed. Let native CanDoubleJump/DoDoubleJump decide whether a real double jump is available; never change doubleJumped or counts directly. |

Additional current native transaction caveats already established in the previous task remain applicable: DamageEnemies.DoDamage sends `TAKE DAMAGE` before HitTaker, CancelAttack leaves enteredColliders, and HealthManager native evasion rejection must not consume the sole window target. None requires a separate air damage implementation.

### Concrete minimal design: one scheduler and one ownership path

Keep a **single** core scheduler per hero with a single monotonically increasing serial, plus the existing `slash/nativeToken/pulseWindow` ownership fields. Extend its action mode to `GroundCombo` and `AirHorizontal`; retain the four ground stages and add one air definition. Do not instantiate two independent ComboTimeline objects with independent serials: both can emit token 1, while NativeV77 and stale cleanup compare a single long token.

The smallest useful core extension is:

- Add an attack-kind enum/property and an `AirHorizontal` definition argument/property. An explicit `PressAir(now, scale)` starts one standalone stage only while inactive, resets ground next-stage/grace, and never writes the ground follow-up buffer.
- Preserve `Press` as the ground sequencing entry point; active air input never calls it. A `CurrentStage`/`CurrentAttack` definition property removes the runtime/presenter's hardcoded `assets.Stages[combo.StageIndex]` lookups for active actions. Events should carry kind or sufficient immutable definition identity; an air event must never accidentally index a ground stage after a later transition.
- `Advance` uses the selected definition's tick duration and windows. Air completion emits one StageEnded, clears target memory, buffer, ground next-stage and grace, and does not emit another StageStarted. Cancellation invalidates the token before native cleanup as today.
- Keep the existing native transaction path: owned Attack → capture selected normal/alternate Slash → per-token timer ownership → fixed-step WindowOpened/Closed → native hit/feedback → Release. `Hit`, `HealthHit`, `Damage` and deferred contacts query the same active scheduler, so air gets the already-reviewed dedupe and cleanup.
- Preserve complete Quick Slash scaling through the same seconds-per-source-tick; reuse the scaled-window-vs-fixedDeltaTime gate.

This changes a bounded core and its adapter, without a second input driver, hitbox, FSM, coroutine, or independent cleanup system. A small generic stage clock extracted from ComboTimeline is also valid, but is not required for one extra action if it expands the patch substantially.

### Runtime eligibility, input and cancellation boundaries

Current `ShouldCancel` at `WukongRuntime.cs:125` includes both `!s.onGround` and `s.jumping` unconditionally, and `Eligible` calls it. Merely relaxing Eligible's onGround check cannot enable ascending aerial attacks: the same frame would cancel them. Split common invalid state checks from kind-specific world checks.

| Observation | Required scoped behavior |
| --- | --- |
| Normal horizontal Attack, safe common state, onGround and not wallSliding | Original four-stage ground entry/behavior. |
| Normal horizontal Attack, safe common state, !onGround and not wallSliding | Start the single air definition. Ascending `jumping`, `doubleJumping` and ordinary falling are valid. |
| Up/down/wall direction or unsupported state | Cancel the old owned action before orig once, then retain native direction/Slash/pogo behavior. WallSliding must be tested before choosing either replacement mode. |
| Active ground → !onGround or a jump input | Cancel ground, drop its buffer/grace and let native jump/movement proceed. |
| Active air → onGround | Cancel explicitly, including during owned Slash/DoDamage fixed synchronization; do not allow the old airborne hit to continue grounded. |
| No active stage, ground chain grace pending → walk/fall off platform | Also reset ground nextStage/grace. Otherwise landing quickly without an air attack can incorrectly resume attack2. Do not lose this behavior while removing the old unconditional airborne ShouldCancel. |
| Active air + attack WasPressed + up/down held | Cancel first, then let the original input gate/direction selection run. Add `DownHeld` alongside current NativeV77.UpHeld, using current action state rather than the previous frame's vertical_input before orig Update. Direction keys alone need not cancel a horizontal action without a new attack request. |
| Active ground + up attack | Retain existing cancel/pass-through behavior; ground down remains the original horizontal convention. |
| Active air + ordinary repeated horizontal press | Do not call ground Press, queue a next stage, or restart the current action. Keep replacement-owned queues cleared as today. Once ownership releases, a new press/normal short native queue follows native CanAttack/cooldown. There is no custom airborne combo buffer. |
| Dash/new jump/turn/damage/death/hazard/scene/control loss, disable/detach/failure | Use the same cancel/release path. A normal already-active jump/fall flag is **not** an air interruption; a fresh jump press may cancel before native ability processing for responsive movement. |

Eligibility should use only common safety plus the requested direction/contact mode, not a ShouldCancel predicate that assumes an already-selected ground mode. `CanAttack` should reject while either owned mode is active, then call orig for all other cases. Do not force true to accelerate repeats.

The current pre/post HeroUpdate checks (`WukongRuntime.cs:66`, `82`) and fixed sync (`108`–`114`, plus Slash/DoDamage sync) are useful observation points. They need the same mode-aware policy, not different one-off ground tests. Extracting a small engine-free contact/kind policy is useful if it allows meaningful boundary tests with actual production code.

### Air cooldown policy: preserve native repetition cadence

`jumpAttack` has 10 ticks at 30 FPS, hence 1/3 second before Quick Slash. It can finish before the runtime's native cooldown. Current `NativeV77.ReleaseTiming` (`:74`–`82`) sets cooldown=0 on **all** normal completions; that is intentional for authored ground chaining but cannot silently become the aerial repetition policy.

For air only, record the actual cooldown set by the original DoAttack, keep owned duration at the authored clip duration, and release cooldown as `max(0, recordedNativeCooldown - (now-acceptedAt))` on both completion and cancellation. While owned, cooldown can be `max(authoredDuration, recordedNativeCooldown)`; CanAttack's owned gate also prevents early repeats. Keep the existing deliberate ground completion policy and original cancellation policy. Store this release policy with the same owner token, not as an unscoped global flag that a later ground stage can inherit.

Do not assert a numeric native cooldown default from the API DLL's configurable fields; this research establishes the data flow, not the serialized client prefab values. A pure helper for the max/remainder policy can be linked into tests if extracted; reflection-backed NativeV77 itself is still a real-client boundary.

### Animation replay and data contract

The presenter currently resets `clipStarted` only when the string changes (`WukongPresenter.cs:76`). Two consecutive aerial attacks can share `jumpAttack`, especially with no rendered intervening idle/fall frame. A changed attack token must establish a fresh attack clock even when clipName is unchanged.

For any controlled action, sample `CurrentAttack.Clip` with `combo.Elapsed(now)/combo.SecondsPerTick`, including AirHorizontal. Track controlled token in addition to desired clip if a fallback transition uses clipStarted; returning from a controlled clip to native `state.attacking` using the same name must not reuse an earlier attack's clock. Keep current presentation priority for death/hurt/special states and the native up/down fallback; do not treat fallback jumpAttack art as ownership of native directional damage.

Final parent design chooses required `combat.air_attack = {clip: "jumpAttack", hit_windows: [{start_tick: 4, end_tick: 7}], range_multiplier: 1.0}` and upgrades `schema_version` to **2**. It has no ground `buffer_open_tick`, chain grace or damage multiplier. CharacterAssets should decode it strictly and expose typed `AirAttack` for the shared scheduler; it must not hide the native body after partially accepting a malformed air contract. Profile/bake/Python validator/runtime/fixtures must agree. The new DLL rejects old schema1, while the old DLL rejects schema2 and retains the native hero; frame/atlas structures and generation math are unchanged.

### Recommended implementation ownership and tests

Runtime/core owner:

- `src/WukongKnight/Core/ComboTimeline.cs` (and small shared policy/helper files only if they enable real reuse/testing): one-mode-aware scheduler, one serial, selected definition and transition resets.
- `src/WukongKnight/WukongRuntime.cs`: mode-aware selection/input/contact cancellation; reuse capture/window/damage/cleanup as-is.
- `src/WukongKnight/NativeV77.cs`: DownHeld and per-token air cooldown policy; no scattered private member strings.
- `src/WukongKnight/CharacterAssets.cs`: typed strict airborne definition decoder.
- `src/WukongKnight/WukongPresenter.cs`: selected definition clock/token replay.
- `tests/WukongKnight.Core.Tests/{Program.cs,WukongKnight.Core.Tests.csproj}`: link actual production helper source as needed, preserve all ten prior checks.

Other worker owns profile/bake/validator/package/doc contract propagation. The final shared JSON field is `combat.air_attack`, schema2, as recorded in the parent design before parallel edits.

Meaningful automatic additions:

1. A single air press opens/closes the authored half-open window and ends; repeated presses during ownership never buffer, change stage, or restart. A later deliberate start gets a new token and a fresh window target set.
2. Ground → air → ground shares one increasing token, clears pending ground follow-up/grace, rejects stale ground/air callbacks and restarts ground at attack1. Cover walking off a ledge during **inactive** grace as well as active stage interruption.
3. Same air responder can hit once/window, another responder remains eligible, and closed or canceled tokens cannot hit. Preserve native evasion gating at the adapter rather than “testing” a fabricated game model.
4. Quick Slash scales the air clip/window together; 20ms physics vs low render rate retains a real open window. Include exact start/end boundaries and the minimum scaled-window gate where practical.
5. Actual production world policy allows air while ascending/falling, cancels it on landing/wall/turn/common interrupts, and keeps ground/air mode selection and directional pass-through explicit. No fake Unity controller stub should stand in for the real adapter.
6. Actual production replay selector/clock helper, if extracted: same clip plus a newer token starts at tick 0 even without an intervening rendered fallback frame. Otherwise review direct core-tick usage carefully and document that SpriteRenderer execution still needs client validation.
7. Actual production cooldown policy helper, if extracted: normal air finish before native cooldown retains the remainder; after cooldown clamps to zero; Quick Slash uses the recorded native value; old token cannot change a new ground action. Ground completion cadence stays unchanged.
8. Existing deferred-contact regression remains intact and extends conceptually to air → landing/directional/next air reuse. Do not mutate contacts from inside native Hit traversal or keep old suppression into the next native transaction.

Then compile real Release against pinned API/HookGen references and run the complete project build/check/package path after all owners are ready. No new hooks are required by this minimal design; existing On Attack/CanAttack/ResetAttacks/Slash/damage hooks suffice.

### External references and versions

- Pinned API release: <https://github.com/hk-modding/api/releases/tag/1.5.78.11833-77>.
- API source commit: `3c47ab577dfcac71bcfae73415618c79310b8f52`; prior task records source and DLL hashes in `research/runtime-integration.md`.
- Existing engine compile reference: UnityEngine.Modules 2021.3.33, compile-only; not evidence of an exact installed client engine match.
- Inspection command used for additional evidence: `.tools/dotnet/dotnet .tools/runtime-inspect/bin/Debug/net10.0/inspect.dll .tools/hollow-knight-api-v77/Assembly-CSharp.dll HeroController:BackOnGround HeroController:HeroJump HeroController:DoDoubleJump HeroController:CanDoubleJump HeroController:Move`.

## Caveats / Not Found

- No game installation/Unity process is available. Native FSM collision reach, actual aerial hit timing/damage/soul, charms, repeated-air cadence, terrain feedback, up/down/pogo, landing/double-jump/turn/dash behavior and disable/scene cleanup remain client acceptance items. A successful compile and pure tests cannot mark them passed.
- Original attack collider geometry is retained with reach multiplier 1.0; this does not recreate source AS3 airborne hit geometry. The source animation's window is authored from preview, not independently established original AS3 damage semantics.
- The native input bindings/prefab values and another mod's hook ordering were not run in an actual client. The current raw up/down action-state approach matches existing project code; verify keyboard/gamepad direction inputs in client acceptance.
- Only the task research file and ignored `.tools/runtime-inspect/air.txt` were written by this research pass; no implementation, spec, Git or packaging changes were made.
