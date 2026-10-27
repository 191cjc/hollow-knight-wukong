using System.Reflection;
#if NETFRAMEWORK
using System.Runtime.Serialization;
#else
using System.Runtime.CompilerServices;
using System.Runtime.Loader;
#endif
using System.Security.Cryptography;
using Mono.Cecil;
using Mono.Cecil.Cil;
using MonoMod.Cil;

var root = Path.GetFullPath(args[0]);
var proof = Path.GetFullPath(args[1]);
bool emit = args.Contains("--emit");
var paths = new[] {
    Path.Combine(root, ".tools/hollow-knight-api-v77"),
    Path.Combine(root, ".tools/unity-reference/lib/net45"),
    Path.Combine(root, "src/WukongKnight/bin/Release/net472")
};
#if NETFRAMEWORK
AppDomain.CurrentDomain.AssemblyResolve += (_, request) => {
    var name = new AssemblyName(request.Name);
#else
AssemblyLoadContext.Default.Resolving += (_, name) => {
#endif
    foreach (string path in paths) {
        string candidate = Path.Combine(path, name.Name + ".dll");
        if (File.Exists(candidate)) return Assembly.LoadFrom(candidate);
    }
    return null;
};
string productPath = Path.Combine(paths[2], "WukongKnight.dll");
Assembly product = Assembly.LoadFrom(productPath);
Type adapter = product.GetType("WukongKnight.NativeDashV77", true);
#if NETFRAMEWORK
object owner = FormatterServices.GetUninitializedObject(adapter);
#else
object owner = RuntimeHelpers.GetUninitializedObject(adapter);
#endif
Directory.CreateDirectory(proof);
using var hasher = SHA256.Create();
Console.WriteLine("Product SHA256 " + BitConverter.ToString(hasher.ComputeHash(File.ReadAllBytes(productPath))).Replace("-", "").ToLowerInvariant());
Console.WriteLine("Real references: " + typeof(ILContext).Assembly.Location + " ; " + typeof(ModuleDefinition).Assembly.Location);
Console.WriteLine("Mode: " + (emit ? "full emission attempt using real RuntimeILReferenceBag" : "production matcher boundary using real NopILReferenceBag"));

foreach (var seam in new[] { ("LookForQueueInput", "PatchInput"), ("Dash", "PatchDash"), ("OnCollisionEnter2D", "PatchLanding") }) {
    using var module = ModuleDefinition.ReadModule(Path.Combine(paths[0], "Assembly-CSharp.dll"));
    var hero = module.Types.Single(t => t.FullName == "HeroController");
    var method = hero.Methods.Single(m => m.Name == seam.Item1);
    string[] protectedCalls = seam.Item1 switch {
        "LookForQueueInput" => new[] { "HeroController::CanDash", "HeroController::HeroDash" },
        "Dash" => new[] { "HeroController::OrigDashVector", "Modding.ModHooks::DashVelocityChange", "UnityEngine.Rigidbody2D::set_velocity" },
        _ => new[] { "HeroController::FindCollisionDirection", "HeroController::DoHardLanding", "HeroController::BackOnGround", "HeroController::SetState" }
    };
    int CountCall(string needle) => method.Body.Instructions.Count(i =>
        (i.OpCode == OpCodes.Call || i.OpCode == OpCodes.Callvirt) &&
        i.Operand is MethodReference called && (called.DeclaringType.FullName + "::" + called.Name) == needle);
    var before = protectedCalls.ToDictionary(c => c, CountCall);
    var patch = adapter.GetMethod(seam.Item2, BindingFlags.Instance | BindingFlags.NonPublic)
        ?? throw new InvalidOperationException("Missing production patch " + seam.Item2);
    int oldCount = method.Body.Instructions.Count;
    using var context = new ILContext(method);
    // Never replace native/game types. Full emission uses the genuine runtime
    // bag; boundary mode deliberately keeps the genuine standalone Nop bag.
    if (emit) context.ReferenceBag = RuntimeILReferenceBag.Instance;
    int labels = 0;
    Exception blocked = null;
    context.Invoke(il => {
        labels = il.Body.Instructions.Count(i => i.Operand is ILLabel || i.Operand is ILLabel[]);
        if (labels == 0) throw new InvalidOperationException("Expected real Invoke label operands");
        try { patch.Invoke(owner, new object[] { il }); }
        catch (TargetInvocationException error) {
            var cause = error.InnerException ?? error;
            bool expected = !emit
                ? cause is NotSupportedException && cause.Message == "Inline references not supported in this context"
                : cause is TypeLoadException && cause.Message.Contains("PlayMaker");
            if (!expected || cause.StackTrace == null || !cause.StackTrace.Contains("EmitDelegate")) throw;
            blocked = cause;
        }
    });
    if (method.Body.Instructions.Any(i => i.Operand is ILLabel || i.Operand is ILLabel[]))
        throw new InvalidOperationException("Invoke did not resolve its labels");
    foreach (var call in before)
        if (CountCall(call.Key) != call.Value) throw new InvalidOperationException("Changed native call " + call.Key);
    if (method.Body.Instructions.Count <= oldCount) throw new InvalidOperationException("Production seam injected no IL");
    string mode = emit ? "emission" : "boundary";
    string file = Path.Combine(proof, seam.Item1 + "." + mode + ".txt");
    File.WriteAllLines(file, new[] { method.FullName }.Concat(method.Body.Instructions.Select(i => i.ToString())));
    if (blocked != null) File.WriteAllText(Path.Combine(proof, seam.Item1 + "." + mode + ".blocked.txt"), blocked.ToString());
    Console.WriteLine($"PASS {seam.Item2} production layout/matcher via real ILContext.Invoke: {labels} labeled branches, {oldCount}->{method.Body.Instructions.Count} instructions; native calls preserved " + string.Join(", ", before.Select(p => p.Key + "=" + p.Value)));
    Console.WriteLine(blocked == null ? "Full delegate emission completed." : "LIMIT: first EmitDelegate reached; complete injection was NOT verified: " + blocked.GetType().Name + ": " + blocked.Message);
}
Console.WriteLine("All three actual compiled patcher layout validators accepted genuine pinned method bodies with real MonoMod ILLabel operands. No Unity/game callback was invoked. Matcher evidence does not imply full hook installation or gameplay acceptance.");
