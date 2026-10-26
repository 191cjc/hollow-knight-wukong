using System;
using System.Collections.Generic;
using UnityEngine;
using WukongKnight.Core;

namespace WukongKnight
{
    /// <summary>Source-clock fist skills. Physics queries resolve actual local hurtboxes.</summary>
    internal sealed class FistSkills : IDisposable
    {
        private sealed class Ghost
        {
            public Vector3 Position;
            public bool Facing;
            public double Born;
            public int Index;
            public bool Released;
            public bool FromGround;
            public double LandedAt = -1;
            public double LastTravel;
            public FistAction Action;
            public double Started;
            public readonly FistContacts Hits = new FistContacts();
            public SpriteRenderer View = null!;
        }
        private sealed class Wave
        {
            public Vector3 Position;
            public bool Facing;
            public bool Full;
            public bool Clone;
            public double Started;
            public double Last;
            public int Damage;
            public readonly FistContacts Hits = new FistContacts();
            public SpriteRenderer View = null!;
            public GameObject? Dream;
        }
        private sealed class Summon
        {
            public Vector3 Position;
            public bool Facing;
            public int Damage;
            public int Nail;
            public FistSummonClock Clock = null!;
            public readonly FistContacts Hits = new FistContacts();
            public SpriteRenderer View = null!;
            public SpriteRenderer? Front;
        }
        private Summon? afterimage;
        private Summon? ape;
        private double nextApe;
        private int lastSummonFrame = -1;
        private readonly HeroController hero;
        private readonly NativeV77 native;
        private readonly NativeSpellV77 forward;
        private readonly NativeSpellV77 down;
        private readonly NativeDreamV77 dream;
        private readonly CharacterAssets assets;
        private readonly Collider2D body;
        private readonly Rigidbody2D motion;
        private readonly float units;
        private readonly float feet;
        private readonly GameObject source;
        private readonly Material material;
        private readonly Renderer nativeBody;
        private readonly RaycastHit2D[] terrain = new RaycastHit2D[32];
        private readonly GodslayerCharge charge = new GodslayerCharge();
        private readonly FistContacts hits = new FistContacts();
        private readonly List<Ghost> ghosts = new List<Ghost>();
        private readonly List<Wave> waves = new List<Wave>();
        private FistAction action;
        private double started;
        private double landedAt = -1;
        private double lastTravel;
        private double nextDream;
        private double lastFixed = double.NegativeInfinity;
        private int lastInputFrame = -1;
        private int nail;
        private bool facing;
        private bool fromGround;
        private bool waveSpawned;
        private bool observing;
        private bool disposed;
        private long token;
        private string lastForward = "";
        private string lastDown = "";
        public int SoulCost => forward.SoulCost;
        private bool Holding => action == FistAction.Earthbreaker ? down.HoldsCast : dream.Holding;
        public bool Active => !disposed && action != FistAction.None;
        public bool FacingRight => facing;
        public bool ProtectsHP => action == FistAction.Earthbreaker && Owns(token);
        private double Elapsed => Math.Max(0, Time.time - started);
        private bool Wielder => PlayerData.instance.GetBool("equippedCharm_30");
        public string Clip => action == FistAction.Godslayer ?
            (charge.Released ? "godslayerRelease" : "godslayerCharge") : "earthbreaker";
        public double Tick => action == FistAction.Godslayer ? charge.Released ? (Elapsed - charge.ReleasedAt) * 30 : charge.ChargeTick(Elapsed, Wielder) :
            action == FistAction.Earthbreaker ? landedAt >= 0 ? 18 + (Time.time - landedAt) * 30 :
                Elapsed * 30 < (fromGround ? 16 : 8) ? Math.Min(7, Elapsed * 30) : Math.Min(17, 8 + (Elapsed * 30 - (fromGround ? 16 : 8))) : Elapsed * 30;
        private Vector3 Origin
        {
            get { Bounds b = body.bounds; return new Vector3(b.center.x, b.min.y + feet * units, hero.transform.position.z); }
        }
        private bool Alive => hero != null && hero.gameObject.activeInHierarchy && !hero.cState.dead && !hero.cState.hazardDeath && !hero.cState.hazardRespawning && !hero.cState.transitioning;
        public FistSkills(HeroController hero, NativeV77 native, CharacterAssets assets, NativeDreamV77 dream)
        {
            this.hero = hero; this.native = native; this.assets = assets; this.dream = dream;
            body = hero.GetComponent<Collider2D>() ?? throw new InvalidOperationException("Hero collider missing");
            motion = hero.GetComponent<Rigidbody2D>() ?? throw new InvalidOperationException("Hero motion missing");
            nativeBody = hero.GetComponent<Renderer>();
            units = body.bounds.size.y / assets.NominalBodyHeight; feet = assets.FeetOffsetPixels;
            if (units <= 0) throw new InvalidOperationException("Invalid fist body calibration");
            source = new GameObject("WukongKnight.FistDamage");
            material = new Material(Shader.Find("Sprites/Default") ?? throw new InvalidOperationException("Sprite shader missing"));
            NativeSpellV77? f = null; NativeSpellV77? d = null;
            try { f = new NativeSpellV77(hero, NativeSpellSlot.Forward); d = new NativeSpellV77(hero, NativeSpellSlot.Down); forward = f; down = d; }
            catch { d?.Dispose(); f?.Dispose(); UnityEngine.Object.Destroy(material); UnityEngine.Object.Destroy(source); throw; }
        }
        public bool BlocksNativeSource(GameObject candidate) => forward.BlocksSource(candidate) || down.BlocksSource(candidate);
        public void Observe(bool input = false)
        {
            if (disposed || observing) return;
            observing = true;
            try
            {
                if (!Alive) { Stop(); ClearActors(); return; }
                if (Time.timeScale <= 0) return;
                ExpireSummons();
                down.SuppressEffects();
                string downState = down.State;
                if (downState != lastDown)
                {
                    lastDown = downState;
                    if (down.HoldsState(downState))
                    {
                        bool accepted = FistRules.TryBeginControlled(true, down.SoulCost,
                            () => PlayerData.instance.GetInt("MPCharge"), () => !Active && !dream.Holding && down.HoldsCast,
                            () => Alive && !disposed && down.HoldsCast, hero.TakeMP, () => down.FinishCast(false));
                        if (accepted) Begin(FistAction.Earthbreaker);
                        else down.FinishCast(false);
                        lastDown = down.State;
                    }
                }
                string state = forward.State;
                if (state != lastForward)
                {
                    lastForward = state;
                    if (forward.HoldsState(state))
                    {
                        Vector3 origin = Origin; bool right = hero.cState.facingRight;
                        bool accepted = false;
                        try
                        {
                            if (!Active && lastSummonFrame != Time.frameCount)
                            {
                                lastSummonFrame = Time.frameCount;
                                accepted = FistRules.TryBeginSummon(FistAction.Afterimage, forward.SoulCost,
                                    () => PlayerData.instance.GetInt("MPCharge"), () => Alive && !disposed && forward.HoldsCast, hero.TakeMP);
                            }
                        }
                        finally { forward.FinishCast(); lastForward = forward.State; }
                        if (accepted && Alive && !disposed) BeginAfterimage(origin, right);
                    }
                }
                if (input && Time.timeScale > 0 && lastInputFrame != Time.frameCount)
                {
                    lastInputFrame = Time.frameCount;
                    if (!Active && !native.DownHeld(hero) && native.DreamPressed(hero) && EligibleDream())
                    {
                        FistAction chosen = native.UpHeld(hero) ? FistAction.FireApe : FistAction.Godslayer;
                        if (chosen == FistAction.FireApe)
                        {
                            if (ape == null && Time.time >= nextApe && FistRules.TryBeginSummon(chosen, forward.SoulCost,
                                () => PlayerData.instance.GetInt("MPCharge"), () => Alive && !disposed && !Active && ape == null && EligibleDream(), hero.TakeMP)) BeginApe();
                        }
                        else if (Time.time >= nextDream && FistRules.TryBeginDream(chosen, forward.SoulCost,
                            () => PlayerData.instance.GetInt("MPCharge"), dream.Begin,
                            () => Alive && dream.Holding, hero.TakeMP, dream.Finish)) Begin(chosen);
                    }
                }
                if (!Active) return;
                if (hero.cState.recoiling || hero.cState.recoilFrozen || !Holding) { Stop(); return; }
                if (action == FistAction.Godslayer) charge.Observe(Elapsed, Wielder, native.DreamHeld(hero));
                if (FistRules.ActionFinished(action, Elapsed, landedAt < 0 ? -1 : Time.time - landedAt,
                    charge.Released, Elapsed - charge.ReleasedAt)) { Stop(true); return; }
                hero.RelinquishControl(); hero.IgnoreInput(); native.ResetInput(hero);
                hero.AffectedByGravity(false); motion.velocity = Vector2.zero;
            }
            finally { observing = false; }
        }
        private bool EligibleDream() => dream.CanBegin(native);
        private void Begin(FistAction chosen)
        {
            action = chosen; token++; started = Time.time; facing = hero.cState.facingRight;
            lastTravel = 0; landedAt = -1; fromGround = hero.cState.onGround; waveSpawned = false;
            charge.Reset(); hits.Clear();
            nail = Math.Max(1, PlayerData.instance.GetInt("nailDamage"));
            foreach (Ghost g in ghosts)
            {
                if (g.Action != FistAction.None || chosen != FistAction.Godslayer && chosen != FistAction.Earthbreaker) continue;
                g.Action = chosen; g.Facing = facing; g.Released = false; g.Started = Time.time; g.Hits.Clear();
                g.LandedAt=-1; g.LastTravel=0;
                if (chosen == FistAction.Earthbreaker) g.FromGround=MoveGhost(g,new Vector2(0,-.02f));
            }
        }
        public void FixedUpdate()
        {
            Observe();
            if (disposed || !Alive || lastFixed == Time.fixedTime || Time.timeScale <= 0) return;
            lastFixed = Time.fixedTime;
            long owned = token;
            FistAction current = action;
            if (Active)
            {
                double tick = Elapsed * 30;
                if (current == FistAction.Godslayer)
                {
                    if (charge.Released && !waveSpawned && Elapsed - charge.ReleasedAt >= .1)
                    {
                        waveSpawned = true; AddWave(Origin, facing, charge.Full, false);
                        foreach (Ghost g in ghosts)
                            if (g.Action == FistAction.Godslayer) { AddWave(g.Position, g.Facing, charge.Full, true); g.Started = Time.time; g.Released = true; }
                    }
                }
                else if (current == FistAction.Earthbreaker)
                {
                    if (landedAt < 0)
                    {
                        double old = lastTravel; lastTravel = tick;
                        double step = FistRules.EarthbreakerStep(old, tick, fromGround);
                        bool grounded = Move(new Vector2(0, (float)step * units));
                        if (grounded && tick > FistRules.EarthbreakerAnticTicks(fromGround)) landedAt = Time.time;
                    }
                    bool land = landedAt >= 0;
                    if (land || tick >= (fromGround ? 16 : 8))
                        Query(Origin, facing, FistRules.Region(land ? "effect1_2" : "effect1_1", 0, facing), hits, land ? 1 : 0, 1, 0,
                            FistRules.DreamDamage(current, nail, false, land, false), () => Owns(owned));
                }
            }
            if (!Alive || disposed) return;
            UpdateSummons();
            if (!Alive || disposed) return;
            // Independent actors survive normal recovery; cancellation never grants old body hits.
            for (int i = ghosts.Count - 1; i >= 0; i--)
            {
                Ghost g = ghosts[i];
                if (FistRules.GhostFinished(g.Action, g.Released, Time.time-g.Started,
                    g.LandedAt < 0 ? -1 : Time.time-g.LandedAt, Time.time-g.Born)) { RemoveGhost(i); continue; }
                if (g.Action == FistAction.Earthbreaker)
                {
                    double t = (Time.time-g.Started)*30;
                    double riseEnd=FistRules.EarthbreakerAnticTicks(g.FromGround);
                    if (g.LandedAt < 0)
                    {
                        double old=g.LastTravel;g.LastTravel=t;
                        double step=FistRules.EarthbreakerStep(old,t,g.FromGround);
                        bool ground=MoveGhost(g,new Vector2(0,(float)step*units));
                        if (ground && t>riseEnd) g.LandedAt=Time.time;
                    }
                    bool land=g.LandedAt>=0;
                    if (land || t>=riseEnd)
                        Query(g.Position, g.Facing, FistRules.Region(land ? "effect1_2" : "effect1_1", 0, g.Facing), g.Hits, land ? 1 : 0, 1, 0,
                            FistRules.DreamDamage(FistAction.Earthbreaker,nail,false,land,true), () => !disposed && Alive && ghosts.Contains(g));
                    if (disposed || !Alive || !ghosts.Contains(g)) return;
                }
                if (disposed || !Alive) return;
            }
            for (int i = waves.Count - 1; i >= 0; i--)
            {
                Wave w = waves[i]; double age = Time.time-w.Started;
                if (age >= (w.Full ? .667 : .5)) { DestroyWave(w); waves.RemoveAt(i); continue; }
                if (w.Full) w.Position += Vector3.right * (float)(Time.time-w.Last) * 720 * units * (w.Facing ? 1 : -1);
                w.Last = Time.time;
                if (w.Dream != null) dream.MoveImpact(w.Dream, w.Position);
                Query(w.Position, w.Facing, FistRules.Region(w.Full ? "effect2_1" : "effect2_2",0,w.Facing), w.Hits, 0, 1, 0,
                    w.Damage, () => !disposed && Alive && waves.Contains(w), true);
                if (disposed || !Alive) return;
            }
        }
        private void BeginAfterimage(Vector3 origin, bool right)
        {
            DestroySummon(afterimage); afterimage = null;
            foreach (Ghost g in ghosts) Destroy(g.View); ghosts.Clear();
            afterimage = new Summon { Position=origin, Facing=right, Clock=new FistSummonClock(FistAction.Afterimage,Time.time),
                Damage=FistRules.SpellDamage(PlayerData.instance.GetInt("fireballLevel"),PlayerData.instance.GetBool("equippedCharm_19")), View=View("SummonedCombo") };
        }
        private void BeginApe()
        {
            var summoned = new Summon { Position=Origin, Facing=hero.cState.facingRight, Clock=new FistSummonClock(FistAction.FireApe,Time.time),
                Nail=Math.Max(1,PlayerData.instance.GetInt("nailDamage")), View=View("MovingApeBack",-1) };
            try { summoned.Front=View("MovingApeFront",2); ape=summoned; }
            catch { DestroySummon(summoned); throw; }
        }
        private static void DestroySummon(Summon? summoned)
        {
            if (summoned == null) return;
            summoned.Clock.Cancel(); Destroy(summoned.View);
            if (summoned.Front != null) Destroy(summoned.Front);
        }
        private void ExpireSummons()
        {
            if (afterimage != null && !afterimage.Clock.Active(Time.time)) { DestroySummon(afterimage); afterimage=null; }
            if (ape != null && !ape.Clock.Active(Time.time)) { DestroySummon(ape); ape=null; nextApe=Time.time+3; }
        }
        private bool OwnsSummon(Summon summoned) => !disposed && Alive && summoned.Clock.Active(Time.time) &&
            (ReferenceEquals(summoned,afterimage) || ReferenceEquals(summoned,ape));
        private void UpdateSummons()
        {
            Summon? combo = afterimage;
            if (combo != null && OwnsSummon(combo))
            {
                while (combo.Clock.NextAfterimageStep(Time.time,out double pixels,out int birth))
                {
                    MoveActor(ref combo.Position,new Vector2((float)pixels*units*(combo.Facing ? 1 : -1),0));
                    if (birth != 0) ghosts.Add(new Ghost { Position=combo.Position,Facing=combo.Facing,Born=Time.time,Index=birth,View=View("Afterimage") });
                }
                for (int i=1;i<=5 && OwnsSummon(combo);i++)
                    Query(combo.Position,combo.Facing,FistRules.Region("effect4_"+i,combo.Clock.Tick(Time.time),combo.Facing),combo.Hits,i,i==1 ? 2 : 1,i==1 ? .3 : 0,
                        combo.Damage,() => OwnsSummon(combo));
            }
            Summon? moving = ape;
            if (moving != null && OwnsSummon(moving))
            {
                moving.Position=Origin; moving.Facing=hero.cState.facingRight;
                double tick=moving.Clock.Tick(Time.time);
                Query(moving.Position,moving.Facing,FistRules.Region("effect5_0",tick,moving.Facing),moving.Hits,0,5,.434,
                    FistRules.DreamDamage(FistAction.FireApe,moving.Nail,false,false,false),() => OwnsSummon(moving));
                if (OwnsSummon(moving)) Query(moving.Position,moving.Facing,FistRules.Region("effect5_1",tick,moving.Facing),moving.Hits,1,2,.4,
                    FistRules.DreamDamage(FistAction.FireApe,moving.Nail,false,true,false),() => OwnsSummon(moving));
            }
        }
        private void AddWave(Vector3 origin, bool right, bool full, bool clone)
        {
            var w = new Wave { Position = origin + new Vector3((right ? 80 : -80)*units,33*units,0), Facing=right, Full=full, Clone=clone,
                Started=Time.time, Last=Time.time, Damage=FistRules.DreamDamage(FistAction.Godslayer,nail,full,false,clone), View=View("Godslayer") };
            try
            {
                if (full && !clone) w.Dream = dream.CreateImpact(w.Position, FistRules.Region("effect2_1",0,right)!.Value, units);
                waves.Add(w);
            }
            catch { DestroyWave(w); throw; }
        }
        private bool Owns(long t) => !disposed && Alive && Active && t == token && !hero.cState.recoiling && !hero.cState.recoilFrozen && Holding;
        private void Query(Vector3 origin, bool right, FireDemonRegion? optional, FistContacts ledger, int window, int cap, double interval, int damage, Func<bool> owns, bool projectile = false)
        {
            if (!optional.HasValue || !owns()) return;
            FireDemonRegion r = optional.Value;
            int mask = native.SkillQueryMask;
            Vector2 center = new Vector2(origin.x+(float)r.X*units,origin.y+(float)r.Y*units);
            Vector2 size = new Vector2((float)r.Width,(float)r.Height)*units;
            foreach (Collider2D collider in Physics2D.OverlapBoxAll(center,size,0,mask))
            {
                if (!owns()) return;
                Component? target = native.SkillTarget(collider,hero,mask);
                if (target == null || target is HealthManager h && native.Evading(h)) continue;
                if (ledger.TryHit(window,target.GetInstanceID(),cap,interval,Time.time))
                {
                    source.transform.position=origin;
                    native.SpellHit(source,target.gameObject,damage,
                        FistRules.PushDirection(origin.x,target.transform.position.x,right,projectile),
                        false,FistRules.KnockbackMagnitude,owns);
                }
            }
        }
        // Cast the unchanged native body against terrain; consume blocked travel immediately.
        private bool Move(Vector2 delta)
        {
            float distance=delta.magnitude; if (distance <= .00001f) return false;
            Vector2 direction=delta/distance;
            var filter=new ContactFilter2D { useTriggers=false, useLayerMask=true, layerMask=Physics2D.GetLayerCollisionMask(body.gameObject.layer) };
            int count=body.Cast(direction,filter,terrain,distance+.02f);
            float allowed=distance; bool floor=false;
            if (count >= terrain.Length) return delta.y < 0;
            for (int i=0;i<count;i++)
            {
                RaycastHit2D h=terrain[i]; if (h.collider == null || h.collider.isTrigger || h.collider.transform.IsChildOf(hero.transform) || Vector2.Dot(h.normal,direction) >= -.01f) continue;
                allowed=Math.Min(allowed,Math.Max(0,h.distance-.015f));
                if (direction.y < -.5f && h.normal.y > .5f) floor=true;
            }
            motion.position += direction*allowed; return floor;
        }
        private bool MoveGhost(Ghost g, Vector2 delta) => MoveActor(ref g.Position, delta);
        private bool MoveActor(ref Vector3 position, Vector2 delta)
        {
            float distance=delta.magnitude; if (distance<=.00001f) return false;
            Vector2 direction=delta/distance;
            Bounds bounds=body.bounds;
            Vector2 center=new Vector2(position.x,position.y+bounds.size.y/2-feet*units);
            var filter=new ContactFilter2D { useTriggers=false,useLayerMask=true,layerMask=Physics2D.GetLayerCollisionMask(body.gameObject.layer) };
            int count=Physics2D.BoxCast(center,bounds.size,0,direction,filter,terrain,distance+.02f);
            float allowed=distance; bool floor=false;
            if (count>=terrain.Length) return delta.y<0;
            for (int i=0;i<count;i++)
            {
                RaycastHit2D h=terrain[i];
                if (h.collider == null || h.collider.isTrigger || h.collider.transform.IsChildOf(hero.transform) || Vector2.Dot(h.normal,direction)>=-.01f) continue;
                allowed=Math.Min(allowed,Math.Max(0,h.distance-.015f));
                if (direction.y<-.5f && h.normal.y>.5f) floor=true;
            }
            position+=(Vector3)(direction*allowed); return floor;
        }
        private SpriteRenderer View(string name, int order = 1)
        {
            var go=new GameObject("WukongKnight."+name); go.transform.localScale=Vector3.one*(100*units);
            var view=go.AddComponent<SpriteRenderer>(); view.sharedMaterial=material;
            view.sortingLayerID=nativeBody.sortingLayerID; view.sortingOrder=nativeBody.sortingOrder+order; return view;
        }
        public void UpdateView()
        {
            if (disposed) return;
            if (afterimage != null && afterimage.Clock.Active(Time.time))
                Render(afterimage.View, afterimage.Position, afterimage.Facing, "afterimageCombo", afterimage.Clock.Tick(Time.time), Color.white);
            if (ape != null && ape.Clock.Active(Time.time))
            {
                // Source moving awakening: both effects follow actual player root/facing.
                Render(ape.View, Origin, hero.cState.facingRight, "fireApeAwakenedBack", ape.Clock.Tick(Time.time), Color.white);
                Render(ape.Front!, Origin, hero.cState.facingRight, "fireApeAwakenedFront", ape.Clock.Tick(Time.time), Color.white);
            }
            foreach (Ghost g in ghosts)
            {
                string clip=g.Action == FistAction.Godslayer ? (g.Released ? "godslayerRelease" : "godslayerCharge") : g.Action == FistAction.Earthbreaker ? "earthbreaker" : "afterimageIdle"+g.Index;
                double t=g.Action == FistAction.Godslayer && !g.Released ? charge.ChargeTick(Elapsed,Wielder) : (Time.time-g.Started)*30;
                if (g.Action == FistAction.Earthbreaker)
                {
                    double elapsed=(Time.time-g.Started)*30, riseEnd=g.FromGround ? 16 : 8;
                    t=g.LandedAt>=0 ? 18+(Time.time-g.LandedAt)*30 : elapsed<riseEnd ? Math.Min(7,elapsed) : Math.Min(17,8+elapsed-riseEnd);
                }
                Render(g.View,g.Position,g.Facing,clip,t,new Color(1,.55f,.18f,.65f));
            }
            foreach (Wave w in waves) Render(w.View,w.Position,w.Facing,w.Full ? "godslayerWave" : "godslayerPunch",(Time.time-w.Started)*30,w.Clone ? new Color(1,.65f,.25f,.65f) : Color.white);
        }
        private void Render(SpriteRenderer view, Vector3 origin, bool right, string clip, double tick, Color color)
        {
            view.sprite=assets.Clips[clip].Sample(clip == "godslayerPunch" ? tick % assets.Clips[clip].Ticks : tick); view.flipX=!right; view.color=color;
            view.transform.position=new Vector3(origin.x,origin.y,hero.transform.position.z-.002f);
        }
        private static void Destroy(SpriteRenderer r) { if (r != null) { r.enabled=false; UnityEngine.Object.Destroy(r.gameObject); } }
        private static void DestroyWave(Wave w)
        {
            if (w.Dream != null) { w.Dream.SetActive(false); UnityEngine.Object.Destroy(w.Dream); }
            Destroy(w.View);
        }
        private void ClearActors()
        {
            DestroySummon(afterimage); afterimage = null; DestroySummon(ape); ape = null;
            foreach (Ghost g in ghosts) Destroy(g.View); ghosts.Clear();
            foreach (Wave w in waves) DestroyWave(w); waves.Clear();
        }
        private void RemoveGhost(int index) { Destroy(ghosts[index].View); ghosts.RemoveAt(index); }
        public void CancelAll() { Stop(); ClearActors(); }
        public void Stop(bool completed = false)
        {
            if (!Active) return;
            bool earthbreaker = action == FistAction.Earthbreaker;
            bool quakeRecovery = completed && earthbreaker && landedAt >= 0;
            action=FistAction.None; token++; hits.Clear();
            nextDream=Time.time+.25;
            for (int i=ghosts.Count-1;i>=0;i--)
                if (ghosts[i].Action == FistAction.Godslayer && !ghosts[i].Released) RemoveGhost(i);
            if (Alive) hero.AffectedByGravity(true);
            // Skip native Quake Finish: only a confirmed landing grants the timer below.
            if (earthbreaker) { down.FinishCast(false); lastDown = down.State; }
            else dream.Finish();
            // Copies, canceled actions and unlanded timeouts never grant this timer.
            if (quakeRecovery && !disposed && Alive && !hero.cState.recoiling && !hero.cState.recoilFrozen) hero.QuakeInvuln();
        }
        public void Dispose()
        {
            if (disposed) return;
            try { Stop(); } finally
            {
                disposed=true; ClearActors();
                try { down.Dispose(); } finally { try { forward.Dispose(); } finally { UnityEngine.Object.Destroy(material); UnityEngine.Object.Destroy(source); } }
            }
        }
    }
}
