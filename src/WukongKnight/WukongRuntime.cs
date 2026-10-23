using System;
using System.Collections.Generic;
using GlobalEnums;
using UnityEngine;
using UnityEngine.SceneManagement;
using WukongKnight.Core;

namespace WukongKnight
{
    /// <summary>Owns the hooks and exactly one hero attachment. Native control/FSMs remain alive.</summary>
    internal sealed class WukongRuntime : IDisposable
    {
        private readonly CharacterAssets assets;
        private readonly NativeV77 native;
        private readonly Action<string> logError;
        private HeroController? hero;
        private WukongPresenter? presenter;
        private WukongLifetime? lifetime;
        private ComboTimeline? combo;
        private NailSlash? slash;
        private long nativeToken;
        private bool capturing;
        private bool permit;
        private bool clearing;
        private bool disposed;
        private bool failed;
        private Vector3 slashScale;
        private MeshRenderer? slashRenderer;
        private bool slashRendererEnabled;
        private int pulseWindow = -1;
        private bool facingAtStage;
        private readonly DeferredContactCleanup<DamageEnemies> contactCleanup = new DeferredContactCleanup<DamageEnemies>();

        public WukongRuntime(CharacterAssets assets, Action<string> logError)
        {
            this.assets = assets; this.logError = logError; native = new NativeV77();
            try
            {
                On.HeroController.Start += HeroStart;
                On.HeroController.Update += HeroUpdate;
                On.HeroController.Attack += Attack;
                On.HeroController.CanAttack += CanAttack;
                On.HeroController.ResetAttacks += ResetAttacks;
                On.NailSlash.StartSlash += StartSlash;
                On.NailSlash.FixedUpdate += SlashFixedUpdate;
                On.NailSlash.CancelAttack += SlashCanceled;
                On.HitTaker.Hit += Hit;
                On.HealthManager.Hit += HealthHit;
                On.DamageEnemies.FixedUpdate += DamageFixedUpdate;
                On.DamageEnemies.DoDamage += Damage;
                UnityEngine.SceneManagement.SceneManager.activeSceneChanged += SceneChanged;
            }
            catch { Dispose(); throw; }
        }

        private void HeroStart(On.HeroController.orig_Start orig, HeroController self)
        { orig(self); TryAttach(self); }

        private void HeroUpdate(On.HeroController.orig_Update orig, HeroController self)
        {
            TryAttach(self);
            bool discardOwnedQueue = false;
            if (hero == self && !failed)
            {
                try
                {
                    ObserveState();
                    if (combo != null && combo.Active && (native.JumpPressed(self) || native.DashPressed(self))) Cancel();
                    if (combo != null && combo.Active)
                    {
                        if (native.AttackPressed(self))
                        {
                            if (native.UpHeld(self) || (combo.Mode == AttackMode.AirHorizontal && native.DownHeld(self))) Cancel();
                            else if (combo.Mode == AttackMode.GroundCombo) Process(combo.Press(Time.time, QuickSlashScale()));
                        }
                        // Do not erase a directional request handed back to the native gate.
                        discardOwnedQueue = combo.Active;
                        native.ClearQueue(self);
                    }
                }
                catch (Exception error) { Fail(error); }
            }
            orig(self);
            if (hero == self && !failed)
            {
                try
                {
                    ObserveState();
                    // Native Update may queue a rejected fresh press AFTER our pre-clear. Drop
                    // requests made while owned even if a physics callback just ended the air
                    // action; otherwise they could silently start another attack next frame.
                    if (discardOwnedQueue || (combo != null && combo.Active)) native.ClearQueue(self);
                }
                catch (Exception error) { Fail(error); }
            }
        }

        private void TryAttach(HeroController self)
        {
            if (disposed || failed || self == null || !self.gameObject.activeInHierarchy || self.cState == null || self.normalSlash == null || self.alternateSlash == null) return;
            if (hero == self) return;
            Detach();
            try
            {
                hero = self;
                combo = new ComboTimeline(assets.Stages, assets.AirAttack, assets.FrameRate, assets.GraceSeconds);
                lastPhysics = double.NegativeInfinity;
                presenter = new WukongPresenter(self, assets);
                lifetime = self.gameObject.AddComponent<WukongLifetime>();
                lifetime.UpdateView = LateUpdate;
                lifetime.AdvancePhysics = FixedUpdate;
                lifetime.DetachOwner = Detach;
            }
            catch (Exception error) { Fail(error); }
        }

