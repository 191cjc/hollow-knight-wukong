using System;
using UnityEngine;
using WukongKnight.Core;

namespace WukongKnight
{
    /// <summary>Native focus spending/cancellation, source action, then damage-triggered healing.</summary>
    internal sealed class BloodthirstyFireEye : IDisposable
    {
        private readonly HeroController hero;
        private readonly NativeSpellV77 focus;
        private readonly FireEyeCharmV77 charm;
        private readonly BloodthirstyBuff buff = new BloodthirstyBuff();
        private readonly FireEyeCastClock castClock = new FireEyeCastClock();
        private bool completed;
        private bool pendingFinish;
        private bool slug;
        private bool observing;
        private bool disposed;
        private bool applyingHeal;
        public bool Casting => !disposed && focus.NormalFocus;
        public double CastTick => castClock.Tick(Time.time);
        public long BuffToken => buff.Active(Time.time) ? buff.Token : -1;
        public double AuraTick => buff.VisualTick(Time.time);
        public bool BuffActive => !disposed && buff.Active(Time.time);

        public BloodthirstyFireEye(HeroController hero, FireEyeCharmV77 charm)
        { this.hero = hero; this.charm = charm; focus = new NativeSpellV77(hero, NativeSpellSlot.Focus); }

        public void Observe()
        {
            if (disposed || observing) return;
            observing = true;
            try
            {
                HeroControllerStates s = hero.cState;
                if (!hero.gameObject.activeInHierarchy || s.dead || s.hazardDeath || s.hazardRespawning || s.transitioning)
                { buff.Clear(); castClock.Clear(); pendingFinish = false; completed = false; return; }
                if (pendingFinish)
                {
                    pendingFinish = false;
                    // Outside the native AddHealth action iteration; avoid FSM reentrancy.
                    focus.FinishFocus(slug);
                }
                // Schedule the source tail after native StartMPDrain selects its actual
                // charm rate. Native startup waits without showing casting flames.
                bool casting = focus.NormalFocus;
                castClock.Observe(casting, focus.FocusSecondsRemaining, Time.time);
                if (!casting) completed = false;
                focus.SuppressEffects();
            }
            finally { observing = false; }
        }

        public bool ReplaceFocusHeal()
        {
            if (disposed || applyingHeal || !focus.FocusHeal) return false;
            if (!completed && hero.gameObject.activeInHierarchy && !hero.cState.dead && !hero.cState.hazardDeath && !hero.cState.transitioning)
            {
                completed = true; pendingFinish = true; slug = focus.State == "Focus Heal 2";
                // Snapshot real native equipment at completion, outside the scoped focus query.
                buff.Activate(Time.time, charm.Equipped);
            }
            return true; // A native completion never directly heals, including Deep Focus.
        }

        public void AfterEnemyHit(long token, int before, int after)
        {
            Observe();
            if (disposed || applyingHeal || !buff.TryHeal(token, Time.time, before, after,
                PlayerData.instance.GetInt("health"), PlayerData.instance.GetInt("maxHealth"))) return;
            applyingHeal = true;
            try { hero.AddHealth(1); }
            finally { applyingHeal = false; }
        }
        public void Dispose()
        {
            if (disposed) return;
            disposed = true; buff.Clear(); castClock.Clear();
            focus.Dispose();
        }
    }
}
