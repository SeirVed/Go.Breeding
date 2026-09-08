# Breeding Logic

## Species selection (no hybrids)
Child species = weighted choice of **Parent A species** vs **Parent B species**.

```
biasA = 0.60*GP(A) + 0.20*tier(A) + 0.10*imprint(A) + 0.10*compat(A,B)
biasB = 0.60*GP(B) + 0.20*tier(B) + 0.10*imprint(B) + 0.10*compat(B,A)
P(species=A) = biasA / (biasA + biasB)
```
- **GP (Genome Pressure)** blends lineage_score (0.55), species_tier (0.30), training_delta^0.6 (0.10), facility_bonus (0.05). Clamp 0.1–2.0.
- **compat(i,j)**: 16×16 matrix with 3–5 bands (penalty/neutral/bonus).

## Stats/traits
- Start from chosen species baseline → blend inherited stats toward chosen parent curves with ± variance influenced by GP.
- Visible axes: weighted average + drift, bounded by species‑allowed bands.
- Invisible traits: dominance/additive; some require unlocks.

## Determinism
All rolls seed from:
```
seed = HMAC(season_key,
    user_key || lineage_hash_A || lineage_hash_B ||
    core_gene_hash_A || core_gene_hash_B ||
    training_delta_A || training_delta_B ||
    pairing_type || txn_id )
```
Same inputs → same result. Save‑scumming yields no new outcomes.

## Pairing rules
- **M×F**: natural offspring (subject to fertility/compat).
- **M×M / F×F**: no natural baby → produce **Gene‑Gel** (lab resource) + small bonding buffs.
- **Lab surrogacy / induced microgamete**: consumes Gene‑Gel and reagents; yields offspring with lower fertility/higher mutation variance.
- **Herm variants (rare)**: flexible roles with penalties; enable lab recipes.

## Elemental affinity
Categorical (Earth/Wind/Fire/Water/Light/Dark). Inherit from parents with environmental bias. Latent element possible; some evolutions require specific elements.

## Stability → viability
Stability ∈ [−1, +1]. Negative stability raises mutation variance but reduces generational viability (fertility drop-off). Crossing with positive stability corrects line at the cost of variance.
