using System;
using System.Collections.Generic;
using System.Reflection;
using UnityEngine;

namespace WukongKnight
{
    internal enum NativeSpellSlot { Up, Down, Focus, Forward }

    /// <summary>Scoped Spell Control timing and suppression; never supplies replacement damage.</summary>
    internal sealed class NativeSpellV77 : IDisposable
    {
        private readonly HeroController hero;
        private readonly NativeSpellSlot slot;
        private readonly HashSet<string> heldStates = new HashSet<string>();
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
        private readonly object? heldEvent;
        private readonly object soulCost;
        private readonly PropertyInfo soulCostValue;
        private readonly FieldInfo? draining;
        private readonly FieldInfo? drainInterval;
        private readonly FieldInfo? drainAmount;
        private readonly FieldInfo? drained;
        private readonly FieldInfo? drainTimer;
        private bool disposed;
        public string State => spell == null || disposed ? "" : (string)activeState.GetValue(spell, null);

        public bool HoldsCast => heldStates.Contains(State);
        public bool HoldsState(string name) => heldStates.Contains(name);
        public bool FocusHeal => State == "Focus Heal" || State == "Focus Heal 2";
        public bool NormalFocus => hero != null && hero.cState.focusing && State != "Focus D" &&
            State != "Focus Start D" && State != "Focus Cancel D" && State != "Keep Focus" && State != "Dream Focus End";

