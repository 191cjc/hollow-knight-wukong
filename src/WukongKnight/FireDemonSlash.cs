using System;
using UnityEngine;
using WukongKnight.Core;

namespace WukongKnight
{
    /// <summary>Source-timed Fire Demon; native down-spell owns input, Soul and recovery.</summary>
    internal sealed class FireDemonSlash : IDisposable
    {
        private readonly HeroController hero;
        private readonly NativeV77 native;
        private readonly NativeSpellV77 spell;
        private readonly CharacterAssets assets;
        private readonly Collider2D body;
        private readonly Rigidbody2D motion;
        private readonly float unitsPerPixel;
        private readonly GameObject source;
        private readonly GameObject airEffect;
        private readonly GameObject impact;
        private readonly SpriteRenderer airRenderer;
        private readonly SpriteRenderer impactRenderer;
        private readonly Material material;
        private readonly SpellHitLedger hits = new SpellHitLedger();
        private FireDemonDamage damage;
        private string state = "";
        private double started;
        private float lastPhysics = float.NegativeInfinity;
        private bool airSpawned;
        private bool facing;
        private bool observing;
        private bool disposed;
        private FireDemonTimeline Clock => new FireDemonTimeline(Time.time - started);
        public bool Active => !disposed && hits.Active && state == "Quake Antic";
        public string Clip => "effect5";
        public double Tick => Clock.Tick;
        public bool FacingRight => facing;

        public FireDemonSlash(HeroController hero, NativeV77 native, CharacterAssets assets)
        {
            this.hero = hero; this.native = native; this.assets = assets;
            body = hero.GetComponent<Collider2D>() ?? throw new InvalidOperationException("Hero collider missing");
            motion = hero.GetComponent<Rigidbody2D>() ?? throw new InvalidOperationException("Hero rigidbody missing");
            unitsPerPixel = body.bounds.size.y / assets.NominalBodyHeight;
            if (unitsPerPixel <= 0) throw new InvalidOperationException("Hero body has no height");
            source = new GameObject("WukongKnight.FireDemonDamage");
            airEffect = new GameObject("WukongKnight.FireDemonAir");
            impact = new GameObject("WukongKnight.FireDemonImpact");
            Material? pendingMaterial = null;
            try
            {
                airRenderer = airEffect.AddComponent<SpriteRenderer>();
                impactRenderer = impact.AddComponent<SpriteRenderer>();
                material = pendingMaterial = new Material(Shader.Find("Sprites/Default") ?? throw new InvalidOperationException("Sprite shader missing"));
                Renderer nativeBody = hero.GetComponent<Renderer>() ?? throw new InvalidOperationException("Native body missing");
                foreach (SpriteRenderer r in new[] { airRenderer, impactRenderer })
                {
                    r.sharedMaterial = material; r.sortingLayerID = nativeBody.sortingLayerID;
                    r.sortingOrder = nativeBody.sortingOrder + 1; r.enabled = false;
                    // Baseline pixel/world calibration. Enlargement is baked into the PNGs.
                    r.transform.localScale = new Vector3(100 * unitsPerPixel, 100 * unitsPerPixel, 1);
                }
                spell = new NativeSpellV77(hero);
            }
            catch { if (pendingMaterial != null) UnityEngine.Object.Destroy(pendingMaterial); DestroyObjects(); throw; }
        }

