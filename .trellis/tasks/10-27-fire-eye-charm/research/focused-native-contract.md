# Focus and buff contracts captured for Fire Eye charm planning

Source: `.trellis/spec/backend/native-combat.md`, checkpoint `187fca8`.
The new task explicitly supersedes the prior five-second duration and native Deep Focus effect; retain all other source timing, healing and ownership rules.

## Source lines 134–167

## Spell-slot and focus completion contract (0.5)

- `NativeSpellV77(hero, NativeSpellSlot.Up/Down/Focus)` validates the exact native
  state/action signatures before patching. Up holds Scream Antic1/2 FINISHED;
  down holds Quake Antic ANIM END using a real ignored FsmEvent, not null.
  The actual Tk2dPlayAnimationWithEvents native completion delegate only sends
  that event; OnEnter does not Finish the action independently. Restore all owned
  events/effect renderers/colliders on failure/dispose. Focus never disables
  effect colliders; suppress focus visuals only during ordinary focus, not dreams.
- Replaced up/down antic skips the later native TakeMP state. `SpendSoul()` must
  charge current FSM MP Cost once per accepted cast, including Spell Twister.
  Read screamLevel for Fire Demon and quakeLevel for Storm; no nail scaling.
- Storm uses `FlameStormClock` (16 ticks), `FlameStormRules` (original ab_effect3
  local mask, tier7/11, Shaman11/17) and `SpellHitLedger(cap5)`. Preserve 100ms
  per-target contacts, native evasion and shared sensor filtering. No lag catch-up
  or extra immunity. Maintain input/velocity/no-gravity during the action and
  release through native recovery; never teleport or freeze Rigidbody constraints.
- Fire Eye uses native focus eligibility, drain/cancel and charm timing.
  Animation starts on ordinary focus entry at original30Hz scaled time; native
  Soul progress does not drive it. After overlay completion hold only final
  original body pose. See0.5.3 below; native completion alone activates the buff.
- Intercept only AddHealth during Focus Heal/Focus Heal 2. Suppress immediate
  heal and activate `BloodthirstyBuff`; defer Focus Get Finish until the native
  action returns. Other healing must call the original entry unchanged.
- Buff is `[completion, completion+5)` in scaled Time.time. Capture the current
  buff token/instance and enemy HP before native HealthManager.Hit, then compare
  actual HP after the original dispatch. Nail/NailBeam/Spell/SharpShadow qualify;
  scenery, dead targets and zero HP loss never heal. Call AddHealth(1) with a
  reentrancy guard; use one >=1s deadline across all attacks/targets and refreshes.
  Full HP does not spend a proc. Refresh replaces expiry, preserves cooldown and
  invalidates old callbacks. Clear on death/hazard/scene/detach, with no expiry heal.
- Tests link actual production policies for cooldown/expiry/refresh/full HP/stale
  ownership and Storm mask/tier/clock/cap. Native focus routing, Soul cost,
  graphics and cleanup remain pending client acceptance after compile checks.

## Source lines 291–321

## 0.6.2 direction and native focus end alignment (supersedes0.5.3 origin)

1. Scope: Dashmaster flames were horizontal; Fire Eye cast played too early.
2. Signatures: NativeV77.DashingDown(hero)->bool through FlameDash.Downward;
   NativeSpellV77.FocusSecondsRemaining->double(-1 before normal focus drain);
   FireEyeCastClock.Observe(casting,remainingSeconds,scaledNow), Tick(now), Clear.
3. Contract: read private native dashingDown, not held input/inferred facing.
   Presenter selects flameDashDown with the same DashProgress clock, white color
   and native dash visibility handling. Only offline flame Draws rotate90;
   body, aura, arcs, view/root/colliders and path damage remain unchanged.
   Native focus remaining=(focusMP_amount-MP_drained)*drainMP_time-drainMP_timer,
   clamped0 while drainMP=true. Capture now+remaining once, after native charm
   selection. Tick=(now-deadline)*30+21; unscheduled returns-1. Negative tick
   shows only opening effect4 body;[0,21) samples original composite;>=21 uses
   final body only. Short native charges start in source tail, never stretch.
4. Error/lifetime matrix: wrong private field type -> fail initialization safely;
   no drain/invalid remaining -> no schedule; invalid now/ordinary focus false,
   death/scene/detach -> clear; repeat observations -> same deadline; pause ->
   scaled clock unchanged; complete/cancel -> normal native/buff cleanup wins.
5. Base/good/bad: normal .891s drain delays flames .191s; Quick .594s uses last
   .594s at30Hz; Deep waits longer. Bad: hardcoded normal duration, restarting
   deadline on every observer, normalized/discrete Soul frame stepping, delaying
   native completion or rotating all hero graphics to point dash flames down.
6. Tests: actual production deadline for startup/window/end, native-rate samples,
   short tail, repeats/pause/cancel/recast/invalid and early native completion;
   source directional pixels/1.5x and979old ticks, actual-reference Release.
   Client still checks both facings, charms/Unn, interruptions and native timing.
7. Wrong: start flames on focus entry then hold final body for long charges.
   Correct: hold opening body without effects, end-align the original30Hz window.
