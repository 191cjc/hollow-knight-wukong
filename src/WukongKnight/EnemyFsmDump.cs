using System;
using System.Collections;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Reflection;
using System.Text;
using System.Text.RegularExpressions;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnitySceneManager = UnityEngine.SceneManagement.SceneManager;

namespace WukongKnight
{
    /// <summary>
    /// Diagnostic only. Writes original enemy PlayMaker structure, scene FSM indexes and live
    /// state/hit traces as plain text beside the Mod. Reads through reflection; never writes
    /// enemy state, FSM data, colliders or damage.
    /// </summary>
    internal sealed class EnemyFsmDump : IDisposable
    {
        private const long TraceLimit = 16L * 1024 * 1024;
        private const int MaxNodes = 400;
        private const int MaxItems = 48;
        private static readonly Regex CloneSuffix = new Regex(@"(\s*\(Clone\))+|\s*\(\d+\)$", RegexOptions.Compiled);
        private static readonly Regex Unsafe = new Regex(@"[^A-Za-z0-9_.\-]+", RegexOptions.Compiled);
        private sealed class Tracked { public Component Fsm = null!; public string Label = ""; public string Last = ""; }
        private readonly string directory;
        private readonly Action<string> logError;
        private readonly HashSet<string> written = new HashSet<string>();
        private readonly HashSet<string> indexed = new HashSet<string>();
        private readonly HashSet<int> trackedIds = new HashSet<int>();
        private readonly List<Tracked> tracked = new List<Tracked>();
        private readonly HashSet<string> reported = new HashSet<string>();
        private readonly StringBuilder trace = new StringBuilder();
        private readonly Dictionary<Type, PropertyInfo?> activeState = new Dictionary<Type, PropertyInfo?>();
        private readonly string tracePath;
        private readonly GameObject pump;
        private long traceBytes;
        private float lastFlush;
        private string pendingScene = "";
        private float pendingSince;
        private bool disposed;

        public EnemyFsmDump(string modDirectory, Action<string> logError)
        {
            this.logError = logError;
            directory = System.IO.Path.Combine(modDirectory, "fsm-dump");
            Directory.CreateDirectory(directory);
            tracePath = System.IO.Path.Combine(directory, "trace-" + DateTime.Now.ToString("yyyyMMdd-HHmmss", CultureInfo.InvariantCulture) + ".txt");
            pump = new GameObject("WukongKnight.EnemyFsmDump");
            UnityEngine.Object.DontDestroyOnLoad(pump);
            pump.AddComponent<EnemyFsmDumpPump>().Tick = Poll;
            Append("# Wukong Knight enemy FSM trace. game " + Application.version + ", unity " + Application.unityVersion);
            On.HealthManager.Start += HealthStart;
            On.HealthManager.Hit += HealthHit;
            UnitySceneManager.activeSceneChanged += SceneChanged;
            pendingScene = UnitySceneManager.GetActiveScene().name; pendingSince = Time.realtimeSinceStartup;
        }

        private void HealthStart(On.HealthManager.orig_Start orig, HealthManager self)
        {
            orig(self);
            if (disposed || self == null) return;
            Guard("enemy", () => DumpEnemy(self));
        }

        private void HealthHit(On.HealthManager.orig_Hit orig, HealthManager self, HitInstance hit)
        {
            int before = self != null ? self.hp : 0;
            orig(self!, hit);
            if (disposed || self == null) return;
            Guard("hit", () => Append(Stamp() + "\tHIT\t" + PathOf(self.transform) + "\t" + hit.AttackType + "\tdamage=" + hit.DamageDealt +
                "\tsource=" + (hit.Source != null ? PathOf(hit.Source.transform) : "null") + "\thp " + before + "->" + self.hp +
                (self.GetIsDead() ? "\tDEAD" : "")));
        }

        private void SceneChanged(Scene previous, Scene next)
        {
            Flush();
            pendingScene = next.name; pendingSince = Time.realtimeSinceStartup;
            Append(Stamp() + "\tSCENE\t" + previous.name + " -> " + next.name);
        }

        private void Poll()
        {
            if (disposed) return;
            Guard("poll", () =>
            {
                // Index once scene objects have finished Awake/Start.
                if (pendingScene.Length > 0 && Time.realtimeSinceStartup - pendingSince > 1.5f)
                {
                    string scene = pendingScene; pendingScene = "";
                    IndexScene(scene);
                }
                for (int i = tracked.Count - 1; i >= 0; i--)
                {
                    Tracked t = tracked[i];
                    if (t.Fsm == null) { tracked.RemoveAt(i); continue; }
                    string state = ActiveState(t.Fsm);
                    if (state == t.Last) continue;
                    Append(Stamp() + "\tSTATE\t" + t.Label + "\t" + t.Last + " -> " + state +
                        (t.Fsm.gameObject.activeInHierarchy ? "" : "\t(inactive)"));
                    t.Last = state;
                }
                if (Time.realtimeSinceStartup - lastFlush > 2f) Flush();
            });
        }

