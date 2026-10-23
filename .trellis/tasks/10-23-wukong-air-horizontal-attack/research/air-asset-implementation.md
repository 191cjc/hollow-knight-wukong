# Air asset and build implementation record

Date: 2026-10-23. Scope: asset contract, Python tooling/tests, package and user documentation. Runtime production source and C# tests were implemented by the parallel runtime owner. No commit or push was performed by this worker.

## Changes

- `data/character/wukong-staff.json` adds required `combat.air_attack` with nonlooping `jumpAttack`, one half-open window `[4,7)` and native range multiplier 1.0. Four grounded stages remain byte-for-byte equivalent as JSON objects.
- `tools/validate_character.py` requires character schema 2 and exports the shared combat validation used by `tools/bake_character.py`. Air definitions accept exactly clip/windows/range fields; validation rejects missing/malformed objects, unsupported fields, looping/wrong clip, noninteger/boolean/out-of-duration windows and nonfinite/boolean/out-of-range reach. Window records accept exactly start/end fields. This also removes the former duplicate profile/manifest combat validators.
- `tools/bake_character.py` emits schema 2. Profile and generator versions remain 1; source sampling, atlas math and artwork are unchanged. Existing fingerprints include profile/baker/validator bytes and schema-1 caches are rejected and rebuilt.
- `tests/test_character_package.py` covers the new contract through the shared validator, authoritative clip duration and range endpoints, exact resource-byte preservation, and failed air validation retaining a prior good package. Existing resource/path/dependency/ZIP tests remain.
- `tests/test_animation_bake.py` verifies actual 10-tick air holds at 0/2/4, deterministic roundtrips, unchanged geometry/tick totals, air settings and old-cache rebuilding.
- `tools/package.py` ships 0.3.0-dev, records `single_air_horizontal_attack`, and explains matched schema-2 resources/DLL and pending client verification. Report schemas are unchanged.
- README, current status, character-assets documentation, processed-assets README and client acceptance cover the new scope, paired resources, landing/input/cooldown checks and native up/down/wall/pogo preservation.
- `tools/prepare_assets.py` needs no feature-specific change: archived source inventory and counts are unaffected. The full build regenerates the same tracked catalogues and development manifest with runtime_tested=false.

## Executed verification

- Initial `.tools/python/bin/python -m unittest discover -s tests -p 'test_*.py'`: **28 passed**, including all 23 previous tests and five new tests.
- Normal `.tools/python/bin/python tools/bake_character.py`: schema 2, **13 clips / 329 ticks / 52 unique cells / 1 atlas**, canvas **231x226**, root **(119,174)**. Atlas **1848x1582**, unchanged SHA-256 `8c7495d94164508119df6da65c389a326a1cda338c82364e51573fb476fb9963`.
- After the runtime owner reported stable, one full `bash scripts/build.sh` with shell pipefail and `tee artifacts/build.log`: **passed**. Original source/research hashes, eight animation re-extractions, PNG/JSON/XML, fourteen full audio decodes, resource validation, **28 Python tests**, **19 linked-production C# checks**, Release and package closure/ZIP bytes passed. Release: **0 warnings / 0 errors**.
- Inspected final ZIP member list, CRC, schema 2 manifest/air configuration and atlas hash from inside the archive. Exactly four files: README, Mod DLL, character JSON, referenced atlas; no source archives, previews, SDK/API/engine DLLs.
- `git diff --check`: passed during implementation; independent final reviewer remains a separate main-session step.

## Initial complete-build output

- Package: `artifacts/WukongKnight-0.3.0-dev.zip`, **534,511 bytes**.
- ZIP SHA-256: `00a35bb7011608200bcdb8a0c3f4d0cc9d2ef08f79fd474e35ddc39240679a40`.
- DLL: **43,520 bytes**, SHA-256 `b89ef76c0dd2df71157d958a606e45ea33655cadbc9d0b76627b39a2abf8adec`.
- Manifest SHA-256: `d352f8cf965e0a5ab8338c02ec9e2dc0fe1c62faeef65c82f66818cd215f28c2`.
- Reports: `artifacts/build-report.json`, `artifacts/character-validation.json`, `artifacts/validation.json`.

These are the initial integrated build results. If independent review changes product code/resources, refresh the appropriate tests/package and use the new final build report hashes.

## Remaining limits

`runtime_tested=false`, `client_acceptance=pending`. No Hollow Knight client was available. Actual hit geometry, rising/falling input, repeated-air cadence, landing/double jump/directional cancellation, charms/soul/pogo, rendering and lifecycle remain unchecked client acceptance items. The authored window is based on held poses, not recovered AS3 damage events. Independent full-scope Trellis review is coordinated by the main session.
