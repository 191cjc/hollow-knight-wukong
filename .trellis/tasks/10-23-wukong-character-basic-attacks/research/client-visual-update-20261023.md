# Client Visual Update: 0.2.1-dev

The user requested a 1.25 multiplier relative to the current Wukong appearance, unchanged native body collision, and the original Knight slash effect on every grounded combo attack. The user explicitly asked to retain the original effect style.

Implementation changes only the replacement view's scale and keeps its feet on the native collider's lower bound. The HeroController transform and body colliders are not resized.

Each authored hit window already calls the selected native NailSlash.StartSlash. The missing visual was caused by immediately hiding its mesh, then hiding it again on every fixed update. Remove both suppression writes so the native animation, material, audio and charm variants run for every hit window. Keep the existing damage-window ownership, cancellation and native renderer cleanup. Stage three retains its two independent pulses.

Build version advances to 0.2.1-dev. Preserve the previous package and back up installed Mod files before updating them. No API/game DLL or save changes are needed.

Validation: run existing production combo-core tests, package/resource tests, warnings-as-errors Release compilation and ZIP closure checks. Actual visual size, all four slash arcs, cancellations and collision behavior still require a client gameplay check; successful initialization alone does not establish these outcomes.
