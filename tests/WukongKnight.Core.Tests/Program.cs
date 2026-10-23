using System;
using System.Collections.Generic;
using System.Linq;
using WukongKnight.Core;

internal static class Program
{
    private static int Main()
    {
        Action[] cases = { SinglePressDoesNotAutoChain, FourPressesFollowFourStages, BufferIsBoundedAndEarlyPressIsRejected, GraceHasAnInclusiveDeadline, CancellationInvalidatesOwnership, DualWindowsDeduplicateActualTargets, QuickSlashScalesEveryStageWindow, PhysicsClockSurvivesSlowRendering, CompletionDoesNotRetainStageFourInput, ContactCleanupWaitsForNativeEnumeration, AirSingleHasOneHalfOpenWindowAndNoBuffer, AirQuickSlashUsesTheSharedPhysicsClock, GroundAirTransitionsShareTokensAndResetChain, AirAndLeavingGroundClearInactiveGrace, AirContactAllowsAscentAndCancelsOnLanding, EventsRetainTheirDefinitionAcrossBufferedTransition, AirRepeatStartsTheSameClipWithAFreshClock, TimingPreservesAirNativeCadence, TimingRejectsStaleOwnersAndKeepsGroundPolicy };
        foreach (Action test in cases)
        {
            try { test(); Console.WriteLine("PASS " + test.Method.Name); }
            catch (Exception error) { Console.Error.WriteLine("FAIL " + test.Method.Name + ": " + error.Message); return 1; }
        }
        Console.WriteLine(cases.Length + " combo-core checks passed (actual linked production source).");
        return 0;
    }

    private static ComboTimeline NewCombo() => new ComboTimeline(new[] {
        new ComboStage("attack1", 12, 2, 1, new[] { new HitWindow(4, 7) }),
        new ComboStage("attack2", 15, 2, 1, new[] { new HitWindow(5, 8) }),
        new ComboStage("attack3", 18, 3, 1, new[] { new HitWindow(3, 5), new HitWindow(11, 14) }),
        new ComboStage("attack4", 20, 5, 1, new[] { new HitWindow(5, 8) }) },
        new AttackDefinition("jumpAttack", 10, 1, new[] { new HitWindow(4, 7) }), 30, .35);

    private static void Check(bool condition, string message)
    { if (!condition) throw new InvalidOperationException(message); }
    private static bool Has(IEnumerable<ComboEvent> events, ComboEventKind kind, int stage = -1) => events.Any(e => e.Kind == kind && (stage < 0 || e.Stage == stage));

