using System;
using UnityEngine;
using WukongKnight.Core;

namespace WukongKnight
{
    /// <summary>Original spinning body/flames and nearby contact mask on down + Dream Nail.</summary>
    internal sealed class FlameStorm : IDisposable
    {
        private readonly HeroController hero;
        private readonly NativeV77 native;
        private readonly NativeDreamV77 dream;
        private readonly Func<int> soulCost;
        private readonly Collider2D body;
        private readonly Rigidbody2D motion;
        private readonly float unitsPerPixel;
        private readonly float feet;
        private readonly GameObject source;
        private readonly SpellHitLedger hits = new SpellHitLedger(FlameStormRules.HitCap);
        private double started;
        private int lastInputFrame = -1;
        private float lastPhysics = float.NegativeInfinity;
        private bool facing;
        private bool observing;
        private bool disposed;
        private int damage;
        private FlameStormClock Clock => new FlameStormClock(Time.time - started);
        public bool Active => !disposed && hits.Active && dream.Holding;
        public double Tick => Clock.Tick;
        public bool FacingRight => facing;

        public FlameStorm(HeroController hero, NativeV77 native, CharacterAssets assets, NativeDreamV77 dream, Func<int> soulCost)
        {
            this.hero = hero; this.native = native; this.dream = dream; this.soulCost = soulCost;
            body = hero.GetComponent<Collider2D>() ?? throw new InvalidOperationException("Hero collider missing");
            motion = hero.GetComponent<Rigidbody2D>() ?? throw new InvalidOperationException("Hero rigidbody missing");
            unitsPerPixel = body.bounds.size.y / assets.NominalBodyHeight;
            feet = assets.FeetOffsetPixels;
            if (unitsPerPixel <= 0) throw new InvalidOperationException("Hero body has no height");
            source = new GameObject("WukongKnight.FlameStormDamage");
        }
        public void Observe(bool input = false)
        {
            if (disposed || observing) return;
            observing = true;
            try
            {
                HeroControllerStates s = hero.cState;
                if (!hero.gameObject.activeInHierarchy || s.dead || s.hazardDeath || s.hazardRespawning || s.transitioning || s.recoiling || s.recoilFrozen)
                {
                    Stop(); return;
                }
                if (Time.timeScale <= 0) return;
                if (hits.Active && !dream.Holding) { Stop(); return; }
                if (input && lastInputFrame != Time.frameCount)
                {
                    lastInputFrame = Time.frameCount;
                    if (!hits.Active && native.DownHeld(hero) && native.DreamPressed(hero) && dream.CanBegin(native, true) &&
                        FistRules.TryBeginControlled(true, soulCost(), () => PlayerData.instance.GetInt("MPCharge"), dream.Begin,
                            () => !disposed && hero.gameObject.activeInHierarchy && !s.dead && !s.hazardDeath && !s.hazardRespawning && !s.transitioning && dream.Holding,
                            hero.TakeMP, dream.Finish))
                    {
                        hits.Begin(); hero.CancelParryInvuln(); started = Time.time; facing = s.facingRight;
                        lastPhysics = float.NegativeInfinity;
                        damage = FlameStormRules.Damage(PlayerData.instance.GetInt("quakeLevel"), PlayerData.instance.GetBool("equippedCharm_19"));
                    }
                }
                if (!Active) return;
                if (Clock.Complete) { Stop(true); return; }
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
        private void Stop(bool completed = false)
        {
            if (!hits.Active) return; // Never finish another skill's shared Dream owner.
            hits.Stop(hits.Token);
            dream.Finish();
            // Preserve successful Storm recovery formerly provided by Quake Finish.
            HeroControllerStates s = hero.cState;
            if (completed && !disposed && hero.gameObject.activeInHierarchy && !s.dead && !s.hazardDeath &&
                !s.hazardRespawning && !s.transitioning && !s.recoiling && !s.recoilFrozen) hero.QuakeInvuln();
        }
        public void Dispose()
        {
            if (disposed) return;
            try { Stop(); }
            finally { disposed = true; UnityEngine.Object.Destroy(source); }
        }
    }
}
