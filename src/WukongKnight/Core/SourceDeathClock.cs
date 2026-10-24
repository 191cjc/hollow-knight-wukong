using System;

namespace WukongKnight.Core
{
    /// <summary>One original death action per native death, then hold its final pose.</summary>
    internal sealed class SourceDeathClock
    {
        private readonly int ticks;
        private readonly double frameRate;
        private double started;
        public bool Active { get; private set; }

        public SourceDeathClock(int ticks, double frameRate)
        {
            if (ticks <= 0 || !Finite(frameRate) || frameRate <= 0) throw new ArgumentOutOfRangeException();
            this.ticks = ticks; this.frameRate = frameRate;
        }

        public bool Begin(double now)
        {
            if (Active || !Finite(now)) return false;
            started = now; Active = true; return true;
        }

        public double Tick(double now) => !Active || !Finite(now) ? 0 :
            Math.Min(ticks - 0.0001, Math.Max(0, now - started) * frameRate);

        public void Clear() { Active = false; started = 0; }
        private static bool Finite(double value) => !double.IsNaN(value) && !double.IsInfinity(value);
    }
}
