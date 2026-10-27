using System;
using System.Collections;
using System.Collections.Generic;
using System.Reflection;
using GlobalEnums;
using Modding;
using Mono.Cecil;
using Mono.Cecil.Cil;
using MonoMod.Cil;
using MonoMod.RuntimeDetour;
using UnityEngine;
using WukongKnight.Core;

namespace WukongKnight
{
    /// <summary>Owns only the new direction of a real, input-admitted v77 dash.</summary>
    internal sealed class NativeDashV77 : IDisposable
    {
        private const BindingFlags Instance = BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance;
        private readonly HeroController hero;
        private readonly NativeV77 native;
        private readonly Func<bool> flameActive;
        private readonly Rigidbody2D body;
        private readonly Action<Exception> fail;
        private readonly Action<string> logError;
        private readonly UpwardDashPolicy policy = new UpwardDashPolicy();
        private readonly List<ILHook> hooks = new List<ILHook>();
        private readonly Func<HeroController, bool> touchingGround;
        private readonly MethodInfo inputMethod = Method("LookForQueueInput", typeof(void));
        private readonly MethodInfo dashMethod = Method("Dash", typeof(void));
        private readonly MethodInfo landingMethod = Method("OnCollisionEnter2D", typeof(void), typeof(Collision2D));
        private bool inputArmed;
        private bool blockedUpInput;
        private bool active;
        private bool disposed;
        public bool Upward => active && !disposed && policy.Active;

        public NativeDashV77(HeroController hero, NativeV77 native, Func<bool> flameActive, Action<string> logError, Action<Exception> fail)
        {
            this.hero = hero; this.native = native; this.flameActive = flameActive; this.logError = logError; this.fail = fail;
            body = hero.GetComponent<Rigidbody2D>() ?? throw new InvalidOperationException("Native dash body missing");
            touchingGround = (Func<HeroController, bool>)Delegate.CreateDelegate(typeof(Func<HeroController, bool>), Method("CheckTouchingGround", typeof(bool)));
        }

        public void Activate()
        {
            if (active || disposed) return;
            try
            {
                Apply(inputMethod, PatchInput);
                Apply(dashMethod, PatchDash);
                Apply(landingMethod, PatchLanding);
                On.HeroController.LookForQueueInput += LookForQueueInput;
                On.HeroController.CancelDash += CancelDash;
                On.HeroController.FinishedDashing += FinishedDashing;
                On.HeroController.BackOnGround += BackOnGround;
                On.HeroController.HeroJump += HeroJump;
                On.HeroController.HeroJumpNoEffect += HeroJumpNoEffect;
                On.HeroController.DoDoubleJump += DoDoubleJump;
                On.HeroController.DoWallJump += DoWallJump;
                On.HeroController.Bounce += Bounce;
                On.HeroController.BounceHigh += BounceHigh;
                On.HeroController.ShroomBounce += ShroomBounce;
                On.HeroController.StartRecoil += StartRecoil;
                ModHooks.LanguageGetHook += LanguageGet;
                active = true;
            }
            catch { Dispose(); throw; }
        }

        private void Apply(MethodInfo method, ILContext.Manipulator patch)
        {
            // Retain the handle before Apply so a failed layout validation unwinds too.
            var hook = new ILHook(method, patch, new ILHookConfig { ManualApply = true });
            hooks.Add(hook);
            hook.Apply();
        }

        private static List<Instruction> Calls(ILContext il, string type, string name, string result, int parameters)
        {
            var found = new List<Instruction>();
            foreach (Instruction instruction in il.Body.Instructions)
                if ((instruction.OpCode == OpCodes.Call || instruction.OpCode == OpCodes.Callvirt) &&
                    instruction.Operand is MethodReference method && method.DeclaringType.FullName == type &&
                    method.Name == name && method.ReturnType.FullName == result && method.Parameters.Count == parameters)
                    found.Add(instruction);
            return found;
        }

