# Native integration evidence for Fire Eye Sigil

Inspected 2026-10-27 from checkpoint `187fca8`, Hollow Knight1.5.78.11833 / Modding API77. No product code or assets changed. Read the sibling IL files for exact compiled instructions.

## Existing behavior

- `Core/BloodthirstyBuff.cs` owns buff expiry, source30Hz aura time, cast tokens and one shared one-second healing deadline. `Activate(now)` currently fixes expiry at now+5. `Clear` revokes the token and healing deadline.
- `BloodthirstyFireEye.ReplaceFocusHeal` intercepts ordinary native Focus Heal/Focus Heal2, activates once, and defers native completion outside the executing action. Damage-triggered `AddHealth(1)` is guarded against recursive activation.
- `NativeSpellV77.FocusSecondsRemaining` computes the native continuous drain remainder. Keep this clock authoritative; no new hardcoded focus duration or charm timing table.
- Production core tests directly link the helper. Existing tests assert expiry, refresh, stale tokens, full-health behavior, global cooldown and visual time against the old five-second duration; update these cases rather than adding a separate implementation-mirroring test harness.

## Charm34 identity and notch accounting

`native-charm-il.txt` confirms public native `gotCharm_34` / `equippedCharm_34` / `charmCost_34` fields. `PlayerData.CalculateNotchesUsed()` reads `equippedCharm_34` with GetBool and `charmCost_34` with GetInt, then writes charmSlotsFilled using the native setter. `EquipCharm(int)` adds the native ID to equippedCharms.

Use the cost query hook to return2 only for charmCost_34. Invoke native notch recalculation after activation on an existing loaded save and after removal of the override; keep native equip, overcharm and ownership rules. Do not assign gotCharm_34, equippedCharm_34, equippedCharms or persistent charmCost_34 merely to install the replacement. Inventory and save reload must see the same native identity.

## Native icon access

`CharmIconList.Awake` only registers Instance. `GetSprite(int)` handles special variants for charms23/24/25/40, otherwise returns spriteList[id]. Thus charm34 uses index34, not33. Prefer a scoped GetSprite hook over changing the global array; inspect other UI consumers during implementation to establish whether any read spriteList directly. If direct consumers need a reversible array patch, retain the original reference and restore only when the same list entry still contains this Mod's own sprite. Existing menu objects caching a previous sprite need an explicit inventory-refresh strategy and client coverage.

The final icon can be an embedded PNG, decoded before hook registration, avoiding a new external runtime directory/schema. Preserve generated originals outside the runtime asset and dispose only owned textures/sprites after restoring UI references.

## Focus slowdown is upstream of HeroController.StartMPDrain

`native-focus-il.txt` shows `orig_StartMPDrain(float)` simply stores its incoming interval, resets drain counters, and reads focusMP_amount. The API wrapper applies existing FocusCost hooks to the amount. It does not test charm34 or calculate a Deep Focus multiplier. Removing the native charge penalty therefore requires the owning Spell Control checks, not a guessed divide-by-constant in StartMPDrain.

`native-focus-actions-il.txt` verifies two original custom actions:

- `HutongGames.PlayMaker.Actions.GetPlayerDataBool`: boolName, storeValue; OnEnter calls GameManager.GetPlayerDataBool, stores the result, then Finish.
- `HutongGames.PlayMaker.Actions.PlayerDataBoolTest`: boolName, isTrue/isFalse; OnEnter calls the same query, emits the corresponding event synchronously, then Finish.

`native-hook-signatures.txt` records available generated hook events for CharmIconList and both custom action types; only their availability, not native Spell Control wiring, is established. Implementation must bind suppression to the actual attached hero's exact Spell Control action and boolName==equippedCharm_34. The boolean read can be overridden only during that owning query; restore the scope before the action sends events or finishes, avoiding leakage into synchronous notch/inventory callbacks. Do not globally make the charm appear unequipped. A separate ordinary equipment read at activation must remain true for selecting the six-second buff.

Use reflection or a compatible exact runtime hook following the project's validated-private-member approach; do not add fake PlayMaker/Unity stubs. Validate actual action ownership/wiring and return to the documented failure fallback on an unsupported layout. No actual serialized Spell Control dump or in-game execution was obtained in this planning pass.

## Localization and lifecycle

The pinned API documents LanguageGetHook(key,sheetTitle,orig), GetPlayerIntHook(name,orig), GetPlayerBoolHook(name,orig), CharmUpdateHook and save-load hooks. Match only the charm34 keys and correct sheet; confirm UI keys from actual consumer/source during implementation. Provide Chinese and English replacement text while preserving all other lookups.

Mod initialization, HeroStart/reattach, inventory opening after enable, reload, partial failure and Unload must share one replacement owner. Existing death and enemy-dump code remain unchanged. Failure of character attachment must not leave charm34 with new cost/UI but native old charge behavior.

## Artwork execution prerequisite

Built-in image generation is not available. The user approved the imagegen CLI/API fallback; OPENAI_API_KEY is absent (only its presence was checked, never its value). Use the bundled CLI once local configuration is available. Default gpt-image-2 with a plain contrasting backdrop plus offline edge-connected background extraction avoids an unauthorized model downgrade. Preserve the untouched generated bitmap, exact prompt, generation settings and final transparency-processing parameters. No generation has occurred.

## Evidence files

- native-charm-il.txt: compiled fields, notch recalculation and CharmIconList.
- native-focus-il.txt: original MP-drain and charm update logic.
- native-focus-actions-il.txt: actual action fields and query/event order.
- native-hook-signatures.txt: generated hook availability.
- focused-native-contract.md: focused original combat/focus constraints for child context.
