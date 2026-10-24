using System;
using System.Reflection;
using System.Collections.Generic;
using UnityEngine;
using WukongKnight.Core;

namespace WukongKnight
{
    internal sealed class WukongPresenter : IDisposable
    {
        private readonly HeroController hero;
        private readonly CharacterAssets assets;
        private readonly NativeV77 native;
        private readonly Dictionary<Renderer, bool> nailVisibility = new Dictionary<Renderer, bool>();
        private readonly Renderer nativeBody;
        private readonly tk2dSprite nativeSprite;
        private readonly PropertyInfo forceOff;
        private readonly bool previousForceOff;
        private readonly GameObject view;
        private readonly SpriteRenderer renderer;
        private readonly SpriteRenderer aura;
        private readonly SpriteRenderer nailArc;
        private readonly Collider2D bodyCollider;
        private readonly float viewScale;
        private readonly NativeDeathV77 death;
        private readonly SourceDeathClock deathClock;
        private Vector3 deathPosition;
        private bool deathFacingRight;
        private string clipName = "";
        private double clipStarted;
        private bool disposed;

        public WukongPresenter(HeroController hero, CharacterAssets assets, NativeV77 native)
        {
            this.hero = hero; this.assets = assets; this.native = native;
            nativeBody = hero.GetComponent<Renderer>() ?? throw new InvalidOperationException("Native body renderer missing.");
            nativeSprite = hero.GetComponent<tk2dSprite>() ?? throw new InvalidOperationException("Native body sprite missing.");
            bodyCollider = hero.GetComponent<Collider2D>() ?? throw new InvalidOperationException("Native hero collider missing.");
            // Resolve against the actual engine at runtime. This preserves native enabled writes
            // (cutscenes/blinking/visibility) while suppressing only its draw submission.
            forceOff = typeof(Renderer).GetProperty("forceRenderingOff") ?? throw new MissingMemberException("Renderer.forceRenderingOff is required for safe replacement.");
            if (!forceOff.CanRead || !forceOff.CanWrite || forceOff.PropertyType != typeof(bool)) throw new MissingMemberException("Unsupported renderer visibility API.");
            previousForceOff = (bool)forceOff.GetValue(nativeBody, null);
            death = new NativeDeathV77(hero, native.DeathEffect(hero));
            deathClock = new SourceDeathClock(assets.Clips["dead"].Ticks, assets.FrameRate);
            // Baseline pixel-to-world calibration only. Appearance enlargement is
            // already baked into the atlas pixels; do not apply a size multiplier here.
            viewScale = 100f * bodyCollider.bounds.size.y / assets.NominalBodyHeight;
            if (viewScale <= 0) throw new InvalidOperationException("Native body has no height.");
            view = new GameObject("WukongKnight.View");
            Material? material = null;
            try
            {
                view.transform.SetParent(hero.transform, false);
                renderer = view.AddComponent<SpriteRenderer>();
                Shader shader = Shader.Find("Sprites/Default");
                if (shader == null) throw new InvalidOperationException("Sprites/Default shader missing.");
                renderer.sharedMaterial = material = new Material(shader);
                renderer.sortingLayerID = nativeBody.sortingLayerID; renderer.sortingOrder = nativeBody.sortingOrder;
                renderer.sprite = assets.Clips["idle"].Frames[0];
                var arcView = new GameObject("WukongKnight.NailArc");
                arcView.transform.SetParent(view.transform, false);
                nailArc = arcView.AddComponent<SpriteRenderer>();
                nailArc.sharedMaterial = material;
                nailArc.sortingLayerID = renderer.sortingLayerID; nailArc.sortingOrder = renderer.sortingOrder + 1;
                nailArc.enabled = false;
                var auraView = new GameObject("WukongKnight.JiyuanFireEye");
                auraView.transform.SetParent(view.transform, false);
                auraView.transform.localPosition = new Vector3(0, 0, -0.001f);
                aura = auraView.AddComponent<SpriteRenderer>();
                aura.sharedMaterial = material;
                aura.sortingLayerID = renderer.sortingLayerID; aura.sortingOrder = renderer.sortingOrder + 2;
                aura.enabled = false;
                // First successful update verifies geometry, pivot and material before hiding the body.
                Update(null, Time.time);
                forceOff.SetValue(nativeBody, true, null);
                foreach (Renderer mesh in native.NailRenderers(hero))
                {
                    if (mesh == null) throw new InvalidOperationException("Native nail renderer missing.");
                    if (nailVisibility.ContainsKey(mesh)) continue;
                    nailVisibility.Add(mesh, (bool)forceOff.GetValue(mesh, null));
                    forceOff.SetValue(mesh, true, null);
                }
            }
            catch
            {
                RestoreNativeVisibility();
                if (material != null) UnityEngine.Object.Destroy(material);
                UnityEngine.Object.Destroy(view); throw;
            }
        }

