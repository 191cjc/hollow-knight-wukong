# Jiyuan Fire Eye and Flame Dash awakening charms

## Goal

Provide two awakening charms in existing native inventory slots: a two-notch
Jiyuan Fire Eye duration upgrade and a Dashmaster upgrade enabling one upward
Flame Dash before landing. Preserve native acquisition and save identity, and
deliver the generated Fire Eye icon through a public link.

## Background and decisions

- The user approved this task and implementation on 2026-10-27. Checkpoint
  `23852f3` implements the original3/6-second Fire Eye and charm34 replacement;
  the user explicitly authorized that local commit. This increment follows the
  same user's request to rename it and repurpose Dashmaster.
- Deep Focus is native charm34. It now costs two notches, keeps its collectible
  and got/equipped flags, and replaces its former focus-healing/slowdown effects.
  The earlier automatic-unlock proposal was superseded by native acquisition.
- Dashmaster is native charm31. Its downward dash, cooldown and Sharp Shadow
  interaction remain on native paths. `CanDash` shares native `airDashed` across
  directions; walls/pogo can reset or bypass that native allowance. Evidence is
  in `research/upward-dash*.txt` and the focused research report.
- The user explicitly authorized committing all workspace changes and pushing
  the current branch to the configured Git remote after verification. Existing
  .gitignore rules remain in effect; no further confirmation is needed.
- The user explicitly confirmed that up dash shares the existing native aerial
  allowance, plus a stricter up-only once-before-landing guard. This preserves
  the requested relationship with downward dash without granting an extra charge.
- Preserve checkpoint187fca8's Afterimage/Storm bindings, recorder and unfinished
  Storm attribution work. There is no new charm ID, pickup, key binding or icon
  generation for Dashmaster.

## Requirements

1. Successful focus activates three scaled gameplay seconds of Jiyuan Fire Eye,
   or six when charm34 is equipped at activation. Preserve real-HP-loss-only
   one-HP healing, the shared one-second cooldown, refresh, and cleanup rules.
2. Charm34 displays **汲元火眼·觉醒 / Jiyuan Fire Eye: Awakening**. Keep its
   existing two-notch cost, native acquisition/save identity and generated icon.
   Other focus modifiers retain their native effects.
3. Charm31 displays **烈焰闪·觉醒 / Flame Dash: Awakening** and describes its
   existing benefits plus upward dash. Preserve its original cost, ownership,
   equipment, collectible, downward dash, cooldown and Sharp Shadow interaction.
4. While airborne with charm31 equipped, holding up and pressing the normal dash
   key with no horizontal/down input requests a vertical upward dash. Native
   unlock, ability/cooldown/control and aerial-dash checks must approve it. It
   consumes native dash allowance; it does not grant another horizontal/down dash.
5. At most one successful upward dash is allowed before a real landing, including
   native HeroWalkable platforms as well as ordinary terrain. Rejected attempts
   do not consume it. Pogo, bounce, wall contact/slide and wall jumps do
   not restore the additional up allowance. Native movement in other directions
   keeps its existing reset behavior. Death/scene/detach clean up the old owner.
6. Reuse native dash speed, duration, collision, control and dash callbacks; change
   only the owned direction. Never fake down input or set `dashingDown` to obtain
   upward behavior. Avoid an extra upward launch after native completion and do
   not erase newer recoil/jump/transition motion. Existing FlameDash hit ledger,
   full-active-dash HP guards and Sharp Shadow deduplication apply upward too.
7. Upward presentation uses the same source12-tick flames rotated offline in the
   opposite direction to downward flames; body/root/aura stay upright. Generate
   a separate profile and original/full1.5x/packed variants, preserve every earlier
   file and clip, and keep pixel enlargement offline.
8. Teardown/failure restores owned native hooks, UI changes and visual suppression.
   Do not write save flags, persistent invincibility, colliders or global inputs.
9. Update the Fire Eye preview title and publicly publish the final preview and
   transparent PNG. Verify HTTP retrieval and matching local bytes; disclose a
   temporary host's availability. Publication is already explicitly authorized.

## Acceptance criteria

- [x] AC1:3/6-second half-open expiry, activation snapshot, cooldown and refresh
  behavior pass production-linked checks at checkpoint23852f3.
- [ ] AC2: Both exact Chinese names appear in native inventory slots34/31 with
  accurate Chinese/English descriptions;34 costs2,31 retains its native cost.
- [ ] AC3: Existing acquired/equipped saves retain identity; uncollected charms
  still use their original pickups. Native equip/overcharm/focus behavior is
  verified in-client, including other focus modifiers.
- [ ] AC4: Equipped31 plus airborne up-only dash moves upward at the selected
  native dash speed and duration; unequipped/locked/grounded/insufficient native
  allowance/repeated-up requests do not bypass native eligibility.
- [ ] AC5: Real landing restores one upward use; pogo/walls do not. Rejected
  attempts, cancellation, scenes, death and replacement cannot leak ownership,
  immunity or old velocity writes into a newer action.
- [ ] AC6: Horizontal/downward dash and normal/shadow dash damage, cooldown,
  immunity, walls/ceilings and Sharp Shadow interaction retain their contracts.
- [x] AC7: The new upward clip has upright body and flame-only rotation; every
  earlier clip retains registered pixels at both sizes and packed reconstruction.
  Core, Python, real pinned-reference Release and package validation pass.
- [x] AC8: Renamed Fire Eye image is visually reviewed and publicly reachable,
  with a direct transparent PNG link matching the embedded resource bytes.

## Out of scope

New charm IDs/SFCore, merchants or auto-grants; Dashmaster icon redesign; enemy
interruption; new input bindings; additional air dashes, costs, damage or collider
changes; reworking existing skills or regenerating archived/older artwork.

## Verification limits

The original icon was generated with the user-selected `gpt-image-2.5-flare` using
locally configured private credentials; no credentials belong in artifacts. See
`research/final-validation.json` and `research/check.md` for checkpoint23852f3's
passing build/package/image checks. Native serialized FSM, inventory and gameplay
acceptance remain pending actual-client execution. The Windows install is
authorized but unavailable from the current Linux filesystem; do not claim an
installation or gameplay test from compilation.

## Current increment verification

The automated/artwork acceptance items above are complete. The full gate passed
70 Python tests and91 linked production Core checks. After review corrected the
native landing matcher's MonoMod ILLabel handling, the affected no-incremental
pinned Release and package checks passed again with zero warnings/errors. The
main audit verified all19 package files, ZIP CRC/bytes, Release/staged DLL equality,
embedded icon bytes and360 preserved inputs. Real MonoMod ILContext checks
reached all three production matcher boundaries and confirmed wrapped ILLabel
targets. Full delegate generation requires unavailable client PlayMaker.dll; it
remains outside the completed offline checks, with no fabricated engine types. See
`research/awakening-final-validation.json`, `research/awakening-check.md` and
`research/awakening-implementation.md` for exact evidence and final signoff.
AC2..AC6 remain pending actual-client behavior; source implementation and compile
validation alone do not complete those items. This task therefore remains active.
