using System;

namespace WukongKnight.Core
{
    /// <summary>Five scaled seconds, one real-damage heal per second across all attacks.</summary>
    internal sealed class BloodthirstyBuff
    {
        private double expires = double.NegativeInfinity;
        private double started = double.PositiveInfinity;
        private double nextHeal = double.NegativeInfinity;
        public long Token { get; private set; }
        public bool Active(double now) => Finite(now) && now >= started && now < expires;
        public double VisualTick(double now) => Active(now) ? (now - started) * 30 : 0;
        public void Activate(double now)
        {
            if (!Finite(now)) return;
            Token++; started = now; expires = now + 5;
            // Refresh cannot bypass a proc cooldown from the preceding buff.
        }
        public void Clear() { Token++; started = double.PositiveInfinity; expires = nextHeal = double.NegativeInfinity; }
        public bool TryHeal(long token, double now, int enemyBefore, int enemyAfter, int health, int maximum)
        {
            if (token != Token || !Active(now) || now < nextHeal || enemyBefore <= 0 ||
                enemyAfter >= enemyBefore || health <= 0 || health >= maximum) return false;
            nextHeal = now + 1;
            return true;
        }
        private static bool Finite(double value) => !double.IsNaN(value) && !double.IsInfinity(value);
    }
}
