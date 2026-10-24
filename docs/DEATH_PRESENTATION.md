# Original Wukong death presentation (0.6.3)

The official resource assets/man/2001/manV535.swf was freshly downloaded over
HTTPS from the archived4399 resource origin. URL, archive SHA-256 and decoded
hashes are in reference/flash/death/provenance.json; raw bundle and decoded
skeleton/texture are retained in that separate folder. They match the previous
original exactly. Runtime reuses the existing65-tick, nonlooping res/dead at30Hz,
including the source falling/prone body and nested ef1 ghost at ticks8..31.
Every original and offline1.5x death frame matches the downloaded source. No
earlier assets are replaced or scaled again.

Native HeroController.Die disables the native body mesh and starts a separate
Hero Death Anim prefab/FSM. Previously Presenter followed nativeBody.enabled,
so the original Wukong dead clip could not be seen. The real Die hook now starts
one idempotent source clock before returning the untouched original iterator.
Presenter captures world anchor/facing and shows white-colored death sprites
despite native mesh enable/alpha, samples65ticks, then holds the prone pose.
It hides the buff/nail layers while dying. A survivable hazard respawn does not
start this full death sequence. Dream deaths enter through the real hook too.

NativeDeathV77 hides only render submissions for heroDeathPrefab and detached
Head/Sword variables; it also mutes only the Blow state's untracked visual-only
FlingObjectsFromGlobalPool(Corpse Nail Hero) action when present in v77. Other
camera/audio/events, Soul/Geo loss, breakable charms, shade/save, dream returns,
Steel Soul handling and respawn continue unchanged. The original FSM is never
disabled or skipped. Captured renderer flags and spawn Enabled value restore on
native resume, scene/hero teardown, initialization failure or Mod disable.

Source timing/pixel checks, actual-reference compilation and compiled hook review
are separate from gameplay acceptance. Pending: ordinary death, dream/boss return,
left/right facing, ghost placement, source65tick pacing, pre/post-death dash
protection, survivable hazards, save/Geo/shade behavior, scene and disable cleanup.
