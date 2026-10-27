# Research: Dashmaster awakening and upward native dash

- Query: Repurpose native Dashmaster/charm31 as 烈焰闪·觉醒, add up + dash with at most one upward use before landing, and rename charm34 to 汲元火眼·觉醒. Establish the smallest safe native integration and distinguish native air-dash recovery from a strict landing-only restriction.
- Scope: internal, including direct Mono.Cecil inspection of the real pinned game/API and HookGen assemblies; no fabricated Unity or PlayMaker types.
- Date: 2026-10-27

## Findings

### Files found

| File | Purpose |
| --- | --- |
| `src/WukongKnight/WukongRuntime.cs` | Owns the single hero attachment, native HeroDash call, FlameDash lifecycle and active-dash HP protection. |
| `src/WukongKnight/FlameDash.cs` | Direction-independent collider sweeps, responder deduplication, Sharp Shadow suppression and renderer ownership. |
| `src/WukongKnight/NativeV77.cs` | Pinned private members, native down direction, dash clock and Sharp Shadow/Dashmaster damage synergy. |
| `src/WukongKnight/WukongPresenter.cs` | Selects horizontal/downward flame clips and maps their ticks to the native dash timer. |
| `src/WukongKnight/FireEyeCharmV77.cs` | Existing exact UI localization hook and charm34 lifecycle; current display name is at line148. |
| `tools/bake_character.py` | Separate original flame and upright body sampling; offline downward flame rotation around the source center. |
| `tests/test_down_dash_assets.py` | Existing production-sampler pixel/registration checks for flame-only rotation. |
| `data/character/active-variant.json` | Selects preserved v074 original/enlarged/packed character variants. |
| `docs/FLAME_DASH.md` | Existing native motion, damage, renderer and active-dash protection contracts. |
| `.tools/hollow-knight-api-v77/Assembly-CSharp.dll` | Inspected real native/API implementation. |
| `.tools/hollow-knight-api-v77/MMHOOK_Assembly-CSharp.dll` | Inspected actual On/IL endpoint and delegate availability. |

Evidence is persisted in `upward-dash-hero-il.txt`, `upward-dash-field-uses-il.txt`, `upward-dash-reset-callers-il.txt`, `upward-dash-charm-api-il.txt`, `upward-dash-hook-signatures.txt`, `upward-dash-hook-delegates.txt` and `upward-dash-binaries.txt` in this directory. The binary file records exact SHA256 identities.

### Verified native admission, direction and transaction

1. `LookForInput` gates on accepting input, unpaused GameManager and gameplay scene. `LookForQueueInput` handles the original dash key, calls `ModHooks.OnDashPressed`, then `CanDash`, then `HeroDash`; the native queue also reuses this path. See `upward-dash-hero-il.txt:5597` and `:5838`, especially LookForQueueInput IL_00ba..00f6 and IL_01c8..0212.
2. `CanDash` rejects `no_input`, `hard_landing`, `dash_landing`, positive `dashCooldownTimer`, an existing dash/backdash, an attack before native recovery, `preventDash`, hazard death and missing native `canDash`. The air test is **onGround OR !airDashed OR wallSliding**. There is no per-direction charge. See `upward-dash-hero-il.txt:9495`, IL_007c..009e.
3. `HeroDash` consumes that common air charge by setting `airDashed=true` when airborne and not in acid (IL_0000..0017). It resets attacks, cancels bounce, handles audio/facing, sets `cState.dashing=true`, initializes the original cooldown and shadow-dash transaction and emits the original VFX/FSM events. See `upward-dash-hero-il.txt:6259`.
4. Native down direction requires `down.IsPressed`, airborne, actual `equippedCharm_31`, and **neither left nor right pressed** (HeroDash IL_00ce..0118). It sets private `dashingDown`; otherwise the flag is false. Pure upward selection should mirror those directional restrictions and should preserve down priority when up/down are both held. Grounded up + dash should remain ordinary horizontal dash under the recommended air-only scope.
5. `HeroDash` itself does not perform the CanDash test. Native scripted `RegainControl/startWithDash` can call it directly. Do not use the hook as a blanket replacement for native admission or infer that every caller is an ordinary player key press.

### Verified native movement seam

The patched API's real `HeroController.Dash` is the live method called by FixedUpdate, and has this exact sequence (`upward-dash-hero-il.txt:2616`):

```text
AffectedByGravity(false)
ResetHardLandingTimer()
if (dash_timer > DASH_TIME) { FinishedDashing(); return; }
vector = OrigDashVector()                     // callvirt at IL_0023
vector = ModHooks.DashVelocityChange(vector)  // call at IL_002a
rb2d.velocity = vector
dash_timer += Time.deltaTime
```

