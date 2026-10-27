# Independent Fire Eye Sigil review

## Scope and contract loading

Reviewed by the dispatched Trellis check role on 2026-10-27, including the final full-scope pass after real artwork integration and the complete build/package gate. No recursive agent delegation was used.

`get_context.py --mode packages` reports a single repository with no configured packages. Affected layers are the C# Mod/native adapter/Core, the linked Core test executable, Python artwork/package tooling, generated charm assets, user-facing docs and owning backend specs. The backend index has no literal Quality Check section; its linked native-combat and character-assets contracts supply the applicable requirements. The PRD, design, implementation plan, all check.jsonl entries, native evidence and implementation notes were loaded.

## Findings fixed during review

- `src/WukongKnight/FireEyeCharmV77.cs`: the implementation agent changed hook installation to construct each pinned ILHook with `ManualApply`, add it to the owner list, then call Apply. Independent inspection of the pinned RuntimeDetour constructor confirms it adds itself to its context before automatic Apply, without a constructor exception-cleanup handler. The change keeps a disposal handle when native-layout validation fails during Apply. The revised block is consistent with partial-initialization cleanup.
- `tools/prepare_charm_icon.py`: the main session added a native-alpha bypass so matte extraction does not damage semitransparent foreground pixels. The final checker exercised that branch with semitransparent ivory input and confirmed exact retained pixel color/alpha.
- Task provenance/status: stale missing-image statements and the top-level image model were corrected by the main session. Final records consistently identify the real gpt-image-2.5-flare input, successful build and pending actual-client checks.

## Native and policy review

- The Core three/six-second rule is selected once at activation. Refresh replaces expiry, revokes old callback tokens and leaves the global one-second heal deadline intact. Real HP loss, health/full-health eligibility and cleanup remain on the existing production path.
- The focus completion hook reads actual native charm34 equipment, rather than the overridden focus-query result. The IL rewrite has the correct stack shape for both pinned native query methods and returns before their FsmBool store, synchronous event and Finish instructions. It calls the original/API query once and changes only exact owned action results; there is no global false-equipment override.
- A recursive independent Cecil scan confirms the compiled charm34 cost/equipment accesses are the native CalculateNotchesUsed query strings and SetupNewPlayerData initialization writes. The adapter does not mutate native ownership, equipment, equipped IDs or persistent charm cost. Notch recalculation and native RefreshOvercharm run around cost-hook activation/removal.
- Cached focus bools and existing/new icon consumers have conditional restoration. Hook subscriptions/removals are paired; runtime initialization activates the charm only after the other adapters are constructed, and teardown disposes the focus adapter before the charm owner. Missing resource/unsupported layout retains the documented coherent native fallback.
- The independent compiled scan confirms CharmIconList.GetSprite is the only native spriteList reader. Icon replacement therefore avoids an unnecessary array mutation. Sprite bounds determine the resource pixels-per-unit; no hero/artwork/collider scaling was added.
- Changes are scoped to Fire Eye/charm34 and their docs/tooling. Existing Afterimage/Storm mappings, enemy recorder, unfinished Storm attribution, character variants and other skill files remain intact.

No additional confirmed code defect or unaddressed scope violation was found in the final full-scope pass.

## Verification completed

- Whitespace/lint equivalent: `git -c core.whitespace=cr-at-eol diff --check` passed.
- Task context validation: both curated JSONL files passed (7 entries each).
- Type checking/compile: independent pinned-reference Release `--no-incremental` build passed with zero warnings/errors. The implementation agent reran that strict build after ManualApply and final resource integration; the final full build also passed with zero warnings/errors.
- Tests: all 81 linked production Core checks passed independently. Updated assertions exercise both duration/visual boundaries and refresh across both equipment directions, retaining cooldown and token checks.
- Full gate: main-session `bash scripts/build.sh` exited zero. The recorded full-build log shows 67 Python tests passed, all 81 linked Core checks passed, Release succeeded and package validation completed. Earlier generated-fixture failures were resolved by preparing current fixtures with existing tooling, without changing product or test logic.
- Python syntax verification passed for the final preparation/package scripts. No fake Unity/PlayMaker test APIs were introduced.

## Final artwork, public preview and package checks

- Independently viewed the saved raw image and final dark/light preview at 256/96/64 pixels. The flame/eye silhouette remains readable, with clean outer transparency and no white rectangle. The final image is 256x256 RGBA with a fully transparent outer border.
- Repeated the production offline processing into a temporary directory; icon and preview bytes matched the selected assets, and the generated original hash remained unchanged. Source/output separation and the final manifest are consistent. `.gitignore` exposes only this charm folder while leaving other processed variants ignored.
- Independently fetched both public Litterbox links: HTTP 200 with image/png and exact local-byte equality. Preview: https://litter.catbox.moe/3b20ya.png ; transparent PNG: https://litter.catbox.moe/jqwude.png . Temporary retention is 72 hours, approximately until 2026-10-30 08:34 UTC.
- Independently loaded the final staged DLL with the pinned Mono.Cecil and extracted the named `WukongKnight.FireEyeSigil.png` EmbeddedResource. Assembly version is 0.7.7.0; all 55,887 resource bytes equal the processed PNG. SHA256: `8d397a5d5e9138e4f6a3030fd1cf1db4e358bfe6d920d0d17cac427f745573d5`.
- Independently validated the 19-file package closure, every staged report hash, ZIP names/CRC and byte equality for every ZIP member. The staged DLL equals the final built DLL. Raw generation files, previews and game/API/Unity/Cecil dependencies are excluded. Current runtime character resources remain 59 clips / 1559 ticks / 16 atlas pages, validated by the full gate.
- Independently verified all 31 preserved old baseline-cache files against their saved hashes. The three unrelated generated audio/inventory/index changes from asset preparation were restored; final tracked changes are within this task's scope.
- ZIP: `artifacts/WukongKnight-0.7.7-dev.zip`, SHA256 `9acab5d2f65e24b956ff91b2631ef96d4bb95961bae5da16269a57bca7f3b98b`.
- DLL SHA256: `00df7bb966a70ae0c88340a24f2d4fe4ba5e9e4ca68763a3d69fd059a2379d2b`.

Automated and artifact quality checks pass. AC1/AC6/AC7 are supported by the recorded evidence; native-client portions of AC2–AC5 remain explicitly pending in the PRD and acceptance checklist.

## Practical limits

Actual-client acceptance remains pending for serialized hero action discovery, normal/Quick Focus/Shape of Unn timing, Soul/cancellation, charm acquisition/UI/localization/two-notch overcharm accounting, cached presentation and enable/disable/death/hazard/scene lifecycle. Compilation and engine-free checks do not establish these results.

No local Windows installation was performed because the authorized Steam path is not mounted in this Linux environment. The final report keeps `runtime_tested=false`; it does not infer gameplay, save/UI acceptance or installation from the passing build.