        private void PatchInput(ILContext il)
        {
            List<Instruction> checks = Calls(il, "HeroController", "CanDash", "System.Boolean", 0);
            List<Instruction> starts = Calls(il, "HeroController", "HeroDash", "System.Void", 0);
            if (checks.Count != 3 || starts.Count != 2)
                throw new InvalidOperationException("Unsupported v77 native dash input callsites");
            foreach (Instruction check in checks)
            {
                var cursor = new ILCursor(il);
                cursor.Goto(check, MoveType.After);
                cursor.Emit(OpCodes.Ldarg_0);
                cursor.EmitDelegate<Func<bool, HeroController, bool>>(FilterInputAdmission);
            }
            foreach (Instruction start in starts)
            {
                var cursor = new ILCursor(il);
                cursor.Goto(start, MoveType.Before);
                // Preserve the actual virtual HeroDash call and its entire HookGen
                // chain. The extra arg is consumed by ArmInput, leaving its receiver.
                cursor.Emit(OpCodes.Ldarg_0);
                cursor.EmitDelegate<Action<HeroController>>(ArmInput);
            }
        }

        private void PatchDash(ILContext il)
        {
            List<Instruction> vectors = Calls(il, "HeroController", "OrigDashVector", "UnityEngine.Vector2", 0);
            List<Instruction> modifiers = Calls(il, "Modding.ModHooks", "DashVelocityChange", "UnityEngine.Vector2", 1);
            List<Instruction> writes = Calls(il, "UnityEngine.Rigidbody2D", "set_velocity", "System.Void", 1);
            if (vectors.Count != 1 || modifiers.Count != 1 || writes.Count != 1 ||
                vectors[0].Next?.OpCode != OpCodes.Stloc_0 || vectors[0].Next?.Next?.OpCode != OpCodes.Ldloc_0 ||
                vectors[0].Next?.Next?.Next != modifiers[0] ||
                ((MethodReference)modifiers[0].Operand).Parameters[0].ParameterType.FullName != "UnityEngine.Vector2" ||
                il.Body.Instructions.IndexOf(modifiers[0]) >= il.Body.Instructions.IndexOf(writes[0]))
                throw new InvalidOperationException("Unsupported v77 native dash vector seam");
            // A local, rather than an adapter field, also survives nested ModHooks calls.
            var token = new VariableDefinition(il.Method.Module.TypeSystem.Int64);
            il.Body.Variables.Add(token);
            il.Body.InitLocals = true;
            var cursor = new ILCursor(il);
            cursor.Goto(vectors[0], MoveType.Before);
            cursor.Emit(OpCodes.Ldarg_0);
            cursor.EmitDelegate<Func<HeroController, long>>(VectorToken);
            cursor.Emit(OpCodes.Stloc, token);
            cursor.Goto(vectors[0], MoveType.After);
            cursor.Emit(OpCodes.Ldarg_0);
            cursor.Emit(OpCodes.Ldloc, token);
            cursor.EmitDelegate<Func<Vector2, HeroController, long, Vector2>>(RedirectVector);
            cursor.Goto(modifiers[0], MoveType.After);
            cursor.Emit(OpCodes.Ldarg_0);
            cursor.Emit(OpCodes.Ldloc, token);
            cursor.EmitDelegate<Func<Vector2, HeroController, long, Vector2>>(RecordVector);
        }

