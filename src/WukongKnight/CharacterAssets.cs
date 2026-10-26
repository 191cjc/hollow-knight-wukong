using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Security.Cryptography;
using Newtonsoft.Json.Linq;
using UnityEngine;
using WukongKnight.Core;

namespace WukongKnight
{
    internal sealed class CharacterClip
    {
        public CharacterClip(int ticks, bool loop, Sprite[] frames, int[] ends)
        { Ticks = ticks; Loop = loop; Frames = frames; Ends = ends; }
        public int Ticks { get; }
        public bool Loop { get; }
        public Sprite[] Frames { get; }
        private int[] Ends { get; }
        public Sprite Sample(double tick)
        {
            double position = Loop ? tick % Ticks : Math.Min(tick, Ticks - 0.0001);
            for (int i = 0; i < Ends.Length; i++) if (position < Ends[i]) return Frames[i];
            return Frames[Frames.Length - 1];
        }
    }

    /// <summary>The only decoder for version 1 of the generated character contract.</summary>
    internal sealed class CharacterAssets : IDisposable
    {
        private static readonly string[] RequiredClips = { "idle", "walk", "runNormal", "jumpNormal", "jumpTwo", "jumpDown", "jumpAttack", "hurtStand", "dead", "attack1", "attack2", "attack3", "attack4", "flameDash", "flameDashDown", "flameStorm", "fireEyeAura", "fireEyeCast", "effect4", "effect5", "fireDemonAir", "fireDemonAirEffect", "fireDemonDive", "fireDemonLand", "fireDemonImpact", "nailAttack1", "nailAttack2", "nailAttack3", "nailAttack4", "nailAir", "nailUp", "nailDown", "nailArc1", "nailArc2", "nailArc3", "nailArc4", "nailArcAir", "nailArcUp", "nailArcDown", "afterimageCombo", "godslayerCharge", "godslayerRelease", "godslayerWave", "godslayerPunch", "earthbreaker", "fireApe", "fireApeAwakenedBack", "fireApeAwakenedFront", "afterimageIdle1", "afterimageIdle2", "afterimageIdle3", "afterimageIdle4" };
        private readonly List<Texture2D> textures = new List<Texture2D>();
        private readonly List<Sprite> sprites = new List<Sprite>();
        public Dictionary<string, CharacterClip> Clips { get; } = new Dictionary<string, CharacterClip>();
        public ComboStage[] Stages { get; private set; } = System.Array.Empty<ComboStage>();
        public double FrameRate { get; private set; }
        public double GraceSeconds { get; private set; }
        public float NominalBodyHeight { get; private set; }
        public float FeetOffsetPixels { get; private set; }
        public float ArtworkScale { get; private set; }

        public static CharacterAssets Load(string directory)
        {
            var result = new CharacterAssets();
            try { result.Read(directory); return result; }
            catch { result.Dispose(); throw; }
        }

