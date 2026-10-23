using System;

namespace WukongKnight.Core
{
    /// <summary>Token-scoped native cooldown policy; duration/field restoration stays in the native adapter.</summary>
    internal sealed class AttackTiming
    {
        private long owner;
        private AttackMode mode;
        private double nativeCooldown;
        private double acceptedAt;

        public double Own(long token, AttackMode actionMode, double authoredDuration, double originalCooldown, double now)
        {
            if (owner != 0 || token == 0) throw new InvalidOperationException("Previous native action still owned or invalid token.");
            owner = token; mode = actionMode; nativeCooldown = originalCooldown; acceptedAt = now;
            return mode == AttackMode.AirHorizontal ? Math.Max(authoredDuration, nativeCooldown) : authoredDuration;
        }

        public bool TryRelease(long token, double now, bool canceled, out double remainingCooldown)
        {
            remainingCooldown = 0;
            if (token == 0 || owner != token) return false;
            owner = 0;
            // Ground completion deliberately supports authored chaining. Air always preserves
            // the original transaction's cadence, even when its shorter clip finishes normally.
            if (mode == AttackMode.AirHorizontal || canceled)
                remainingCooldown = Math.Max(0, nativeCooldown - Math.Max(0, now - acceptedAt));
            return true;
        }
    }
}
