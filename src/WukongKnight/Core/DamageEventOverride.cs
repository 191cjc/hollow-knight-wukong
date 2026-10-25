using System;

namespace WukongKnight.Core
{
    /// <summary>Replace one owned cancellation event, restoring only our own write.</summary>
    internal sealed class DamageEventOverride
    {
        private readonly Func<object> read;
        private readonly Action<object> write;
        private readonly object original;
        private readonly object replacement;
        public DamageEventOverride(Func<object> read, Action<object> write, object replacement)
        { this.read = read; this.write = write; original = read(); this.replacement = replacement; }
        public void Set(bool active)
        {
            object current = read();
            if (active)
            {
                if (!ReferenceEquals(current, original) && !ReferenceEquals(current, replacement))
                    throw new InvalidOperationException("Dream damage transition changed by another owner");
                if (!ReferenceEquals(current, replacement)) write(replacement);
            }
            else if (ReferenceEquals(current, replacement)) write(original);
        }
    }
}
