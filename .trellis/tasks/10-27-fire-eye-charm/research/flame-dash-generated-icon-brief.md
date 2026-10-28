# Flame Dash awakening charm — generation brief

User request: generate a suitable new charm image to replace the original skill
thumbnail used in 0.7.10. Match the visual language of the installed Fire Eye
charm, without copying its eye motif. Preserve the archived source skill icon,
the 0.7.10 processed icon, and the approved Fire Eye icon.

Status: generation pending. This session has no built-in image generation tool;
the process environment has no OPENAI_API_KEY. Do not claim an image exists or
replace the installed resource until a generated image has passed visual review.
The imagegen skill requires explicit user confirmation for the fallback API and
for gpt-image-1.5 (chosen because it supports real transparent output).

## Final generation prompt

Use case: stylized-concept
Asset type: one transparent PNG inventory charm for the Flame Dash: Awakening
ability in a Hollow Knight Wukong mod.
Primary request: create an original, compact, hand-painted 2D charm representing
a sudden burst of fiery movement, visually compatible with Hollow Knight's
collectible charm icons and the project's dark-and-ivory Fire Eye charm.
Subject: a swept, right-leaning orange-gold flame enclosed by a dark charcoal
charm body with an ivory outer rim. Two clean curved flame trails suggest a
fast dash. Subtle curled ivory tips may echo Wukong's headband without adding
a face, a character or lettering. Use the flame and dash silhouette as the
single focal point; do not use an eye motif.
Style: crisp organic black outlines, simple ivory shell shapes, restrained
painted shading, warm ember-red and golden-orange interior. Strong readable
silhouette and a few broad shapes that remain clear at 48 to 64 pixels.
Composition: a single centered isolated charm, roughly square overall footprint,
fully contained in the frame with 12 percent transparent padding on every side.
Background: true transparent alpha, including outside the charm silhouette.
Avoid: square card or background tile, UI frame, text, letters, numbers, watermark,
scenery, characters, excessive small details, scattered sparks, soft outer glow,
checkerboard drawn into the image, 3D photorealism, an eye symbol.

## Planned integration after generation

- Save the untouched generated original and this exact prompt in a new versioned
  source folder within the repository, separate from archived game artwork.
- Produce a separate processed icon folder through a reusable offline script.
  Crop only transparent outer padding, retain clean alpha and center registration,
  and prepare a 256 x 256 RGBA icon plus dark/light and small-size previews.
- Preserve the current 0.7.10 processed folder; update only the embedded Flame
  Dash icon input. Keep its logical resource name WukongKnight.FlameDashCharm.png.
- Confirm small-size readability, transparent borders, reproducible processing,
  embedded PNG byte equality and unchanged Fire Eye/character resource hashes.
- Build and package, back up and install while the game is closed, and verify
  installed hashes. DebugMod must remain disabled. No commit/push requested.
