using System;
using System.Collections;
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
        private readonly FieldInfo slashBaseScale = Field(typeof(NailSlash), "scale", typeof(Vector3));
        private readonly FieldInfo mesh = Field(typeof(NailSlash), "mesh", typeof(MeshRenderer));
        private readonly FieldInfo input = Field(typeof(HeroController), "inputHandler", typeof(InputHandler));
        private readonly FieldInfo actions = typeof(InputHandler).GetField("inputActions", Instance) ?? throw new MissingFieldException("InputHandler.inputActions");
        private readonly MethodInfo doAttack = Method(typeof(HeroController), "DoAttack");
        private readonly MethodInfo reset = Method(typeof(HeroController), "ResetAttacks");
        private readonly MethodInfo resetInput = Method(typeof(HeroController), "ResetInput");
        private readonly FieldInfo evasion = Field(typeof(HealthManager), "evasionByHitRemaining", typeof(float));
        private readonly FieldInfo contacts = Field(typeof(DamageEnemies), "enteredColliders", typeof(List<Collider2D>));
        private readonly MethodInfo invulnerable = typeof(HeroController).GetMethod("Invulnerable", Instance, null, new[] { typeof(float) }, null)
            ?? throw new MissingMethodException("HeroController.Invulnerable(float)");
        private readonly FieldInfo invulTime = Field(typeof(HeroController), "INVUL_TIME", typeof(float));
        private readonly FieldInfo invulTimeStal = Field(typeof(HeroController), "INVUL_TIME_STAL", typeof(float));
        private readonly FieldInfo damageEffect = FieldByTypeName(typeof(HeroController), "damageEffectFSM", "PlayMakerFSM");
        private readonly FieldInfo doubleHitEffect = Field(typeof(HeroController), "takeHitDoublePrefab", typeof(GameObject));
        private readonly FieldInfo heroDeath = Field(typeof(HeroController), "heroDeathPrefab", typeof(GameObject));
        private readonly FieldInfo dashDown = Field(typeof(HeroController), "dashingDown", typeof(bool));
        private readonly FieldInfo dashTimer = Field(typeof(HeroController), "dash_timer", typeof(float));
        private readonly FieldInfo dashDuration = Field(typeof(HeroController), "DASH_TIME", typeof(float));
        private readonly FieldInfo sharpShadow = Field(typeof(HeroController), "sharpShadowPrefab", typeof(GameObject));
        private readonly MethodInfo takeDamageEvent = typeof(FSMUtility).GetMethod("SendEventToGameObject", BindingFlags.Public | BindingFlags.Static,
            null, new[] { typeof(GameObject), typeof(string), typeof(bool) }, null) ?? throw new MissingMethodException("FSMUtility.SendEventToGameObject(GameObject,string,bool)");
        private readonly FieldInfo dashEffect = Field(typeof(HeroController), "dashEffect", typeof(GameObject));
        private readonly FieldInfo dashBurst = FieldByTypeName(typeof(HeroController), "dashBurst", "PlayMakerFSM");
        private readonly FieldInfo dashParticles = Field(typeof(HeroController), "dashParticlesPrefab", typeof(GameObject));
        private readonly FieldInfo shadowParticles = Field(typeof(HeroController), "shadowdashParticlesPrefab", typeof(GameObject));
        private FieldInfo? attackAction;
        private PropertyInfo? wasPressed;
        private FieldInfo? jumpAction;
        private FieldInfo? dashAction;
        private FieldInfo? upAction;
        private FieldInfo? downAction;
        private FieldInfo? dreamAction;
        private PropertyInfo? isPressed;
        private float savedDuration;
        private float nativeCooldown;
        private double acceptedAt;
        private long owner;

        public GameObject DeathEffect(HeroController hero) => (GameObject)heroDeath.GetValue(hero);
        public bool DashingDown(HeroController hero) => (bool)dashDown.GetValue(hero);

        public bool ControlAvailable(HeroController hero) => !(bool)relinquished.GetValue(hero) && hero.CanInput();
        public bool AttackPressed(HeroController hero) => Pressed(hero, "attack", ref attackAction);
        public bool JumpPressed(HeroController hero) => Pressed(hero, "jump", ref jumpAction);
        public bool DashPressed(HeroController hero) => Pressed(hero, "dash", ref dashAction);
        public bool DreamPressed(HeroController hero) => Pressed(hero, "dreamNail", ref dreamAction);
        public bool DreamHeld(HeroController hero) => Held(hero, "dreamNail", ref dreamAction);
        public bool DownHeld(HeroController hero) => Held(hero, "down", ref downAction);
        public bool UpHeld(HeroController hero) => Held(hero, "up", ref upAction);
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
        public int SkillQueryMask => SkillTargetPolicy.QueryMask(Physics2D.GetLayerCollisionMask(SkillTargetPolicy.AttackLayer));

        public Component? SkillTarget(Collider2D collider, HeroController hero, int queryMask)
        {
            if (collider == null || !collider.enabled || !collider.gameObject.activeInHierarchy ||
                collider.transform == hero.transform || collider.transform.IsChildOf(hero.transform) ||
                collider.CompareTag("Geo") || !SkillTargetPolicy.Allows(collider.gameObject.layer, queryMask, false)) return null;
            Transform target = collider.transform;
            for (int depth = 0; target != null && depth < 3; depth++, target = target.parent)
            {
                if (!(target.GetComponent<IHitResponder>() is Component component)) continue;
                return SkillTargetPolicy.Allows(collider.gameObject.layer, queryMask, component is HealthManager) ? component : null;
            }
            return null;
        }
        public void ClearContacts(DamageEnemies source) => ((List<Collider2D>)contacts.GetValue(source)).Clear();
        public void DoAttack(HeroController hero) => doAttack.Invoke(hero, null);
        public void Reset(HeroController hero) => reset.Invoke(hero, null);
        public void ResetInput(HeroController hero) => resetInput.Invoke(hero, null);
        public void ClearQueue(HeroController hero) { queue.SetValue(hero, false); queueSteps.SetValue(hero, 0); }

        public double AttackProgress(HeroController hero)
        {
            float durationValue = (float)duration.GetValue(hero);
            return durationValue <= 0 ? 0 : Math.Min(1, Math.Max(0, (float)attackTime.GetValue(hero) / durationValue));
        }

        public Vector3 NailRangeScale(HeroController hero)
        {
            NailSlash? slash = Selected(hero);
            if (slash == null) return Vector3.one;
            Vector3 baseline = (Vector3)slashBaseScale.GetValue(slash);
            if (Math.Abs(baseline.x) < 0.0001f || Math.Abs(baseline.y) < 0.0001f)
                throw new InvalidOperationException("Native nail baseline scale is invalid.");
            // StartSlash already applied actual charm scaling. Read its result;
            // never call it again or maintain a separate charm multiplier table.
            Vector3 actual = slash.transform.localScale;
            return new Vector3(Math.Abs(actual.x / baseline.x), Math.Abs(actual.y / baseline.y), 1f);
        }

        public IEnumerable<Renderer> NailRenderers(HeroController hero)
        {
            foreach (NailSlash slash in new[] { hero.normalSlash, hero.alternateSlash, hero.upSlash, hero.downSlash, hero.wallSlash })
            {
                if (slash == null) throw new InvalidOperationException("Native nail slash missing.");
                yield return SlashRenderer(slash);
            }
        }

        public double DashProgress(HeroController hero)
        {
            float durationValue = (float)dashDuration.GetValue(hero);
            return durationValue <= 0 ? 0 : Math.Min(1, Math.Max(0, (float)dashTimer.GetValue(hero) / durationValue));
        }

        public bool SuspendSharpShadow(HeroController hero)
        {
            GameObject? effect = sharpShadow.GetValue(hero) as GameObject;
            bool active = effect != null && effect.activeSelf;
            if (active) effect!.SetActive(false); // The flame owns this dash's damage, avoiding a second source.
            return active;
        }

        public void RestoreSharpShadow(HeroController hero, bool wasActive)
        {
            GameObject? effect = sharpShadow.GetValue(hero) as GameObject;
            if (wasActive && effect != null && hero.cState.dashing && hero.cState.shadowDashing) effect.SetActive(true);
        }

        public IEnumerable<Renderer> DashRenderers(HeroController hero)
        {
            Component? burst = dashBurst.GetValue(hero) as Component;
            if (burst != null)
                foreach (Renderer renderer in burst.GetComponentsInChildren<Renderer>(true)) yield return renderer;
            foreach (FieldInfo field in new[] { dashEffect, dashParticles, shadowParticles })
            {
                GameObject? effect = field.GetValue(hero) as GameObject;
                if (effect != null)
                    foreach (Renderer renderer in effect.GetComponentsInChildren<Renderer>(true)) yield return renderer;
            }
        }

        public void FlameDashHit(GameObject source, GameObject target, float direction, Func<bool> stillOwned)
        {
            if (!stillOwned() || source == null || target == null) return;
            int damage = Math.Max(1, PlayerData.instance.GetInt("nailDamage"));
            if (PlayerData.instance.GetBool("equippedCharm_16") && PlayerData.instance.GetBool("equippedCharm_31"))
                damage = (int)Math.Round(damage * 1.5f);
            // Bind the exact string overload without adding a distributable PlayMaker reference.
            takeDamageEvent.Invoke(null, new object[] { target, "TAKE DAMAGE", false });
            // The FSM can synchronously interrupt the dash, replace the hero, or unload the Mod.
            if (!stillOwned() || source == null || target == null) return;
            HitTaker.Hit(target, new HitInstance {
                Source = source, AttackType = AttackTypes.SharpShadow, DamageDealt = damage,
                Direction = direction, IgnoreInvulnerable = false, MagnitudeMultiplier = 1f, Multiplier = 1f
            }, 1);
        }

        // Called only after native TakeDamage has applied HP, charms, death and hazards.
        // Keep its normal damage VFX and native post-hit cooldown, without motion/freeze.
        public IEnumerator ArmoredDamage(HeroController hero, bool spawnDamageEffect, int damage)
        {
            if (spawnDamageEffect)
            {
                object effect = damageEffect.GetValue(hero);
                (effect.GetType().GetMethod("SendEvent", new[] { typeof(string) })
                    ?? throw new MissingMethodException("Damage effect.SendEvent(string)"))
                    .Invoke(effect, new object[] { "DAMAGE" });
                if (damage > 1)
                    UnityEngine.Object.Instantiate((GameObject)doubleHitEffect.GetValue(hero), hero.transform.position, hero.transform.rotation);
            }
            return (IEnumerator)invulnerable.Invoke(hero, new object[] {
                (float)(PlayerData.instance.GetBool("equippedCharm_4") ? invulTimeStal : invulTime).GetValue(hero) });
        }

        public void FireDemonHit(GameObject source, GameObject target, int damage, float direction, bool finisher, Func<bool> stillOwned)
            => SpellHit(source, target, damage, direction, finisher, finisher ? 1f : 0.15f, stillOwned);

        public void SpellHit(GameObject source, GameObject target, int damage, float direction, bool circleDirection, float magnitude, Func<bool> stillOwned)
        {
            if (!stillOwned() || source == null || target == null) return;
            takeDamageEvent.Invoke(null, new object[] { target, "TAKE DAMAGE", false });
            if (!stillOwned() || source == null || target == null) return;
            HitTaker.Hit(target, new HitInstance {
                Source = source, AttackType = AttackTypes.Spell, DamageDealt = damage,
                Direction = direction, CircleDirection = circleDirection, IgnoreInvulnerable = false,
                MagnitudeMultiplier = magnitude, Multiplier = 1f
            }, 1);
        }

        public void OwnTiming(HeroController hero, long token, double seconds, double now)
        {
            if (owner != 0) throw new InvalidOperationException("Previous native stage still owned.");
            owner = token; acceptedAt = now; savedDuration = (float)duration.GetValue(hero);
            nativeCooldown = (float)cooldown.GetValue(hero);
            attackTime.SetValue(hero, 0f);
            // Native Update must not reset attacking ahead of the source-tick timeline.
            duration.SetValue(hero, float.MaxValue);
            cooldown.SetValue(hero, (float)seconds);
            ClearQueue(hero);
        }

        public void ReleaseTiming(HeroController hero, long token, double now, bool canceled)
        {
            if (owner != token) return;
            owner = 0;
            duration.SetValue(hero, savedDuration);
            // Normal completion releases the authored cooldown. Cancellation keeps only the
            // unexpired portion of the original native cooldown, never an old preattack value.
            cooldown.SetValue(hero, canceled ? Math.Max(0f, nativeCooldown - (float)(now - acceptedAt)) : 0f);
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
        private static FieldInfo FieldByTypeName(Type type, string name, string expected)
        {
            FieldInfo field = type.GetField(name, Instance) ?? throw new MissingFieldException(type.FullName, name);
            if (field.FieldType.FullName != expected) throw new MissingFieldException("Unexpected v77 field type: " + type.Name + "." + name);
            return field;
        }
        private static MethodInfo Method(Type type, string name) => type.GetMethod(name, Instance, null, Type.EmptyTypes, null) ?? throw new MissingMethodException(type.FullName, name);
    }
}
