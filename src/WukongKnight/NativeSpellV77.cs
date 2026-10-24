using System;
using System.Collections.Generic;
using System.Reflection;
using UnityEngine;

namespace WukongKnight
{
    /// <summary>Scoped Spell Control timing and suppression; never supplies replacement damage.</summary>
    internal sealed class NativeSpellV77 : IDisposable
    {
        private readonly HeroController hero;
        private readonly Component spell;
        private readonly PropertyInfo activeState;
        private readonly MethodInfo setState;
        private readonly object[] effectVariables;
        private readonly PropertyInfo variableValue;
        private readonly PropertyInfo forceOff;
        private readonly Dictionary<Renderer, bool> visuals = new Dictionary<Renderer, bool>();
        private readonly Dictionary<Collider2D, bool> colliders = new Dictionary<Collider2D, bool>();
        private readonly HashSet<GameObject> sources = new HashSet<GameObject>();
        private readonly List<Tuple<object, FieldInfo, object>> events = new List<Tuple<object, FieldInfo, object>>();
        private readonly List<Tuple<object, PropertyInfo, bool>> shakes = new List<Tuple<object, PropertyInfo, bool>>();
        private readonly object heldEvent;
        private bool disposed;
        public string State => spell == null || disposed ? "" : (string)activeState.GetValue(spell, null);

        public NativeSpellV77(HeroController hero)
        {
            this.hero = hero;
            const BindingFlags flags = BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance;
            FieldInfo field = typeof(HeroController).GetField("spellControl", flags) ?? throw new MissingFieldException("HeroController.spellControl");
            if (field.FieldType.FullName != "PlayMakerFSM") throw new MissingFieldException("Unexpected spellControl type");
            spell = field.GetValue(hero) as Component ?? throw new InvalidOperationException("Spell Control missing");
            Type type = spell.GetType();
            activeState = Property(type, "ActiveStateName");
            setState = type.GetMethod("SetState", new[] { typeof(string) }) ?? throw new MissingMethodException("PlayMakerFSM.SetState(string)");
            Array states = (Array)Property(type, "FsmStates").GetValue(spell, null);
            var byName = new Dictionary<string, object>();
            foreach (object state in states) byName.Add((string)Property(state.GetType(), "Name").GetValue(state, null), state);
            foreach (string name in new[] { "Quake Antic", "Quake Finish", "Spell End" })
                if (!byName.ContainsKey(name)) throw new InvalidOperationException("Unsupported Spell Control state: " + name);
            object antic = FindAction(byName["Quake Antic"], "HutongGames.PlayMaker.Actions.Tk2dPlayAnimationWithEvents");
            FieldInfo complete = antic.GetType().GetField("animationCompleteEvent") ?? throw new MissingFieldException("Quake animationCompleteEvent");
            object original = complete.GetValue(antic) ?? throw new InvalidOperationException("Quake completion event missing");
            if (EventName(original) != "ANIM END") throw new InvalidOperationException("Another Mod changed Quake Antic completion");
            heldEvent = Activator.CreateInstance(original.GetType(), new object[] { "WUKONG FIRE DEMON HELD" });
            events.Add(Tuple.Create(antic, complete, original));
            shakes.Add(FindShake(byName["Quake Antic"], "EnemyKillShake"));
            object variables = Property(type, "FsmVariables").GetValue(spell, null);
            Array gameObjects = (Array)Property(variables.GetType(), "GameObjectVariables").GetValue(variables, null);
            var selected = new List<object>();
            foreach (object variable in gameObjects)
            {
                string name = (string)Property(variable.GetType(), "Name").GetValue(variable, null);
                if (name.StartsWith("Q ", StringComparison.Ordinal) || name == "Q1 Pillar") selected.Add(variable);
            }
            if (selected.Count == 0) throw new InvalidOperationException("Native quake variables missing");
            effectVariables = selected.ToArray();
            variableValue = Property(effectVariables[0].GetType(), "Value");
            forceOff = Property(typeof(Renderer), "forceRenderingOff");
            try
            {
                // Null would retain an old tk2d callback. A real ignored event replaces it.
                foreach (var patch in events) patch.Item2.SetValue(patch.Item1, heldEvent);
                foreach (var patch in shakes) patch.Item2.SetValue(patch.Item1, false, null);
                SuppressEffects();
            }
            catch { Restore(); throw; }
        }

