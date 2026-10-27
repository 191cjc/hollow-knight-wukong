# Research: Attack cancellation and return to default behavior

- Query: Find 1–3 concrete ordinary-enemy or boss layouts for canceling the current attack and returning to that enemy's own walking, flying or idle behavior, without inventing a support whitelist.
- Scope: internal inspection of previously downloaded public EnemyRandomizer source at commit `58b86f010e328494d1820c9d636951bd90bc7650`; no new network research and no product-code changes.
- Date: 2026-10-27

## Findings

### Deliverable boundary

The six downloaded enemy-source files contain useful exact state/action clues, but **no inspected example proves the complete original attack-cancel → cleanup → default-behavior contract**. They are randomizer patches, not full native FSM dumps. This research therefore adds **zero verified support profiles**.

The first two candidates below provide more than state-name guesses: identifiable native action types and object variables can be checked against a live FSM. They can seed a fail-closed structure inspector or a narrowly gated prototype after their original actions and transitions are read. They are insufficient to enable a production adapter solely because a state named `Idle` or `Distance Fly` exists. A structure match establishes the expected shape; it does not establish cleanup or recovery semantics by itself.

### 1. Super Spitter: own flying behavior has a concrete native action

- **Source identity:** `SuperSpitterControl`, `BasicFlyingEnemies.cs:309`; explicit FSM `spitter` at `:311`. This is the source prefab/controller identifier; its optional randomizer-created superboss form must not be confused with ordinary native support.
- **Default-behavior candidate:** `Distance Fly`, retrieved at `:413`; its native **`DistanceFly`** action is found by type at `:421`. The mod adjusts `distance`, `speedMax`, and `acceleration` (`:424`–434). Thus this is concrete flying behavior, not merely an `Idle` label.
- **Attack clue:** `Fire` is retrieved at `:451`; the original action is read and disabled at `:455`–456 and a replacement is inserted at the same location. `ConfigureFire()` calls the helper with indexes **11, 8, 1** at `:480`–482. These are **not a proven list of three native fire actions or a reliable fallback chain**: `didConfigDistanceShot` is set after the first successful call (`:446`–473), so later calls become no-ops; an exception exits to the catch enclosing the whole sequence.
- **Cleanup clue / gap:** the mod stores its created projectile in FSM GameObject variable **`Shot`** at `:538`; there is no demonstrated native `Cancel Fire` event, cleanup state, `Fire` exit action, or transition from `Fire` to `Distance Fly` in this excerpt. The shown projectile spawning is a **custom replacement**, not proof that an original pending projectile is owned or cleaned identically.
- **Prototype judgment:** best candidate for a **structure probe**: exact FSM name + `Distance Fly` + `DistanceFly` action + `Fire` + actual native firing action/transition inspection. Do not hardcode action index 11, or infer safe cancellation by jumping to `Distance Fly`. A prototype must separately establish stopping future shots, treatment of an already spawned `Shot`, and normal subsequent attack selection.
- **Evidence:** [BasicFlyingEnemies.cs:406](https://github.com/Kerr1291/EnemyRandomizer/blob/58b86f010e328494d1820c9d636951bd90bc7650/EnemyRandomizerDll/EnemyRandomizerDB/Library/Enemies/BasicFlyingEnemies.cs#L406), [attack patch:446](https://github.com/Kerr1291/EnemyRandomizer/blob/58b86f010e328494d1820c9d636951bd90bc7650/EnemyRandomizerDll/EnemyRandomizerDB/Library/Enemies/BasicFlyingEnemies.cs#L446), [Shot:538](https://github.com/Kerr1291/EnemyRandomizer/blob/58b86f010e328494d1820c9d636951bd90bc7650/EnemyRandomizerDll/EnemyRandomizerDB/Library/Enemies/BasicFlyingEnemies.cs#L538).

### 2. Royal guard / Kingsmould candidate: explicit idle timer and thrown-object ownership

- **Source identity:** misspelled class `RoyalGaurdControl`, `BasicEnemies.cs:1564`; explicit FSM **`Guard`** at `:1566`. Runtime/display-name mapping must still be checked on the actual native prefab.
- **Default-behavior candidate:** `Idle` contains a typed **`Wait` at index 2** (`:1604`–1605); `Wait` contains **`WaitRandom` at index 2** (`:1600`–1602). The mod changes these delays only for its custom elite form. The source therefore supplies a useful typed idle-structure clue, not the original timeout values or proof that `Idle` resets the body/attack collider.
- **Attack clue:** `Throw` contains an original **`CreateObject` action at index 0**, whose projectile prefab is read at `:1652`–1653. The mod disables/replaces it and stores a new instance in FSM GameObject variable **`Boomerang`** at `:1664`–1669.
- **Recovery/cleanup candidate:** state **`Throw Catch`** is retrieved at `:1707`; the mod inserts deletion of its tracked boomerang there at `:1708`–1719. A fallback **`CAUGHT`** event is added to `Throw` at `:1705`. These names identify where to inspect the original throw/catch flow.
- **Critical distinction:** the added timeout and object deletion are **randomizer cleanup**, not demonstrated original cleanup. The source does not show the original `CAUGHT` destination, `Throw Catch` exit, or a safe interruption of the separate melee/slash attack. `Run Speed` and `SlashStepSpeed` variables (`:1607`–1608) further show that resetting idle alone need not reset attack movement.
- **Prototype judgment:** useful structure-probe profile (`Guard`, `Idle/Wait`, `Throw/CreateObject`, `Boomerang`, `Throw Catch`, `CAUGHT` transition). Not enough evidence to support all attacks, or to jump from an arbitrary active attack directly into `Idle`. Inspect the original flow first; do not copy the elite/randomizer behavior or delete arbitrary unrelated projectiles.
- **Evidence:** [BasicEnemies.cs:1564](https://github.com/Kerr1291/EnemyRandomizer/blob/58b86f010e328494d1820c9d636951bd90bc7650/EnemyRandomizerDll/EnemyRandomizerDB/Library/Enemies/BasicEnemies.cs#L1564), [idle types:1600](https://github.com/Kerr1291/EnemyRandomizer/blob/58b86f010e328494d1820c9d636951bd90bc7650/EnemyRandomizerDll/EnemyRandomizerDB/Library/Enemies/BasicEnemies.cs#L1600), [throw:1648](https://github.com/Kerr1291/EnemyRandomizer/blob/58b86f010e328494d1820c9d636951bd90bc7650/EnemyRandomizerDll/EnemyRandomizerDB/Library/Enemies/BasicEnemies.cs#L1648), [catch:1704](https://github.com/Kerr1291/EnemyRandomizer/blob/58b86f010e328494d1820c9d636951bd90bc7650/EnemyRandomizerDll/EnemyRandomizerDB/Library/Enemies/BasicEnemies.cs#L1704).

### 3. Electric Mage: an actual abort-event clue, but no demonstrated destination

- **Source identity:** `ElectricMageControl`, `FixedFlyingEnemies.cs:260`; explicit FSM **`Electric Mage`** at `:262`.
- **Cancellation clue:** in original state **`Gen`**, the mod inserts an action at index 0 that sends **`END`** when the player is out of aggro range (`:292`–296). This is evidence of an expected event-based way to leave that state, rather than an invented global `CANCEL` message.
- **Default/cleanup gaps:** neither the destination of `Gen/END` nor its cleanup is present in this source. Other names are `Wake`, `Select Target`, `Init`, with a **`Teleport Point` Vector3** variable and `TELEPORT` event (`:275`–298). The `Select Target` body is itself replaced by the mod. These cannot be relabeled as a proven idle/fly return route.
- **Prototype judgment:** **state/event clue only**. A live graph inspector can test whether `Gen` actually has a valid `END` transition, then inspect its target and all actions for stopping beam/generation logic and returning to normal behavior. No directly usable adapter is established.
- **Evidence:** [FixedFlyingEnemies.cs:260](https://github.com/Kerr1291/EnemyRandomizer/blob/58b86f010e328494d1820c9d636951bd90bc7650/EnemyRandomizerDll/EnemyRandomizerDB/Library/Enemies/FixedFlyingEnemies.cs#L260), [Gen/END:292](https://github.com/Kerr1291/EnemyRandomizer/blob/58b86f010e328494d1820c9d636951bd90bc7650/EnemyRandomizerDll/EnemyRandomizerDB/Library/Enemies/FixedFlyingEnemies.cs#L292).

### Additional negative evidence relevant to planning

- Most common melee and flying enemies in `BasicEnemies.cs` / `BasicFlyingEnemies.cs` have empty `DefaultSpawnedEnemyControl` wrappers, including sentries, mantises, hoppers and mosquitoes. These wrappers expose **no** original attack/default graph. Their presence in the database cannot be turned into an interruption whitelist.
- `MossChargerControl` uses FSM `Mossy Control`, sends `CANCEL` only in `Hero Beyond?` when out of aggro range (`FixedEnemies.cs:417`–442). The source does not show its target state, charge cleanup, or permission to cancel a charge already underway. A local aiming-state cancellation event is not a universal attack-cancel API.
- `MimicSpiderControl` changes `Roof Jump?/ROOF SPIT` to `Idle` and skips transformation states into `Idle` (`BossEnemies.cs:160`–206). These are randomizer changes to an intro/attack-selection branch, not proof that a mid-charge/spit cancellation cleans movement, spawned hazards and colliders. No new boss support follows from this.

### Implication for the first implementation plan

The available evidence supports planning a dispatcher that only observes actual surviving-target HP loss, verifies a specific profile's exact native structure and allowed current attack state, and otherwise skips control changes. It also supports recording concise mismatch/inspection evidence so a real profile can be established. It does **not** currently support promising a nonempty list of safely interrupted enemies from these public-source clues alone.

If a first version must visibly interrupt at least one real enemy, the plan needs a concrete native-FSM inspection step before enabling that profile: discover one allowed attack exit, its cleanup, and the actual return path. This is a required acceptance prerequisite, not a claim that matching `Idle` names is enough. Do not silently count a framework that always skips as delivery of the user's requested gameplay behavior.

Whether existing projectiles remain in flight after canceling their owner's **current** attack is a separate behavior boundary. The supplied public excerpts do not establish a universal original policy; do not promise that every detached hazard disappears, or delete all enemy projectiles generically.

### Files found / related contracts

- `/tmp/wukong-hurt-feasibility-20261027/sources/Kerr1291/EnemyRandomizer/EnemyRandomizerDll/EnemyRandomizerDB/Library/Enemies/BasicFlyingEnemies.cs`: Super Spitter's typed flying action and firing patch; many ordinary flying wrappers contain no graph.
- `/tmp/wukong-hurt-feasibility-20261027/sources/Kerr1291/EnemyRandomizer/EnemyRandomizerDll/EnemyRandomizerDB/Library/Enemies/BasicEnemies.cs`: guard idle timer, projectile creation, catch state and randomizer-specific cleanup.
- `/tmp/wukong-hurt-feasibility-20261027/sources/Kerr1291/EnemyRandomizer/EnemyRandomizerDll/EnemyRandomizerDB/Library/Enemies/FixedFlyingEnemies.cs`: Electric Mage's local generation-end event.
- `research/force-walk-alternative.md`: no universal walking/default-state interface; returning to default is not an attack cooldown or stun duration.
- `.trellis/spec/backend/native-combat.md`: keep native target masks, damage rejection, death/phase handling, ownership rechecks and responder identity; actual client acceptance remains separate from compilation.
- `src/WukongKnight/FlameStorm.cs:88` and `src/WukongKnight/NativeV77.cs:181`: existing skill contact and native damage ownership boundaries remain applicable.

## Caveats / Not Found

- No original serialized FSM, native action list, attack transition destination, client run or successful interruption was obtained for these three candidates. No native scene or game asset was downloaded.
- Public source at the pinned mod commit is not itself a serialized-FSM contract for Hollow Knight `1.5.78.11833` / Modding API `v77`.
- No prior `Stun` candidate was re-researched. This report concerns attack cancellation and return to existing default behavior only.
