using System;

namespace WukongKnight.Core
{
    /// <summary>Attributes one synchronous native hit to its exact dispatched source and responder.</summary>
    internal sealed class ScopedEnemyDamage<TSource, TTarget> where TSource : class where TTarget : class
    {
        private readonly TSource source;
        private readonly TTarget target;
        private readonly int initialHealth;
        private bool observed;
        private bool eligible;
        private bool completed;
        private long sequence;
        public long Token { get; }

        public ScopedEnemyDamage(TSource source, TTarget target, long token, int initialHealth)
        {
            this.source = source ?? throw new ArgumentNullException(nameof(source));
            this.target = target ?? throw new ArgumentNullException(nameof(target));
            Token = token;
            this.initialHealth = initialHealth;
        }

        public bool Begin(TSource actualSource, TTarget actualTarget, long token, int health, int depth, long hitSequence)
        {
            if (!ReferenceEquals(source, actualSource) || !ReferenceEquals(target, actualTarget) || token != Token) return false;
            // Only the first exact matching dispatch can be attributed. Nested native callbacks
            // invalidate the outer result through hitSequence, even when their damage is rejected.
            if (completed || observed) return false;
            observed = true;
            if (Token <= 0 || initialHealth <= 0 || health != initialHealth || depth != 1) return false;
            sequence = hitSequence;
            eligible = true;
            return true;
        }

        public bool Complete(TSource actualSource, TTarget actualTarget, long token, int health, long hitSequence, bool stillOwned)
        {
            if (completed) return false;
            completed = true;
            return eligible && sequence == hitSequence && stillOwned && token == Token &&
                ReferenceEquals(source, actualSource) && ReferenceEquals(target, actualTarget) &&
                health > 0 && health < initialHealth;
        }
    }
}