        private void DumpEnemy(HealthManager enemy)
        {
            var fsms = new List<Component>();
            Transform? parent = enemy.transform.parent;
            if (parent != null) fsms.AddRange(Fsms(parent.gameObject, false));
            fsms.AddRange(Fsms(enemy.gameObject, true));
            foreach (Component fsm in fsms) Track(fsm);
            string scene = enemy.gameObject.scene.name;
            string key = scene + "|" + CloneSuffix.Replace(enemy.gameObject.name, "");
            if (!written.Add(key)) return;
            string file = System.IO.Path.Combine(directory, Safe(scene) + "__" + Safe(CloneSuffix.Replace(enemy.gameObject.name, "")) + ".txt");
            if (File.Exists(file)) return;
            var text = new StringBuilder();
            text.AppendLine("# Wukong Knight enemy FSM dump (diagnostic, read-only)");
            text.AppendLine("game: " + Application.version + "  unity: " + Application.unityVersion);
            text.AppendLine("scene: " + scene);
            text.AppendLine("object: " + PathOf(enemy.transform) + "  layer: " + LayerMask.LayerToName(enemy.gameObject.layer));
            text.AppendLine("hp: " + enemy.hp + "  position: " + enemy.transform.position);
            text.AppendLine("components: " + Components(enemy.gameObject));
            text.AppendLine();
            text.AppendLine("## Hierarchy (path | activeSelf | layer | components)");
            int nodes = 0;
            Hierarchy(enemy.transform, 0, text, ref nodes);
            foreach (Component fsm in fsms) { text.AppendLine(); DumpFsm(fsm, text); }
            File.WriteAllText(file, text.ToString(), Encoding.UTF8);
        }

        private void IndexScene(string name)
        {
            if (name.Length == 0 || !indexed.Add(name)) return;
            Scene scene = UnitySceneManager.GetSceneByName(name);
            if (!scene.IsValid() || !scene.isLoaded) return;
            string file = System.IO.Path.Combine(directory, "scene__" + Safe(name) + ".txt");
            if (File.Exists(file)) return;
            var text = new StringBuilder();
            text.AppendLine("# Scene FSM index (object path | FSM | enabled | active state | states)");
            text.AppendLine("game: " + Application.version + "  scene: " + name);
            foreach (GameObject root in scene.GetRootGameObjects())
                foreach (Component fsm in Fsms(root, true))
                {
                    Array? states = Get(fsm, "FsmStates") as Array;
                    var names = new List<string>();
                    if (states != null) foreach (object s in states) names.Add(Str(Get(s, "Name")));
                    text.AppendLine(PathOf(fsm.transform) + " | " + Str(Get(fsm, "FsmName")) + " | " + Str(Get(fsm, "enabled")) +
                        " | " + ActiveState(fsm) + " | " + string.Join(", ", names.ToArray()));
                }
            File.WriteAllText(file, text.ToString(), Encoding.UTF8);
        }

