# Fire Demon source presentation restoration (0.4.3-dev)

The user supersedes the centered/raised air region and native landing adaptation.
Restore the original relative spawn/mask conversion and moving character flashes,
trigger the finisher when the air effect expires even in midair, and retain full
cast immunity plus the corrected enemy hurtbox filter.

## Evidence and smallest change boundary

- WKEntity.addEff5_1: source offset (+177 facing, -95 Flash Y-down), spawned at
  main animation frame 5. Air effect duration 31 ticks at 30 FPS.
- WKEntity.advanceTime/addEff5_2: air effect deletion creates effect51 at the
  current entity origin; no floor-contact condition. Finisher lasts 20 ticks.
- Main manV535 `effect5` is 60 ticks. Its torso positions at ticks 8/20/32 move
  around the attack; ticks 12/24/28/35/36 are genuinely empty blink frames. The
  earlier helper normalized this travel and filled gaps; the presenter then hid
  that normalized layer. The untouched `effect5` clip is already in the active
  27-clip atlas, so restoration needs no asset rewrite or new scaled images.
- Skill5 effect5_1 contains twelve nested slash slots; effect51 contains the
  original burst. All are present in the current reader. The missing moving
  character is in the main effect5 animation, not another missing texture file.
- Actual Spell Control Quake Antic invokes RelinquishControl,
  StopAnimationControl and AffectedByGravity(false); its tk2d completion currently
  leads to native downward motion. Hold this state throughout the source cast,
  then directly enter Quake Finish for native damage-mode/state cleanup and
  Spell End's RegainControl/StartAnimationControl/gravity recovery. No Quake Down
  or Land state is needed. PlayMakerFSM.SetState(string) is verified in the local
  PlayMaker DLL. Down/Land and their BigShake events are skipped; the antic EnemyKillShake action is scoped off/restored.

## Implementation boundary

- Core/FireDemonTimeline.cs: production source clock and original mask geometry,
  with half-open timing boundaries independent of ground contact.
- FireDemonSlash.cs: native antic as input/Soul/control gate; source timer owns
  air/finisher creation and damage, source effect5 owns character visual motion.
- NativeSpellV77.cs: release held cast through Quake Finish instead of Quake Down;
  preserve scoped restoration on normal exit, cancellation and unload.
- WukongPresenter.cs / CharacterAssets.cs: display required original effect5,
  retaining its genuine blink gaps instead of hiding the entire source layer.
- Real-source Python and actual production C# regression checks, current package
  notes/specs and installer version/hash. Preserve all artwork, body collision,
  nail effects, Flame Dash and mapped fixed spell damage. No API/save edits.

Validation: source animation bounds/blank frames, atlas-to-source comparison,
time transitions without landing, original offsets/masks in both directions,
immunity/ledger ownership, Release build, package closure, actual preview and
backed-up installation. Gameplay remains pending; the task stays in_progress.


## Completed review and verification

- Inline review followed trellis-check/trellis-update-spec, covering native
  combat and character assets. Reused original effect5 frames; no image pipeline
  mutation or new resized assets were needed. All 22 character files are byte
  identical to the previous installed 0.4.2 package.
- 38 Python checks passed, one Windows symlink-privilege skip. New source checks
  prove travel, genuine blank frames and byte equality of baked/direct samples.
- 27 production C# core checks passed, including original mask conversion in both
  facings, source phase boundaries without any ground input, lag and protected
  finisher/ledger ownership. Existing hurtbox and combo/dash regressions passed.
- Release warnings-as-errors, source inventory, package/export and installed
  24-file closure/hashes passed. Actual 0.4.3 source-atlas contact sheet reviewed;
  a two-facing ground/air animated preview was generated from packaged frames.
  These previews are not gameplay captures.
- Actual native PlayMakerFSM.SetState(string) forwards into Fsm.SetState; native
  Spell Control Finish/Spell End action metadata was inspected for control,
  gravity, spellQuake and damage-mode restoration. Dead/transition guards prevent
  forced recovery on a disappearing hero. No fake game/Unity stubs were used.
- Installed with game stopped: 2026-10-24T11:39:35.107688+08:00.
- Complete previous-Mod backup: `C:\Users\19122\Documents\Codex\2026-10-23\qin\work\backups\installed-WukongKnight-before-0.4.3-20261024-113934.zip`.
- DLL SHA256: `07e80f43a9a4bb9c5ad4535cfdb0052b17ee270a7ed27f1abae37d12b0e7c9ad`.
- ZIP SHA256: `ec63534f4ecbe1d52578c0d4234a7496f25981fd346db5df4d8599efa6e3282c`.
- No API/save changes; downloaded checkout has no .git, so no commit/push.
- runtime_tested=false; real ground/midair combat/control/gravity/immunity and
  visual acceptance remain pending. Task stays in_progress.
