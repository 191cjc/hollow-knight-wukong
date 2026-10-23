using System;
using System.Collections.Generic;
using System.Linq;
using WukongKnight.Core;

internal static class Program
{
    private static int Main()
    {
        Action[] cases = { SinglePressDoesNotAutoChain, FourPressesFollowFourStages, BufferIsBoundedAndEarlyPressIsRejected, GraceHasAnInclusiveDeadline, CancellationInvalidatesOwnership, DualWindowsDeduplicateActualTargets, QuickSlashScalesEveryStageWindow, PhysicsClockSurvivesSlowRendering, CompletionDoesNotRetainStageFourInput, ContactCleanupWaitsForNativeEnumeration };
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
        new ComboStage("attack4", 20, 5, 1, new[] { new HitWindow(5, 8) }) }, 30, .35);

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
}