        public bool BlocksNativeSource(GameObject sourceObject) => !disposed && spell.BlocksSource(sourceObject);
        public void Observe()
        {
            if (disposed || observing) return;
            observing = true;
            try
            {
                spell.SuppressEffects();
                string next = spell.State;
                if (hero == null || !hero.gameObject.activeInHierarchy || hero.cState.dead || hero.cState.hazardDeath || hero.cState.hazardRespawning || hero.cState.transitioning || hero.cState.recoiling || hero.cState.recoilFrozen)
                {
                    Cancel(); state = next;
                    spell.FinishCast(); return;
                }
                if (next != state)
                {
                    state = next;
                    if (state == "Quake Antic")
                    {
                        started = Time.time; airSpawned = false;
                        lastPhysics = float.NegativeInfinity;
                        facing = hero.cState.facingRight;
                        damage = new FireDemonDamage(PlayerData.instance.GetInt("quakeLevel"), PlayerData.instance.GetBool("equippedCharm_19"));
                        hits.Begin();
                    }
                    else Cancel();
                }
                if (!Active) return;
                FireDemonTimeline clock = Clock;
                if (clock.Complete)
                {
                    Cancel(); spell.FinishCast(); state = spell.State; return;
                }
                // Quake Antic relinquishes only on entry. Keep its input/motion
                // invariant for the longer source timeline, before native updates.
                // RelinquishControl alone is a no-op if already relinquished.
                hero.RelinquishControl();
                hero.IgnoreInput();
                native.ResetInput(hero);
                hero.AffectedByGravity(false);
                motion.velocity = Vector2.zero;
                if (clock.Air && !airSpawned)
                {
                    airSpawned = true;
                    // Original (+177 facing, -95 Flash Y-down), without centered registration.
                    airEffect.transform.position = Origin() + new Vector3(
                        (float)FireDemonGeometry.AirSpawnX * (facing ? 1 : -1),
                        (float)FireDemonGeometry.AirSpawnY, 0) * unitsPerPixel;
                    airRenderer.flipX = !facing;
                }
                if (clock.Finisher && !hits.FinisherStarted)
                {
                    // Original effect expiry, never a ground-contact or native dive event.
                    hits.BeginFinisher(hits.Token);
                    impact.transform.position = Origin();
                    impactRenderer.flipX = !facing;
                }
            }
            finally { observing = false; }
        }

        private Vector3 Origin()
        {
            Bounds bounds = body.bounds;
            // Share the source root with the original effect5 character animation.
            return new Vector3(bounds.center.x, bounds.min.y + assets.FeetOffsetPixels * unitsPerPixel, hero.transform.position.z - 0.002f);
        }
        private void Cancel()
        {
            hits.Stop(hits.Token); airRenderer.enabled = false; impactRenderer.enabled = false;
        }
        public void FixedUpdate()
        {
            Observe();
            if (disposed || !Active || lastPhysics == Time.fixedTime) return;
            lastPhysics = Time.fixedTime;
            if (Clock.Air && airSpawned) Query(true);
            else if (Clock.Finisher && hits.FinisherStarted) Query(false);
        }

        private void Query(bool air)
        {
            long token = hits.Token;
            FireDemonRegion region = air ? FireDemonGeometry.Air(facing) : FireDemonGeometry.Finisher(facing);
            Vector2 size = new Vector2((float)region.Width, (float)region.Height) * unitsPerPixel;
            Vector3 origin = air ? airEffect.transform.position : impact.transform.position;
            Vector2 center = new Vector2(origin.x + (float)region.X * unitsPerPixel, origin.y + (float)region.Y * unitsPerPixel);
            source.transform.position = origin;
            int queryMask = native.SkillQueryMask;
            foreach (Collider2D collider in Physics2D.OverlapBoxAll(center, size, 0, queryMask))
            {
                if (!Owns(token, air)) return;
                Component? component = native.SkillTarget(collider, hero, queryMask);
                if (component == null || (component is HealthManager health && native.Evading(health))) continue;
                bool accepted = air ? hits.TryAirHit(token, component.GetInstanceID(), Time.time) : hits.TryFinisher(token, component.GetInstanceID());
                if (accepted)
                    native.FireDemonHit(source, component.gameObject, air ? damage.Air : damage.Finisher,
                        facing ? 0 : 180, !air, () => Owns(token, air));
            }
        }
        private bool Owns(long token, bool air)
        {
            Observe();
            return !disposed && hits.Owns(token) && Active && (air ? Clock.Air : Clock.Finisher);
        }
        public void UpdateView()
        {
            Observe();
            if (disposed) return;
            FireDemonTimeline clock = Clock;
            airRenderer.enabled = Active && clock.Air && airSpawned;
            if (airRenderer.enabled) airRenderer.sprite = assets.Clips["fireDemonAirEffect"].Sample(clock.AirTick);
            impactRenderer.enabled = Active && clock.Finisher && hits.FinisherStarted;
            if (impactRenderer.enabled) impactRenderer.sprite = assets.Clips["fireDemonImpact"].Sample(clock.FinisherTick);
        }
        private void DestroyObjects()
        { UnityEngine.Object.Destroy(impact); UnityEngine.Object.Destroy(airEffect); UnityEngine.Object.Destroy(source); }
        public void Dispose()
        {
            if (disposed) return;
            Cancel(); disposed = true;
            try { spell.Dispose(); }
            finally { UnityEngine.Object.Destroy(material); DestroyObjects(); }
        }
    }
}
