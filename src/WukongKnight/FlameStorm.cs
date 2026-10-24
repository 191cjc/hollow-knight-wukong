using System;
using UnityEngine;
using WukongKnight.Core;

namespace WukongKnight
{
    /// <summary>Original spinning body/flames and nearby contact mask on down + spell.</summary>
    internal sealed class FlameStorm : IDisposable
    {
        private readonly HeroController hero;
        private readonly NativeV77 native;
        private readonly NativeSpellV77 spell;
        private readonly Collider2D body;
        private readonly Rigidbody2D motion;
        private readonly float unitsPerPixel;
        private readonly float feet;
        private readonly GameObject source;
        private readonly SpellHitLedger hits = new SpellHitLedger(FlameStormRules.HitCap);
        private double started;
        private string state = "";
        private float lastPhysics = float.NegativeInfinity;
        private bool facing;
        private bool observing;
        private bool disposed;
        private int damage;
        private FlameStormClock Clock => new FlameStormClock(Time.time - started);
        public bool Active => !disposed && hits.Active && spell.HoldsState(state);
        public double Tick => Clock.Tick;
        public bool FacingRight => facing;

        public FlameStorm(HeroController hero, NativeV77 native, CharacterAssets assets)
        {
            this.hero = hero; this.native = native;
            body = hero.GetComponent<Collider2D>() ?? throw new InvalidOperationException("Hero collider missing");
            motion = hero.GetComponent<Rigidbody2D>() ?? throw new InvalidOperationException("Hero rigidbody missing");
            unitsPerPixel = body.bounds.size.y / assets.NominalBodyHeight;
            feet = assets.FeetOffsetPixels;
            if (unitsPerPixel <= 0) throw new InvalidOperationException("Hero body has no height");
            source = new GameObject("WukongKnight.FlameStormDamage");
            try { spell = new NativeSpellV77(hero, NativeSpellSlot.Down); }
            catch { UnityEngine.Object.Destroy(source); throw; }
        }
        public bool BlocksNativeSource(GameObject candidate) => !disposed && spell.BlocksSource(candidate);
        public void Observe()
        {
            if (disposed || observing) return;
            observing = true;
            try
            {
                spell.SuppressEffects();
                string next = spell.State;
                HeroControllerStates s = hero.cState;
                if (!hero.gameObject.activeInHierarchy || s.dead || s.hazardDeath || s.hazardRespawning || s.transitioning || s.recoiling || s.recoilFrozen)
                {
                    hits.Stop(hits.Token); state = next; spell.FinishCast(); return;
                }
                if (next != state)
                {
                    state = next;
                    if (spell.HoldsState(state))
                    {
                        if (!spell.SpendSoul()) { hits.Stop(hits.Token); spell.FinishCast(); state = spell.State; return; }
                        hits.Begin(); started = Time.time; facing = s.facingRight;
                        lastPhysics = float.NegativeInfinity;
                        damage = FlameStormRules.Damage(PlayerData.instance.GetInt("quakeLevel"), PlayerData.instance.GetBool("equippedCharm_19"));
                    }
                    else hits.Stop(hits.Token);
                }
                if (!Active) return;
                if (Clock.Complete) { hits.Stop(hits.Token); spell.FinishCast(); state = spell.State; return; }
                hero.RelinquishControl(); hero.IgnoreInput(); native.ResetInput(hero);
                hero.AffectedByGravity(false); motion.velocity = Vector2.zero;
            }
            finally { observing = false; }
        }
        public void FixedUpdate()
        {
            Observe();
            if (!Active || lastPhysics == Time.fixedTime) return;
            lastPhysics = Time.fixedTime;
            long token = hits.Token;
            FireDemonRegion region = FlameStormRules.Region(facing);
            Bounds bounds = body.bounds;
            Vector3 origin = new Vector3(bounds.center.x, bounds.min.y + feet * unitsPerPixel, hero.transform.position.z);
            source.transform.position = origin;
            Vector2 center = new Vector2(origin.x + (float)region.X * unitsPerPixel, origin.y + (float)region.Y * unitsPerPixel);
            Vector2 size = new Vector2((float)region.Width, (float)region.Height) * unitsPerPixel;
            int mask = native.SkillQueryMask;
            foreach (Collider2D collider in Physics2D.OverlapBoxAll(center, size, 0, mask))
            {
                if (!Owns(token)) return;
                Component? target = native.SkillTarget(collider, hero, mask);
                if (target == null || target is HealthManager health && native.Evading(health)) continue;
                if (hits.TryAirHit(token, target.GetInstanceID(), Time.time))
                    native.FireDemonHit(source, target.gameObject, damage, target.transform.position.x >= origin.x ? 0 : 180,
                        true, () => Owns(token));
            }
        }
        private bool Owns(long token) { Observe(); return Active && hits.Owns(token); }
        public void Dispose()
        {
            if (disposed) return;
            hits.Stop(hits.Token); disposed = true;
            try { spell.Dispose(); }
            finally { UnityEngine.Object.Destroy(source); }
        }
    }
}
