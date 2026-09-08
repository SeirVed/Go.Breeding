# Go.Breeding (godot-breeding)

**Working title:** `Go.Breeding` — a 2D, Godot-driven breeding sim focused on **systems-first genetics**, not VN-first presentation.

## High-level pitch
Breed, reroll, and evolve demi-species across four orthogonal trait axes. Unlock new species via **readable evolutionary conditions** (e.g., `Cow + Feral + STR ≥ 120 → Minotaur`). Content is data-driven so new species, traits, and evolutions can be added without engine rewrites.

## What makes it different
- **Systems > Scenes**: Core loop and genetics come first; visuals are param-driven.
- **Deterministic genetics**: Same parents + same seed → same outcome.
- **Elemental ecology (4+2)**: Earth • Wind • Fire • Water • Light • Dark.
- **Lineage stability**: Push for extreme mutations and then stabilize or the line collapses.
- **No hybrids**: Offspring species is one parent; the other contributes traits/stats (readable + balanced).

## Repo layout
```
go.breeding/
├─ README.md
├─ docs/
│  ├─ design_vision.md
│  ├─ trait_system.md
│  ├─ species_list.md
│  ├─ breeding_logic.md
│  ├─ silhouettes.md
│  ├─ invisible_traits.md
│  ├─ unlock_paths.md
│  ├─ dev_map.md
│  └─ appearance_system.md
├─ project.godot      # Godot 4.7 project entry point
├─ scenes/            # Scene files
├─ scripts/           # UI flow, persistence, and game state
└─ data/              # Data-driven location registry
```

See `/docs` for details. Phase 0 uses layered emoji composites; the param-driven art plan is specified so real assets can drop in later.

## Current build

**Version 0.2.4 — Jack, Jill & Bonk** expands the old-town commission board into three tabs—Jack & Jill, Jack & Jack, and Jill & Jill—for 243 directional animation commissions. Every unfinished commission honestly reports `PLACEHOLDER ACTIVE`. Pressing Breed now plays the deliberately silly, text-emoji `Emoji Bonk v0` sequence before revealing the deterministic offspring. Proper choreography has not been implemented yet. See [CHANGELOG.md](CHANGELOG.md) for the complete build history. Open this folder in Godot 4.7.2 or run `godot --path .`.