        public NativeSpellV77(HeroController hero, NativeSpellSlot slot)
        {
            this.hero = hero; this.slot = slot;
            const BindingFlags flags = BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance;
            FieldInfo field = typeof(HeroController).GetField("spellControl", flags) ?? throw new MissingFieldException("HeroController.spellControl");
            if (field.FieldType.FullName != "PlayMakerFSM") throw new MissingFieldException("Unexpected spellControl type");
            spell = field.GetValue(hero) as Component ?? throw new InvalidOperationException("Spell Control missing");
            if (slot == NativeSpellSlot.Focus)
            {
                draining = FocusField("drainMP", typeof(bool));
                drainInterval = FocusField("drainMP_time", typeof(float));
                drainAmount = FocusField("focusMP_amount", typeof(float));
                drained = FocusField("MP_drained", typeof(float));
                drainTimer = FocusField("drainMP_timer", typeof(float));
            }
            Type type = spell.GetType();
            activeState = Property(type, "ActiveStateName");
            setState = type.GetMethod("SetState", new[] { typeof(string) }) ?? throw new MissingMethodException("PlayMakerFSM.SetState(string)");
            Array states = (Array)Property(type, "FsmStates").GetValue(spell, null);
            var byName = new Dictionary<string, object>();
            foreach (object state in states) byName.Add((string)Property(state.GetType(), "Name").GetValue(state, null), state);
            string[] required = slot == NativeSpellSlot.Up ? new[] { "Scream Antic1", "Scream Antic2", "Spell End" } :
                slot == NativeSpellSlot.Down ? new[] { "Quake Antic", "Quake Finish", "Spell End" } :
                slot == NativeSpellSlot.Forward ? new[] { "Fireball Antic", "Spell End" } :
                new[] { "Focus Heal", "Focus Heal 2", "Focus Get Finish", "Focus Get Finish 2", "Focus Cancel", "Focus Cancel 2" };
            foreach (string name in required)
                if (!byName.ContainsKey(name)) throw new InvalidOperationException("Unsupported Spell Control state: " + name);
            if (slot != NativeSpellSlot.Focus)
                foreach (string name in slot == NativeSpellSlot.Up ? new[] { "Scream Antic1", "Scream Antic2" } :
                    slot == NativeSpellSlot.Forward ? new[] { "Fireball Antic" } : new[] { "Quake Antic" })
                {
                    heldStates.Add(name);
                    object antic = FindAction(byName[name], "HutongGames.PlayMaker.Actions.Tk2dPlayAnimationWithEvents");
                    FieldInfo complete = antic.GetType().GetField("animationCompleteEvent") ?? throw new MissingFieldException(name + " completion");
                    object original = complete.GetValue(antic) ?? throw new InvalidOperationException(name + " completion event missing");
                    string expected = slot == NativeSpellSlot.Up ? "FINISHED" : "ANIM END";
                    if (EventName(original) != expected) throw new InvalidOperationException("Another Mod changed " + name + " completion");
                    if (heldEvent == null) heldEvent = Activator.CreateInstance(original.GetType(), new object[] { "WUKONG SPELL HELD" });
                    events.Add(Tuple.Create(antic, complete, original));
                }
            if (slot == NativeSpellSlot.Down) shakes.Add(FindShake(byName["Quake Antic"], "EnemyKillShake"));
            object variables = Property(type, "FsmVariables").GetValue(spell, null);
            Array ints = (Array)Property(variables.GetType(), "IntVariables").GetValue(variables, null);
            object? cost = null;
            foreach (object variable in ints)
                if ((string)Property(variable.GetType(), "Name").GetValue(variable, null) == "MP Cost") cost = variable;
            soulCost = cost ?? throw new InvalidOperationException("Native MP Cost missing");
            soulCostValue = Property(soulCost.GetType(), "Value");
            Array gameObjects = (Array)Property(variables.GetType(), "GameObjectVariables").GetValue(variables, null);
            var selected = new List<object>();
            foreach (object variable in gameObjects)
            {
                string name = (string)Property(variable.GetType(), "Name").GetValue(variable, null);
                bool use = slot == NativeSpellSlot.Up ? name.StartsWith("Scr ", StringComparison.Ordinal) || name == "Roar Wave" :
                    slot == NativeSpellSlot.Down ? name.StartsWith("Q ", StringComparison.Ordinal) || name == "Q1 Pillar" :
                    slot == NativeSpellSlot.Focus && (name.StartsWith("Focus ", StringComparison.Ordinal) || name == "Lines Anim");
                if (use) selected.Add(variable);
            }
            if (selected.Count == 0 && slot != NativeSpellSlot.Forward) throw new InvalidOperationException("Native spell effect variables missing");
            effectVariables = selected.ToArray();
            variableValue = Property(gameObjects.GetValue(0)!.GetType(), "Value");
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

        // Read after native StartMPDrain, including the selected focus charm rate.
        // Timer remainder compensates integer Soul steps; this is continuous time.
        public double FocusSecondsRemaining
        {
            get
            {
                if (!NormalFocus || draining == null || !(bool)draining.GetValue(hero)) return -1;
                double interval = (float)drainInterval!.GetValue(hero);
                double amount = (float)drainAmount!.GetValue(hero);
                double used = (float)drained!.GetValue(hero);
                double timer = (float)drainTimer!.GetValue(hero);
                if (interval <= 0 || amount <= 0) return -1;
                return Math.Max(0, (amount - used) * interval - timer);
            }
        }

        private static FieldInfo FocusField(string name, Type type)
        {
            FieldInfo? field = typeof(HeroController).GetField(name, BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance);
            if (field == null || field.FieldType != type) throw new MissingFieldException("HeroController." + name);
            return field;
        }

        public void FinishCast(bool quakeRecovery = true)
        {
            if (!HoldsCast || !CanRecover) return;
            // Held Fireball Antic already took control; Spell End skips projectile/spending states.
            setState.Invoke(spell, new object[] { slot == NativeSpellSlot.Down && quakeRecovery ? "Quake Finish" : "Spell End" });
        }

        private bool CanRecover => hero != null && hero.gameObject.activeInHierarchy &&
            !hero.cState.dead && !hero.cState.hazardDeath && !hero.cState.hazardRespawning && !hero.cState.transitioning;

        // Native Set Spell Cost updates this shared variable on CHARM INDICATOR CHECK,
        // independently of casting; directional Dream skills read the same live value.
        public int SoulCost
        {
            get
            {
                int cost = (int)soulCostValue.GetValue(soulCost, null);
                if (cost <= 0 || cost > 99) throw new InvalidOperationException("Unsupported native spell MP Cost");
                return cost;
            }
        }
        public bool SpendSoul()
        {
            int cost = SoulCost;
            if (!HoldsCast || PlayerData.instance.GetInt("MPCharge") < cost) return false;
            // The native spending state follows the antic and is intentionally skipped.
            // Charge its current cost once; it already includes native Spell Twister.
            hero.TakeMP(cost);
            return true;
        }

        public void FinishFocus(bool slug, bool cancel = false)
        {
            if (slot != NativeSpellSlot.Focus || !NormalFocus || !CanRecover) return;
            hero.StopMPDrain();
            setState.Invoke(spell, new object[] { cancel ? (slug ? "Focus Cancel 2" : "Focus Cancel") :
                (slug ? "Focus Get Finish 2" : "Focus Get Finish") });
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
            if (slot == NativeSpellSlot.Focus && !NormalFocus) { RestoreEffects(); return; }
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
                if (slot != NativeSpellSlot.Focus)
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
            RestoreEffects();
        }
        private void RestoreEffects()
        {
            foreach (var pair in visuals) if (pair.Key != null) forceOff.SetValue(pair.Key, pair.Value, null);
            foreach (var pair in colliders) if (pair.Key != null) pair.Key.enabled = pair.Value;
            visuals.Clear(); colliders.Clear(); sources.Clear();
        }
        public void Dispose()
        {
            if (disposed) return;
            // Keep native sources suppressed while releasing a held FSM state.
            try
            {
                if (slot == NativeSpellSlot.Focus) FinishFocus(State.Contains("2") || State == "Focus S", true);
                else FinishCast(false);
            }
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
