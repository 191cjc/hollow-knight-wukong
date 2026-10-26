using System;

namespace WukongKnight.Core
{
    internal sealed class FistSummonClock
    {
        public FistAction Action { get; }
        private readonly double started;
        private double previousTick;
        private int born;
        private bool cancelled;
        public FistSummonClock(FistAction action, double now)
        {
            if (action != FistAction.Afterimage && action != FistAction.FireApe || double.IsNaN(now) || double.IsInfinity(now))
                throw new ArgumentOutOfRangeException(nameof(action));
            Action = action; started = now;
        }
        public double Tick(double now) => Math.Max(0, (now - started) * 30);
        public bool Active(double now) => !cancelled && !double.IsNaN(now) && !double.IsInfinity(now) &&
            !FistRules.ActionFinished(Action, Math.Max(0, now-started), -1, false, 0);
        public void Cancel() { cancelled = true; }
        // Split travel at each original birth tick so slow frames retain trail spacing.
        public bool NextAfterimageStep(double now, out double pixels, out int birth)
        {
            pixels = 0; birth = 0;
            if (cancelled || Action != FistAction.Afterimage || double.IsNaN(now) || double.IsInfinity(now)) return false;
            double tick = Math.Min(71, Tick(now));
            if (born < FistRules.CloneBirthTicks.Length && tick >= FistRules.CloneBirthTicks[born])
            { tick = FistRules.CloneBirthTicks[born]; birth = ++born; }
            if (tick <= previousTick && birth == 0) return false;
            pixels = FistRules.AfterimageTravel(tick) - FistRules.AfterimageTravel(previousTick);
            previousTick = tick; return true;
        }
    }
}
