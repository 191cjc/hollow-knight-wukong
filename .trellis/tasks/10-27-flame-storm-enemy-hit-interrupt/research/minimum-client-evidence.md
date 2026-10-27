# Research: Minimum client evidence without sharing game assets

- Query: Do the previously identified FSM viewers document exporting only one enemy's states/actions/transitions as text or JSON on the user's own computer?
- Scope: one focused README/source-description check; no exporter implementation, game assets, product changes or additional dataset survey.
- Date: 2026-10-27

## Findings

**No verified single-enemy text/JSON export procedure is documented in the inspected READMEs.** Do not tell the user to click an invented export menu or run an unverified command.

| Verified source | What it actually documents |
| --- | --- |
| [HollowKnightFSMView README](https://github.com/nesrak1/HollowKnightFSMView/blob/db8084407ff1fa33d256f91614299011bbeb1f9c/README.md) | Viewing Hollow Knight PlayMaker FSMs and downloading the viewer. Its “Export a cldb” link concerns a **Unity type/class database**, not an enemy's graph/actions export. |
| [FSMViewAvalonia README](https://github.com/nesrak1/FSMViewAvalonia/blob/64ed6606db90f0a602d2682f44f8385fcc7be8c6/README.md) | Describes the viewer port and points to FSMExpress. No export steps. The earlier-read `Json/JsonDataProvider.cs` accepts supplied JSON; it establishes an input reader, not an export command or user interface. |
| [FSMExpress default-branch README](https://github.com/nesrak1/FSMExpress/blob/master/readme.md) | Describes a rewrite of FSMViewAvalonia, shows a screenshot and links Windows/Ubuntu downloads. **No text/JSON export steps.** Exact README blob SHA from GitHub Contents API: `8766186fc4e8c194c9d3a9fa5e8316e0fbb95fa8`. |

FSMViewAvalonia's linked FSMExpress `skong` reference returned 404 at the GitHub commit endpoint. The same focused README check then retrieved FSMExpress's default README through `https://api.github.com/repos/nesrak1/FSMExpress/readme`; its actual filename is lowercase `readme.md`. That fallback still supplied no export instructions. This is not a claim that those tools lack any undocumented export capability.

### Concrete minimum information for resumption

The game directory itself is not necessary **if equivalent complete target data can be supplied as plain text or an existing dump**. The following is the data contract to extract or transcribe locally; it is not a claim that the tools provide a particular export UI:

1. Exact game version, scene, enemy GameObject path and FSM name; specify the original game enemy rather than a randomizer-modified one.
2. For **Electric Mage**: every original action in `Electric Mage / Gen` with its serialized fields, the `END` transition's actual destination, and that destination's full cleanup/recovery chain until the normal default/attack-selection state. Include generated attack-object references and the FSMs/controllers responsible for stopping them.
3. Alternatively, for **Super Spitter**: complete original `spitter / Fire` and `Distance Fly` actions and outgoing transitions, firing/animation callbacks, projectile ownership references, and the actual normal exit/cleanup path. A list of those two state names is insufficient.
4. Include relevant child attack objects/colliders and any transition/action that controls their activation, plus the death/disabled/hidden states that must take precedence. Full target-FSM text is preferable when identifying the relevant chain would otherwise require guessing.

This small textual evidence could permit review and a narrow adapter without sharing textures, scenes, assemblies or the entire game folder. Obtaining evidence alone does **not** deliver the feature: a real target still needs a compatible cancellation implementation and validation that its interrupted attack stops and normal behavior resumes.

### Saved evidence / related files

- `/tmp/wukong-default-behavior-full-evidence-20261027/fsmview-old-readme.json`, `fsmview-new-readme.json`, `fsmview-data-loader.json`: previously fetched exact source text and URLs.
- `/tmp/wukong-default-behavior-full-evidence-20261027/fsmexpress-readme-default.json`: default README, GitHub source URL, blob SHA and exact text from this check.
- `research/default-behavior-full-evidence.md`: why current public-source clues do not establish a complete enabled adapter.
- `.trellis/spec/backend/native-combat.md`: actual native FSM/client compatibility remains distinct from compilation and structural matching.

## Caveats / Not Found

- No verified local single-FSM exporter steps were found. This report does not assert that an undocumented export function exists or does not exist.
- No tool was installed or executed against a client; compatibility of the linked viewer builds with the user's installation was not tested.
