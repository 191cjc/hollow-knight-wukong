# 0.7.6 directional control swap and forced-hurt assessment

Baseline main05ea9ea, installed0.7.5. User requested down-spell Earthbreaker and
down-Dream Storm, plus a feasibility assessment only for forced enemy hurt states.

Runtime now owns a single Dream adapter, shared by FistSkills and FlameStorm,
disposed after both. Existing Dream eligibility was moved into that adapter with
unchanged native menu/control/unlock gates and optional down-air support. Storm
receives the existing live Spell Control MP Cost through a borrowed callback;
it uses the extracted controlled-action transaction, begins its16-tick ledger,
and locks input/gravity/velocity exactly as before. It may finish Dream only when
its own ledger was active. Fist ignores down-Dream input; neutral Godslayer and
up-Dream detached Ape keep their existing behavior.

Fist owns down-spell Quake Antic/suppression and observes each acquisition once.
Successful Soul payment starts unchanged Earthbreaker, with native-owner checks
selecting down-spell for Earthbreaker and Dream for Godslayer. Source travel,
terrain sweeps, masks, nail damage, copied ghosts and full-action HP protection
are preserved. Down finish uses Spell End rather than Quake Finish, so the prior
confirmed-player-landing recovery call remains the only grant. Cancellation,
unlanded timeout and adapter disposal cannot acquire automatic native recovery.
Quake Antic has not yet entered the native fall invulnerability states; the
skipped Quake Finish damage-mode reset is therefore unnecessary for this hold.
Storm clears prior parry protection on successful start (as original Quake Antic
did) and grants original QuakeInvuln after successful Dream End. It has no
full-action HP guard. Native ordinary-damage/hazard/timer semantics remain intact.

The extracted Core TryBeginControlled preserves TryBeginDream's original paid/
free acquisition algorithm. Added regressions cover insufficient pre-acquisition
Soul, Soul loss during acquisition, valid reacquisition, payment revocation and
MP-hook exceptions releasing native ownership. Existing Fist transaction tests
also passed. Compiled IL confirms one Dream construction, two shared transaction
calls and scoped successful recovery paths. See reference/flash/fist/control-swap-
v076.json and control-swap-v076-compiled.txt for evidence.

Forced-hurt work was not implemented. Current Storm hits already send TAKE DAMAGE
then native HitTaker/HealthManager damage/hit/Recoil events. Increasing recoil
does not guarantee a hurt-state transition. Some ordinary enemies have dedicated
hurt states; others only flash/recoil. Bosses use different stun/counter/phase
FSMs, and changing state may leave an already-spawned hitbox/projectile alive.
Supporting a selected set of ordinary enemies is moderate work; reliable broad
Boss/all-enemy support is high effort and cannot assume a universal hurt pose.
Recommend explicit supported-enemy adapters and native fallback, with repeated
Storm contacts prevented from accidentally creating endless stun or phase locks.

Validation:66Python passed, one Windows symlink-privilege skip,76actual linked
production C# checks, warnings-as-errors net472 Release and package validation.
All17character resource hashes are unchanged (59clips/1559ticks/16pages).
All19installed files match the verified export, with the game stopped and a
complete previous-Mod backup. No API/save changes. Client gameplay remains
runtime_tested=false and the parent task remains in_progress. The user later
requested committing the current workspace locally; no remote push requested.
