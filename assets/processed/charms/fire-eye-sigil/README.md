# Fire Eye Sigil artwork

Original generated with the approved bundled imagegen CLI, model
`gpt-image-2.5-flare`, quality high, size1024x1024, PNG. No native charm art or
existing character textures were overwritten.

- Original: `output/imagegen/fire-eye-sigil-v1.png` (repository root).
- Exact prompt: `.trellis/tasks/10-27-fire-eye-charm/research/icon-prompt.txt`.
- Reprocess: `.tools/python/bin/python tools/prepare_charm_icon.py output/imagegen/fire-eye-sigil-v1.png`.
- `icon.png`:256x256 RGBA, transparent outer padding, embedded as
  `WukongKnight.FireEyeSigil.png`; only this image enters the Mod DLL.
- `preview.png`: dark/light comparisons at256/96/64px; reviewed for readable
  flame/eye silhouette and clean outer transparency.
- `manifest.json`: source/final SHA256, crop and offline processing parameters.

Offline rerun produced the same hashes and preserved the generated original.
Native inventory/pickup rendering remains a client acceptance check. Public
preview URLs and verified HTTP/byte evidence are recorded in the active task's
`research/public-preview.json`; temporary hosting is separate from the package.