        public void FinishCast()
        {
            if (State != "Quake Antic" || hero == null || !hero.gameObject.activeInHierarchy ||
                hero.cState.dead || hero.cState.hazardDeath || hero.cState.hazardRespawning || hero.cState.transitioning) return;
            // Finish restores native damage mode/spellQuake, then Spell End restores
            // input, animation and gravity. Never enter native Quake Down/Land.
            setState.Invoke(spell, new object[] { "Quake Finish" });
        }

        public bool BlocksSource(GameObject source)
        {
            if (disposed || source == null) return false;
            SuppressEffects();
            return sources.Contains(source);
        }
        public void SuppressEffects()
        {
            if (disposed) return;
            foreach (object variable in effectVariables)
            {
                GameObject? effect = variableValue.GetValue(variable, null) as GameObject;
                if (effect == null) continue;
                if (hero.transform.IsChildOf(effect.transform) || effect == hero.gameObject)
                    throw new InvalidOperationException("Quake effect resolves to hero root");
                foreach (Transform t in effect.GetComponentsInChildren<Transform>(true)) sources.Add(t.gameObject);
                foreach (Renderer r in effect.GetComponentsInChildren<Renderer>(true))
                {
                    if (!visuals.ContainsKey(r)) visuals.Add(r, (bool)forceOff.GetValue(r, null));
                    forceOff.SetValue(r, true, null);
                }
                // Native spells also damage through PlayMaker TakeDamage, not only DamageEnemies.
                foreach (Collider2D c in effect.GetComponentsInChildren<Collider2D>(true))
                {
                    if (!colliders.ContainsKey(c)) colliders.Add(c, c.enabled);
                    c.enabled = false;
                }
            }
        }
        private void Restore()
        {
            foreach (var patch in events)
                if (ReferenceEquals(patch.Item2.GetValue(patch.Item1), heldEvent)) patch.Item2.SetValue(patch.Item1, patch.Item3);
            foreach (var patch in shakes)
                if (!(bool)patch.Item2.GetValue(patch.Item1, null)) patch.Item2.SetValue(patch.Item1, patch.Item3, null);
            foreach (var pair in visuals) if (pair.Key != null) forceOff.SetValue(pair.Key, pair.Value, null);
            foreach (var pair in colliders) if (pair.Key != null) pair.Key.enabled = pair.Value;
            visuals.Clear(); colliders.Clear(); sources.Clear();
        }
        public void Dispose()
        {
            if (disposed) return;
            // Keep native sources suppressed while releasing a held FSM state.
            try { FinishCast(); }
            finally { try { Restore(); } finally { disposed = true; } }
        }
        private static string EventName(object e) => (string)Property(e.GetType(), "Name").GetValue(e, null);
        private static PropertyInfo Property(Type type, string name) => type.GetProperty(name) ?? throw new MissingMemberException(type.FullName, name);
        private static Tuple<object, PropertyInfo, bool> FindShake(object state, string eventName)
        {
            Tuple<object, PropertyInfo, bool>? found = null;
            foreach (object action in (Array)Property(state.GetType(), "Actions").GetValue(state, null))
            {
                Type type = action.GetType();
                if (type.FullName != "HutongGames.PlayMaker.Actions.SendEventByName") continue;
                FieldInfo field = type.GetField("sendEvent") ?? throw new MissingFieldException(type.FullName, "sendEvent");
                object value = field.GetValue(action) ?? throw new InvalidOperationException("Native landing event missing");
                if ((string)Property(value.GetType(), "Value").GetValue(value, null) != eventName) continue;
                if (found != null) throw new InvalidOperationException("Ambiguous native landing shake");
                PropertyInfo enabled = Property(type, "Enabled");
                if (enabled.PropertyType != typeof(bool) || !enabled.CanWrite) throw new InvalidOperationException("Unsupported native shake action");
                found = Tuple.Create(action, enabled, (bool)enabled.GetValue(action, null));
            }
            return found ?? throw new InvalidOperationException("Missing native shake action: " + eventName);
        }
        private static object FindAction(object state, string fullName)
        {
            object? found = null;
            foreach (object action in (Array)Property(state.GetType(), "Actions").GetValue(state, null))
                if (action.GetType().FullName == fullName)
                {
                    if (found != null) throw new InvalidOperationException("Ambiguous Quake action");
                    found = action;
                }
            return found ?? throw new InvalidOperationException("Missing native Quake animation action");
        }
    }
}