        private void PatchLanding(ILContext il)
        {
            List<Instruction> sides = Calls(il, "HeroController", "FindCollisionDirection", "GlobalEnums.CollisionSide", 1);
            List<Instruction> grounded = Calls(il, "HeroController", "BackOnGround", "System.Void", 0);
            List<Instruction> hard = Calls(il, "HeroController", "DoHardLanding", "System.Void", 0);
            List<Instruction> down = Calls(il, "HeroController", "SetState", "System.Void", 1);
            if (sides.Count != 1 || grounded.Count != 1 || hard.Count != 1 || down.Count != 1 ||
                ((MethodReference)sides[0].Operand).Parameters[0].ParameterType.FullName != "UnityEngine.Collision2D" ||
                ((MethodReference)down[0].Operand).Parameters[0].ParameterType.FullName != "GlobalEnums.ActorStates" ||
                down[0].Previous?.OpCode != OpCodes.Ldc_I4_6 ||
                sides[0].Next?.OpCode != OpCodes.Stloc_0 || il.Body.Variables.Count == 0 ||
                il.Body.Variables[0].VariableType.FullName != "GlobalEnums.CollisionSide")
                throw new InvalidOperationException("Unsupported v77 native landing calls");
            // All calls must remain inside the native bottom branch. Its existing
            // layer8/HeroWalkable, hard-landing and SteepSlope/state gates stay intact.
            Instruction? bottom = null;
            for (Instruction? step = sides[0].Next; step != null && step != hard[0]; step = step.Next)
                if (step.OpCode == OpCodes.Ldloc_0 && step.Next?.OpCode == OpCodes.Ldc_I4_3 &&
                    step.Next?.Next is Instruction branch &&
                    (branch.OpCode == OpCodes.Bne_Un || branch.OpCode == OpCodes.Bne_Un_S) &&
                    (branch.Operand is ILLabel label ? label.Target : branch.Operand as Instruction) is Instruction target &&
                    il.Body.Instructions.IndexOf(target) > il.Body.Instructions.IndexOf(down[0]))
                { bottom = step; break; }
            if (bottom == null || il.Body.Instructions.IndexOf(hard[0]) >= il.Body.Instructions.IndexOf(grounded[0]) ||
                il.Body.Instructions.IndexOf(grounded[0]) >= il.Body.Instructions.IndexOf(down[0]))
                throw new InvalidOperationException("Unsupported v77 native bottom landing branch");
            var token = new VariableDefinition(il.Method.Module.TypeSystem.Int64);
            il.Body.Variables.Add(token);
            il.Body.InitLocals = true;
            foreach (Instruction landing in new[] { hard[0], grounded[0], down[0] })
            {
                var cursor = new ILCursor(il);
                cursor.Goto(landing, MoveType.Before);
                cursor.Emit(OpCodes.Ldarg_0);
                cursor.EmitDelegate<Func<HeroController, long>>(LandingToken);
                cursor.Emit(OpCodes.Stloc, token);
                cursor.Goto(landing, MoveType.After);
                cursor.Emit(OpCodes.Ldarg_0);
                cursor.Emit(OpCodes.Ldloc, token);
                cursor.EmitDelegate<Action<HeroController, long>>(ConfirmLanding);
            }
        }

        private long LandingToken(HeroController self)
            => self == hero && active && !disposed ? policy.Token : -1;

        private void ConfirmLanding(HeroController self, long token)
        {
            if (self != hero || !active || disposed || hero == null || hero.cState == null) return;
            HeroControllerStates state = hero.cState;
            if (state.dead || state.hazardDeath || state.hazardRespawning || state.transitioning) return;
            try { policy.ConfirmLanding(token, native.LandingAccepted(hero)); }
            catch (Exception error) { fail(error); }
        }

        private bool FilterInputAdmission(bool original, HeroController self)
        {
            if (!active || disposed || self != hero) return original;
            try
            {
                Observe();
                bool requestsUp = RequestsUp();
                if (!active || disposed) return original;
                if (requestsUp && policy.UsedUntilLanding) blockedUpInput = true;
                return policy.Allows(original, requestsUp);
            }
            catch (Exception error) { fail(error); return original; }
        }

        private void ArmInput(HeroController self)
        {
            // Only the two admitted input/queue callsites can mark this request.
            inputArmed = active && !disposed && self == hero;
        }

        private void LookForQueueInput(On.HeroController.orig_LookForQueueInput orig, HeroController self)
        {
            if (self == hero) blockedUpInput = false;
            try { orig(self); }
            finally
            {
                if (self == hero)
                {
                    inputArmed = false;
                    // A forbidden repeat must not survive as a queued sideways dash
                    // on landing. First-use cooldown/native-rejected queues stay native.
                    if (active && !disposed && blockedUpInput)
                        try { native.ClearDashQueue(hero); }
                        catch (Exception error) { fail(error); }
                    blockedUpInput = false;
                }
            }
        }