        private double lastPhysics = double.NegativeInfinity;
        private void FixedUpdate()
        {
            if (disposed || failed || hero == null || combo == null) return;
            try
            {
                // Contact can change later in the same physics tick (BackOnGround does not
                // reset attacks). Observe cancellation before deduplicating clock advancement.
                ObserveState();
                if (!combo.Active || Time.fixedTime == lastPhysics) return;
                lastPhysics = Time.fixedTime;
                Process(combo.Advance(Time.fixedTime, QuickSlashScale()));
            }
            catch (Exception error) { Fail(error); }
        }

        private void LateUpdate()
        {
            if (disposed || failed || hero == null || presenter == null) return;
            try { presenter.Update(combo, Time.time); }
            catch (Exception error) { Fail(error); }
        }

        private bool Interrupted()
        {
            if (hero == null) return true;
            HeroControllerStates s = hero.cState;
            return !hero.gameObject.activeInHierarchy || s.dashing || s.backDashing || s.superDashing || s.dead || s.hazardDeath || s.hazardRespawning || s.transitioning || s.recoiling || s.recoilFrozen || s.casting || s.focusing || !native.ControlAvailable(hero) || (combo != null && combo.Active && s.facingRight != facingAtStage);
        }

        private void ObserveState()
        {
            if (Interrupted()) { Cancel(); return; }
            if (hero == null || combo == null) return;
            HeroControllerStates s = hero.cState;
            Process(combo.ObserveContact(s.onGround, s.jumping, s.wallSliding));
        }

        private bool Eligible(HeroController self, AttackDirection direction)
        {
            HeroControllerStates s = self.cState;
            return self == hero && !failed && !disposed && direction == AttackDirection.normal && !s.wallSliding && (!s.onGround || !s.jumping) && !Interrupted();
        }

        private bool CanAttack(On.HeroController.orig_CanAttack orig, HeroController self)
        {
            if (self == hero && combo != null && combo.Active) return false;
            return orig(self);
        }

        private void Attack(On.HeroController.orig_Attack orig, HeroController self, AttackDirection direction)
        {
            if (!Eligible(self, direction))
            {
                if (self == hero) Cancel();
                orig(self, direction); return;
            }
            if (combo == null) { orig(self, direction); return; }
            try
            {
                if (!combo.Active)
                {
                    if (self.cState.onGround) combo.Press(Time.time, QuickSlashScale());
                    else combo.PressAir(Time.time, QuickSlashScale());
                }
                // A buffered stage has already begun in the core; exactly one native transaction initializes it.
                if (nativeToken != 0) return;
                nativeToken = combo.Token; facingAtStage = self.cState.facingRight;
                capturing = true;
                try { orig(self, direction); }
                finally { capturing = false; }
                if (slash == null || !self.cState.attacking) throw new InvalidOperationException("Native Attack did not select a horizontal NailSlash.");
                foreach (HitWindow window in combo.CurrentAttack.Windows)
                    if ((window.EndTick - window.StartTick) * combo.SecondsPerTick < Time.fixedDeltaTime)
                        throw new InvalidOperationException("Physics timestep is too large for the authored attack windows.");
                native.OwnTiming(self, nativeToken, combo.Mode, combo.Duration, Time.time);
            }
            catch (Exception error) { Fail(error); }
        }

        private void StartSlash(On.NailSlash.orig_StartSlash orig, NailSlash self)
        {
            if (capturing && hero != null && (self == hero.normalSlash || self == hero.alternateSlash))
            {
                slash = self;
                slashScale = self.transform.localScale;
                slashRenderer = native.SlashRenderer(self);
                slashRendererEnabled = slashRenderer.enabled;
                // Native Attack has initialized damage/charm FSM data, but its hit begins at the authored frame.
                self.CancelAttack();
                return;
            }
            if (self == slash && nativeToken != 0 && !permit) return;
            orig(self);
            if (self == slash && nativeToken != 0 && slashRenderer != null) slashRenderer.enabled = false;
        }

        private void SlashFixedUpdate(On.NailSlash.orig_FixedUpdate orig, NailSlash self)
        {
            if (self != slash || nativeToken == 0) { orig(self); return; }
            FixedUpdate();
            if (self != slash || nativeToken == 0) return;
            // Own only the selected slash's polygons. Avoid native stepCounter activation latency
            // and animation-complete callbacks closing a longer authored damage window.
            bool active = pulseWindow >= 0 && combo != null && combo.Active && combo.Token == nativeToken;
            native.Polygon(self).enabled = active;
            native.ClashPolygon(self).enabled = active;
            if (slashRenderer != null) slashRenderer.enabled = false;
        }

        private void SlashCanceled(On.NailSlash.orig_CancelAttack orig, NailSlash self)
        {
            orig(self);
            if (self == slash) pulseWindow = -1;
        }

