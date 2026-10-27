# Real MonoMod matcher boundary audit

This audit runs the actual private PatchInput/PatchDash/PatchLanding from the
final production DLL against genuine pinned Assembly-CSharp method bodies,
inside the actual pinned MonoMod ILContext.Invoke. It never invokes a Unity or
game callback, constructs a HeroController, installs a live detour, or supplies
replacement engine/game classes. An uninitialized adapter is used only as the
target of its layout/emission methods; no adapter gameplay callbacks execute.

All three native layout validators passed with wrapped ILLabel operands.
Input/dash/landing saw41/1/25 labeled branches. The emitted textual IL files are
**partial** bodies up to the first EmitDelegate, not executable patched methods.
Native call counts and label restoration are asserted after Invoke returns.

- boundary.log: real standalone NopILReferenceBag deliberately rejects inline
  references. This gives a deterministic production matcher boundary check.
- emission.log: real RuntimeILReferenceBag progresses further, then cannot load
  the genuine HeroController.normalSlashFsm field because PlayMaker.dll1.6.0.0
  is absent from the compile-reference bundle. Complete injection is unverified.
- Each blocked.txt preserves the original exception stack, including the actual
  production patcher and MonoMod ILCursor.EmitDelegate frames.

Product DLL SHA256:
11c2e94339e4721ab0f5d12ddab4dc306260d52ca1a23944505685234c03cf54.

The isolated audit tool builds with0warnings/0errors. It used Mono-sgen6.8.0.105,
genuine MonoMod/Cecil binaries from .tools/hollow-knight-api-v77 and genuine
.NET SDK net461 facade DLLs for the runtime-bag attempt. No dependency was faked.

Reproduce from the repository root, with Mono runtime and pinned toolchain ready:

```bash
.tools/dotnet/dotnet build .trellis/tasks/10-27-fire-eye-charm/research/awakening-il-smoke/review.csproj -f net472 -c Release
/usr/bin/mono-sgen .trellis/tasks/10-27-fire-eye-charm/research/awakening-il-smoke/bin/Release/net472/review.exe "$PWD" "$PWD/.trellis/tasks/10-27-fire-eye-charm/research/awakening-il-smoke"
MONO_PATH="$PWD/.tools/dotnet/sdk/10.0.402/Microsoft/Microsoft.NET.Build.Extensions/net461/lib" /usr/bin/mono-sgen .trellis/tasks/10-27-fire-eye-charm/research/awakening-il-smoke/bin/Release/net472/review.exe "$PWD" "$PWD/.trellis/tasks/10-27-fire-eye-charm/research/awakening-il-smoke" --emit
```

The tool reports LIMIT for the emission boundary and does not call it a full
smoke pass. Actual-client acceptance remains pending (runtime_tested=false).

Saved exception text has trailing spaces removed; exception messages, frames and
IL contents are unchanged.