    private static void SinglePressDoesNotAutoChain()
    {
        ComboTimeline combo = NewCombo(); combo.Press(0, 1);
        var events = combo.Advance(.4, 1);
        Check(!combo.Active && Has(events, ComboEventKind.StageEnded) && !Has(events, ComboEventKind.StageStarted), "One press started extra attacks.");
    }
    private static void FourPressesFollowFourStages()
    {
        ComboTimeline combo = NewCombo(); combo.Press(0, 1);
        double now = 0;
        for (int stage = 0; stage < 4; stage++)
        {
            Check(combo.StageIndex == stage, "Wrong stage sequence.");
            double end = now + combo.Duration;
            if (stage < 3) combo.Press(now + .2, 1);
            var changes = combo.Advance(end + .000001, 1);
            if (stage < 3) Check(Has(changes, ComboEventKind.StageStarted, stage + 1), "Buffered stage was not emitted.");
            now = end + .000001;
        }
        Check(!combo.Active, "Fourth stage did not finish.");
    }
    private static void BufferIsBoundedAndEarlyPressIsRejected()
    {
        ComboTimeline combo = NewCombo(); combo.Press(0, 1); combo.Press(.001, 1);
        Check(!combo.Buffered, "Premature input survived the buffer opening.");
        for (int i = 0; i < 20; i++) combo.Press(.15, 1);
        Check(combo.Buffered, "Valid input missing.");
        combo.Advance(.4, 1);
        Check(combo.StageIndex == 1 && !combo.Buffered, "More than one pending input carried into stage two.");
        combo.Advance(.91, 1); Check(!combo.Active, "Spammed stage-one inputs leaked into stage three.");
    }
    private static void GraceHasAnInclusiveDeadline()
    {
        ComboTimeline combo = NewCombo(); combo.Press(0, 1); combo.Advance(.4, 1); combo.Press(.75, 1);
        Check(combo.StageIndex == 1, "Exact grace deadline reset chain.");
        combo = NewCombo(); combo.Press(0, 1); combo.Advance(.4, 1); combo.Press(.750001, 1);
        Check(combo.StageIndex == 0, "Expired chain survived.");
    }
    private static void CancellationInvalidatesOwnership()
    {
        ComboTimeline combo = NewCombo(); combo.Press(0, 1); long token = combo.Token;
        combo.Advance(.14, 1); Check(combo.TryHit(token, 0, 7), "Expected first hit.");
        combo.Press(.2, 1); combo.Cancel();
        Check(!combo.Active && !combo.Buffered && !combo.TryHit(token, 0, 8), "Cancel left damage/buffer active.");
        combo.Press(.21, 1); combo.Advance(.35, 1);
        Check(combo.StageIndex == 0 && combo.Token != token && !combo.TryHit(token, 0, 9), "Stale callback can hit a new stage.");
        Check(combo.TryHit(combo.Token, 0, 7), "Old dedupe memory survived cancellation.");
    }
    private static void DualWindowsDeduplicateActualTargets()
    {
        ComboTimeline combo = NewCombo(); combo.Press(0, 1); combo.Press(.2, 1); combo.Advance(.4, 1);
        combo.Press(.6, 1); combo.Advance(.9, 1); long token = combo.Token;
        combo.Advance(1.001, 1);
        Check(combo.StageIndex == 2 && combo.WindowIndex == 0, "Third stage first window missing.");
        Check(combo.TryHit(token, 0, 71) && !combo.TryHit(token, 0, 71) && combo.TryHit(token, 0, 72), "Repeated collider hit or multi-target rejection.");
        combo.Advance(1.1, 1); Check(!combo.TryHit(token, 0, 73), "Closed window damaged a target.");
        combo.Advance(1.28, 1);
        Check(combo.WindowIndex == 1 && combo.TryHit(token, 1, 71) && !combo.TryHit(token, 1, 71), "Second window did not independently rearm the target.");
        Check(!combo.TryHit(token, 0, 74), "Old window callback leaked into second pulse.");
    }
    private static void QuickSlashScalesEveryStageWindow()
    {
        ComboTimeline combo = NewCombo(); combo.Press(0, .6);
        Check(Math.Abs(combo.Duration - .24) < 1e-9, "Stage duration ignored clock scale.");
        combo.Advance(.079, .6); Check(combo.WindowIndex == -1, "Window opened early.");
        combo.Advance(.081, .6); Check(combo.WindowIndex == 0, "Scaled hit window missing.");
        combo.Advance(.14, .6); Check(combo.WindowIndex == -1, "Scaled close window missing.");
        combo.Press(.15, .6); combo.Advance(.24, .6);
        Check(combo.StageIndex == 1 && Math.Abs(combo.Duration - .3) < 1e-9, "Next stage lost Quick Slash clock.");
    }
    private static void PhysicsClockSurvivesSlowRendering()
    {
        ComboTimeline combo = NewCombo(); combo.Press(0, .6);
        int physicsHits = 0;
        // Render at 10 FPS, but advance gameplay once per 20ms physics step as the runtime does.
        for (int step = 1; step <= 12; step++)
        {
            combo.Advance(step * .02, .6);
            if (combo.TryHit(combo.Token, combo.WindowIndex, 5)) physicsHits++;
        }
        Check(physicsHits == 1, "Short active window disappeared or repeated under slow rendering.");
    }
    private static void CompletionDoesNotRetainStageFourInput()
    {
        ComboTimeline combo = NewCombo(); combo.Press(0, 1);
        double now = 0;
        for (int i = 0; i < 4; i++) { combo.Press(now + .2, 1); now += combo.Duration + .000001; combo.Advance(now, 1); }
        Check(!combo.Active && !combo.Buffered, "Fourth-stage input began another chain automatically.");
        combo.Press(now + .01, 1); Check(combo.StageIndex == 0, "Next explicit press did not reset to attack one.");
    }