        private void ResetAttacks(On.HeroController.orig_ResetAttacks orig, HeroController self)
        {
            if (self == hero && !clearing && nativeToken != 0) Cancel(false);
            orig(self);
        }

        private void Process(List<ComboEvent> events)
        {
            foreach (ComboEvent change in events)
            {
                if (hero == null || combo == null) return;
                switch (change.Kind)
                {
                    case ComboEventKind.StageStarted:
                        // First stages arrive through the player's original DoAttack. Buffered ones
                        // arrive here only after the preceding native transaction has been released.
                        native.DoAttack(hero);
                        break;
                    case ComboEventKind.WindowOpened:
                        if (nativeToken != change.Token || slash == null) break;
                        ClosePulse();
                        permit = true;
                        try { slash.StartSlash(); }
                        finally { permit = false; }
                        AttackDefinition stage = change.Definition;
                        Vector3 nativeScale = slash.transform.localScale; // includes current range charms
                        slash.transform.localScale = new Vector3(nativeScale.x * (float)stage.RangeMultiplier, nativeScale.y, nativeScale.z);
                        pulseWindow = change.Window;
                        native.Polygon(slash).enabled = true;
                        native.ClashPolygon(slash).enabled = true;
                        break;
                    case ComboEventKind.WindowClosed:
                        if (nativeToken == change.Token && pulseWindow == change.Window) ClosePulse();
                        break;
                    case ComboEventKind.StageEnded:
                        Release(change.Token, false, true);
                        break;
                    case ComboEventKind.Canceled:
                        Release(change.Token, true, true);
                        break;
                }
            }
        }

        private void ClosePulse()
        {
            pulseWindow = -1;
            if (slash != null)
            {
                slash.CancelAttack();
                ClearContacts(slash);
            }
        }

        private void ClearContacts(NailSlash closingSlash)
        {
            // CancelAttack disables polygons, but DamageEnemies retains its contacts until a
            // later physics exit. Clear only components beneath this owned slash. A close may
            // originate inside Hit, so defer mutation of any currently enumerated native list.
            foreach (DamageEnemies source in closingSlash.GetComponentsInChildren<DamageEnemies>(true))
                if (contactCleanup.Request(source)) Cleanup(() => native.ClearContacts(source));
        }

        private void DamageFixedUpdate(On.DamageEnemies.orig_FixedUpdate orig, DamageEnemies self)
        {
            contactCleanup.Enter(self);
            try { orig(self); }
            finally
            {
                if (contactCleanup.Exit(self)) Cleanup(() => native.ClearContacts(self));
                if (disposed && !contactCleanup.HasActiveIterations) UnhookDamage();
            }
        }

        private void Damage(On.DamageEnemies.orig_DoDamage orig, DamageEnemies self, GameObject target)
        {
            // The remainder of an old native enumeration cannot emit TAKE DAMAGE or Hit after
            // cancellation. A new StartSlash has no deferred isolation and runs normally.
            if (contactCleanup.IsPending(self)) return;
            if (OwnedSource(self.gameObject))
            {
                // Native DoDamage emits its FSM event before HitTaker. Synchronize at this
                // earlier boundary too, regardless of the components' FixedUpdate order.
                FixedUpdate();
                if (!OwnedSource(self.gameObject) || pulseWindow < 0 || contactCleanup.IsPending(self)) return;
            }
            orig(self, target);
        }

        private void UnhookDamage()
        {
            On.DamageEnemies.FixedUpdate -= DamageFixedUpdate;
            On.DamageEnemies.DoDamage -= Damage;
        }

        private bool OwnedSource(GameObject? source)
        {
            return nativeToken != 0 && slash != null && source != null &&
                (source == slash.gameObject || source.transform.IsChildOf(slash.transform));
        }

        private void Hit(On.HitTaker.orig_Hit orig, GameObject target, HitInstance hit, int recursionDepth)
        {
            if (!OwnedSource(hit.Source)) { orig(target, hit, recursionDepth); return; }
            FixedUpdate(); // DamageEnemies may run before the owned component in this physics step.
            if (!OwnedSource(hit.Source)) return;
            if (combo == null || pulseWindow < 0 || target == null) return;
            // Match the original HitTaker parent walk, retaining hooks/original dispatch for each
            // responder. Identity is the responder, so sibling/multiple colliders cannot duplicate it.
            Transform current = target.transform;
            for (int depth = 0; current != null && depth < recursionDepth; depth++, current = current.parent)
            {
                IHitResponder responder = current.GetComponent<IHitResponder>();
                if (responder == null) continue;
                if (responder is HealthManager) orig(current.gameObject, hit, 1); // deduped after native evasion gate below
                else if (responder is Component component && combo.TryHit(nativeToken, pulseWindow, component.GetInstanceID())) orig(current.gameObject, hit, 1);
            }
        }

