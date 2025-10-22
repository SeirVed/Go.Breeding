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
└─ src/               # (empty; Godot project later)
```

See `/docs` for details. Phase 0 uses **static PNG placeholders**; the param-driven art plan is specified so real assets can drop in later.
