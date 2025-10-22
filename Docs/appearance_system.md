# Appearance System (2D, Godot 4)

## Philosophy
Param-driven paper‑doll with **bands** for Feral/Refined and Neotenous/Peramorphous, **palettes** for Elements, and **FX** for Stability.

## Node topology (Creature.tscn)
- `Skeleton2D` (optional for later)
- `Body/` Sprite2D slots: Base, Head, Ears, Tail, Arms, Legs, Addons (horns/claws/crest)
- `FX/` GPUParticles2D nodes: ElementAura, Footsteps, Breath
- `Anim` (AnimationPlayer/Tree)
- `Audio` (species SFX bank)

## Data
- `species.json` (family, allowed bands, sprite indices, sockets)
- `bands_feral.json` and `bands_dev.json` (toggle/morph presets)
- `palettes.tres` (element ramps)
- `vfx_kits/*.tres` (per element)

## Phase rollout
- **Phase 0**: static PNG placeholders; swap by band/element.
- **Phase 1**: additive idles + palette shader for elements; simple particles.
- **Phase 2**: Skeleton2D minor bone scales for proportion presets; more VFX.
- **Phase 3**: polish, species‑specific add‑ons, thumbnails/codex cards.

## Performance notes
Single texture atlases per body part family; keep anchors consistent across species. Data‑driven swaps for rapid iteration.
