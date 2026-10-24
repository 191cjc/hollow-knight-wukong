using System;

namespace WukongKnight.Core
{
    /// <summary>Original 30 Hz casting art ending at the native focus deadline.</summary>
    internal sealed class FireEyeCastClock
    {
        private bool scheduled;
        private double ends;

        public void Observe(bool casting, double remainingSeconds, double now)
        {
            if (!casting || !Finite(now)) { Clear(); return; }
            if (scheduled || !Finite(remainingSeconds) || remainingSeconds < 0) return;
            ends = now + remainingSeconds; scheduled = true;
        }

        // Negative ticks mean preparation: hold only the opening body pose.
        // Short native charges select the source tail without changing its speed.
        public double Tick(double now) => !scheduled || !Finite(now) ? -1 : (now - ends) * 30 + 21;

        private static bool Finite(double value) => !double.IsNaN(value) && !double.IsInfinity(value);
        public void Clear() { scheduled = false; ends = 0; }
    }
}
