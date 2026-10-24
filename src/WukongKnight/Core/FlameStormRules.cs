using System;

namespace WukongKnight.Core
{
    internal readonly struct FlameStormClock
    {
        public const int DurationTicks = 16;
        public FlameStormClock(double elapsed)
        { Tick = double.IsNaN(elapsed) || double.IsInfinity(elapsed) ? DurationTicks : Math.Max(0, elapsed) * 30; }
        public double Tick { get; }
        public bool Complete => Tick >= DurationTicks;
    }

    internal static class FlameStormRules
    {
        public const int HitCap = 5;
        public static int Damage(int level, bool shaman) => shaman ? (int)Math.Ceiling((level >= 2 ? 11 : 7) * 1.5) : level >= 2 ? 11 : 7;
        // Original ab_effect3 sprite39 places shape32 with these SWF transforms.
        public static FireDemonRegion Region(bool facingRight) => new FireDemonRegion(
            (facingRight ? 1 : -1) * (1.5618286 * 58 - 97.05),
            -(2.2077942 * -33.5 + 38.95), 1.5618286 * 258, 2.2077942 * 77);
    }
}
