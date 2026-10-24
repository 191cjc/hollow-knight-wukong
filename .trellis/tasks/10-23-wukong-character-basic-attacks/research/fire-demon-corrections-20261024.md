# Fire Demon corrections (0.4.1-dev)

User requirements: body invisible before the last strike, full-cast damage
immunity, and a hero-centered start instead of the forward spawn offset.

Changes are scoped to the existing Fire Demon cast: presenter suppression during
air/dive, a token-owned finisher transition in SpellHitLedger, hero damage guards
in the existing runtime hook owner, and effect registration in FireDemonSlash /
CharacterAssets. Existing assets remain preserved; no rebake or reach/size change
is required. Damage amounts/caps/cooldown remain unchanged.

`BeginFinisher(token)` reveals only the owned cast while Active remains true for
its full immunity interval. Cancellation/completion clears hiding/protection;
late finisher/stop calls cannot affect a new token. Air callbacks cannot continue
after the finisher transition. The native body remains suppressed separately.

Native HeroController.TakeDamage IL was inspected. Its alternate invulnerable
branch still handles spike/acid HP loss, so guarding CanTakeDamage alone would
not meet the request. Runtime wraps actual TakeDamage and TakeHealth signatures,
observing the current spell state at each entry; original dispatch resumes as
soon as this cast ends/cancels/detaches. No invulnerability/save flag is changed.

Air overlap center is captured from native hero collider bounds at effect spawn,
independent of facing. Old +/-177,+95 offset removed. Sprite registration
subtracts the source mask center times offline ArtworkScale, allowing artwork
and original-sized damage geometry to share this world anchor. No runtime
appearance enlargement is added.

Checks: 36 Python passed / 1 Windows symlink privilege skip; 20 production C#
core checks; warnings-as-errors Release compilation; actual 0.4.1 atlas-derived
preview reviewed. Installed 24-file closure/hashes checked. Native gameplay
acceptance remains pending, especially immunity expiry/spikes/acid and left/right
centering. Existing task remains in_progress; downloaded checkout has no .git.

ZIP SHA256: `8d2698dd09a604da6e7e0fe99338bc7af7ddacaa52bc6ff11f640eba7a16d36f`.
DLL SHA256: `9cde19cf685a2452be6e9c8928c88f8e2419203dc99609766a2812c0f876581c`.
Installed 2026-10-24 00:32:07 +08:00 with game stopped. Complete prior Mod backup:
enclosing `work/backups/installed-WukongKnight-before-0.4.1-20261024-003207.zip`.
No API/save modifications. Exact evidence is in `artifacts/build-report.json`.
