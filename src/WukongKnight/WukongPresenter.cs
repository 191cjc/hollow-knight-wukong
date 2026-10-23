using System;
using System.Reflection;
using UnityEngine;
using WukongKnight.Core;

namespace WukongKnight
{
    internal sealed class WukongPresenter : IDisposable
    {
        private readonly HeroController hero;
        private readonly CharacterAssets assets;
        private readonly Renderer nativeBody;
        private readonly tk2dSprite nativeSprite;
        private readonly PropertyInfo forceOff;
        private readonly bool previousForceOff;
        private readonly GameObject view;
        private readonly SpriteRenderer renderer;
        private readonly Collider2D bodyCollider;
        private readonly float viewScale;
        // Actual idle alpha bounds end at source y=+6px below the export root.
        private const float DefaultStaffFeetOffsetPixels = 6f;
        private string clipName = "";
        private long clipToken;
        private double clipStarted;
        private bool disposed;

        public WukongPresenter(HeroController hero, CharacterAssets assets)
        {
            this.hero = hero; this.assets = assets;
            nativeBody = hero.GetComponent<Renderer>() ?? throw new InvalidOperationException("Native body renderer missing.");
            nativeSprite = hero.GetComponent<tk2dSprite>() ?? throw new InvalidOperationException("Native body sprite missing.");
            bodyCollider = hero.GetComponent<Collider2D>() ?? throw new InvalidOperationException("Native hero collider missing.");
            // Resolve against the actual engine at runtime. This preserves native enabled writes
            // (cutscenes/blinking/visibility) while suppressing only its draw submission.
            forceOff = typeof(Renderer).GetProperty("forceRenderingOff") ?? throw new MissingMemberException("Renderer.forceRenderingOff is required for safe replacement.");
            if (!forceOff.CanRead || !forceOff.CanWrite || forceOff.PropertyType != typeof(bool)) throw new MissingMemberException("Unsupported renderer visibility API.");
            previousForceOff = (bool)forceOff.GetValue(nativeBody, null);
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
                // First successful update verifies geometry, pivot and material before hiding the body.
                Update(null, Time.time);
                forceOff.SetValue(nativeBody, true, null);
            }
            catch
            {
                forceOff.SetValue(nativeBody, previousForceOff, null);
                if (material != null) UnityEngine.Object.Destroy(material);
                UnityEngine.Object.Destroy(view); throw;
            }
        }

        public void Update(ComboTimeline? combo, double now)
        {
            if (disposed) return;
            HeroControllerStates state = hero.cState;
            string desired;
            if (state.dead || state.hazardDeath) desired = "dead";
            else if (state.recoiling || state.recoilFrozen || state.hazardRespawning) desired = "hurtStand";
            else if (state.transitioning || state.casting || state.focusing || state.superDashing || state.dashing || state.backDashing) desired = "idle";
            else if (combo != null && combo.Active) desired = combo.CurrentAttack.Clip;
            else if (state.attacking) desired = state.onGround ? "attack1" : "jumpAttack";
            else if (state.wallSliding) desired = "jumpNormal";
            else if (!state.onGround) desired = state.doubleJumping ? "jumpTwo" : state.falling ? "jumpDown" : "jumpNormal";
            else if (Math.Abs(hero.move_input) > 0.05f) desired = state.inWalkZone ? "walk" : "runNormal";
            else desired = "idle";
            bool controlled = combo != null && combo.Active && desired == combo.CurrentAttack.Clip;
            long desiredToken = controlled ? combo!.Token : 0;
            if (clipName != desired || clipToken != desiredToken)
            { clipName = desired; clipToken = desiredToken; clipStarted = now; }
            double ticks = controlled
                ? combo!.Elapsed(now) / combo.SecondsPerTick : (now - clipStarted) * assets.FrameRate;
            renderer.sprite = assets.Clips[desired].Sample(ticks);
            renderer.color = nativeSprite.color;
            renderer.enabled = nativeBody.enabled && !previousForceOff && hero.gameObject.activeInHierarchy;
            Bounds bounds = bodyCollider.bounds;
            view.transform.position = new Vector3(bounds.center.x, bounds.min.y + viewScale * DefaultStaffFeetOffsetPixels / 100f, nativeBody.transform.position.z - 0.001f);
            view.transform.rotation = Quaternion.identity;
            float scale = viewScale;
            Vector3 parentScale = hero.transform.lossyScale;
            if (Math.Abs(parentScale.x) < 0.001f || Math.Abs(parentScale.y) < 0.001f) { renderer.enabled = false; return; }
            // Cancel inherited root mirroring; exactly one explicit source-facing mapping below.
            view.transform.localScale = new Vector3(scale / parentScale.x, scale / parentScale.y, 1f);
            // Default staff source faces right. No second flip follows the Knight's negative root X.
            renderer.flipX = !state.facingRight;
        }

        public void Dispose()
        {
            if (disposed) return; disposed = true;
            try { if (nativeBody != null) forceOff.SetValue(nativeBody, previousForceOff, null); }
            finally
            {
                if (renderer != null && renderer.sharedMaterial != null) UnityEngine.Object.Destroy(renderer.sharedMaterial);
                if (view != null) UnityEngine.Object.Destroy(view);
            }
        }
    }
}
