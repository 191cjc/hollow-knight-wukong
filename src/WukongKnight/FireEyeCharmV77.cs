using System;
using System.Collections.Generic;
using System.IO;
using System.Reflection;
using Modding;
using Mono.Cecil;
using Mono.Cecil.Cil;
using MonoMod.Cil;
using MonoMod.RuntimeDetour;
using UnityEngine;

namespace WukongKnight
{
    /// <summary>Replaces Deep Focus in its native slot, without changing saved ownership/equipment.</summary>
    internal sealed class FireEyeCharmV77 : IDisposable
    {
        private const int CharmId = 34;
        private const string Equipment = "equippedCharm_34";
        private const string Resource = "WukongKnight.FireEyeSigil.png";
        private readonly HashSet<object> queries = new HashSet<object>();
        private readonly List<MethodInfo> queryMethods = new List<MethodInfo>();
        private readonly List<Tuple<object, PropertyInfo>> cachedEquipment = new List<Tuple<object, PropertyInfo>>();
        private readonly Dictionary<object, object> actionCaches = new Dictionary<object, object>();
        private readonly HashSet<object> ownedCaches = new HashSet<object>();
        private readonly List<ILHook> hooks = new List<ILHook>();
        private readonly Dictionary<Sprite, Sprite> icons = new Dictionary<Sprite, Sprite>();
        private readonly Action<string> logError;
        private readonly Action<Exception> fail;
        private Texture2D? texture;
        private bool active;
        private bool disposed;
        public bool Equipped => active && !disposed && PlayerData.instance.GetBool(Equipment);

        public FireEyeCharmV77(HeroController hero, Action<string> logError, Action<Exception> fail)
        {
            this.logError = logError; this.fail = fail;
            const BindingFlags flags = BindingFlags.Instance | BindingFlags.Public | BindingFlags.NonPublic;
            FieldInfo field = typeof(HeroController).GetField("spellControl", flags)
                ?? throw new MissingFieldException("HeroController.spellControl");
            Component spell = field.GetValue(hero) as Component ?? throw new InvalidOperationException("Spell Control missing");
            if (spell.GetType().FullName != "PlayMakerFSM") throw new InvalidOperationException("Unexpected Spell Control type");
            foreach (object state in (Array)Prop(spell.GetType(), "FsmStates").GetValue(spell, null))
            foreach (object action in (Array)Prop(state.GetType(), "Actions").GetValue(state, null))
            {
                Type type = action.GetType();
                object? name = type.GetField("boolName")?.GetValue(action);
                if (name == null || (string)Prop(name.GetType(), "Value").GetValue(name, null) != Equipment) continue;
                if (type.Assembly != typeof(HeroController).Assembly ||
                    (type.FullName != "HutongGames.PlayMaker.Actions.GetPlayerDataBool" &&
                     type.FullName != "HutongGames.PlayMaker.Actions.PlayerDataBoolTest"))
                    throw new InvalidOperationException("Unsupported Deep Focus query action: " + type.FullName);
                queries.Add(action);
                MethodInfo enter = type.GetMethod("OnEnter", Type.EmptyTypes)
                    ?? throw new MissingMethodException(type.FullName, "OnEnter");
                if (!queryMethods.Contains(enter)) queryMethods.Add(enter);
                object? value = type.GetField("storeValue")?.GetValue(action);
                if (value != null)
                {
                    PropertyInfo property = Prop(value.GetType(), "Value");
                    if (property.PropertyType != typeof(bool) || !property.CanWrite)
                        throw new InvalidOperationException("Unsupported Deep Focus cached bool");
                    cachedEquipment.Add(Tuple.Create(value, property));
                    actionCaches.Add(action, value);
                }
            }
            if (queries.Count == 0) throw new InvalidOperationException("Native Deep Focus checks not found in Spell Control");
            try
            {
                using (Stream stream = typeof(FireEyeCharmV77).Assembly.GetManifestResourceStream(Resource)
                    ?? throw new InvalidOperationException("Fire Eye Sigil embedded icon missing"))
                using (var bytes = new MemoryStream())
                {
                    stream.CopyTo(bytes);
                    texture = new Texture2D(2, 2, TextureFormat.RGBA32, false) { name = "Wukong Fire Eye Sigil" };
                    if (!ImageConversion.LoadImage(texture, bytes.ToArray(), false))
                        throw new InvalidOperationException("Fire Eye Sigil icon cannot be decoded");
                    texture.filterMode = FilterMode.Bilinear;
                    texture.wrapMode = TextureWrapMode.Clamp;
                }
            }
            catch { Dispose(); throw; }
        }

