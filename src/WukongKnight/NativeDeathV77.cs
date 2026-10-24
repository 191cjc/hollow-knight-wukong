using System;
using System.Collections.Generic;
using System.Reflection;
using UnityEngine;

namespace WukongKnight
{
    /// <summary>Suppress only native death graphics; all original FSM actions still run.</summary>
    internal sealed class NativeDeathV77
    {
        private readonly HeroController hero;
        private readonly GameObject effect;
        private readonly Renderer body;
        private readonly object[] debris;
        private readonly PropertyInfo value;
        private readonly PropertyInfo forceOff;
        private readonly Dictionary<Renderer, bool> visibility = new Dictionary<Renderer, bool>();
        private readonly List<Tuple<object, PropertyInfo, bool>> visualSpawns = new List<Tuple<object, PropertyInfo, bool>>();
        private bool suppressing;

        public NativeDeathV77(HeroController hero, GameObject effect)
        {
            this.hero = hero;
            this.effect = effect != null ? effect : throw new InvalidOperationException("Native death effect missing.");
            body = hero.GetComponent<Renderer>() ?? throw new InvalidOperationException("Native body renderer missing.");
            Component? fsm = null;
            foreach (Component component in effect.GetComponents<Component>())
                if (component != null && component.GetType().Name == "PlayMakerFSM" &&
                    (string)Property(component.GetType(), "FsmName").GetValue(component, null) == "Hero Death Anim")
                    fsm = component;
            if (fsm == null) throw new InvalidOperationException("Native Hero Death Anim FSM missing.");
            object variables = Property(fsm.GetType(), "FsmVariables").GetValue(fsm, null);
            var selected = new List<object>();
            foreach (object variable in (Array)Property(variables.GetType(), "GameObjectVariables").GetValue(variables, null))
            {
                string name = (string)Property(variable.GetType(), "Name").GetValue(variable, null);
                // These outputs are detached/spawned by the native death FSM.
                if (name == "Head" || name == "Sword") selected.Add(variable);
            }
            if (selected.Count == 0) throw new InvalidOperationException("Native death debris variables changed.");
            debris = selected.ToArray();
            value = Property(debris[0].GetType(), "Value");
            forceOff = Property(typeof(Renderer), "forceRenderingOff");
            // v77 flings an untracked pooled nail instead of storing Sword. Mute
            // only that visual spawn; the state's camera/events still execute.
            foreach (object state in (Array)Property(fsm.GetType(), "FsmStates").GetValue(fsm, null))
            {
                if ((string)Property(state.GetType(), "Name").GetValue(state, null) != "Blow") continue;
                foreach (object action in (Array)Property(state.GetType(), "Actions").GetValue(state, null))
                {
                    Type type = action.GetType();
                    if (type.FullName != "HutongGames.PlayMaker.Actions.FlingObjectsFromGlobalPool") continue;
                    FieldInfo field = type.GetField("gameObject") ?? throw new MissingFieldException(type.FullName, "gameObject");
                    object variable = field.GetValue(action);
                    GameObject? prefab = Property(variable.GetType(), "Value").GetValue(variable, null) as GameObject;
                    if (prefab == null || prefab.name != "Corpse Nail Hero")
                        throw new InvalidOperationException("Unexpected native death pooled visual.");
                    PropertyInfo enabled = Property(type, "Enabled");
                    visualSpawns.Add(Tuple.Create(action, enabled, (bool)enabled.GetValue(action, null)));
                }
            }
        }

        public bool ReadyToResume => hero != null && !hero.cState.dead && body != null && body.enabled &&
            (effect == null || !effect.activeInHierarchy);

        public void Suppress()
        {
            suppressing = true;
            foreach (var patch in visualSpawns) patch.Item2.SetValue(patch.Item1, false, null);
            Hide(effect);
            foreach (object variable in debris) Hide(value.GetValue(variable, null) as GameObject);
        }

        private void Hide(GameObject? source)
        {
            if (source == null) return;
            if (source == hero.gameObject || hero.transform.IsChildOf(source.transform))
                throw new InvalidOperationException("Death visual resolves to hero root.");
            foreach (Renderer renderer in source.GetComponentsInChildren<Renderer>(true))
            {
                if (!visibility.ContainsKey(renderer)) visibility.Add(renderer, (bool)forceOff.GetValue(renderer, null));
                forceOff.SetValue(renderer, true, null);
            }
        }

        public void Restore()
        {
            if (!suppressing) return;
            foreach (var patch in visualSpawns)
                if (!(bool)patch.Item2.GetValue(patch.Item1, null)) patch.Item2.SetValue(patch.Item1, patch.Item3, null);
            foreach (var pair in visibility) if (pair.Key != null) forceOff.SetValue(pair.Key, pair.Value, null);
            visibility.Clear();
            suppressing = false;
        }

        private static PropertyInfo Property(Type type, string name) =>
            type.GetProperty(name) ?? throw new MissingMemberException(type.FullName, name);
    }
}
