using System;
using System.Collections.Generic;

namespace WukongKnight.Core
{
    /// <summary>Source-style per-target contact cooldown/cap, not animation pulses.</summary>
    internal sealed class SpellHitLedger
    {
        private sealed class Contact
        {
            public int Count;
            public double Last;
        }
        private readonly Dictionary<int, Contact> air = new Dictionary<int, Contact>();
        private readonly HashSet<int> finishers = new HashSet<int>();
        private readonly int repeatingHitCap;
        public SpellHitLedger(int repeatingHitCap = FireDemonDamage.AirHitCap)
        {
            if (repeatingHitCap <= 0) throw new ArgumentOutOfRangeException(nameof(repeatingHitCap));
            this.repeatingHitCap = repeatingHitCap;
        }
        public long Token { get; private set; }
        public bool Active { get; private set; }
        public bool FinisherStarted { get; private set; }
        public bool HidesBody => Active && !FinisherStarted;
        public long Begin() { Token++; Active = true; FinisherStarted = false; air.Clear(); finishers.Clear(); return Token; }
        public void Stop(long token) { if (token == Token) Active = false; }
        public bool Owns(long token) => Active && token == Token;
        public bool BeginFinisher(long token)
        {
            if (!Owns(token)) return false;
            FinisherStarted = true; return true;
        }
        public bool TryAirHit(long token, int target, double now)
        {
            if (!Owns(token) || FinisherStarted || double.IsNaN(now) || double.IsInfinity(now)) return false;
            if (!air.TryGetValue(target, out Contact? contact))
                air.Add(target, contact = new Contact { Last = double.NegativeInfinity });
            if (contact.Count >= repeatingHitCap || now - contact.Last + 0.000001 < 0.1) return false;
            contact.Count++; contact.Last = now; return true;
        }
        public bool TryFinisher(long token, int target) => Owns(token) && FinisherStarted && finishers.Add(target);
    }

    internal readonly struct FireDemonDamage
    {
        public const int AirHitCap = 11;
        public FireDemonDamage(int quakeLevel, bool shamanStone)
        {
            int air = quakeLevel >= 2 ? 3 : 2;
            int finisher = quakeLevel >= 2 ? 22 : 14;
            Air = shamanStone ? (int)Math.Ceiling(air * 1.5) : air;
            Finisher = shamanStone ? (int)Math.Ceiling(finisher * 1.5) : finisher;
        }
        public int Air { get; }
        public int Finisher { get; }
        public int FullContactTotal => AirHitCap * Air + Finisher;
    }
}
