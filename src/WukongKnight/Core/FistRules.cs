using System;
using System.Collections.Generic;

namespace WukongKnight.Core
{
    internal enum FistAction { None, Afterimage, Godslayer, Earthbreaker, FireApe }

    /// <summary>Source frame39 permits full damage; frame60 forces a single release.</summary>
    internal sealed class GodslayerCharge
    {
        public const double FullTicks = 38;
        public const double MaximumTicks = 59;
        public bool Released { get; private set; }
        public bool Full { get; private set; }
        public double ReleasedAt { get; private set; }
        public void Reset() { Released = false; Full = false; ReleasedAt = 0; }
        public double ChargeTick(double elapsed, bool wielder) => double.IsNaN(elapsed) || double.IsInfinity(elapsed) ? 0 : Math.Min(MaximumTicks, Math.Max(0, elapsed) * 30 * (wielder ? 2 : 1));
        public bool Observe(double elapsed, bool wielder, bool held)
        {
            // Latch at this observation so a delayed frame still gets its release tail/wave.
            return (!held || ChargeTick(elapsed, wielder) + 1e-7 >= MaximumTicks) && Release(elapsed, wielder);
        }
        public bool Release(double elapsed, bool wielder)
        {
            if (Released || double.IsNaN(elapsed) || double.IsInfinity(elapsed) || elapsed < 0) return false;
            Full = ChargeTick(elapsed, wielder) + 1e-7 >= FullTicks;
            Released = true; ReleasedAt = elapsed; return true;
        }
    }

    /// <summary>Each original subskill owns its cap and interval, then clears on recast.</summary>
    internal sealed class FistContacts
    {
        private sealed class Contact { public int Count; public double Last = double.NegativeInfinity; }
        private readonly Dictionary<long, Contact> contacts = new Dictionary<long, Contact>();
        public bool TryHit(int window, int target, int cap, double interval, double now)
        {
            if (cap < 1 || interval < 0 || double.IsNaN(now) || double.IsInfinity(now)) return false;
            long key = ((long)window << 32) | (uint)target;
            if (!contacts.TryGetValue(key, out Contact? c)) contacts.Add(key, c = new Contact());
            if (c.Count >= cap || now - c.Last + 1e-7 < interval) return false;
            c.Count++; c.Last = now; return true;
        }
        public void Clear() => contacts.Clear();
    }

    internal static partial class FistRules
    {
        // These end predicates are also observed synchronously before incoming hits.
        public static bool HeroFinished(FistAction action, double elapsed, double landingSeconds, bool released, double releaseSeconds)
        {
            if (double.IsNaN(elapsed) || double.IsInfinity(elapsed) || elapsed < 0) return true;
            if (action == FistAction.Afterimage) return elapsed * 30 >= 71;
            if (action == FistAction.FireApe) return elapsed * 30 >= 105;
            if (action == FistAction.Godslayer) return released && releaseSeconds >= 25.0 / 30;
            return action != FistAction.Earthbreaker || landingSeconds >= 14.0 / 30 || elapsed >= 5;
        }
        public static bool RequiresSoul(FistAction action) => action == FistAction.Earthbreaker || action == FistAction.FireApe;
        public static bool TryBeginDream(FistAction action, int cost, Func<int> soul, Func<bool> acquire,
            Func<bool> holds, Action<int> spend, Action cancel)
        {
            if (action != FistAction.Godslayer && !RequiresSoul(action)) return false;
            bool paid = RequiresSoul(action);
            if (paid && (cost <= 0 || cost > 99 || soul() < cost)) return false;
            if (!acquire()) return false;
            // Native cancellation and TakeMP hooks may revoke control or change Soul.
            bool started = false;
            try
            {
                if (!holds() || paid && soul() < cost) return false;
                if (paid) spend(cost);
                started = holds();
                return started;
            }
            finally { if (!started) cancel(); }
        }
        public static readonly int[] CloneBirthTicks = { 11, 25, 39, 51 };
        public const double CloneSeconds = 10;
        // Original Q Slam Hit L/R uses horizontal spell recoil at magnitude2.
        public const float KnockbackMagnitude = 2f;
        public const double EarthbreakerFallPixelsPerTick = 33;
        public static double EarthbreakerAnticTicks(bool fromGround) => fromGround ? 16 : 8;
        public static double EarthbreakerStep(double previousTick, double tick, bool fromGround)
        {
            double antic = EarthbreakerAnticTicks(fromGround);
            double rise = fromGround ? Math.Max(0, Math.Min(tick, antic) - Math.Min(previousTick, antic)) * 17.8 : 0;
            double fall = Math.Max(0, tick - Math.Max(previousTick, antic)) * EarthbreakerFallPixelsPerTick;
            return rise - fall;
        }
        public static bool GhostFinished(FistAction action, bool released, double actionSeconds, double landingSeconds, double age)
        {
            if (action == FistAction.None) return age >= CloneSeconds;
            if (action == FistAction.Godslayer) return released && actionSeconds >= 25.0 / 30;
            return action == FistAction.Earthbreaker && (landingSeconds >= 14.0 / 30 || actionSeconds >= 5);
        }
        public static float PushDirection(double sourceX, double targetX, bool facingRight, bool projectile)
        {
            // A passing wave must keep pushing along its travel, not back toward the hero.
            if (projectile || Math.Abs(targetX - sourceX) < 1e-6) return facingRight ? 0 : 180;
            return targetX > sourceX ? 0 : 180;
        }
        public static double AfterimageTravel(double tick) => Math.Min(48, Math.Max(0, tick - 3)) * 7.5 + Math.Min(12, Math.Max(0, tick - 51)) * 15;
        public static int SpellDamage(int level, bool shaman) => shaman ? (int)Math.Ceiling((level >= 2 ? 5 : 3) * 1.5) : level >= 2 ? 5 : 3;
        // Dream-key damage scales with nail upgrades, without Strength or Soul-on-hit.
        public static int DreamDamage(FistAction action, int nail, bool full, bool landing, bool clone)
        {
            double factor = action == FistAction.Godslayer ? (full ? 2.5 : 1) : action == FistAction.Earthbreaker ? (landing ? 1.2 : .4) : landing ? .6 : .4;
            return Math.Max(1, (int)Math.Ceiling(Math.Max(1, nail) * factor * (clone ? .2 : 1)));
        }
    }
}