`OrigDashVector` selects **live DASH_SPEED_SHARP** only for equipped charm16 plus actual `shadowDashing`; otherwise it selects live `DASH_SPEED`. It then returns `(0,-speed)` for actual downward dash or `(+/-speed,bumpY)` for ordinary dash. See `upward-dash-hero-il.txt:11441`. Do not call `orig_Dash`: it is the old unpatched implementation and bypasses the v77 vector hook.

The narrow recommended seam is an IL insertion immediately after the unique `callvirt HeroController.OrigDashVector():Vector2`, before `ModHooks.DashVelocityChange`. Load `ldarg.0` and transform only `(Vector2 original, HeroController self)` for the attached hero's currently owned upward dash. Because its native `dashingDown` remains false, `(0, abs(original.x))` preserves the exact normal/Sharp Shadow speed already selected by native code. Other native dash vectors pass through unchanged; subsequent ModHooks vector subscribers still run. Validate the unique method signature and the following call before installing; fail initialization safely on a changed layout.

Actual HookGen availability, verified in the pinned DLL:

| Endpoint | On delegate | IL endpoint |
| --- | --- | --- |
| `HeroController.HeroDash` | `void(orig_HeroDash, HeroController)` | `ILContext.Manipulator` |
| `HeroController.Dash` | `void(orig_Dash, HeroController)` | `ILContext.Manipulator` |
| `HeroController.CanDash` | `bool(orig_CanDash, HeroController)` | `ILContext.Manipulator` |
| `HeroController.BackOnGround` | `void(orig_BackOnGround, HeroController)` | `ILContext.Manipulator` |
| `HeroController.FinishedDashing` | `void(orig_FinishedDashing, HeroController)` | `ILContext.Manipulator` |

**There is no On/IL OrigDashVector endpoint in the pinned HookGen DLL.** Do not invent one. `ModHooks.DashVectorHook` exists as `Func<Vector2,Vector2>` and chains subscribers, but has no hero parameter; the exact Dash IL seam provides stronger hero ownership and a predictable position before that chain. See `upward-dash-charm-api-il.txt:6895` and `:6913`.

### Native air charge recovery is not landing-only

The recursive field-reference scan includes nested native iterators; `upward-dash-field-uses-il.txt` is the complete occurrence index for this pinned DLL.

| Native event / method | Effect on airDashed |
| --- | --- |
| Accepted airborne HeroDash, any direction, not in acid | true |
| `BackOnGround` | false, also sets native onGround |
| `ResetAirMoves` | false, also resets double jump |
| `Bounce` / `BounceHigh` / `ShroomBounce` | false when their respective native gates allow the bounce |
| Actual native nail pogo | `NailSlash.orig_OnTriggerEnter2D` calls Bounce; therefore restores the common charge |
| Entering wall slide in LookForInput | false |
| Remaining wallSliding in orig_Update | false repeatedly |
| `DoWallJump` | false |
| `RegainControl` with native startWithWallslide | false |
| `SetStartingMotionState` when actually grounded | calls ResetAirMoves |
| `ExitAcid` | false; airborne dash while in acid does not consume it |
| EnterSceneDreamGate, EnterScene/Respawn/HazardRespawn iterators | false |
| Ordinary damage, dash finish/cancel, double jump alone | no direct airDashed reset found |

Damage may indirectly lead to wall/ground/respawn recovery. Serialized PlayMaker actions and other mods can call public movement methods; the field scan does not prove all runtime event wiring. `SetBackOnGround` itself only sets onGround and does not clear airDashed; CanDash allows grounded heroes regardless.

### Recommended smallest lifecycle

Use the existing one native air charge for all dash directions. Add a separate, unsaved **upwardUsedUntilLanding** restriction only for the new upward direction so that wall slide, pogo, native control recovery or ResetAirMoves cannot permit a second upward use before landing. This guard can restrict native admission; it must never turn a native false CanDash result into true or clear native `airDashed`.