    private static void ContactCleanupWaitsForNativeEnumeration()
    {
        var cleanup = new DeferredContactCleanup<object>();
        object source = new object(), other = new object();
        var contacts = new List<int> { 1, 2, 3 };
        var damaged = new List<int>();
        cleanup.Enter(source);
        try
        {
            for (int i = contacts.Count - 1; i >= 0; i--)
            {
                if (cleanup.IsPending(source)) continue;
                damaged.Add(contacts[i]);
                Check(!cleanup.Request(source), "Active contact enumeration was cleared inside Hit.");
                Check(cleanup.Request(other) && !cleanup.IsPending(other), "Cleanup leaked into another source.");
            }
        }
        finally { if (cleanup.Exit(source)) contacts.Clear(); }
        Check(damaged.SequenceEqual(new[] { 3 }) && contacts.Count == 0, "Canceled contacts leaked damage or survived final cleanup.");
        Check(!cleanup.HasActiveIterations && !cleanup.IsPending(source), "Cleanup guard survived the old transaction.");
        // The same native source may immediately begin an original airborne attack.
        cleanup.Enter(source);
        Check(!cleanup.IsPending(source), "New native attack inherited cancellation suppression.");
        cleanup.Enter(source); cleanup.Request(source);
        Check(!cleanup.Exit(source) && cleanup.IsPending(source), "Nested callbacks flushed an active outer iterator.");
        Check(cleanup.Exit(source) && !cleanup.HasActiveIterations, "Outermost callback did not release pending contacts.");
    }

    private static void AirSingleHasOneHalfOpenWindowAndNoBuffer()
    {
        ComboTimeline combo = NewCombo();
        var start = combo.PressAir(0, 1); long token = combo.Token;
        Check(start.Count == 1 && start[0].Mode == AttackMode.AirHorizontal && combo.StageIndex == -1 && combo.CurrentAttack.Clip == "jumpAttack", "Air entry selected a ground stage.");
        combo.Advance(4.0 / 30 - .000001, 1);
        Check(!combo.TryHit(token, 0, 21), "Air hit before its first forward pose.");
        var open = combo.Advance(4.0 / 30, 1);
        Check(open.Count == 1 && open[0].Kind == ComboEventKind.WindowOpened, "Exact air window start was not inclusive.");
        Check(combo.TryHit(token, 0, 21) && !combo.TryHit(token, 0, 21) && combo.TryHit(token, 0, 22), "Air target ownership lost per-window dedupe.");
        for (int i = 0; i < 20; i++)
        {
            Check(combo.PressAir(.2, 1).Count == 0 && combo.Press(.2, 1).Count == 0, "An active air press started another action.");
        }
        Check(!combo.Buffered && combo.Token == token, "Air presses buffered or restarted the action.");
        combo.Advance(7.0 / 30, 1);
        Check(combo.WindowIndex == -1 && !combo.TryHit(token, 0, 23), "Air window end was not exclusive.");
        var end = combo.Advance(10.0 / 30, 1);
        Check(end.Count == 1 && end[0].Kind == ComboEventKind.StageEnded && !combo.Active && !combo.Buffered, "Air completion replayed queued input.");
    }

