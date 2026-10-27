using System;
using System.Collections.Generic;
using System.Reflection;
using UnityEngine;
using WukongKnight.Core;

namespace WukongKnight
{
    /// <summary>Native dash movement, original flame artwork, and one native dash hit per target.</summary>
    internal sealed class FlameDash : IDisposable
    {
        private readonly HeroController hero;
        private readonly NativeV77 native;
        private readonly NativeDashV77 direction;
        private readonly Collider2D body;
        private readonly GameObject source;
        private readonly DashHitLedger hits = new DashHitLedger();
        private readonly HashSet<int> sampled = new HashSet<int>();
        private readonly Dictionary<Renderer, bool> nativeVisuals = new Dictionary<Renderer, bool>();
        private readonly PropertyInfo forceOff = typeof(Renderer).GetProperty("forceRenderingOff") ?? throw new MissingMemberException("Renderer.forceRenderingOff");
        private Vector2 previousCenter;
        private bool restoreSharpShadow;
        private bool disposed;
        private float lastPhysics = float.NegativeInfinity;
        public bool Active => hits.Active && !disposed;
        public bool Downward => Active && native.DashingDown(hero);
        public bool Upward => Active && direction.Upward;
        public double Progress => native.DashProgress(hero);

        public FlameDash(HeroController hero, NativeV77 native, NativeDashV77 direction)
        {
            this.hero = hero; this.native = native; this.direction = direction;
            body = hero.GetComponent<Collider2D>() ?? throw new InvalidOperationException("Native dash collider missing.");
            source = new GameObject("WukongKnight.FlameDash");
            source.transform.SetParent(hero.transform, false);
        }

        public void Begin()
        {
            Stop();
            if (disposed || !hero.cState.dashing) return;
            hits.Begin();
            long token = hits.Token;
            lastPhysics = float.NegativeInfinity;
            previousCenter = body.bounds.center;
            native.SuspendSharpShadow(hero, ref restoreSharpShadow);
            if (!Owns(token)) return; // SetActive can synchronously detach or replace this dash.
            foreach (Renderer renderer in native.DashRenderers(hero))
            {
                if (nativeVisuals.ContainsKey(renderer)) continue;
                nativeVisuals.Add(renderer, (bool)forceOff.GetValue(renderer, null));
                forceOff.SetValue(renderer, true, null);
            }
        }

        public void Observe()
        {
            if (!Active) return;
            if (hero == null || body == null) { Stop(); return; }
            HeroControllerStates s = hero.cState;
            if (!hero.gameObject.activeInHierarchy || !s.dashing || s.dead || s.hazardDeath || s.hazardRespawning || s.transitioning || s.recoiling || s.recoilFrozen)
                Stop();
        }

        public void FixedUpdate()
        {
            Observe();
            if (!Active) return;
            if (lastPhysics == Time.fixedTime) return;
            lastPhysics = Time.fixedTime;
            long token = hits.Token;
            Bounds bounds = body.bounds;
            Vector2 center = bounds.center;
            Vector2 size = new Vector2(bounds.size.x, bounds.size.y);
            Vector2 delta = center - previousCenter;
            int queryMask = native.SkillQueryMask;
            if (delta.sqrMagnitude > 25f) { Stop(); return; } // Scene/teleport is not a dash sweep.
            sampled.Clear();
            if (delta.sqrMagnitude > 0.000001f)
                foreach (RaycastHit2D hit in Physics2D.BoxCastAll(previousCenter, size, 0f, delta.normalized, delta.magnitude, queryMask))
                {
                    if (!Owns(token)) return;
                    Consider(token, hit.collider, delta, queryMask);
                }
            if (!Owns(token)) return;
            foreach (Collider2D collider in Physics2D.OverlapBoxAll(center, size, 0f, queryMask))
            {
                if (!Owns(token)) return;
                Consider(token, collider, delta, queryMask);
            }
            if (Owns(token)) previousCenter = center;
        }

        private bool Owns(long token)
        {
            Observe();
            return Active && hits.Token == token;
        }

        private void Consider(long token, Collider2D collider, Vector2 movement, int queryMask)
        {
            if (!Owns(token)) return;
            Component? component = native.SkillTarget(collider, hero, queryMask);
            if (component == null || !sampled.Add(component.GetInstanceID())) return;
            if (component is HealthManager health && native.Evading(health)) return;
            if (!hits.TryHit(token, component.GetInstanceID())) return;
            float direction = movement.sqrMagnitude > 0.000001f ? Mathf.Atan2(movement.y, movement.x) * Mathf.Rad2Deg : hero.cState.facingRight ? 0f : 180f;
            native.FlameDashHit(source, component.gameObject, direction, () => Owns(token));
        }

        public void Stop()
        {
            if (!hits.Active) return;
            hits.Stop(hits.Token);
            bool sharpShadow = restoreSharpShadow;
            restoreSharpShadow = false;
            var visuals = new Dictionary<Renderer, bool>(nativeVisuals);
            nativeVisuals.Clear();
            foreach (KeyValuePair<Renderer, bool> visual in visuals)
                if (visual.Key != null) forceOff.SetValue(visual.Key, visual.Value, null);
            // Restore flags/state before SetActive callbacks can begin another dash.
            if (hero != null) native.RestoreSharpShadow(hero, sharpShadow);
        }

        public void Dispose()
        {
            if (disposed) return;
            disposed = true;
            try { Stop(); }
            finally { if (source != null) UnityEngine.Object.Destroy(source); }
        }
    }
}