        private void DumpFsm(Component fsm, StringBuilder text)
        {
            text.AppendLine("## FSM \"" + Str(Get(fsm, "FsmName")) + "\" on " + PathOf(fsm.transform) + "  enabled=" + Str(Get(fsm, "enabled")));
            object? core = Get(fsm, "Fsm");
            text.AppendLine("start: " + Str(core == null ? null : Get(core, "StartState")) + "  active: " + ActiveState(fsm));
            if (Get(fsm, "FsmEvents") is Array events)
            {
                var names = new List<string>();
                foreach (object e in events) names.Add(Str(Get(e, "Name")) + (Get(e, "IsGlobal") is bool g && g ? "(global)" : ""));
                text.AppendLine("events: " + string.Join(", ", names.ToArray()));
            }
            object? variables = Get(fsm, "FsmVariables");
            if (variables != null)
            {
                text.AppendLine("variables:");
                foreach (PropertyInfo p in variables.GetType().GetProperties(BindingFlags.Public | BindingFlags.Instance))
                {
                    if (!p.PropertyType.IsArray || !p.Name.EndsWith("Variables", StringComparison.Ordinal) || p.GetIndexParameters().Length != 0) continue;
                    if (!(Safe(() => p.GetValue(variables, null)) is Array list)) continue;
                    foreach (object v in list)
                        text.AppendLine("  " + p.Name.Replace("Variables", "") + " " + Str(Get(v, "Name")) + " = " + Format(Get(v, "Value"), 1));
                }
            }
            if (Get(fsm, "FsmGlobalTransitions") is Array globals)
                foreach (object t in globals) text.AppendLine("global: " + Str(Get(t, "EventName")) + " -> " + Str(Get(t, "ToState")));
            if (!(Get(fsm, "FsmStates") is Array states)) return;
            foreach (object state in states)
            {
                text.AppendLine("state \"" + Str(Get(state, "Name")) + "\"");
                if (Get(state, "Transitions") is Array transitions)
                    foreach (object t in transitions) text.AppendLine("  on " + Str(Get(t, "EventName")) + " -> " + Str(Get(t, "ToState")));
                if (!(Get(state, "Actions") is Array actions)) { text.AppendLine("  actions: <unavailable>"); continue; }
                for (int i = 0; i < actions.Length; i++)
                {
                    object? action = actions.GetValue(i);
                    if (action == null) { text.AppendLine("  [" + i + "] null"); continue; }
                    Type type = action.GetType();
                    text.AppendLine("  [" + i + "] " + type.FullName + "  enabled=" + Str(Get(action, "Enabled")));
                    foreach (FieldInfo f in type.GetFields(BindingFlags.Public | BindingFlags.Instance))
                    {
                        if (f.DeclaringType != null && f.DeclaringType.FullName == "HutongGames.PlayMaker.FsmStateAction") continue;
                        text.AppendLine("      " + f.Name + " = " + Format(Safe(() => f.GetValue(action)), 0));
                    }
                }
            }
        }

        private static string Format(object? value, int depth)
        {
            if (value == null) return "null";
            if (value is UnityEngine.Object unity)
            {
                if (unity == null) return "null(destroyed)";
                if (unity is GameObject go) return "GameObject:" + PathOf(go.transform);
                if (unity is Component c) return c.GetType().Name + ":" + PathOf(c.transform);
                return unity.GetType().Name + ":" + unity.name;
            }
            Type type = value.GetType();
            if (value is string s) return "\"" + (s.Length > 300 ? s.Substring(0, 300) + "..." : s) + "\"";
            if (type.IsPrimitive || type.IsEnum || value is decimal) return Convert.ToString(value, CultureInfo.InvariantCulture) ?? "";
            if (value is Vector2 || value is Vector3 || value is Vector4 || value is Color || value is Quaternion || value is Rect) return value.ToString();
            if (value is IList list)
            {
                var items = new List<string>();
                for (int i = 0; i < list.Count && i < MaxItems; i++) items.Add(depth > 3 ? "..." : Format(list[i], depth + 1));
                return "[" + string.Join(", ", items.ToArray()) + (list.Count > MaxItems ? ", ...(" + list.Count + ")" : "") + "]";
            }
            if (type.Namespace == "HutongGames.PlayMaker")
            {
                if (type.Name == "FsmEvent") return "event:" + Str(Get(value, "Name"));
                if (type.Name == "FsmOwnerDefault")
                    return "owner:" + Str(Get(value, "OwnerOption")) + "/" + Format(Get(value, "GameObject"), depth + 1);
                string prefix = Get(value, "UseVariable") is bool use && use && Str(Get(value, "Name")).Length > 0 ? "var:" + Str(Get(value, "Name")) + "=" : "";
                if (type.GetProperty("Value") != null && depth < 4) return prefix + Format(Get(value, "Value"), depth + 1);
                if (type.GetProperty("Values") != null && depth < 4) return prefix + Format(Get(value, "Values"), depth + 1);
            }
            if (depth >= 2) return value.ToString() ?? type.Name;
            var fields = new List<string>();
            foreach (FieldInfo f in type.GetFields(BindingFlags.Public | BindingFlags.Instance))
                fields.Add(f.Name + "=" + Format(Safe(() => f.GetValue(value)), depth + 1));
            return type.Name + "{" + string.Join(", ", fields.ToArray()) + "}";
        }

        private static void Hierarchy(Transform t, int depth, StringBuilder text, ref int nodes)
        {
            if (++nodes > MaxNodes) { if (nodes == MaxNodes + 1) text.AppendLine("...(truncated)"); return; }
            text.AppendLine(new string(' ', depth * 2) + PathOf(t) + " | " + t.gameObject.activeSelf + " | " +
                LayerMask.LayerToName(t.gameObject.layer) + " | " + Components(t.gameObject));
            for (int i = 0; i < t.childCount && depth < 8; i++) Hierarchy(t.GetChild(i), depth + 1, text, ref nodes);
        }