    private static void AirQuickSlashUsesTheSharedPhysicsClock()
    {
        ComboTimeline combo = NewCombo(); combo.PressAir(0, .6);
        Check(Math.Abs(combo.Duration - .2) < 1e-9, "Air clip ignored Quick Slash.");
        combo.Advance(.079, .6); Check(combo.WindowIndex == -1, "Scaled air window opened early.");
        combo.Advance(.08, .6); Check(combo.WindowIndex == 0, "Scaled air window failed to open.");
        Check(Math.Abs(combo.Elapsed(.08) / combo.SecondsPerTick - 4) < 1e-9, "Visual source ticks diverged from the hit window.");
        combo.Advance(.14, .6); Check(combo.WindowIndex == -1, "Scaled air window did not close.");
        combo = NewCombo(); combo.PressAir(0, .6); int hits = 0;
        for (int step = 1; step <= 10; step++)
        {
            combo.Advance(step * .02, .6);
            if (combo.TryHit(combo.Token, combo.WindowIndex, 9)) hits++;
        }
        Check(hits == 1 && !combo.Active, "Air pulse vanished or repeated between slow rendered frames.");
    }

    private static void GroundAirTransitionsShareTokensAndResetChain()
    {
        ComboTimeline combo = NewCombo(); combo.Press(0, 1); long groundToken = combo.Token;
        combo.Press(.1, 1); combo.Advance(.14, 1);
        Check(combo.TryHit(groundToken, 0, 5), "Ground setup did not own its window.");
        var groundCancel = combo.ObserveContact(false, true, false);
        Check(Has(groundCancel, ComboEventKind.Canceled) && !combo.Active && !combo.Buffered, "Leaving ground kept a buffered combo.");
        combo.PressAir(.15, 1); long airToken = combo.Token;
        Check(airToken > groundToken && !combo.TryHit(groundToken, 0, 6), "Air entry reused ground ownership.");
        combo.Advance(.29, 1); Check(combo.TryHit(airToken, 0, 5), "Air inherited old target memory.");
        combo.ObserveContact(true, false, false);
        combo.Press(.3, 1); long nextGroundToken = combo.Token;
        combo.Advance(.44, 1);
        Check(nextGroundToken > airToken && combo.StageIndex == 0 && combo.Mode == AttackMode.GroundCombo, "Landing resumed a ground continuation.");
        Check(!combo.TryHit(airToken, 0, 6) && combo.TryHit(nextGroundToken, 0, 5), "Stale air callbacks can damage the next ground stage.");
    }

    private static void AirAndLeavingGroundClearInactiveGrace()
    {
        ComboTimeline combo = NewCombo(); combo.Press(0, 1); combo.Advance(.4, 1);
        combo.ObserveContact(false, false, false); combo.ObserveContact(true, false, false);
        combo.Press(.5, 1);
        Check(combo.StageIndex == 0, "Walking off a ledge during inactive grace resumed attack2.");
        combo = NewCombo(); combo.Press(0, 1); combo.Advance(.4, 1);
        combo.PressAir(.41, 1); combo.Advance(.75, 1); combo.Press(.76, 1);
        Check(combo.StageIndex == 0 && combo.Mode == AttackMode.GroundCombo, "Air completion preserved ground grace.");
    }

    private static void AirContactAllowsAscentAndCancelsOnLanding()
    {
        ComboTimeline combo = NewCombo(); combo.PressAir(0, 1); long token = combo.Token;
        Check(combo.ObserveContact(false, true, false).Count == 0 && combo.Active, "Ascending jump canceled an air attack.");
        combo.Advance(.14, 1);
        Check(combo.ObserveContact(false, false, false).Count == 0 && combo.TryHit(token, 0, 31), "Falling canceled an air attack.");
        // No time advancement: a later contact observation in this same physics tick must cancel.
        var landed = combo.ObserveContact(true, false, false);
        Check(landed.Count == 1 && landed[0].Kind == ComboEventKind.Canceled && landed[0].Token == token && landed[0].Definition.Clip == "jumpAttack", "Landing left the air pulse owned.");
        Check(!combo.TryHit(token, 0, 32) && !combo.Active, "Landing allowed an old air callback.");
        combo.PressAir(.15, 1); combo.ObserveContact(false, true, true);
        Check(!combo.Active, "Wall contact retained owned air semantics.");
        combo.Press(.2, 1); combo.ObserveContact(true, true, false);
        Check(!combo.Active, "Ground jump flag did not interrupt the ground combo.");
    }