        public long PrepareStart()
        {
            if (!active || disposed) return 0;
            bool fromInput = inputArmed;
            inputArmed = false; // Native synchronous scripted HeroDash must not inherit this.
            Observe();
            long beforeQuery = policy.Token;
            bool upward = fromInput && RequestsUp();
            if (!active || disposed || beforeQuery != policy.Token) return 0;
            return policy.Prepare(upward);
        }

        public void CompleteStart(long token)
        {
            if (!active || disposed) return;
            policy.Complete(token, Alive() && hero.cState.dashing && !hero.cState.onGround && !native.DashingDown(hero));
        }

        public bool IsCurrentStart(long token) => active && !disposed && token != 0 && policy.Token == token;

        private bool RequestsUp()
        {
            if (!Alive() || !native.ControlAvailable(hero)) return false;
            return UpwardDashPolicy.RequestsUp(PlayerData.instance.GetBool("equippedCharm_31"), !hero.cState.onGround,
                native.UpHeld(hero), native.DownHeld(hero), native.LeftHeld(hero), native.RightHeld(hero));
        }

        private bool Alive()
        {
            if (hero == null || !hero.gameObject.activeInHierarchy || hero.cState == null) return false;
            HeroControllerStates s = hero.cState;
            return !s.dead && !s.hazardDeath && !s.hazardRespawning && !s.transitioning && !s.recoiling && !s.recoilFrozen;
        }

        public void Observe()
        {
            if (!active || disposed) return;
            if (hero == null || !hero.gameObject.activeInHierarchy || hero.cState == null ||
                hero.cState.dead || hero.cState.hazardDeath || hero.cState.hazardRespawning || hero.cState.transitioning)
            { Clear(); return; }
            if (!Alive()) { policy.Stop(policy.Token); return; }
            // HeroDash emits synchronous native calls before setting dashing=true.
            // Passive observation must not revoke a prepared, not-yet-active start.
            policy.Observe(hero.cState.dashing, flameActive());
            if (!policy.Active && hero.cState.onGround) policy.Landed(true, touchingGround(hero));
        }

        public void Clear()
        {
            inputArmed = false;
            blockedUpInput = false;
            policy.Clear();
        }

        private long VectorToken(HeroController self)
        {
            if (!active || disposed || self != hero) return 0;
            try { Observe(); return Upward ? policy.Token : 0; }
            catch (Exception error) { fail(error); return 0; }
        }

        private Vector2 RedirectVector(Vector2 original, HeroController self, long token)
        {
            if (self != hero || !active || disposed || !policy.Owns(token) || !Alive() || !hero.cState.dashing) return original;
            // OrigDashVector has already selected the live normal/Sharp Shadow speed.
            return new Vector2(0, Math.Abs(original.x));
        }

        private Vector2 RecordVector(Vector2 original, HeroController self, long token)
        {
            if (self == hero && active && !disposed && Alive() && hero.cState.dashing)
                policy.RecordVelocity(token, original.x, original.y);
            return original;
        }

        private void FinishedDashing(On.HeroController.orig_FinishedDashing orig, HeroController self)
        {
            if (self == hero && active && !disposed)
            {
                try
                {
                    Vector2 velocity = body.velocity;
                    bool normalFinish = Alive() && hero.cState.dashing && native.DashExpired(hero) && native.ControlAvailable(hero);
                    if (policy.Finish(policy.Token, normalFinish, velocity.x, velocity.y))
                        body.velocity = new Vector2(velocity.x, 0);
                }
                catch (Exception error) { fail(error); }
            }
            // Clear only proven old momentum BEFORE native CancelDash/DashEnd events.
            // Their new jump/recoil/scene motion is never overwritten after orig.
            orig(self);
        }

