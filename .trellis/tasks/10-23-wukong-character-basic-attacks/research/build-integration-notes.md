# Build and Package Integration Results

- Date: 2026-10-23.
- Owner: build_integration implementer.
- Scope: dependencies, source/generated boundary validation, build/test/package flow, documentation.
- Client testing: not performed; `runtime_tested=false`, `client_acceptance=pending`.

## Changes

- `tools/bootstrap.py` retains existing SDK/API locks and additionally prepares Pillow11.3.0 in `.tools/python` with binary-wheel SHA-256 requirements, plus locked UnityEngine.Modules2021.3.33 compiler references under `.tools/unity-reference/lib/net45`.
- `toolchain.lock.json` adds the Unity NuGet archive URL/hash; `tools/requirements-image.txt` locks Linux x64 CPython3.12–3.14 Pillow wheels. API/Unity compiler references are never package inputs.
- `tools/validate_character.py` is the shared final baked-manifest validator, reused by the converter, build and packaging. It checks source hashes when source inputs are supplied; exact supported identity/schema/13clips, common canvas/root, RGBA atlas hashes/dimensions/CRC/pixel decode, per-tick bounds/totals, ordered four stages and1/1/2/1 windows. Unsupported custom damage fields are rejected.
- `tools/prepare_assets.py` preserves the original raw/archive/reference/re-extraction checks. Its source catalogue no longer claims combat/animation implementation is false; final character validation adds separate baked-assets status. All runtime flags remain false.
- `scripts/build.sh` runs source validation, cached bake, final manifest validation, all Python tests, linked production-core C# checks, Release compilation and packaging in strict fail-fast order. It accepts MSBuild property arguments for compatible reference overrides.
- `tools/package.py` stages through a validated temporary directory and copies only the Mod DLL, instructions, manifest and referenced runtime atlases. It removes stale staging files, rejects unexpected files/symlinks, writes deterministic ZIP metadata, then verifies exact member closure/CRC/bytes. Build report v2 separates implemented, built, automatic checks and client acceptance.
- Documentation updated: README, CURRENT_STATUS, docs/ASSET_INDEX, docs/CHARACTER_ASSETS, docs/CLIENT_ACCEPTANCE and assets/processed/README.
- `tests/test_character_package.py` adds8 meaningful malformed-contract/package tests; it does not duplicate animation/core testing.

## Commands Actually Run

1. `python3 tools/bootstrap.py` — passed; Pillow11.3.0 installed with required hashes; Unity archive SHA-256 verified as `d32d34526d89958c63220d3a5ce26c5c44c11bfd411a2e1fbc3200088ef160c4`; local SDK10.0.402.
2. `.tools/python/bin/python -m unittest discover -s tests -p 'test_character_package.py'` —8 tests passed while integration was prepared.
3. `.tools/python/bin/python tools/validate_character.py` — generated current resource contract passed.
4. After asset and runtime owners explicitly declared stable/ready, `bash scripts/build.sh > artifacts/build.log 2>&1` — exit0. Full source checks including14MP3 complete decode passed;23Python tests passed;9production-core C# checks passed; Release0warnings/0errors; package closure/ZIP bytes passed.

The8package tests check source/hash changes, invalid schema/geometry/ticks/windows/custom damage, unsafe paths, stale-engine-DLL exclusion, referenced-file-only staging, failure preserving a previous usable stage, deterministic ZIP bytes and symlink rejection.

## Final Build Artifacts at This Checkpoint

| Item | Bytes | SHA-256 |
|---|---:|---|
| `artifacts/WukongKnight-0.2.0-dev.zip` |531690|`ef0bfbb5310dfe70afdb3804fd90ae107b811df18902808ad57e95b9dd6cc67d`|
| `artifacts/mod/WukongKnight/WukongKnight.dll` |37888|`185e01c266e9133dc65f94f41dcdf6ef9a81e96a8239475e4d50bcf02f6d8b09`|
| `artifacts/mod/WukongKnight/character/character.json` |57227|`b0c7253fe3682901eff1682ca2add17fb6d79e387d1683e7aa01f2c694522aeb`|
| `artifacts/mod/WukongKnight/character/atlas-000.png` |525049|`8c7495d94164508119df6da65c389a326a1cda338c82364e51573fb476fb9963`|

ZIP contains exactly4files: README.txt, WukongKnight.dll, character/character.json and character/atlas-000.png, under the WukongKnight root. Preview files, original resources and all API/game/framework/Unity DLLs are excluded. Processed character artwork is included as required for runtime.

Reports: `artifacts/validation.json`, `artifacts/character-validation.json`, `artifacts/build-report.json`; full log: `artifacts/build.log`.

## Handoff / Limits

All owned implementation/documentation edits are finished and ready for independent Trellis check. No game installation, deployment, git commit, remote push or archive operation was performed. Actual client rendering, collision, third-stage two HP losses, charms/soul/breakables, pogo and cleanup remain pending. The Unity reference package is a compiler input, not proof of exact client engine compatibility. Any later code/resource edits require new appropriate verification and a refreshed build report/hash.
