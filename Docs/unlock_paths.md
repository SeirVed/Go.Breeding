# Species Unlock Paths (Evolution Conditions)

## Pattern types
1. **Stat Threshold** (readable; early-game)
2. **Trait Condition** (invisible trait + axis requirements)
3. **Cross‑Lineage** (requires lateral trait present)
4. **Environmental Trigger** (biome/reagent/facility)

## Examples (starter)
- **Minotaur** ← Cow + Feral ≥ 0.5 + STR ≥ 120
- **Dire Wolf** ← Wolf + Peramorphous ≥ 0.5 + Stability ≥ 0.3
- **Nekomata** ← Cat + Refined ≥ 0.8 + Neotenous ≥ 0.5
- **Dryad** ← Elf + Plant lineage present + Photosymbiosis trait
- **Toxic Ooze** ← Slime + Mutation Flux ≥ 0.25 bred in Polluted biome
- **Drakekin** ← Lizard + Fire element + Peramorphous ≥ 0.6
- **Dragon** ← Drakekin + Stability ≥ 0.5 + Elemental Mastery (Fire)
- **Hellhound** ← Dire Wolf + Dark element + Aggression trait
- **Cerberus** ← Hellhound + Light element + Gene Lock (stabilized)

## Design rules
- Provide **at least 2 distinct routes** to most mid/rare species.
- On near‑miss, produce variant offspring with a **codex hint** explaining which condition was short.
- Conditions are checked **deterministically** in the breeding result calculation (no hidden coin flips beyond required RNG).