        private void Read(string directory)
        {
            JObject root = JObject.Parse(File.ReadAllText(Path.Combine(directory, "character.json")));
            Require(Int(root, "schema_version") == 1, "Unsupported character schema.");
            Require((string?)root["character_id"] == "2001" && (string?)root["appearance"] == "default_staff", "Unexpected appearance.");
            FrameRate = Number(root, "frame_rate"); Require(FrameRate > 0 && FrameRate <= 240, "Invalid frame rate.");
            int canvasWidth = Int(root, "canvas_width"), canvasHeight = Int(root, "canvas_height");
            Require(canvasWidth > 0 && canvasHeight > 0, "Invalid canvas.");
            float rootX = (float)Number(root, "root_x"), rootY = (float)Number(root, "root_y");
            Require(rootX >= 0 && rootX <= canvasWidth && rootY >= 0 && rootY <= canvasHeight, "Invalid root.");
            NominalBodyHeight = (float)Number(root, "nominal_body_height");
            Require(NominalBodyHeight > 0, "Invalid nominal body height.");
            FeetOffsetPixels = root["feet_offset_pixels"] == null ? 6f : (float)Number(root, "feet_offset_pixels");
            Require(FeetOffsetPixels >= 0 && FeetOffsetPixels <= canvasHeight, "Invalid feet offset.");
            // Used for effect registration only; PNG resizing already owns appearance size.
            ArtworkScale = root["asset_transform"] == null ? 1f : (float)Number(root["asset_transform"]!, "scale");
            Require(ArtworkScale > 0 && !float.IsInfinity(ArtworkScale), "Invalid artwork scale.");
            JArray atlases = Array(root, "atlases"); Require(atlases.Count > 0, "No atlases.");
            foreach (JToken page in atlases)
            {
                string relative = (string?)page["path"] ?? throw new InvalidDataException("Missing atlas path.");
                Require(!Path.IsPathRooted(relative) && !relative.Contains("\\") && relative.Split('/').All(p => p.Length > 0 && p != "." && p != ".."), "Unsafe atlas path.");
                string path = Path.Combine(directory, relative);
                byte[] bytes = File.ReadAllBytes(path);
                using (SHA256 hash = SHA256.Create())
                {
                    string actual = BitConverter.ToString(hash.ComputeHash(bytes)).Replace("-", "").ToLowerInvariant();
                    Require(actual == (string?)page["sha256"], "Atlas hash mismatch: " + relative);
                }
                var texture = new Texture2D(2, 2, TextureFormat.RGBA32, false);
                textures.Add(texture);
                Require(ImageConversion.LoadImage(texture, bytes, false), "Cannot decode atlas: " + relative);
                Require(texture.width == Int(page, "width") && texture.height == Int(page, "height"), "Atlas dimensions mismatch.");
                texture.filterMode = FilterMode.Point; texture.wrapMode = TextureWrapMode.Clamp;
            }
            JObject clips = root["clips"] as JObject ?? throw new InvalidDataException("Missing clips.");
            foreach (JProperty property in clips.Properties())
            {
                JToken clip = property.Value; int total = Int(clip, "duration_ticks");
                Require(total > 0, "Empty clip: " + property.Name);
                JArray frames = Array(clip, "frames"); Require(frames.Count > 0, "No frames: " + property.Name);
                var clipSprites = new List<Sprite>(); var ends = new List<int>(); int tick = 0;
                foreach (JToken frame in frames)
                {
                    int index = Int(frame, "atlas"), x = Int(frame, "x"), y = Int(frame, "y");
                    int width = Int(frame, "width"), height = Int(frame, "height"), duration = Int(frame, "duration_ticks");
                    Require(index >= 0 && index < textures.Count && x >= 0 && y >= 0 && width > 0 && height > 0 && width <= canvasWidth && height <= canvasHeight && duration > 0, "Invalid frame rectangle.");
                    int cropX = root["atlas_packing"] == null ? 0 : Int(frame, "source_x");
                    int cropY = root["atlas_packing"] == null ? 0 : Int(frame, "source_y");
                    Require(cropX >= 0 && cropY >= 0 && (long)cropX + width <= canvasWidth && (long)cropY + height <= canvasHeight, "Crop outside source canvas.");
                    Require(root["atlas_packing"] != null || width == canvasWidth && height == canvasHeight, "Unexpected cropped frame.");
                    Require(cropX <= rootX && rootX <= cropX + width && cropY <= rootY && rootY <= cropY + height, "Crop excludes source root.");
                    Texture2D texture = textures[index];
                    Require((long)x + width <= texture.width && (long)y + height <= texture.height, "Frame outside atlas.");
                    // PNG rectangles and pivots are top-left; Unity rectangles and pivots are bottom-left.
                    Sprite sprite = Sprite.Create(texture, new Rect(x, texture.height - y - height, width, height), new Vector2((rootX - cropX) / width, 1f - (rootY - cropY) / height), 100f, 0, SpriteMeshType.FullRect);
                    sprites.Add(sprite); clipSprites.Add(sprite); tick = checked(tick + duration); ends.Add(tick);
                }
                Require(tick == total, "Clip duration mismatch: " + property.Name);
                Clips.Add(property.Name, new CharacterClip(total, Bool(clip, "loop"), clipSprites.ToArray(), ends.ToArray()));
            }
            foreach (string name in RequiredClips) Require(Clips.ContainsKey(name), "Missing clip: " + name);
            JToken combat = root["combat"] ?? throw new InvalidDataException("Missing combat configuration.");
            GraceSeconds = Number(combat, "chain_grace_seconds"); Require(GraceSeconds >= 0 && GraceSeconds <= 2, "Invalid chain grace.");
            JArray stages = Array(combat, "stages"); Require(stages.Count == 4, "Exactly four stages required.");
            var decoded = new List<ComboStage>();
            for (int i = 0; i < stages.Count; i++)
            {
                JToken stage = stages[i]; string name = (string?)stage["clip"] ?? "";
                Require(name == "attack" + (i + 1), "Invalid stage order.");
                int duration = Clips[name].Ticks, buffer = Int(stage, "buffer_open_tick");
                Require(buffer >= 0 && buffer < duration, "Invalid buffer window.");
                double reach = Number(stage, "range_multiplier"); Require(reach > 0 && reach <= 4, "Invalid reach.");
                JArray windows = Array(stage, "hit_windows"); Require(windows.Count == (i == 2 ? 2 : 1), "Invalid hit count.");
                var hits = new List<HitWindow>(); int previousEnd = 0;
                foreach (JToken window in windows)
                {
                    int begin = Int(window, "start_tick"), end = Int(window, "end_tick");
                    Require(begin >= previousEnd && end > begin && end <= duration, "Invalid hit window.");
                    hits.Add(new HitWindow(begin, end)); previousEnd = end;
                }
                decoded.Add(new ComboStage(name, duration, buffer, reach, hits.ToArray()));
            }
            Stages = decoded.ToArray();
        }

        private static JArray Array(JToken token, string field) => token[field] as JArray ?? throw new InvalidDataException("Missing array: " + field);
        private static int Int(JToken token, string field)
        {
            JToken value = token[field] ?? throw new InvalidDataException("Missing integer: " + field);
            Require(value.Type == JTokenType.Integer, "Expected integer: " + field); return (int)value;
        }
        private static bool Bool(JToken token, string field)
        {
            JToken value = token[field] ?? throw new InvalidDataException("Missing boolean: " + field);
            Require(value.Type == JTokenType.Boolean, "Expected boolean: " + field); return (bool)value;
        }
        private static double Number(JToken token, string field)
        {
            JToken value = token[field] ?? throw new InvalidDataException("Missing number: " + field);
            Require(value.Type == JTokenType.Integer || value.Type == JTokenType.Float, "Expected number: " + field);
            double number = (double)value; Require(!double.IsNaN(number) && !double.IsInfinity(number), "Nonfinite number: " + field); return number;
        }
        private static void Require(bool condition, string message) { if (!condition) throw new InvalidDataException(message); }
        public void Dispose()
        {
            foreach (Sprite sprite in sprites) if (sprite != null) UnityEngine.Object.Destroy(sprite);
            foreach (Texture2D texture in textures) if (texture != null) UnityEngine.Object.Destroy(texture);
            sprites.Clear(); textures.Clear(); Clips.Clear();
        }
    }
}
