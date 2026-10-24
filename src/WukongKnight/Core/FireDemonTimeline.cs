using System;

namespace WukongKnight.Core
{
    /// <summary>Original effect expiry drives the finisher, independently of floor contact.</summary>
    internal readonly struct FireDemonTimeline
    {
        public const int FrameRate = 30;
        public const int AirStart = 5;
        public const int AirDuration = 31;
        public const int FinisherStart = AirStart + AirDuration;
        public const int FinisherDuration = 20;
        public const int End = FinisherStart + FinisherDuration;
        public FireDemonTimeline(double elapsed)
        {
            Tick = double.IsNaN(elapsed) || double.IsInfinity(elapsed) ? End : Math.Max(0, elapsed) * FrameRate;
        }
        public double Tick { get; }
        public bool Air => Tick >= AirStart && Tick < FinisherStart;
        public bool Finisher => Tick >= FinisherStart && Tick < End;
        public bool Complete => Tick >= End;
        public double AirTick => Tick - AirStart;
        public double FinisherTick => Tick - FinisherStart;
    }

    internal readonly struct FireDemonRegion
    {
        public FireDemonRegion(double x, double y, double width, double height)
        { X = x; Y = y; Width = width; Height = height; }
        public double X { get; }
        public double Y { get; }
        public double Width { get; }
        public double Height { get; }
    }

    /// <summary>Original unscaled Flash pixels, with Y converted to Unity up.</summary>
    internal static class FireDemonGeometry
    {
        public const double AirSpawnX = 177;
        public const double AirSpawnY = 95;
        public static FireDemonRegion Air(bool facingRight) => new FireDemonRegion(
            (facingRight ? 1 : -1) * 2.52776, 57.96991, 442.94934, 209.89949);
        public static FireDemonRegion Finisher(bool facingRight) => new FireDemonRegion(
            (facingRight ? 1 : -1) * -0.95083, 79.01354, 261.99975, 231.95052);
    }
}
