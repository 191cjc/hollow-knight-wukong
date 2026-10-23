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

    /// <summary>The only decoder for version 2 of the generated character contract.</summary>
    internal sealed class CharacterAssets : IDisposable
    {
        private static readonly string[] RequiredClips = { "idle", "walk", "runNormal", "jumpNormal", "jumpTwo", "jumpDown", "jumpAttack", "hurtStand", "dead", "attack1", "attack2", "attack3", "attack4" };
        private readonly List<Texture2D> textures = new List<Texture2D>();
        private readonly List<Sprite> sprites = new List<Sprite>();
        public Dictionary<string, CharacterClip> Clips { get; } = new Dictionary<string, CharacterClip>();
        public ComboStage[] Stages { get; private set; } = System.Array.Empty<ComboStage>();
        public AttackDefinition AirAttack { get; private set; } = null!;
        public double FrameRate { get; private set; }
        public double GraceSeconds { get; private set; }
        public float NominalBodyHeight { get; private set; }

        public static CharacterAssets Load(string directory)
        {
            var result = new CharacterAssets();
            try { result.Read(directory); return result; }
            catch { result.Dispose(); throw; }
        }

        private void Read(string directory)
        {
            JObject root = JObject.Parse(File.ReadAllText(Path.Combine(directory, "character.json")));
            Require(Int(root, "schema_version") == 2, "Unsupported character schema; version 2 resources required.");
            Require((string?)root["character_id"] == "2001" && (string?)root["appearance"] == "default_staff", "Unexpected appearance.");
            FrameRate = Number(root, "frame_rate"); Require(FrameRate > 0 && FrameRate <= 240, "Invalid frame rate.");
            int canvasWidth = Int(root, "canvas_width"), canvasHeight = Int(root, "canvas_height");
            Require(canvasWidth > 0 && canvasHeight > 0, "Invalid canvas.");
            float rootX = (float)Number(root, "root_x"), rootY = (float)Number(root, "root_y");
            Require(rootX >= 0 && rootX <= canvasWidth && rootY >= 0 && rootY <= canvasHeight, "Invalid root.");
            NominalBodyHeight = (float)Number(root, "nominal_body_height");
            Require(NominalBodyHeight > 0, "Invalid nominal body height.");
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
                    Require(index >= 0 && index < textures.Count && x >= 0 && y >= 0 && width == canvasWidth && height == canvasHeight && duration > 0, "Invalid frame rectangle.");
                    Texture2D texture = textures[index];
                    Require((long)x + width <= texture.width && (long)y + height <= texture.height, "Frame outside atlas.");
                    // PNG rectangles and pivots are top-left; Unity rectangles and pivots are bottom-left.
                    Sprite sprite = Sprite.Create(texture, new Rect(x, texture.height - y - height, width, height), new Vector2(rootX / width, 1f - rootY / height), 100f, 0, SpriteMeshType.FullRect);
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
                double reach = Reach(stage);
                decoded.Add(new ComboStage(name, duration, buffer, reach, ReadWindows(stage, i == 2 ? 2 : 1, duration)));
            }
            Stages = decoded.ToArray();
            JObject air = combat["air_attack"] as JObject ?? throw new InvalidDataException("Missing air_attack object.");
            Require(air.Properties().Select(p => p.Name).OrderBy(n => n).SequenceEqual(new[] { "clip", "hit_windows", "range_multiplier" }), "Unsupported air_attack fields.");
            Require(air["clip"]?.Type == JTokenType.String && (string?)air["clip"] == "jumpAttack", "Invalid air attack clip.");
            CharacterClip airClip = Clips["jumpAttack"];
            Require(!airClip.Loop, "Air attack clip must not loop.");
            AirAttack = new AttackDefinition("jumpAttack", airClip.Ticks, Reach(air), ReadWindows(air, 1, airClip.Ticks));
        }

        private static double Reach(JToken attack)
        {
            double value = Number(attack, "range_multiplier");
            Require(value >= 0.25 && value <= 3, "Invalid reach."); return value;
        }

        private static HitWindow[] ReadWindows(JToken attack, int count, int duration)
        {
            JArray windows = Array(attack, "hit_windows"); Require(windows.Count == count, "Invalid hit count.");
            var hits = new List<HitWindow>(); int previousEnd = 0;
            foreach (JToken window in windows)
            {
                JObject fields = window as JObject ?? throw new InvalidDataException("Expected hit window object.");
                Require(fields.Properties().Select(p => p.Name).OrderBy(n => n).SequenceEqual(new[] { "end_tick", "start_tick" }), "Unsupported hit window fields.");
                int begin = Int(window, "start_tick"), end = Int(window, "end_tick");
                Require(begin >= previousEnd && end > begin && end <= duration, "Invalid hit window.");
                hits.Add(new HitWindow(begin, end)); previousEnd = end;
            }
            return hits.ToArray();
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
