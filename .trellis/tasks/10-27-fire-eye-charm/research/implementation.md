# Fire Eye Sigil implementation evidence

## Production change boundary

Changes owned by the implementation agent are `src/WukongKnight/` and the existing engine-free Core test project. Character assets, image generation/preparation, packaging, docs/specs and public preview are owned by the main session. Other skills, the Afterimage/Storm mapping, read-only enemy recorder and unfinished enemy attribution remain unchanged.

- `Core/BloodthirstyBuff.Activate(now, sigilEquipped)` uses the single production three/six-second rule. Equipment is a boolean snapshot; refresh replaces expiry, invalidates earlier tokens and preserves the shared healing deadline.
- `BloodthirstyFireEye.ReplaceFocusHeal` reads real native charm34 equipment at successful completion, retaining deferred native completion, native focus Soul drain, source clock and one-HP real-damage healing.
- New `FireEyeCharmV77` validates actual charm34 query actions from the attached hero's Spell Control before activation. It uses the pinned original `GetPlayerDataBool.OnEnter` / `PlayerDataBoolTest.OnEnter` implementations, replacing only their `GameManager.GetPlayerDataBool(string)` call with a delegate that performs that same original/API query exactly once and changes the returned value only for exact owned action objects. Each real pinned ILHook is constructed with ManualApply, registered in the owner list and only then applied, so a native-layout exception retains a handle for cleanup. The delegate returns before original Finish/Event code; no global equip-bool hook or saved-flag mutation exists.
- An owning cached FsmBool output already populated before attachment is changed to false; disposal restores a still-owned false output to current actual native equipment. Saved ownership/equipment remain untouched. Unknown charm34 query action types, missing actions or changed native method layout fail the complete hero attachment coherently.
- Cost query is2 only for `charmCost_34`; native `CalculateNotchesUsed` runs after activation and after removing hooks, followed by native `GameManager.RefreshOvercharm`. The first method only changes filled notches; the second applies native filled>available overcharm policy, including an already-equipped save when reducing4to2slots or restoring native cost. Original collection/equip/save identity stays34.
- Localization targets only `CHARM_NAME_34` / `CHARM_DESC_34` on `UI`, Chinese and English. Keys follow SFCore convention; serialized sheet wiring still requires client validation.
- Icon handling hooks original `CharmIconList.GetSprite(34)` and derives pixels-per-unit from original native Sprite.bounds. Cached SpriteRenderers referencing the old sprite are refreshed; disposal scans for only the owned sprite references and restores their source sprite before destroying owned textures/sprites. No global sprite-array mutation occurs.
- Adapter activates only after other hero adapters and lifetime initialize, disposes after the Fire Eye focus adapter, and routes hook-time icon compatibility failures through normal runtime fallback. Version is0.7.7-dev+fsmdump / assembly0.7.7.

## Additional pinned native evidence

A recursive Cecil scan of all pinned Assembly-CSharp types and nested types found `CharmIconList.GetSprite` is the only method directly reading `CharmIconList.spriteList`. Its only compiled external consumer is `CharmDisplay.Start`. Thus no direct-array patch is necessary. Another recursive native scan found charmCost_34/equippedCharm_34 direct field writes only in SetupNewPlayerData; compiled notch counting uses GetBool/GetInt string queries, with no compiled direct-field cost bypass. The scene/FSM may hold serialized icon objects, so pickup presentation and inventory refresh remain client checks.

The production adapter references the real pinned Mono.Cecil DLL with `Private=false`, alongside existing MonoMod.RuntimeDetour and MonoMod.Utils references. It does not add PlayMaker or Unity stand-ins.

## Validation completed

- Existing linked production Core executable:81checks passed. Duration/visual expiry cases cover both3s and6s boundaries; refresh covers both equipment directions, prior token rejection and preserved global cooldown. Existing death/scene/full-health/invalid-time/other-skill cases remain passing.
- Pinned-reference Release build, no-incremental, warnings-as-errors: passed with0warnings and0errors.
- Git whitespace check: passed.

## Final icon integration

The real generated and processed icon is now present at `assets/processed/charms/fire-eye-sigil/icon.png`. `WukongKnight.csproj` unconditionally embeds it as `WukongKnight.FireEyeSigil.png`; CRLF line endings are preserved. No placeholder or alternate runtime file layout was introduced.

After this integration, the pinned no-incremental Release build again passed with0warnings and0errors. Cecil extracted the actual EmbeddedResource data and compared every byte to the filesystem PNG:55,887bytes, SHA-256 `8d397a5d5e9138e4f6a3030fd1cf1db4e358bfe6d920d0d17cac427f745573d5`, exact equality. The final filesystem hash was reread after inspection and remained identical. A later artwork refinement requires the main package gate to rebuild and reverify these bytes.

The existing81Core checks already passed for the unchanged production duration source. No additional Core rerun was needed for the resource-only integration. Git whitespace validation passed after the csproj change. Final full package, public preview and installation gates remain owned by the main session.

## Practical limits

A pinned IL audit also verified `GameManager.RefreshOvercharm` contains exactly the native filled-versus-available comparison and native SetBool writes, with no custom overcharm policy.

No live game or serialized hero Spell Control dump was available. Runtime action discovery, all native charm UI/equip/overcharm behavior, existing/missing/unequipped ownership saves, Quick Focus/Shape of Unn timing, pickup art, scene transitions and enable/disable need the documented actual-client matrix. Compilation and pure Core tests do not establish those results.
