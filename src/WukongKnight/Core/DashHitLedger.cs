using System.Collections.Generic;

namespace WukongKnight.Core
{
    /// <summary>One hit per actual responder per dash; stale callbacks never own a new dash.</summary>
    internal sealed class DashHitLedger
    {
        private readonly HashSet<int> targets = new HashSet<int>();
        public long Token { get; private set; }
        public bool Active { get; private set; }
        public long Begin() { Token++; Active = true; targets.Clear(); return Token; }
        public void Stop(long token) { if (token == Token) { Active = false; targets.Clear(); } }
        public bool TryHit(long token, int responder) => Active && token == Token && targets.Add(responder);
    }
}
