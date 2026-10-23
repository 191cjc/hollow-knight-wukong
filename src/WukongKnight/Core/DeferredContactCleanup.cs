using System;
using System.Collections.Generic;

namespace WukongKnight.Core
{
    /// <summary>Never mutate a native contact list while its damage callback is enumerating it.</summary>
    internal sealed class DeferredContactCleanup<T> where T : class
    {
        private readonly Dictionary<T, int> iterations = new Dictionary<T, int>();
        private readonly HashSet<T> pending = new HashSet<T>();

        public bool HasActiveIterations => iterations.Count != 0;
        public bool IsPending(T source) => pending.Contains(source);

        public void Enter(T source)
        {
            iterations.TryGetValue(source, out int depth);
            iterations[source] = depth + 1;
        }

        // True means it is safe for the caller to clear this source immediately.
        public bool Request(T source)
        {
            if (!iterations.ContainsKey(source)) return true;
            pending.Add(source);
            return false;
        }

        // True means the final enumerator has returned and its deferred clear must run now.
        public bool Exit(T source)
        {
            if (!iterations.TryGetValue(source, out int depth))
                throw new InvalidOperationException("Unbalanced native contact iteration.");
            if (depth > 1) { iterations[source] = depth - 1; return false; }
            iterations.Remove(source);
            return pending.Remove(source);
        }
    }
}