        // Called only after every other hero adapter has initialized successfully.
        public void Activate()
        {
            if (active || disposed) return;
            try
            {
                foreach (MethodInfo method in queryMethods)
                {
                    // Keep a disposal handle even when a changed native layout fails Apply.
                    var hook = new ILHook(method, ReplaceQuery, new ILHookConfig { ManualApply = true });
                    hooks.Add(hook);
                    hook.Apply();
                }
                active = true;
                // A native initialization read may have populated these before hero attachment.
                foreach (var value in cachedEquipment)
                    if ((bool)value.Item2.GetValue(value.Item1, null))
                    { ownedCaches.Add(value.Item1); value.Item2.SetValue(value.Item1, false, null); }
                ModHooks.GetPlayerIntHook += GetInt;
                ModHooks.LanguageGetHook += LanguageGet;
                On.CharmIconList.GetSprite += GetSprite;
                On.CharmIconList.Awake += IconListAwake;
                RefreshIcons(CharmIconList.Instance);
                RefreshNotches();
            }
            catch { Dispose(); throw; }
        }

        private void ReplaceQuery(ILContext il)
        {
            Instruction? query = null;
            foreach (Instruction instruction in il.Body.Instructions)
            {
                if (instruction.OpCode != OpCodes.Callvirt || !(instruction.Operand is MethodReference method) ||
                    method.DeclaringType.FullName != typeof(GameManager).FullName || method.Name != "GetPlayerDataBool" ||
                    method.ReturnType.FullName != "System.Boolean" || method.Parameters.Count != 1 ||
                    method.Parameters[0].ParameterType.FullName != "System.String") continue;
                if (query != null) throw new InvalidOperationException("Ambiguous native Deep Focus query call");
                query = instruction;
            }
            if (query == null) throw new InvalidOperationException("Native Deep Focus query call missing");
            var cursor = new ILCursor(il);
            cursor.Goto(query, MoveType.Before);
            cursor.Remove();
            cursor.Emit(OpCodes.Ldarg_0);
            cursor.EmitDelegate<Func<GameManager, string, object, bool>>(ReadFocusEquipment);
        }

        private bool ReadFocusEquipment(GameManager manager, string name, object action)
        {
            // Keep native/API query side effects exactly once. Only this action's returned
            // value changes; its Finish/Event calls run after this method has returned.
            bool original = manager.GetPlayerDataBool(name);
            if (!active || disposed || name != Equipment || !queries.Contains(action)) return original;
            if (actionCaches.TryGetValue(action, out object cache)) ownedCaches.Add(cache);
            return false;
        }

        private int GetInt(string name, int original) => active && name == "charmCost_34" ? 2 : original;

        private string LanguageGet(string key, string sheet, string original)
        {
            if (!active || sheet != "UI") return original;
            bool chinese = Language.Language.CurrentLanguage().ToString().StartsWith("ZH", StringComparison.OrdinalIgnoreCase);
            if (key == "CHARM_NAME_34") return chinese ? "火眼之印" : "Fire Eye Sigil";
            if (key == "CHARM_DESC_34") return chinese
                ? "凝结着不熄余烬的印记。<br><br>将汲元火眼的持续时间从3秒延长至6秒。"
                : "A sigil holding an undying ember.<br><br>Extends Jiyuan Fire Eye from 3 seconds to 6 seconds.";
            return original;
        }

