using System;
using System.IO;
using Modding;

namespace WukongKnight
{
    public sealed class WukongKnightMod : Mod, ITogglableMod
    {
        private CharacterAssets? assets;
        private WukongRuntime? runtime;
        public WukongKnightMod() : base("Wukong Knight") { }
        public override string GetVersion() => "0.4.4-dev";

        public override void Initialize()
        {
            Unload();
            try
            {
                string directory = Path.GetDirectoryName(typeof(WukongKnightMod).Assembly.Location) ?? throw new InvalidOperationException("Mod directory unavailable.");
                assets = CharacterAssets.Load(Path.Combine(directory, "character"));
                runtime = new WukongRuntime(assets, message => LogError(message));
                Log("Wukong artwork resized offline to 1.5x; Flame Dash replaces normal dash visuals and damages each target once; native dash movement/cooldown and hero colliders retained. Client acceptance pending.");
            }
            catch (Exception error)
            {
                Unload();
                LogError("Could not initialize Wukong; native hero retained. " + error);
            }
        }

        public void Unload()
        {
            runtime?.Dispose(); runtime = null;
            assets?.Dispose(); assets = null;
        }
    }
}
