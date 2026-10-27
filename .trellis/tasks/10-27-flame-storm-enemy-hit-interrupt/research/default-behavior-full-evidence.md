# Research: Complete native default-behavior cancellation evidence

- Query: Obtain a complete original Electric Mage FSM showing `Gen` / `END`, cleanup and return behavior, or the original Super Spitter `Fire` → `Distance Fly` exit contract.
- Scope: bounded external public-source search and inspection; no product edits, game downloads or implementation changes.
- Date: 2026-10-27

## Findings

**No complete original graph or complete controller reproduction was obtained.** Neither candidate can be promoted to an enabled adapter on the evidence in this pass. This is a negative result within the sources/access paths below, not proof that no public dump exists anywhere.

No new enemy shortlist is introduced. Earlier state-name/mod-patch evidence remains in `default-behavior-candidates.md`; this investigation specifically sought the missing **full transitions/actions**, without treating another patch as that proof.

### What was actually inspected

| Source / identifier | Inspection | Result |
| --- | --- | --- |
| [Kerr1291/ModCommon tree at supplied identifier `767a5b7c7a7e21a4d4179c69a635d2d0fcd1c6f4`](https://api.github.com/repos/Kerr1291/ModCommon/git/trees/767a5b7c7a7e21a4d4179c69a635d2d0fcd1c6f4?recursive=1) | Complete, non-truncated recursive tree; in particular `ModCommon/Components/StateMachines/Rewrites/`. | The rewrite directory contains Hornet and its effects/controllers, shiny items and Super Dash; **no Electric Mage or Spitter reproduction**. `ModCommon/Util/FsmUtil.cs` is utility code, not either target's native FSM. |
| [Kerr1291/EnemyRandomizer tree at supplied identifier `58b86f010e328494d1820c9d636951bd90bc7650`](https://api.github.com/repos/Kerr1291/EnemyRandomizer/git/trees/58b86f010e328494d1820c9d636951bd90bc7650?recursive=1) | Complete, non-truncated recursive tree; looked for serialized FSM datasets, target controllers and rewrite/dump paths beyond the already-read patches. | No full native FSM graph identified. Found generic spawner/FSM utilities and scene/object XML metadata; those are not original target state transition/action dumps. No additional modification snippet was accepted as complete evidence. |
| [nesrak1/HollowKnightFSMView tree `db8084407ff1fa33d256f91614299011bbeb1f9c`](https://github.com/nesrak1/HollowKnightFSMView/tree/db8084407ff1fa33d256f91614299011bbeb1f9c) | Complete repository tree plus [README](https://raw.githubusercontent.com/nesrak1/HollowKnightFSMView/db8084407ff1fa33d256f91614299011bbeb1f9c/README.md). | A **viewer/parser**, with `ActionReader.cs`, `FSMInstance.cs`, asset readers and type metadata. No bundled Electric Mage/Spitter graph. README links tool releases, a screenshot and generic class-database tooling; no target native dump. |
| [nesrak1/FSMViewAvalonia tree `64ed6606db90f0a602d2682f44f8385fcc7be8c6`](https://github.com/nesrak1/FSMViewAvalonia/tree/64ed6606db90f0a602d2682f44f8385fcc7be8c6) | Complete repository tree, [README](https://raw.githubusercontent.com/nesrak1/FSMViewAvalonia/64ed6606db90f0a602d2682f44f8385fcc7be8c6/README.md), `FSMViewAvalonia2/Json/JsonDataProvider.cs`. | Viewer/core loader code, not bundled game FSMs. `JsonDataProvider` lines 7–9 wraps a supplied JSON token and lines 25–28 read supplied keys; supporting JSON input does **not** provide a target JSON dataset. README points to subsequent FSMExpress tooling, without supplying the required graph. No further tool-chain survey was pursued. |
| [Clazex/HollowKnight.AlreadyEnoughPlayMaker tree `a2140598f83dda76b9f9b7250f1e150a2078c56e`](https://github.com/Clazex/HollowKnight.AlreadyEnoughPlayMaker/tree/a2140598f83dda76b9f9b7250f1e150a2078c56e) | Complete tree and README. | Optimization hooks, not target controllers or native FSM dumps. README requires `HKRefs` pointing to the user's game `Managed` folder; no target graph supplied. |

The `git/trees/HEAD` results above identify **Git tree objects**, not independently verified commit objects. Tree identifiers and stable raw content URLs are recorded without relabeling them as commits. The two supplied source identifiers were reused from the main investigation.

### Exact search attempts and access limits

- GitHub repository search, `https://api.github.com/search/repositories`, queries: `Hollow Knight FSM dump`, `HollowKnight FSM data`, `Hollow Knight Electric Mage`, `Hollow Knight spitter FSM` — each returned no repositories.
- Follow-up repository queries: `HollowKnight FSM` found the two viewers above, the PlayMaker optimization mod, and an unrelated Silksong memory probe; `"Hollow Knight" "data"` returned text/save/logic/achievement datasets; `"Hollow Knight" "dump"` returned sprite/logic dump tools; `hollowknight gamedata` returned none. No complete target graph was identified among the returned relevant sources.
- GitHub code search, `https://api.github.com/search/code`, query `"Electric Mage" "Gen"` — HTTP **401 Unauthorized**; no code-search result could be inspected without credentials.
- grep.app API exact phrase combinations `"Electric Mage" "Gen"`, `"Distance Fly" "Fire"`, `"Electric Mage" "END"` — HTTP **429 Too Many Requests** for all three; no search result obtained.
- Sourcegraph search stream queries `context:global "Electric Mage" "Gen"` and `context:global "Distance Fly" "Fire" "spitter"` — HTTP **403 Forbidden** for both; no search result obtained.
- No credentials were requested, no authentication or access-control bypass attempted, and no game/scene asset was downloaded.

### Remaining evidence that actually gates an enabled profile

For **Electric Mage**, the missing artifact is the original `Electric Mage` FSM's `Gen` state action list and outgoing `END` transition, the full target/recovery path, generated attack-object references/owners and cleanup, and allowed active states where interruption is safe. The existing mod's sending `END` before its own range check does not establish the destination or make it a universal event.

For **Super Spitter**, the missing artifact is the complete original `spitter` FSM: `Fire` actions and all transitions, any firing/animation event callbacks still active after exit, projectile creation/ownership, and the entry/exit and attack-selection behavior of `Distance Fly`. Knowing that the latter contains a `DistanceFly` action does not establish safe cancellation from `Fire`.

A useful next evidence source is a dump from the **actual compatible native client/prefab**, containing state names, all transitions, action type + fields and referenced child objects for one of those exact targets. That can enable one narrow adapter after review. A dispatcher/probe that always skips unknown structures remains infrastructure; it must not be reported as successful gameplay interruption of at least one enemy.

### Files saved

Read-only API responses, tree manifests, fetched tool README/loader contents and error audit records are under `/tmp/wukong-default-behavior-full-evidence-20261027/`:

- `repo-0.json` through `repo-3.json`: follow-up GitHub repository search responses; each stores its exact URL and query.
- `code-0.json`: GitHub code-search 401 audit.
- `Kerr1291-ModCommon-tree.json`, `Kerr1291-EnemyRandomizer-tree.json`: complete pinned-source tree responses.
- `nesrak1-HollowKnightFSMView-tree.json`, `nesrak1-FSMViewAvalonia-tree.json`, `Clazex-HollowKnight.AlreadyEnoughPlayMaker-tree.json`: complete tool repository trees.
- `fsmview-old-readme.json`, `fsmview-new-readme.json`, `fsmview-data-loader.json`, `alreadyenough-readme.json`: exact fetched text and source URLs.
- `sourcegraph-0.json`, `sourcegraph-1.json`: exact targeted query URLs and 403 results.

The initial four empty GitHub searches and the three grep.app 429 responses were inspected in tool output; they are listed above but do not have separate downloaded response files.

### Related specs and code

- `.trellis/spec/backend/native-combat.md`: actual client FSM acceptance, native damage rejection and synchronous ownership rechecks remain required.
- `research/default-behavior-candidates.md`: earlier candidate-specific partial evidence and its limitations.
- `src/WukongKnight/FlameStorm.cs:88`, `src/WukongKnight/NativeV77.cs:181`: current contact/native damage boundary; no new native control entry is established by this research.

## Caveats / Not Found

- No complete transition/action artifact obtained; **no new supported enemy** and no safe generic `END`, `CANCEL`, `Idle` or `Distance Fly` adapter established.
- Search-provider access limits prevent a claim of exhaustive global code search. Repository-name/description search cannot find every state string embedded in arbitrary repositories.
- No product code, tests, prior research files, plans, specs, task lifecycle or git state changed by this investigation.
