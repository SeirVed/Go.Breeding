# Appearance System (2D, Godot 4)

> **Status: planned creature-appearance architecture with an invisible-rig and editor-authoring prototype.** The main game still uses text emoji composites. Walk Lab has six pose profiles and image-part binding; the editor-only Rig Studio can assign draft cutouts. Gameplay uses one universal emergency silhouette until art is complete. There are no production creature cutouts, sprite atlases or paired retargeted animations yet.

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
- **Phase 0 (implemented prototype)**: layered, scaled text emoji composites and `Emoji Bonk v0`.
- **Phase 1**: one universal paired paper-doll template and reusable creature slots.
- **Phase 2**: size/morphology variants, additive idles, palette shader, and simple particles.
- **Phase 3**: exception-tag and ordered-archetype templates; minor bone scales where useful.
- **Long tail**: species-specific add-ons, bespoke pair variants, thumbnails, and codex cards.

## Performance notes
Single texture atlases per body part family; keep anchors consistent across species. Data-driven swaps support an open-ended creature registry rather than a fixed monster count. See [Paired Paper-Doll Animation Pipeline](animation_pipeline.md).