    private static void EventsRetainTheirDefinitionAcrossBufferedTransition()
    {
        ComboTimeline combo = NewCombo(); combo.Press(0, 1); combo.Press(.2, 1);
        var events = combo.Advance(.4, 1);
        Check(combo.CurrentAttack.Clip == "attack2", "Buffered transition did not occur.");
        Check(events.Where(e => e.Kind != ComboEventKind.StageStarted).All(e => e.Definition.Clip == "attack1" && e.Mode == AttackMode.GroundCombo), "Old events read the newer stage definition.");
        Check(events.Last().Kind == ComboEventKind.StageStarted && events.Last().Definition.Clip == "attack2", "New event retained the previous definition.");
    }

    private static void AirRepeatStartsTheSameClipWithAFreshClock()
    {
        ComboTimeline combo = NewCombo(); combo.PressAir(0, 1); long first = combo.Token;
        combo.Advance(.14, 1); combo.TryHit(first, 0, 41); combo.Advance(10.0 / 30, 1);
        combo.PressAir(10.0 / 30, 1); long second = combo.Token;
        Check(second > first && combo.CurrentAttack.Clip == "jumpAttack" && combo.Elapsed(10.0 / 30) == 0, "Consecutive same-name air clip did not restart.");
        combo.Advance(.47, 1);
        Check(combo.TryHit(second, 0, 41) && !combo.TryHit(first, 0, 42), "Air repeat inherited dedupe or stale ownership.");
    }

    private static void TimingPreservesAirNativeCadence()
    {
        var timing = new AttackTiming();
        double owned = timing.Own(1, AttackMode.AirHorizontal, 10.0 / 30, .41, 0);
        Check(Math.Abs(owned - .41) < 1e-9, "Short air clip shortened the owned native cooldown.");
        Check(timing.TryRelease(1, 10.0 / 30, false, out double remaining) && Math.Abs(remaining - (.41 - 10.0 / 30)) < 1e-9, "Normal air completion discarded native cooldown remainder.");
        owned = timing.Own(2, AttackMode.AirHorizontal, .2, .25, 1);
        Check(Math.Abs(owned - .25) < 1e-9 && timing.TryRelease(2, 1.2, false, out remaining) && Math.Abs(remaining - .05) < 1e-9, "Quick Slash lost its recorded native cooldown.");
        owned = timing.Own(3, AttackMode.AirHorizontal, .5, .4, 2);
        Check(owned == .5 && timing.TryRelease(3, 2.6, false, out remaining) && remaining == 0, "Late air release did not clamp expired cooldown.");
        timing.Own(4, AttackMode.AirHorizontal, .333, .41, 3);
        Check(timing.TryRelease(4, 3.1, true, out remaining) && Math.Abs(remaining - .31) < 1e-9, "Air cancellation shortened native cooldown.");
    }

    private static void TimingRejectsStaleOwnersAndKeepsGroundPolicy()
    {
        var timing = new AttackTiming(); timing.Own(1, AttackMode.AirHorizontal, .333, .41, 0);
        timing.TryRelease(1, .333, false, out _);
        Check(timing.Own(2, AttackMode.GroundCombo, .4, .5, .34) == .4, "Air policy leaked into ground ownership.");
        Check(!timing.TryRelease(1, .35, true, out _) && timing.TryRelease(2, .74, false, out double remaining) && remaining == 0, "Stale air release changed the new ground transaction.");
        Check(!timing.TryRelease(2, .75, false, out _), "An old native action released timing twice.");
        timing.Own(3, AttackMode.GroundCombo, .4, .5, 1);
        Check(timing.TryRelease(3, 1.1, true, out remaining) && Math.Abs(remaining - .4) < 1e-9, "Ground cancellation lost its original remainder policy.");
    }
}
