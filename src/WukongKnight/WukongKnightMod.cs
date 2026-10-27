using System;
using System.IO;
using Modding;

namespace WukongKnight
{
    public sealed class WukongKnightMod : Mod, ITogglableMod
    {
        private CharacterAssets? assets;
        private WukongRuntime? runtime;
        private EnemyFsmDump? fsmDump;
        public WukongKnightMod() : base("Wukong Knight") { }
        public override string GetVersion() => "0.7.6-dev+fsmdump";

        public override void Initialize()
        {
            Unload();
            try
            {
                string directory = Path.GetDirectoryName(typeof(WukongKnightMod).Assembly.Location) ?? throw new InvalidOperationException("Mod directory unavailable.");
                // Read-only diagnostic, independent of the character replacement.
                try { fsmDump = new EnemyFsmDump(directory, message => LogError(message)); }
                catch (Exception error) { fsmDump?.Dispose(); fsmDump = null; LogError("Enemy FSM dump unavailable (diagnostic only). " + error); }
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
            fsmDump?.Dispose(); fsmDump = null;
            assets?.Dispose(); assets = null;
        }
    }
}