1. A small production Core policy can own the independent upward-used flag and per-dash direction/token. Test accepted/failed starts, landing reset, pogo/wall nonreset, native rejection, cancellation and stale completion. Link that production policy into existing Core tests; do not create fake Unity tests.
2. In a hero-specific CanDash wrapper, call native once, then reject only the exact owned upward chord when its independent used flag is set. A missing charm, a horizontal chord or a grounded dash follows native behavior. Whether a blocked upward chord should be rejected or become an ordinary sideways dash must be explicit; rejection avoids surprising movement.
3. Capture the upward request before calling original HeroDash, from the real charm31 flag and native Up/Down/Left/Right action state. Do not spoof inputs. Call original exactly once. After synchronous native callbacks, recheck runtime/attachment/adapter identity, disposal/failure and actual live `cState.dashing` before beginning the existing FlameDash transaction and consuming the new guard. Selection is latched for that accepted transaction; releasing/changing direction never redirects it mid-dash.
4. The Dash IL callback only redirects the current matching hero/token while FlameDash is active and native still reports dashing. Recheck death/hazard/scene/recoil/control state through the existing Observe path. Do not set `dashingDown`, `onGround`, `isInvincible`, unlock/equipment/save flags, cooldowns, timer, collider, constraints or root rotation.
5. Reset the independent guard on confirmed native grounding, not on `ResetAirMoves`, bounce, wall slide, wall jump or ordinary control return. `BackOnGround` is unconditionally grounding and is also called by FailSafeChecks and hard/dash-landing timeouts; its name alone is not proof of physical contact. Corroborate post-BackOnGround/grounded observation with the real native `CheckTouchingGround()` where appropriate, or verified native bottom-contact handling for Terrain/HeroWalkable surfaces. The native ground query uses three downward rays against layer8, so retain acceptance for HeroWalkable objects on other layers. Because the recommended upward entry is air-only, immediate stale grounded state at start does not erase the consumption. A future grounded upward launch would need an explicit leave-ground state and cannot reuse a simple grounded reset safely.
6. Dash completion/cancel releases the per-dash direction and damage/presentation token while retaining the independent used flag. Native landing replenishes it. Hero replacement, scene detach, death/respawn and adapter disposal clear local lifecycle state and remove all hooks; no state is written into saves. Charm unequip/re-equip while airborne should not replenish the flag.
7. Keep FlameDash's existing sweep/overlap masks, unchanged hero bounds, once-per-responder ledger and stale-token checks (`FlameDash.cs:61`, `:96`). Keep Sharp Shadow source suppression/restore (`:43`, `:107`) and runtime incoming protection (`WukongRuntime.cs:75`). Upward is the same damage/protection transaction, not a second custom attack.

### Completion momentum and collision caveats

`CancelDash` clears shadowDashing/dashing, resets dash_timer, restores gravity and disables native effects, **but does not zero Rigidbody2D velocity** (`upward-dash-hero-il.txt:7272`). `FinishedDashing` invokes CancelDash and native animation/`HeroCtrl-DashEnd` events (`:7707`). FixedUpdate caps only negative fall velocity (`:1331`). Consequently rotating the vector alone can leave positive upward momentum after DASH_TIME; native gravity decays it rather than instantly ending displacement.

There is another native interaction: LookForInput calls `JumpReleased()` on every Update where jump is not held (`:5806`), and that method can zero positive y after its own native minimum-step/acid/shroom tests (`:7639`). Therefore native-only upward tail can depend on whether jump is held. Do not claim a fixed upward displacement from vector rotation alone.

Two defensible completion choices:

- **Smallest:** retain native velocity/gravity cleanup entirely and document/test the natural upward tail, with jump-held/released cases.
- **Consistent end:** add narrowly owned positive-y cleanup at the real successful FinishedDashing boundary. Capture the current dash token and prove the positive velocity is still the adapter's last applied upward output; clear only that y, preferably before native synchronous DashEnd events so a later native event's new motion wins. Never blindly zero all velocity after orig, or during death/hazard/scene/recoil/cancellation, and do not erase new jump/pogo/conveyor/other-mod motion. If ownership cannot be proved, leave it native. This is an intentional addition to the native motion contract and needs explicit tests/client checks.

Native `OnCollisionEnter2D` handles ceiling contact by canceling jump/double jump/bounce, but **does not cancel an ordinary dash on top contact** (`:9783`, IL_00a7..0142). The native collider physically blocks upward movement; without an intentional extra rule the dash timer/protection can remain active until normal finish. Keep collision/collider behavior native, and test low ceilings/corners/thin platforms. Setting dashingDown=true would instead also enable downward landing hard-land behavior and wrong VFX/animation/wall-facing logic, so it is unsuitable.

### Charm31 and rename details

