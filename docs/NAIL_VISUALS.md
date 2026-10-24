# Original Wukong nail visuals (0.6.1-dev)

Normal ground attacks use the corresponding source attack1..4 body plus arc.
Air horizontal uses jumpAttack. Up nail uses original effect1 rising-strike body
and arc. Down nail uses the upright jumpAttack body retimed10/15 and only the
effect1 arc rotated180 degrees about source center(0,-44.5).

The six independent original overlays come from
assets/zmxy4/animations/2001/skill1V472; body comes from manV535/res. Original
Entity.onUpdateAnimationAfter2 attaches the same-named overlay above the body
at(0,0), using shared animation time and facing. Anticipation/recovery hidden
ticks and original per-image registration are preserved, without tweening.

Offline processing uses tools/prepare_all_assets.py (Windows batch:
scripts/prepare-all-assets.bat). The v06 profile creates new original and1.5x
variant folders and seven separate nonlooping composites, preserving every
earlier input and variant. No new runtime appearance scaling is introduced.

Presenter suppresses only five actual hero NailSlash mesh draw submissions,
restoring prior flags on detach/failed setup. Native attack objects, enabled
writes, damage/upgrades, charm logic, Soul, reach, polygons/clashes, terrain
interaction and down pogo continue. Combo ticks remain authored; other attacks
fit source art to the actual native attack duration, including Quick Slash.
No new projectiles or damage sources are added. Base arc appearance is1.5x artwork. In0.6.1 only the independent arc layer
additionally follows the actual selected native slash reach; body size and
native damage/collider logic remain untouched.

Automated verification covers every original display/hidden schedule, only-arc
center rotation, all105new source/enlarged frames,322preserved asset hashes and
769old frames at each size. Both-facing actual atlas previews are reviewed.
Actual client checks remain pending in docs/CLIENT_ACCEPTANCE.md.


## Native charm scaling

Original v77 NailSlash.StartSlash multiplies serialized baseline X/Y by1.15 for
Longnail,1.25 for Mark of Pride and1.4 for both, or1 with neither. It also selects
animName+" M" for Pride/both; ordinary/Longnail use animName. Thus the original
uses both animation variants and transform scaling, with range controlled by
the numeric transform. Wukong keeps its original source arc sequence and reads
the already-computed native transform result rather than cloning Knight art.

NativeV77.NailRangeScale returns abs(actual.localScale / serialized scale) per
axis. Presenter applies it only to its new arc child SpriteRenderer. Its pivot
compensation (1-ratio)*source-center keeps attachment stable. Body and arc sample
the same existing clock; down body remains jumpAttack retimed10/15. The original
37clips/874ticks remain unchanged, and7arc-only tracks add105ticks. Active v061
art has44clips/979ticks/31pages in new original/offline1.5x folders.

There are no pre-enlarged charm copies and no new body appearance multiplier.
No charm state is written, no extra native slash is started and no hitboxes are
resized. Inactive/cancelled attacks hide the arc; detach destroys its child and
restores native mesh flags through the existing lifecycle.
