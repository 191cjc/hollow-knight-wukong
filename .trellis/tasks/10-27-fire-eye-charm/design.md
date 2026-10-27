# Fire Eye Sigil design

## Behavior and ownership

Repurpose native Deep Focus, charm34, as 火眼之印 / Fire Eye Sigil. Retain gotCharm_34, equippedCharm_34, the original world collectible and native equip list. Its sole new effect is choosing a six-second Jiyuan Fire Eye at successful focus completion, against a three-second base duration. Snapshot the equipment result at activation; a later equipment change affects the next activation. Do not stack duration or reset the existing global heal deadline on refresh.

Keep the existing native focus Soul drain, interruption, final0.7s source artwork clock and one-HP damage-triggered heal path. Remove the former Deep Focus double-heal/charge slowdown, while leaving Quick Focus, Shape of Unn, focus cost hooks and other charm behavior on their original paths. Current immediate healing is already suppressed for ordinary focus.

## Smallest implementation boundary

- Extend Core/BloodthirstyBuff activation to accept the chosen supported duration, with one authoritative3/6 rule and finite-time validation. Test actual production logic with existing linked core tests.
- Add one disposable native charm adapter responsible for the icon/text/cost query hooks, exact hero-focus query suppression, notch recalculation and cleanup. Put native reflection/hook details here or in the existing Focus adapter, not in pure Core.
- Read true native equipment for the buff choice, separately from the suppressed native Deep Focus focus checks. Pass the duration from BloodthirstyFireEye at activation without changing its deferred completion or heal ordering.
- Bind the replacement lifecycle to successful Mod/runtime initialization and attachment. Teardown restores only owned mutations and unsubscribes every hook. Unsupported native layouts must disable/restore the replacement coherently.
- Embed one processed PNG through WukongKnight.csproj; no SFCore, new charm registration or custom persistent settings are required.

## Native contracts

Detailed verified instructions and unresolved client checks are in research/native-integration.md.

1. Return2 from the cost hook only for charmCost_34. Native CalculateNotchesUsed owns aggregate accounting; recalculate on attachment/loaded-save activation and after removing the cost override. Existing overcharm/equip rules stay native.
2. Use CharmIconList.GetSprite(34) and verify direct spriteList consumers. Any array change must save the original and restore only if the same slot still contains the owned sprite. Never change another charm's icon.
3. Scope suppression to the attached hero Spell Control's exact original action reading equippedCharm_34. The read itself observes false; UI, equip bookkeeping and our buff selection observe true. Scope ends before synchronous FSM transitions/events. Never write the saved equip flag or install a global false override.
4. StartMPDrain receives an already selected interval; do not reverse-engineer a new charm multiplier table there. Preserve existing FocusCost hook execution exactly once.
5. Replace charm34 localization keys on their actual UI sheet, with Chinese/English name and effect description. Other language keys pass through.

## Artwork

Use the approved imagegen CLI/API fallback after OPENAI_API_KEY is configured locally. Draft prompt is research/icon-prompt.txt. Concept: a compact hand-drawn pendant, a central ember eye held inside a curled flame, dark organic contour, restrained ivory and ember highlights, readable at native inventory size. No text, scene, border or collage.

Generate using the bundled script with the user-selected gpt-image-2.5-flare, then keep the raw output under output/imagegen/. A reusable offline preparation script writes separate transparent PNG and small-size preview sheets to new charm folders. Use edge-connected backdrop removal and inspect anti-aliased edges on dark and light backgrounds. Determine final dimensions/pixels-per-unit from the native charm's sprite bounds instead of guessing a world-size multiplier. Preserve character art and previous assets byte-for-byte.

Embed only the selected final PNG, with a stable resource name; original output/previews are outside the runtime package. Record hashes and generation/preparation settings for reproducibility of the final processing step. Generation is an external nondeterministic input; the saved original is the reproducible input to offline processing.

## Public image preview

The user explicitly authorized a public preview. After generating and processing the icon, publish a small dedicated preview directory containing the finished PNG and optional dark/light inventory-size comparisons. Use a temporary static server and public tunnel or a suitable image-hosting route. No tunnel is installed yet; select and verify the concrete route during implementation. Provide both a browser preview and direct transparent-PNG URL, check successful HTTP retrieval and matching file bytes, and disclose temporary availability. This delivery depends on the generated image and does not require another publication-approval question.

## Compatibility and rollback

No custom save schema or ownership migration. Existing Deep Focus owners see the replacement while the Mod is active; users who have not obtained it still collect it through the original location. Disabling/removing the Mod restores native Deep Focus behavior and its original cost/icon/text. Recalculate native used notches after cost restoration rather than editing aggregate saved values with hand-written arithmetic. Cover a save with charm34 already equipped and a save without it.

Preserve checkpoint187fca8's Afterimage/Storm mapping, enemy recorder and unreleased enemy attribution. Use a dedicated feature branch for implementation. On verified build/package completion, routine local installation is already authorized: confirm game closed, back up old Mod, copy complete package, and compare hashes if the Windows installation is accessible. Do not claim gameplay acceptance from installation/compilation.

## Verification limits and readiness

Core3/6 expiry, refresh, cooldown and tokens are automatically testable. Native focus branches, charm UI caching, equip accounting, collectible presentation and disable/re-enable need actual-client checks. No in-game behavior has been tested during planning. The final plan was approved. After the first provider rejected both requested models, the user configured a separate private image-service environment. The approved bundled CLI generated the final image with gpt-image-2.5-flare; original, processed PNG and visual review are complete.
