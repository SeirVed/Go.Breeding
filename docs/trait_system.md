# Trait System

## Visible axes (4)
1) **Feral ↔ Refined** (−1…+1, banded): morphology & behavior silhouette.
2) **Neotenous ↔ Peramorphous** (−1…+1, banded): growth curve & maturity.
3) **Elemental Affinity** (categorical): Earth, Wind, Fire, Water, Light, Dark.
4) **Genetic Stability** (−1…+1): mutation variance vs. lineage viability.

> Banded visuals for 2D: 5 feral bands × 4 development bands × 6 elements. Stability is visualized (shader/FX), not a separate sprite set.

## Invisible traits (no negatives)
- **Breeding Efficiency**: fertility_factor, gestation_efficiency, growth_acceleration, breeding_xp_bonus.
- **Transmission/Mutation**: gene_lock, mutation_flux, trait_rarity_bias.
- **Stat Potential**: stat_ceiling_amp, inheritance_efficiency, training_responsiveness, specialization_bias.
- **Health/Longevity**: germline_integrity, senescence_delay, cross_compat_bias.

All start at **0.0** (neutral). Stack with diminishing returns; cap typically 0.15–0.30.

## Species‑exclusive / Gated / Environmental traits
- **Species‑exclusive** require lateral transfer via crossbreeding to express in other species.
- **Gated** require facilities/story to activate (e.g., Gene Lock at Genetics Lab L3).
- **Environmental** activate when bred/gestated under conditions (biome, reagent).

## Inheritance philosophy
- Visible axes: weighted average + small drift (deterministic per seed).
- Invisible traits: dominance / additive with soft caps; some may require unlocks to manifest.