        private void HealthHit(On.HealthManager.orig_Hit orig, HealthManager self, HitInstance hit)
        {
            if (!OwnedSource(hit.Source)) { orig(self, hit); return; }
            FixedUpdate();
            if (!OwnedSource(hit.Source)) return;
            if (combo == null || pulseWindow < 0 || native.Evading(self)) return;
            // Native 0.2s hit evasion remains authoritative. Do not consume a second-window
            // target while it is evading; native repeated trigger callbacks may retry in this window.
            if (combo.TryHit(nativeToken, pulseWindow, self.GetInstanceID())) orig(self, hit);
        }

        private double QuickSlashScale()
        {
            if (hero == null || !PlayerData.instance.GetBool("equippedCharm_32")) return 1;
            if (hero.ATTACK_COOLDOWN_TIME <= 0 || hero.ATTACK_COOLDOWN_TIME_CH <= 0) throw new InvalidOperationException("Invalid native Quick Slash clock.");
            return hero.ATTACK_COOLDOWN_TIME_CH / hero.ATTACK_COOLDOWN_TIME;
        }

        private void Cancel(bool resetNative = true)
        {
            if (combo == null) return;
            long token = nativeToken;
            combo.Cancel();
            Release(token, true, resetNative);
        }

        private void Release(long token, bool canceled, bool resetNative)
        {
            if (token == 0 || nativeToken != token) return;
            NailSlash? oldSlash = slash;
            MeshRenderer? oldRenderer = slashRenderer;
            // Invalidate ownership first, so cleanup callbacks cannot close a newer transaction.
            pulseWindow = -1; slash = null; slashRenderer = null; nativeToken = 0;
            if (oldSlash != null)
            {
                Cleanup(() => oldSlash.CancelAttack());
                Cleanup(() => ClearContacts(oldSlash));
                Cleanup(() => oldSlash.transform.localScale = slashScale);
            }
            if (oldRenderer != null) Cleanup(() => oldRenderer.enabled = slashRendererEnabled);
            if (hero != null)
            {
                HeroController owner = hero;
                Cleanup(() => native.ReleaseTiming(owner, token, Time.time, canceled));
                if (resetNative)
                {
                    clearing = true;
                    try { Cleanup(() => native.Reset(owner)); }
                    finally { clearing = false; }
                }
            }
        }

        private void Cleanup(Action action)
        {
            try { action(); }
            catch (Exception error) { logError("Wukong cleanup could not restore one owned member: " + error); }
        }

        private void SceneChanged(Scene previous, Scene next) { Detach(); }
        private void Fail(Exception error)
        {
            if (failed) return;
            failed = true;
            logError("Wukong replacement disabled; native hero restored. " + error);
            Detach();
        }
        private void Detach()
        {
            Cancel();
            if (lifetime != null)
            {
                lifetime.DetachOwner = null; lifetime.UpdateView = null; lifetime.AdvancePhysics = null;
                UnityEngine.Object.Destroy(lifetime); lifetime = null;
            }
            WukongPresenter? oldPresenter = presenter;
            presenter = null; combo = null; hero = null;
            if (oldPresenter != null) Cleanup(oldPresenter.Dispose);
        }
        public void Dispose()
        {
            if (disposed) return; disposed = true;
            Detach();
            On.HeroController.Start -= HeroStart;
            On.HeroController.Update -= HeroUpdate;
            On.HeroController.Attack -= Attack;
            On.HeroController.CanAttack -= CanAttack;
            On.HeroController.ResetAttacks -= ResetAttacks;
            On.NailSlash.StartSlash -= StartSlash;
            On.NailSlash.FixedUpdate -= SlashFixedUpdate;
            On.NailSlash.CancelAttack -= SlashCanceled;
            On.HitTaker.Hit -= Hit;
            On.HealthManager.Hit -= HealthHit;
            // If unload occurs inside damage dispatch, keep only these guards until the
            // current native enumerators finish and their deferred clears have run.
            if (!contactCleanup.HasActiveIterations) UnhookDamage();
            UnityEngine.SceneManagement.SceneManager.activeSceneChanged -= SceneChanged;
        }
    }

    internal sealed class WukongLifetime : MonoBehaviour
    {
        internal Action? UpdateView;
        internal Action? AdvancePhysics;
        internal Action? DetachOwner;
        private void LateUpdate() { UpdateView?.Invoke(); }
        private void FixedUpdate() { AdvancePhysics?.Invoke(); }
        private void OnDisable() { DetachOwner?.Invoke(); }
        private void OnDestroy() { DetachOwner?.Invoke(); }
    }
}
