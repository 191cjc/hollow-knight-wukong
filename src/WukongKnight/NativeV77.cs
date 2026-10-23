using System;
using System.Collections.Generic;
using System.Reflection;
using UnityEngine;
using WukongKnight.Core;

namespace WukongKnight
{
    /// <summary>One version gate owns all private v77 member names; never substitutes fabricated game APIs.</summary>
    internal sealed class NativeV77
    {
        private const BindingFlags Instance = BindingFlags.Instance | BindingFlags.Public | BindingFlags.NonPublic;
        private readonly FieldInfo attackTime = Field(typeof(HeroController), "attack_time", typeof(float));
        private readonly FieldInfo cooldown = Field(typeof(HeroController), "attack_cooldown", typeof(float));
        private readonly FieldInfo duration = Field(typeof(HeroController), "attackDuration", typeof(float));
        private readonly FieldInfo queue = Field(typeof(HeroController), "attackQueuing", typeof(bool));
        private readonly FieldInfo queueSteps = Field(typeof(HeroController), "attackQueueSteps", typeof(int));
        private readonly FieldInfo relinquished = Field(typeof(HeroController), "controlReqlinquished", typeof(bool));
        private readonly FieldInfo selected = Field(typeof(HeroController), "slashComponent", typeof(NailSlash));
        private readonly FieldInfo poly = Field(typeof(NailSlash), "poly", typeof(PolygonCollider2D));
        private readonly FieldInfo clash = Field(typeof(NailSlash), "clashTinkPoly", typeof(PolygonCollider2D));
        private readonly FieldInfo mesh = Field(typeof(NailSlash), "mesh", typeof(MeshRenderer));
        private readonly FieldInfo input = Field(typeof(HeroController), "inputHandler", typeof(InputHandler));
        private readonly FieldInfo actions = typeof(InputHandler).GetField("inputActions", Instance) ?? throw new MissingFieldException("InputHandler.inputActions");
        private readonly MethodInfo doAttack = Method(typeof(HeroController), "DoAttack");
        private readonly MethodInfo reset = Method(typeof(HeroController), "ResetAttacks");
        private readonly FieldInfo evasion = Field(typeof(HealthManager), "evasionByHitRemaining", typeof(float));
        private readonly FieldInfo contacts = Field(typeof(DamageEnemies), "enteredColliders", typeof(List<Collider2D>));
        private FieldInfo? attackAction;
        private PropertyInfo? wasPressed;
        private FieldInfo? jumpAction;
        private FieldInfo? dashAction;
        private FieldInfo? upAction;
        private FieldInfo? downAction;
        private PropertyInfo? isPressed;
        private float savedDuration;
        private readonly AttackTiming timing = new AttackTiming();

        public bool ControlAvailable(HeroController hero) => !(bool)relinquished.GetValue(hero) && hero.CanInput();
        public bool AttackPressed(HeroController hero) => Pressed(hero, "attack", ref attackAction);
        public bool JumpPressed(HeroController hero) => Pressed(hero, "jump", ref jumpAction);
        public bool DashPressed(HeroController hero) => Pressed(hero, "dash", ref dashAction);
        public bool UpHeld(HeroController hero) => Held(hero, "up", ref upAction);
        public bool DownHeld(HeroController hero) => Held(hero, "down", ref downAction);
        private bool Held(HeroController hero, string name, ref FieldInfo? actionField)
        {
            object? handler = input.GetValue(hero); if (handler == null) return false;
            object? actionSet = actions.GetValue(handler); if (actionSet == null) return false;
            if (actionField == null) actionField = actionSet.GetType().GetField(name, Instance) ?? throw new MissingFieldException("HeroActions." + name);
            object? action = actionField.GetValue(actionSet); if (action == null) return false;
            if (isPressed == null) isPressed = action.GetType().GetProperty("IsPressed", Instance) ?? throw new MissingMemberException("PlayerAction.IsPressed");
            return (bool)isPressed.GetValue(action, null);
        }
        public NailSlash? Selected(HeroController hero) => selected.GetValue(hero) as NailSlash;
        public PolygonCollider2D Polygon(NailSlash slash) => (PolygonCollider2D)poly.GetValue(slash);
        public PolygonCollider2D ClashPolygon(NailSlash slash) => (PolygonCollider2D)clash.GetValue(slash);
        public MeshRenderer SlashRenderer(NailSlash slash) => (MeshRenderer)mesh.GetValue(slash);
        public bool Evading(HealthManager target) => (float)evasion.GetValue(target) > 0;
        public void ClearContacts(DamageEnemies source) => ((List<Collider2D>)contacts.GetValue(source)).Clear();
        public void DoAttack(HeroController hero) => doAttack.Invoke(hero, null);
        public void Reset(HeroController hero) => reset.Invoke(hero, null);
        public void ClearQueue(HeroController hero) { queue.SetValue(hero, false); queueSteps.SetValue(hero, 0); }

        public void OwnTiming(HeroController hero, long token, AttackMode mode, double seconds, double now)
        {
            savedDuration = (float)duration.GetValue(hero);
            double ownedCooldown = timing.Own(token, mode, seconds, (float)cooldown.GetValue(hero), now);
            attackTime.SetValue(hero, 0f);
            // Native Update must not reset attacking ahead of the source-tick timeline.
            duration.SetValue(hero, float.MaxValue);
            cooldown.SetValue(hero, (float)ownedCooldown);
            ClearQueue(hero);
        }

        public void ReleaseTiming(HeroController hero, long token, double now, bool canceled)
        {
            if (!timing.TryRelease(token, now, canceled, out double remainingCooldown)) return;
            duration.SetValue(hero, savedDuration);
            cooldown.SetValue(hero, (float)remainingCooldown);
            ClearQueue(hero);
        }

        private bool Pressed(HeroController hero, string name, ref FieldInfo? actionField)
        {
            object? handler = input.GetValue(hero); if (handler == null) return false;
            object? actionSet = actions.GetValue(handler); if (actionSet == null) return false;
            if (actionField == null) actionField = actionSet.GetType().GetField(name, Instance) ?? throw new MissingFieldException("HeroActions." + name);
            object? action = actionField.GetValue(actionSet); if (action == null) return false;
            if (wasPressed == null) wasPressed = action.GetType().GetProperty("WasPressed", Instance) ?? throw new MissingMemberException("PlayerAction.WasPressed");
            return (bool)wasPressed.GetValue(action, null);
        }
        private static FieldInfo Field(Type type, string name, Type expected)
        {
            FieldInfo field = type.GetField(name, Instance) ?? throw new MissingFieldException(type.FullName, name);
            if (field.FieldType != expected) throw new MissingFieldException("Unexpected v77 field type: " + type.Name + "." + name);
            return field;
        }
        private static MethodInfo Method(Type type, string name) => type.GetMethod(name, Instance, null, Type.EmptyTypes, null) ?? throw new MissingMethodException(type.FullName, name);
    }
}
