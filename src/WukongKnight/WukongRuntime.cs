using System;
using System.Collections;
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
        private FlameDash? flameDash;
        private FireDemonSlash? fireDemon;
        private FlameStorm? flameStorm;
        private BloodthirstyFireEye? bloodEye;
        private FistSkills? fist;
        private NativeDreamV77? dream;
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
        private int healthHitDepth;
        private long healthHitSequence;
        private readonly DeferredContactCleanup<DamageEnemies> contactCleanup = new DeferredContactCleanup<DamageEnemies>();

        public WukongRuntime(CharacterAssets assets, Action<string> logError)
        {
            this.assets = assets; this.logError = logError; native = new NativeV77();
            try
            {
                On.HeroController.Start += HeroStart;
                On.HeroController.HeroDash += HeroDash;
                On.HeroController.Die += HeroDie;
                On.HeroController.Update += HeroUpdate;
                On.HeroController.FixedUpdate += HeroFixedUpdate;
                On.HeroController.Attack += Attack;
                On.HeroController.CanAttack += CanAttack;
                On.HeroController.TakeDamage += HeroTakeDamage;
                On.HeroController.TakeHealth += HeroTakeHealth;
                On.HeroController.AddHealth += HeroAddHealth;
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

        private bool SkillProtects(HeroController self)
        {
            if (disposed || failed || self != hero) return false;
            try
            {
                // Damage can arrive before our Update/FixedUpdate. Observe the real
                // native spell state here too, including exact start/end boundaries.
                flameDash?.Observe();
                fireDemon?.Observe();
                fist?.Observe();
                return (flameDash != null && flameDash.Active) || (fireDemon != null && fireDemon.Active) || (fist != null && fist.ProtectsHP);
            }
            catch (Exception error) { Fail(error); return false; }
        }

        private void HeroTakeDamage(On.HeroController.orig_TakeDamage orig, HeroController self, GameObject source, CollisionSide side, int amount, int hazardType)
        {
            // CanTakeDamage=false alone still lets native invulnerable heroes take
            // spike/acid damage. Guard the whole entry, without changing save flags.
            if (!SkillProtects(self)) orig(self, source, side, amount, hazardType);
        }

        private void HeroTakeHealth(On.HeroController.orig_TakeHealth orig, HeroController self, int amount)
        {
            if (!SkillProtects(self)) orig(self, amount);
        }

        private void HeroAddHealth(On.HeroController.orig_AddHealth orig, HeroController self, int amount)
        {
            if (self == hero && !failed && !disposed && bloodEye != null)
            {
                try { if (bloodEye.ReplaceFocusHeal()) return; }
                catch (Exception error) { Fail(error); }
            }
            orig(self, amount);
        }

        private IEnumerator HeroDie(On.HeroController.orig_Die orig, HeroController self)
        {
            if (self == hero && !failed && !disposed)
            {
                try
                {
                    Cancel(); flameDash?.Stop();
                    fist?.CancelAll();
                    presenter?.BeginDeath(Time.time);
                }
                catch (Exception error) { Fail(error); }
            }
            // Preserve the complete native death iterator, including dream/Steel Soul.
            return orig(self);
        }

        private void HeroDash(On.HeroController.orig_HeroDash orig, HeroController self)
        {
            if (self == hero) Cancel();
            orig(self);
            if (self == hero && !failed)
            {
                try { flameDash?.Begin(); }
                catch (Exception error) { Fail(error); }
            }
        }

        private void HeroUpdate(On.HeroController.orig_Update orig, HeroController self)
        {
            TryAttach(self);
            if (hero == self && !failed)
            {
                try
                {
                    flameStorm?.Observe();
                    fist?.Observe(true);
                    ObserveSpells(self); // Neutralize input before native LookForInput.
                    if (ShouldCancel() || (combo != null && combo.Active && (native.JumpPressed(self) || native.DashPressed(self)))) Cancel();
                    if (combo != null && combo.Active)
                    {
                        if (native.AttackPressed(self))
                        {
                            if (native.UpHeld(self)) Cancel();
                            else Process(combo.Press(Time.time, QuickSlashScale()));
                        }
                        native.ClearQueue(self);
                    }
                }
                catch (Exception error) { Fail(error); }
            }
            orig(self);
            if (hero == self && !failed)
            {
                try { if (ShouldCancel()) Cancel(); flameDash?.Observe(); ObserveSpells(self); }
                catch (Exception error) { Fail(error); }
            }
        }

        private void HeroFixedUpdate(On.HeroController.orig_FixedUpdate orig, HeroController self)
        {
            ObserveSpells(self);
            orig(self);
            // Native physics may write velocity (e.g. conveyors). Resolve the
            // active cast after it, regardless of WukongLifetime update order.
            ObserveSpells(self);
        }

        private void ObserveSpells(HeroController self)
        {
            if (disposed || failed || self != hero) return;
            try { fireDemon?.Observe(); flameStorm?.Observe(); bloodEye?.Observe(); fist?.Observe(); }
            catch (Exception error) { Fail(error); }
        }

        private void TryAttach(HeroController self)
        {
            if (disposed || failed || self == null || !self.gameObject.activeInHierarchy || self.cState == null || self.normalSlash == null || self.alternateSlash == null) return;
            if (hero == self) return;
            Detach();
            try
            {
                hero = self;
                combo = new ComboTimeline(assets.Stages, assets.FrameRate, assets.GraceSeconds);
                presenter = new WukongPresenter(self, assets, native);
                flameDash = new FlameDash(self, native);
                fireDemon = new FireDemonSlash(self, native, assets);
                bloodEye = new BloodthirstyFireEye(self);
                dream = new NativeDreamV77(self);
                fist = new FistSkills(self, native, assets, dream);
                flameStorm = new FlameStorm(self, native, assets);
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
            if (!disposed && !failed && flameDash != null)
            {
                try { flameDash.FixedUpdate(); fireDemon?.FixedUpdate(); flameStorm?.FixedUpdate(); fist?.FixedUpdate(); bloodEye?.Observe(); }
                catch (Exception error) { Fail(error); }
            }
            if (disposed || failed || hero == null || combo == null || !combo.Active || Time.fixedTime == lastPhysics) return;
            lastPhysics = Time.fixedTime;
            try
            {
                if (ShouldCancel()) Cancel();
                else Process(combo.Advance(Time.fixedTime, QuickSlashScale()));
            }
            catch (Exception error) { Fail(error); }
        }

        private void LateUpdate()
        {
            if (disposed || failed || hero == null || presenter == null) return;
            try { fireDemon?.UpdateView(); flameStorm?.Observe(); bloodEye?.Observe(); fist?.UpdateView(); presenter.Update(combo, Time.time, flameDash, fireDemon, flameStorm, bloodEye, fist); }
            catch (Exception error) { Fail(error); }
        }

        private bool ShouldCancel()
        {
            if (hero == null) return true;
            HeroControllerStates s = hero.cState;
            return !hero.gameObject.activeInHierarchy || !s.onGround || s.wallSliding || s.jumping || s.dashing || s.backDashing || s.superDashing || s.dead || s.hazardDeath || s.hazardRespawning || s.transitioning || s.recoiling || s.recoilFrozen || s.casting || s.focusing || !native.ControlAvailable(hero) || (combo != null && combo.Active && s.facingRight != facingAtStage);
        }

        private bool Eligible(HeroController self, AttackDirection direction)
        {
            HeroControllerStates s = self.cState;
            return self == hero && !failed && !disposed && direction == AttackDirection.normal && s.onGround && !s.wallSliding && !ShouldCancel();
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
                if (!combo.Active) combo.Press(Time.time, QuickSlashScale());
                // A buffered stage has already begun in the core; exactly one native transaction initializes it.
                if (nativeToken != 0) return;
                nativeToken = combo.Token; facingAtStage = self.cState.facingRight;
                capturing = true;
                try { orig(self, direction); }
                finally { capturing = false; }
                if (slash == null || !self.cState.attacking) throw new InvalidOperationException("Native Attack did not select a horizontal NailSlash.");
                foreach (HitWindow window in assets.Stages[combo.StageIndex].Windows)
                    if ((window.EndTick - window.StartTick) * combo.SecondsPerTick < Time.fixedDeltaTime)
                        throw new InvalidOperationException("Physics timestep is too large for the authored attack windows.");
                native.OwnTiming(self, nativeToken, combo.Duration, Time.time);
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
            // Each authored hit window restarts the selected native slash, including its
            // native animation and charm logic. Presenter replaces only mesh draw submissions.
            orig(self);
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
                        ComboStage stage = assets.Stages[change.Stage];
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
            if (BlocksReplacedSpell(self.gameObject)) return;
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
            if (BlocksReplacedSpell(hit.Source)) return;
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
            long sequence = ++healthHitSequence;
            healthHitDepth++;
            try
            {
                if (BlocksReplacedSpell(hit.Source)) return;
                FlameStorm? storm = flameStorm;
                ScopedEnemyDamage<GameObject, HealthManager>? attempt = null;
                if (storm != null && hit.AttackType == AttackTypes.Spell && !failed && !disposed)
                {
                    try { attempt = storm.BeginEnemyHit(hit.Source, self, healthHitDepth, sequence); }
                    catch (Exception error) { Fail(error); }
                }
                BloodthirstyFireEye? eye = bloodEye;
                long token = eye == null ? -1 : eye.BuffToken;
                int before = self.hp;
                DispatchHealthHit(orig, self, hit);
                int after = self.hp;
                bool playerDamage = hit.AttackType == AttackTypes.Nail || hit.AttackType == AttackTypes.NailBeam ||
                    hit.AttackType == AttackTypes.Spell || hit.AttackType == AttackTypes.SharpShadow;
                if (playerDamage && token >= 0 && ReferenceEquals(eye, bloodEye) && eye != null && !failed && !disposed)
                {
                    try { eye.AfterEnemyHit(token, before, self.hp); }
                    catch (Exception error) { Fail(error); }
                }
                if (attempt != null && storm != null && ReferenceEquals(storm, flameStorm) && !failed && !disposed)
                {
                    // The accepted result will feed a verified native cancellation profile.
                    // No enemy state is changed until that profile's cleanup contract is established.
                    try
                    {
                        storm.Observe();
                        _ = storm.CompleteEnemyHit(attempt, hit.Source, self, after, healthHitSequence);
                    }
                    catch (Exception error) { Fail(error); }
                }
            }
            finally { healthHitDepth--; }
        }

        private bool BlocksReplacedSpell(GameObject source) =>
            fireDemon != null && fireDemon.BlocksNativeSource(source) || fist != null && fist.BlocksNativeSource(source) ||
            flameStorm != null && flameStorm.BlocksNativeSource(source);

        private void DispatchHealthHit(On.HealthManager.orig_Hit orig, HealthManager self, HitInstance hit)
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
            FistSkills? oldFist = fist; fist = null;
            if (oldFist != null) Cleanup(oldFist.Dispose);
            FlameDash? oldDash = flameDash; flameDash = null;
            if (oldDash != null) Cleanup(oldDash.Dispose);
            FireDemonSlash? oldSpell = fireDemon; fireDemon = null;
            if (oldSpell != null) Cleanup(oldSpell.Dispose);
            FlameStorm? oldStorm = flameStorm; flameStorm = null;
            if (oldStorm != null) Cleanup(oldStorm.Dispose);
            NativeDreamV77? oldDream = dream; dream = null;
            if (oldDream != null) Cleanup(oldDream.Dispose);
            BloodthirstyFireEye? oldEye = bloodEye; bloodEye = null;
            if (oldEye != null) Cleanup(oldEye.Dispose);
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
            On.HeroController.HeroDash -= HeroDash;
            On.HeroController.Die -= HeroDie;
            On.HeroController.Update -= HeroUpdate;
            On.HeroController.FixedUpdate -= HeroFixedUpdate;
            On.HeroController.Attack -= Attack;
            On.HeroController.CanAttack -= CanAttack;
            On.HeroController.TakeDamage -= HeroTakeDamage;
            On.HeroController.TakeHealth -= HeroTakeHealth;
            On.HeroController.AddHealth -= HeroAddHealth;
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
