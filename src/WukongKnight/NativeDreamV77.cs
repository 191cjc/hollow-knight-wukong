using System;
using System.Collections;
using System.Collections.Generic;
using System.Reflection;
using UnityEngine;
using WukongKnight.Core;

namespace WukongKnight
{
    /// <summary>Own only the physical Dream input listener and one held native antic.</summary>
    internal sealed class NativeDreamV77 : IDisposable
    {
        private readonly HeroController hero;
        private readonly Component fsm;
        private readonly PropertyInfo state;
        private readonly MethodInfo setState;
        private readonly object listener;
        private readonly object inactiveState;
        private readonly PropertyInfo activeActions;
        private readonly int listenerIndex;
        private readonly PropertyInfo enabled;
        private readonly bool wasEnabled;
        private readonly object antic;
        private readonly FieldInfo completion;
        private readonly object originalCompletion;
        private readonly object hold;
        private readonly GameObject hitTemplate;
        private bool owned;
        private bool disposed;
        public string State => disposed || fsm == null ? "" : (string)state.GetValue(fsm, null);
        public bool Holding => owned && (State == "Start" || State == "Fsm Cancel" || State == "Take Control");
        private static PropertyInfo Prop(Type t, string n) => t.GetProperty(n) ?? throw new MissingMemberException(t.FullName, n);
        public NativeDreamV77(HeroController hero)
        {
            this.hero = hero;
            Component? found = null;
            foreach (Component c in hero.GetComponents<Component>())
                if (c != null && c.GetType().FullName == "PlayMakerFSM" && (string)Prop(c.GetType(), "FsmName").GetValue(c, null) == "Dream Nail") found = c;
            fsm = found ?? throw new InvalidOperationException("Native Dream Nail FSM missing");
            state = Prop(fsm.GetType(), "ActiveStateName");
            setState = fsm.GetType().GetMethod("SetState", new[] { typeof(string) }) ?? throw new MissingMethodException("Dream Nail.SetState");
            var states = new Dictionary<string, object>();
            foreach (object s in (Array)Prop(fsm.GetType(), "FsmStates").GetValue(fsm, null)) states.Add((string)Prop(s.GetType(), "Name").GetValue(s, null), s);
            foreach (string n in new[] { "Inactive", "Fsm Cancel", "Take Control", "Start", "End", "Regain Control" })
                if (!states.ContainsKey(n)) throw new InvalidOperationException("Unsupported Dream state " + n);
            inactiveState = states["Inactive"];
            listener = Action(inactiveState, "ListenForDreamNail");
            activeActions = inactiveState.GetType().GetProperty("ActiveActions", BindingFlags.Instance | BindingFlags.Public | BindingFlags.NonPublic)
                ?? throw new MissingMemberException("Dream Inactive.ActiveActions");
            Array inactiveActions = (Array)Prop(inactiveState.GetType(), "Actions").GetValue(inactiveState, null);
            listenerIndex = Array.IndexOf(inactiveActions, listener);
            enabled = Prop(listener.GetType(), "Enabled"); wasEnabled = (bool)enabled.GetValue(listener, null);
            antic = Action(states["Start"], "Tk2dPlayAnimationWithEvents");
            completion = antic.GetType().GetField("animationCompleteEvent") ?? throw new MissingFieldException("Dream Start completion");
            originalCompletion = completion.GetValue(antic) ?? throw new InvalidOperationException("Dream completion missing");
            if ((string)Prop(originalCompletion.GetType(), "Name").GetValue(originalCompletion, null) != "FINISHED")
                throw new InvalidOperationException("Another Mod changed Dream Nail antic");
            hold = Activator.CreateInstance(originalCompletion.GetType(), new object[] { "WUKONG DREAM HELD" });
            Transform t = hero.transform.Find("Dream Effects/Hitbox");
            hitTemplate = t != null ? t.gameObject : throw new InvalidOperationException("Native dream hitbox missing");
            if (hitTemplate.GetComponent<PolygonCollider2D>() == null || hitTemplate.activeSelf)
                throw new InvalidOperationException("Unexpected Dream hitbox template");
            try
            {
                enabled.SetValue(listener, false, null);
                // v77 updates ActiveActions without rechecking Enabled until reentry.
                // Remove just our listener from an already-entered Inactive state.
                ((IList)activeActions.GetValue(inactiveState, null)).Remove(listener);
                completion.SetValue(antic, hold);
            }
            catch { Restore(); throw; }
        }
        public bool CanBegin(NativeV77 native, bool airborneDown = false)
        {
            HeroControllerStates s = hero.cState;
            if (disposed || !PlayerData.instance.GetBool("hasDreamNail") || !native.ControlAvailable(hero) || State != "Inactive" ||
                s.attacking || s.dashing || s.backDashing || s.superDashing || s.casting || s.focusing || s.recoiling || s.recoilFrozen || s.wallSliding) return false;
            // Keep native menu/conversation gates; only down-Dream adds air casting.
            return hero.CanDreamNail() || (airborneDown && !s.onGround && native.DownHeld(hero) && hero.CanInput());
        }
        public bool Begin()
        {
            if (disposed || owned || State != "Inactive") return false;
            owned = true;
            // Native broadcast cancels other owned hero actions before taking control.
            setState.Invoke(fsm, new object[] { "Fsm Cancel" });
            if (!Holding) { Finish(); return false; }
            return true;
        }
        public void Finish()
        {
            bool held = Holding; owned = false;
            if (held && hero != null && hero.gameObject.activeInHierarchy && !hero.cState.dead && !hero.cState.hazardDeath && !hero.cState.hazardRespawning && !hero.cState.transitioning)
            {
                hero.AffectedByGravity(true);
                setState.Invoke(fsm, new object[] { "End" });
            }
        }
        // Clone the actual native trigger, preserving tag and SendDreamImpact/FSM handling.
        // Its independent 60ms Deactivate FSM is disabled on this clone only.
        public GameObject CreateImpact(Vector3 position, FireDemonRegion region, float units)
        {
            GameObject clone = UnityEngine.Object.Instantiate(hitTemplate);
            try
            {
                clone.name = "WukongKnight.FullGodslayerDreamImpact";
                clone.transform.SetParent(null, false); clone.transform.rotation = Quaternion.identity;
                clone.transform.localScale = Vector3.one; clone.transform.position = position;
                bool sender = false, deactivator = false;
                foreach (Component c in clone.GetComponents<Component>())
                {
                    if (c == null || c.GetType().FullName != "PlayMakerFSM") continue;
                    string n = (string)Prop(c.GetType(), "FsmName").GetValue(c, null);
                    if (n == "Deactivate") { ((Behaviour)c).enabled = false; deactivator = true; }
                    else if (n == "Send Event") sender = true;
                    else throw new InvalidOperationException("Unexpected native dream trigger FSM");
                }
                if (!sender || !deactivator) throw new InvalidOperationException("Native dream trigger contract changed");
                PolygonCollider2D p = clone.GetComponent<PolygonCollider2D>();
                float x = (float)region.X * units, y = (float)region.Y * units;
                float w = (float)region.Width * units / 2, h = (float)region.Height * units / 2;
                p.pathCount = 1; p.offset = Vector2.zero;
                p.SetPath(0, new[] { new Vector2(x-w,y-h), new Vector2(x+w,y-h), new Vector2(x+w,y+h), new Vector2(x-w,y+h) });
                // The native child trigger inherited the hero Rigidbody2D. An
                // independent wave needs its own kinematic body for static dream scenery.
                Rigidbody2D motion = clone.AddComponent<Rigidbody2D>();
                motion.bodyType = RigidbodyType2D.Kinematic; motion.gravityScale = 0;
                motion.useFullKinematicContacts = true; motion.position = position;
                p.enabled = true; clone.SetActive(true); return clone;
            }
            catch { clone.SetActive(false); UnityEngine.Object.Destroy(clone); throw; }
        }
        public void MoveImpact(GameObject impact, Vector3 position)
        {
            if (impact != null) impact.GetComponent<Rigidbody2D>().position = position;
        }
        private static object Action(object s, string shortName)
        {
            object? result = null;
            foreach (object a in (Array)Prop(s.GetType(), "Actions").GetValue(s, null))
                if (a.GetType().Name == shortName)
                {
                    if (result != null) throw new InvalidOperationException("Ambiguous Dream action " + shortName);
                    result = a;
                }
            return result ?? throw new InvalidOperationException("Missing Dream action " + shortName);
        }
        private void Restore()
        {
            // An action disabled before its first entry has no cached input handler.
            // Prime only this listener when restoring it in its active state.
            if (wasEnabled && State == "Inactive")
                (listener.GetType().GetMethod("OnEnter", Type.EmptyTypes) ?? throw new MissingMethodException("Dream listener.OnEnter")).Invoke(listener, null);
            enabled.SetValue(listener, wasEnabled, null);
            if (wasEnabled && State == "Inactive")
            {
                IList cached = (IList)activeActions.GetValue(inactiveState, null);
                if (!cached.Contains(listener)) cached.Insert(Math.Min(Math.Max(0, listenerIndex), cached.Count), listener);
            }
            if (ReferenceEquals(completion.GetValue(antic), hold)) completion.SetValue(antic, originalCompletion);
        }
        public void Dispose()
        {
            if (disposed) return;
            try { Finish(); } finally { try { Restore(); } finally { disposed = true; } }
        }
    }
}