        public void BeginDeath(double now)
        {
            if (disposed || !deathClock.Begin(now)) return;
            deathFacingRight = hero.cState.facingRight;
            Bounds bounds = bodyCollider.bounds;
            deathPosition = new Vector3(bounds.center.x, bounds.min.y + viewScale * assets.FeetOffsetPixels / 100f,
                                        nativeBody.transform.position.z - 0.001f);
            death.Suppress();
        }

        public void Update(ComboTimeline? combo, double now, FlameDash? flameDash = null, FireDemonSlash? fireDemon = null,
            FlameStorm? flameStorm = null, BloodthirstyFireEye? bloodEye = null)
        {
            if (disposed) return;
            HeroControllerStates state = hero.cState;
            if (deathClock.Active && death.ReadyToResume) { deathClock.Clear(); death.Restore(); }
            if (state.dead && !deathClock.Active) BeginDeath(now);
            bool dying = deathClock.Active;
            if (dying) death.Suppress();
            string desired;
            if (dying) desired = "dead";
            else if (state.hazardDeath || state.recoiling || state.recoilFrozen || state.hazardRespawning) desired = "hurtStand";
            else if (flameDash != null && flameDash.Active && state.dashing) desired = flameDash.Downward ? "flameDashDown" : "flameDash";
            else if (fireDemon != null && fireDemon.Active) desired = fireDemon.Clip;
            else if (flameStorm != null && flameStorm.Active) desired = "flameStorm";
            else if (bloodEye != null && bloodEye.Casting) desired = "fireEyeCast";
            else if (state.transitioning || state.casting || state.focusing || state.superDashing || state.dashing || state.backDashing) desired = "idle";
            else if (combo != null && combo.Active) desired = "nailAttack" + (combo.StageIndex + 1);
            else if (state.attacking)
            {
                NailSlash? selected = native.Selected(hero);
                desired = selected == hero.upSlash ? "nailUp" : selected == hero.downSlash ? "nailDown" :
                    state.onGround ? "nailAttack1" : "nailAir";
            }
            else if (state.wallSliding) desired = "jumpNormal";
            else if (!state.onGround) desired = state.doubleJumping ? "jumpTwo" : state.falling ? "jumpDown" : "jumpNormal";
            else if (Math.Abs(hero.move_input) > 0.05f) desired = state.inWalkZone ? "walk" : "runNormal";
            else desired = "idle";
            if (clipName != desired) { clipName = desired; clipStarted = now; }
            double ticks = combo != null && combo.Active && desired == "nailAttack" + (combo.StageIndex + 1)
                ? combo.Elapsed(now) / combo.SecondsPerTick : (now - clipStarted) * assets.FrameRate;
            if (state.attacking && desired.StartsWith("nail", StringComparison.Ordinal) && (combo == null || !combo.Active))
                ticks = Math.Min(assets.Clips[desired].Ticks - 0.0001, native.AttackProgress(hero) * assets.Clips[desired].Ticks);
            if (dying) ticks = deathClock.Tick(now);
            bool dashing = desired == "flameDash" || desired == "flameDashDown";
            if (dashing && flameDash != null)
                ticks = Math.Min(assets.Clips[desired].Ticks - 0.0001, flameDash.Progress * assets.Clips[desired].Ticks);
            if (fireDemon != null && fireDemon.Active && desired == fireDemon.Clip) ticks = fireDemon.Tick;
            if (flameStorm != null && flameStorm.Active && desired == "flameStorm") ticks = flameStorm.Tick;
            if (bloodEye != null && bloodEye.Casting && desired == "fireEyeCast")
                ticks = bloodEye.CastTick;
            // Hold the opening body without flames until the final source-duration
            // window, then run both source layers at 30 Hz to native completion.
            bool nail = desired.StartsWith("nail", StringComparison.Ordinal);
            if (nail)
            {
                string body = desired == "nailUp" ? "effect1" : desired == "nailAir" || desired == "nailDown"
                    ? "jumpAttack" : "attack" + desired.Substring("nailAttack".Length);
                double bodyTick = desired == "nailDown" ? ticks * assets.Clips[body].Ticks / assets.Clips[desired].Ticks : ticks;
                renderer.sprite = assets.Clips[body].Sample(bodyTick);
                string arc = desired.StartsWith("nailAttack", StringComparison.Ordinal)
                    ? "nailArc" + desired.Substring("nailAttack".Length) : "nailArc" + desired.Substring("nail".Length);
                nailArc.sprite = assets.Clips[arc].Sample(ticks);
                Vector3 range = native.NailRangeScale(hero);
                nailArc.transform.localScale = range;
                // Scale the arc about the same fixed source character center used
                // for down rotation, keeping its attachment stable as reach changes.
                float centerY = (assets.NominalBodyHeight * assets.ArtworkScale / 2f - assets.FeetOffsetPixels) / 100f;
                nailArc.transform.localPosition = new Vector3(0, centerY * (1f - range.y), -0.0005f);
            }
            else renderer.sprite = desired == "fireEyeCast" && (ticks < 0 || ticks >= assets.Clips[desired].Ticks)
                ? assets.Clips["effect4"].Sample(ticks < 0 ? 0 : assets.Clips["effect4"].Ticks - 0.0001)
                : assets.Clips[desired].Sample(ticks);
            renderer.color = dying || dashing || (fireDemon != null && fireDemon.Active) ? Color.white : nativeSprite.color;
            renderer.enabled = (nativeBody.enabled || dying || dashing || (fireDemon != null && fireDemon.Active)) && !previousForceOff && hero.gameObject.activeInHierarchy;
            nailArc.enabled = nail && renderer.enabled;
            nailArc.color = renderer.color;
            aura.enabled = !dying && bloodEye != null && bloodEye.BuffActive && renderer.enabled;
            if (aura.enabled && bloodEye != null)
            {
                aura.sprite = assets.Clips["fireEyeAura"].Sample(bloodEye.AuraTick);
                aura.flipX = !state.facingRight;
            }
            // effect5 owns its moving character flashes and genuinely transparent blink gaps.
            // Hiding this entire source layer would also erase the skill's afterimages.
            Bounds bounds = bodyCollider.bounds;
            view.transform.position = dying ? deathPosition : new Vector3(bounds.center.x, bounds.min.y + viewScale * assets.FeetOffsetPixels / 100f, nativeBody.transform.position.z - 0.001f);
            view.transform.rotation = Quaternion.identity;
            float scale = viewScale;
            Vector3 parentScale = hero.transform.lossyScale;
            if (Math.Abs(parentScale.x) < 0.001f || Math.Abs(parentScale.y) < 0.001f) { renderer.enabled = false; aura.enabled = false; nailArc.enabled = false; return; }
            // Cancel inherited root mirroring; exactly one explicit source-facing mapping below.
            view.transform.localScale = new Vector3(scale / parentScale.x, scale / parentScale.y, 1f);
            // Default staff source faces right. No second flip follows the Knight's negative root X.
            renderer.flipX = !(dying ? deathFacingRight : fireDemon != null && fireDemon.Active ? fireDemon.FacingRight :
                flameStorm != null && flameStorm.Active ? flameStorm.FacingRight : state.facingRight);
            nailArc.flipX = renderer.flipX;
        }

        private void RestoreNativeVisibility()
        {
            deathClock.Clear(); death.Restore();
            foreach (KeyValuePair<Renderer, bool> entry in nailVisibility)
                if (entry.Key != null) forceOff.SetValue(entry.Key, entry.Value, null);
            nailVisibility.Clear();
            if (nativeBody != null) forceOff.SetValue(nativeBody, previousForceOff, null);
        }

        public void Dispose()
        {
            if (disposed) return; disposed = true;
            try { RestoreNativeVisibility(); }
            finally
            {
                if (renderer != null && renderer.sharedMaterial != null) UnityEngine.Object.Destroy(renderer.sharedMaterial);
                if (view != null) UnityEngine.Object.Destroy(view);
            }
        }
    }
}