        private Sprite GetSprite(On.CharmIconList.orig_GetSprite orig, CharmIconList self, int id)
        {
            Sprite original = orig(self, id);
            try { return active && id == CharmId && original != null ? IconFor(original) : original!; }
            catch (Exception error) { fail(error); return original; }
        }

        private Sprite IconFor(Sprite original)
        {
            if (icons.TryGetValue(original, out Sprite owned)) return owned;
            if (texture == null) throw new InvalidOperationException("Fire Eye Sigil texture unavailable");
            // Fit the original native icon bounds; never scale the UI or hero transforms.
            float size = Math.Max(original.bounds.size.x, original.bounds.size.y);
            if (size <= 0) throw new InvalidOperationException("Native Deep Focus icon bounds invalid");
            owned = Sprite.Create(texture, new Rect(0, 0, texture.width, texture.height), new Vector2(.5f, .5f),
                Math.Max(texture.width, texture.height) / size, 0, SpriteMeshType.FullRect);
            owned.name = "Wukong Fire Eye Sigil";
            icons.Add(original, owned);
            return owned;
        }

        private void IconListAwake(On.CharmIconList.orig_Awake orig, CharmIconList self)
        {
            orig(self);
            try { if (active) RefreshIcons(self); }
            catch (Exception error) { fail(error); }
        }

        private void RefreshIcons(CharmIconList list)
        {
            if (list == null) return;
            // GetSprite is the only pinned native reader of spriteList. Existing renderers
            // can cache the old sprite across disable/re-enable, so refresh their references.
            Sprite original = list.spriteList[CharmId];
            if (original == null) throw new InvalidOperationException("Native Deep Focus icon missing");
            Sprite owned = IconFor(original);
            foreach (SpriteRenderer renderer in Resources.FindObjectsOfTypeAll<SpriteRenderer>())
            {
                if (renderer.sprite != original) continue;
                renderer.sprite = owned;
            }
        }

        private void RestoreIcons()
        {
            // Also restore consumers which requested our icon after initial registration.
            foreach (SpriteRenderer renderer in Resources.FindObjectsOfTypeAll<SpriteRenderer>())
            foreach (var pair in icons)
                if (renderer.sprite == pair.Value) { renderer.sprite = pair.Key; break; }
        }

        public void Dispose()
        {
            if (disposed) return;
            bool wasActive = active;
            disposed = true; active = false;
            ModHooks.GetPlayerIntHook -= GetInt;
            ModHooks.LanguageGetHook -= LanguageGet;
            On.CharmIconList.GetSprite -= GetSprite;
            On.CharmIconList.Awake -= IconListAwake;
            foreach (ILHook hook in hooks) Cleanup(hook.Dispose);
            hooks.Clear();
            if (wasActive)
            {
                foreach (var value in cachedEquipment)
                    Cleanup(() => { if (ownedCaches.Contains(value.Item1) && !(bool)value.Item2.GetValue(value.Item1, null))
                        value.Item2.SetValue(value.Item1, PlayerData.instance.GetBool(Equipment), null); });
                Cleanup(RefreshNotches);
            }
            Cleanup(RestoreIcons);
            foreach (Sprite sprite in icons.Values) if (sprite != null) UnityEngine.Object.Destroy(sprite);
            icons.Clear();
            if (texture != null) UnityEngine.Object.Destroy(texture);
            texture = null;
        }

        private void Cleanup(Action action)
        {
            try { action(); }
            catch (Exception error) { logError("Fire Eye Sigil could not restore an owned member: " + error); }
        }
        private static void RefreshNotches()
        {
            PlayerData.instance.CalculateNotchesUsed();
            // Native used-notch calculation does not update the saved overcharmed flag.
            // Reuse its own follow-up policy for an already-equipped loaded save too.
            if (GameManager.instance != null) GameManager.instance.RefreshOvercharm();
        }
        private static PropertyInfo Prop(Type type, string name) => type.GetProperty(name)
            ?? throw new MissingMemberException(type.FullName, name);
    }
}