- Real native identity is `gotCharm_31`, `equippedCharm_31`, `charmCost_31`, `newCharm_31`. SetupNewPlayerData initializes the cost to **2** (`upward-dash-charm-api-il.txt:3708`, IL_10a7). Preserve native acquisition and saved identity; no new ID, auto-grant, SFCore or cost override is needed.
- Native HeroDash selects DASH_COOLDOWN_CH when charm31 is actually equipped (IL_01ba..01e1). Move combines charm31 + grounded Sprintmaster/charm37 through RUN_SPEED_CH_COMBO (`upward-dash-hero-il.txt:1892`). Preserve both existing bonuses unless requirements explicitly replace them.
- Existing FlameDash damage code already checks actual charm16 + charm31 and applies1.5x nail damage (`NativeV77.cs:165`); preserve this and native source deduplication. The complete original Sharp Shadow damage interaction may also involve serialized FSM data; the C# operand scan alone does not establish that wiring.
- Existing localization pattern uses exact UI sheet keys `CHARM_NAME_34`, `CHARM_DESC_34` (`FireEyeCharmV77.cs:144`). Rename charm34's displayed Chinese name exactly to **汲元火眼·觉醒**, retaining current icon/cost/3→6seconds. For charm31 use `CHARM_NAME_31` and `CHARM_DESC_31` in UI, exact Chinese name **烈焰闪·觉醒**, description covering retained native dash bonuses plus upward chord/landing-only restriction. The standard suffix key convention is corroborated by existing task research; real client display remains acceptance.
- The user requested new names/ability, not a new charm31 icon in this follow-up. Reuse the native Dashmaster icon unless main scopes additional artwork.

### Artwork selection seam and affected files

Presenter currently selects `flameDash.Downward ? flameDashDown : flameDash` at `WukongPresenter.cs:115`, then recognizes only those two as native-clock dashing at `:138`. Add an owned Upward property and an upward clip to both paths. Keep upright body, native dash progress, white dash color and native mesh visibility rules.

For input, extend the existing version-gated `NativeV77.Held` pattern (`NativeV77.cs:65`) with LeftHeld/RightHeld caches for the real HeroActions.left/right fields. Native direction tests use these separate IsPressed values, not the filtered `move_input` scalar. Existing UpHeld/DownHeld are already available.

`tools/bake_character.py:139` rotates **only** source `flame_dash_fx` around the registered center using Affine; body draws are unchanged. A matching upward clip should rotate flame draws counterclockwise in source Y-down coordinates around the same center, through the reusable offline pipeline. Save new original/enlarged/packed variant folders and select them via the active variant, preserving v074 and old baked pixels. Do not rotate the whole composed body/view/root, scale runtime art or enlarge colliders. Extend actual sampler/pixel tests analogous to `tests/test_down_dash_assets.py`.

Likely owners: new upward adapter/Core policy, runtime hook/lifecycle wiring, FlameDash direction, presenter, native field/input helper only if necessary, FireEyeCharmV77 localized names, new charm31 localization adapter or carefully shared UI hook, character baker/profile/variant and asset/package validation, docs/FLAME_DASH.md, CLIENT_ACCEPTANCE and owning native/asset specs.

## External references and related specs

- Pinned baseline contract: Hollow Knight1.5.78.11833 / Modding APIv77 / net472. Binary inspection is local and uses the genuine pinned Mono.Cecil; identities are in `upward-dash-binaries.txt`.
- Existing task localization evidence: SFCore CharmHelper, https://github.com/SFGrenade/SFCore/blob/master/src/CharmHelper.cs, blob `db34ce29a3d70b789f1874f72d1f7ad401e9f590` (already recorded in the parent task; not newly fetched here).
- `.trellis/spec/backend/native-combat.md`: native dash transaction, unchanged collider, token rechecks, Sharp Shadow deduplication, native down direction and active owned-dash HP protection.
- `.trellis/spec/backend/character-assets.md`: preserved sources/variants, offline appearance changes, reproducible manifests/package validation.
- `.trellis/spec/guides/index.md`: search before changing constants; cross-layer ownership.

## Caveats / Not Found

- **Product ambiguity:** native lateral/downward/upward dashes sharing one air charge versus granting an independent extra upward charge. Recommendation: preserve the shared native charge and layer the landing-only upward restriction; granting extra charge would intentionally bypass one native admission condition and requires additional scope.
- Native recovery by wall/pogo is verified and is broader than literal landing-only. The independent guard above enforces the user's stronger restriction without weakening native dash eligibility or altering the existing downward charge behavior.
- Ground upward launch, residual upward momentum and immediate dash termination on ceiling are separate possible behaviors; neither comes free from native down-dash support. Air-only entry plus native collision is the smallest scope. Record the momentum choice before claiming behavior.
- No real client was launched. Serialized prefab DASH_TIME/DASH_SPEED/cooldown values, live charm UI wiring, controller directional thresholds and terrain/protection behavior were not proven by compilation or IL. Use live fields and keep actual-client acceptance pending.
- This research wrote only task research files; it changed no product code, specs, task planning artifacts or git state.
