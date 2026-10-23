# Independent Bake Preview Review

- Date: 2026-10-23.
- Scope: generated offline previews only; no game execution.
- Reviewed by: main session, independently from the converter implementer.

## Reviewed outputs

- `assets/processed/wukong/previews/overview.png`
- `assets/processed/wukong/previews/idle-contact.png`
- `assets/processed/wukong/previews/attacks-contact.png`

## Observations

- Default Wukong head, torso, limbs, clothing and staff form a coherent character. No obvious disconnected body pieces or doubled staff appear in these images.
- Grounded idle feet remain on the fixed root/ground line across the sampled idle poses. Other source poses retain their authored offsets; do not remove these by per-frame centering.
- Default baked facing is right. Runtime must map this to the pinned HeroController's actual facing/root-scale convention with only one effective mirror.
- Attack1 visibly extends forward at tick4, attack2 at tick5, attack3 at ticks3 and11, and attack4 at ticks5/7. Attack3 ticks7/9 turn backward; they cannot justify a forward-facing native damage window without a deliberate direction policy.
- Sent these frame observations to asset/runtime owners to replace the initial illustrative windows with the reviewed transplant profile.
- Output uses a 231x226 common canvas, root (119,174); exact identical cells deduplicate 329 source ticks into52 cells on one1848x1582 page. This preserves the every-tick manifest timing contract while limiting runtime texture memory.

## Remaining checks

- Final generated manifest/profile must carry the adjusted hit windows and be the version consumed by runtime and packaging.
- Character scale, world placement, transparency synchronization, native directional/air effects and actual damage timing still require runtime/client verification; these images establish none of those results.