        private void CancelDash(On.HeroController.orig_CancelDash orig, HeroController self)
        {
            if (self == hero) policy.Stop(policy.Token);
            orig(self);
        }

        private void BackOnGround(On.HeroController.orig_BackOnGround orig, HeroController self)
        {
            orig(self);
            if (self == hero && active && !disposed)
                try { Observe(); }
                catch (Exception error) { fail(error); }
        }

        private void NewMotion(HeroController self) { if (self == hero) policy.RevokeMotion(); }
        private void HeroJump(On.HeroController.orig_HeroJump orig, HeroController self) { NewMotion(self); orig(self); }
        private void HeroJumpNoEffect(On.HeroController.orig_HeroJumpNoEffect orig, HeroController self) { NewMotion(self); orig(self); }
        private void DoDoubleJump(On.HeroController.orig_DoDoubleJump orig, HeroController self) { NewMotion(self); orig(self); }
        private void DoWallJump(On.HeroController.orig_DoWallJump orig, HeroController self) { NewMotion(self); orig(self); }
        private void Bounce(On.HeroController.orig_Bounce orig, HeroController self) { NewMotion(self); orig(self); }
        private void BounceHigh(On.HeroController.orig_BounceHigh orig, HeroController self) { NewMotion(self); orig(self); }
        private void ShroomBounce(On.HeroController.orig_ShroomBounce orig, HeroController self) { NewMotion(self); orig(self); }
        private IEnumerator StartRecoil(On.HeroController.orig_StartRecoil orig, HeroController self, CollisionSide side, bool spawnDamageEffect, int damageAmount)
        { NewMotion(self); return orig(self, side, spawnDamageEffect, damageAmount); }

        private string LanguageGet(string key, string sheet, string original)
        {
            if (!active || disposed || sheet != "UI") return original;
            bool chinese = Language.Language.CurrentLanguage().ToString().StartsWith("ZH", StringComparison.OrdinalIgnoreCase);
            if (key == "CHARM_NAME_31") return chinese ? "烈焰闪·觉醒" : "Flame Dash: Awakening";
            if (key == "CHARM_DESC_31") return chinese
                ? "唤醒烈焰闪的力量。<br><br>缩短冲刺间隔，保留向下冲刺。空中仅按住上方向并冲刺可向上突进，与其他方向共用空中冲刺次数，且每次落地前最多向上冲刺一次。"
                : "Awakens Flame Dash.<br><br>Dash more often and dash downward. In midair, hold only Up and dash to rise. Shares the native aerial dash allowance; upward dash can be used once before landing.";
            return original;
        }

        public void Dispose()
        {
            if (disposed) return;
            disposed = true; active = false; Clear();
            ModHooks.LanguageGetHook -= LanguageGet;
            On.HeroController.LookForQueueInput -= LookForQueueInput;
            On.HeroController.CancelDash -= CancelDash;
            On.HeroController.FinishedDashing -= FinishedDashing;
            On.HeroController.BackOnGround -= BackOnGround;
            On.HeroController.HeroJump -= HeroJump;
            On.HeroController.HeroJumpNoEffect -= HeroJumpNoEffect;
            On.HeroController.DoDoubleJump -= DoDoubleJump;
            On.HeroController.DoWallJump -= DoWallJump;
            On.HeroController.Bounce -= Bounce;
            On.HeroController.BounceHigh -= BounceHigh;
            On.HeroController.ShroomBounce -= ShroomBounce;
            On.HeroController.StartRecoil -= StartRecoil;
            foreach (ILHook hook in hooks)
                try { hook.Dispose(); }
                catch (Exception error) { logError("Upward dash hook cleanup failed: " + error); }
            hooks.Clear();
        }

        private static MethodInfo Method(string name, Type result, params Type[] arguments)
        {
            MethodInfo method = typeof(HeroController).GetMethod(name, Instance, null, arguments, null)
                ?? throw new MissingMethodException("HeroController", name);
            if (method.ReturnType != result) throw new InvalidOperationException("Unexpected v77 method: " + name);
            return method;
        }
    }
}