        private static string Components(GameObject go)
        {
            var parts = new List<string>();
            foreach (Component c in go.GetComponents<Component>())
            {
                if (c == null) { parts.Add("<missing>"); continue; }
                string name = c.GetType().Name;
                if (c is Collider2D col) name += "(enabled=" + col.enabled + ",trigger=" + col.isTrigger + ")";
                else if (c is Behaviour b) name += b.enabled ? "" : "(disabled)";
                if (c.GetType().FullName == "PlayMakerFSM") name += "[" + Str(Get(c, "FsmName")) + "]";
                parts.Add(name);
            }
            return string.Join(", ", parts.ToArray());
        }

        private static List<Component> Fsms(GameObject go, bool children)
        {
            var result = new List<Component>();
            foreach (Component c in children ? go.GetComponentsInChildren<Component>(true) : go.GetComponents<Component>())
                if (c != null && c.GetType().FullName == "PlayMakerFSM") result.Add(c);
            return result;
        }

        private void Track(Component fsm)
        {
            if (!trackedIds.Add(fsm.GetInstanceID())) return;
            tracked.Add(new Tracked { Fsm = fsm, Label = PathOf(fsm.transform) + " [" + Str(Get(fsm, "FsmName")) + "]", Last = ActiveState(fsm) });
        }

        private string ActiveState(Component fsm)
        {
            Type type = fsm.GetType();
            if (!activeState.TryGetValue(type, out PropertyInfo? p)) activeState[type] = p = type.GetProperty("ActiveStateName");
            return p == null ? "?" : Str(Safe(() => p.GetValue(fsm, null)));
        }

        private static string PathOf(Transform t)
        {
            string path = t.name;
            for (Transform? p = t.parent; p != null; p = p.parent) path = p.name + "/" + path;
            return path;
        }

        private static object? Get(object target, string name)
        {
            const BindingFlags flags = BindingFlags.Public | BindingFlags.Instance;
            Type type = target.GetType();
            PropertyInfo? p = type.GetProperty(name, flags);
            if (p != null && p.GetIndexParameters().Length == 0) return Safe(() => p.GetValue(target, null));
            FieldInfo? f = type.GetField(name, flags);
            return f == null ? null : Safe(() => f.GetValue(target));
        }

        private static object? Safe(Func<object?> read)
        {
            try { return read(); }
            catch (Exception error) { return "<error " + (error.InnerException ?? error).GetType().Name + ">"; }
        }

        private static string Str(object? value) => value == null ? "null" : Convert.ToString(value, CultureInfo.InvariantCulture) ?? "";
        private static string Safe(string name) { string s = Unsafe.Replace(name, "_").Trim('_'); return s.Length == 0 ? "unnamed" : s.Length > 80 ? s.Substring(0, 80) : s; }
        private static string Stamp() => Time.time.ToString("F3", CultureInfo.InvariantCulture) + "\t" + UnitySceneManager.GetActiveScene().name;

        private void Append(string line)
        {
            if (traceBytes > TraceLimit) return;
            trace.AppendLine(line);
            traceBytes += line.Length + 2;
            if (traceBytes > TraceLimit) trace.AppendLine("# trace size limit reached; later events are not recorded");
        }

        private void Flush()
        {
            lastFlush = Time.realtimeSinceStartup;
            if (trace.Length == 0) return;
            string text = trace.ToString(); trace.Length = 0;
            Guard("write", () => File.AppendAllText(tracePath, text, Encoding.UTF8));
        }

        // Diagnostics must never disable gameplay; report each failure kind once.
        private void Guard(string kind, Action action)
        {
            try { action(); }
            catch (Exception error) { if (reported.Add(kind)) logError("Enemy FSM dump " + kind + " failed (diagnostic only): " + error); }
        }

        public void Dispose()
        {
            if (disposed) return;
            On.HealthManager.Start -= HealthStart;
            On.HealthManager.Hit -= HealthHit;
            UnitySceneManager.activeSceneChanged -= SceneChanged;
            Flush();
            disposed = true;
            tracked.Clear();
            if (pump != null) UnityEngine.Object.Destroy(pump);
        }
    }

    internal sealed class EnemyFsmDumpPump : MonoBehaviour
    {
        internal Action? Tick;
        private void Update() { Tick?.Invoke(); }
    }
}
