# Breeding Animation Matrix

> **Status: board UI and placeholder implemented; custom scripts planned.** The 243-cell tracker exists. All commission progress is currently 0%, and `Emoji Bonk v0` is the only playable breeding-action animation.

This document crystallizes the reusable body-pair model recovered from the project archive.

## Base silhouettes

Every ordinary species maps to one of nine body silhouettes:

| Size / Morph | Feral | Neutral (formerly Regular) | Refined |
|---|---|---|---|
| Small | Feral familiar / beast | Demi-beast scout | Compact humanoid |
| Medium | Hunter / primal form | Classic demi-human | Humanlike mage |
| Large | Apex beast / brute | Demi-beast tank | Noble giant / humanoid apex |

The primary dimensions are:

- **Size:** Small (1.2–1.5 m), Medium (1.5–1.8 m), Large (1.8–2.4 m+).
- **Morphology:** Feral, Neutral, Refined.

The old term **Regular** became **Neutral** in the maintained design documents. “Pure” is not an established band; **Refined** is the intended animal-to-humanoid end of the axis.

## Pair-script target count

Each pairing board contains 81 ordered targets:

`9 × 9 = 81 per board`

There are three boards:

- **Jack & Jill:** male archetypes × female archetypes.
- **Jack & Jack:** male Role A × male Role B.
- **Jill & Jill:** female Role A × female Role B.

The full production tracker therefore contains `81 × 3 = 243` directional commissions. On every board, the upper triangle (including the diagonal) is labelled **Regular** and the lower triangle is labelled **Inverted**. Every square is a real target; the lower half is not a mirrored duplicate.

For example, `Small Neutral > Large Neutral` is distinct from `Large Neutral > Small Neutral`. The two couplings can require different reach, leverage, alignment, weight support, staging, and transition work—the same broad distinction as a four-foot man with a seven-foot woman versus a four-foot woman with a seven-foot man.

The archetype names describe the male-frame and female-frame biomechanics used by this production board. Species, identity, pose, and personality-specific choreography can still be authored as variants within the relevant directional cell.

## Archetype names

| Body type | Male | Female |
|---|---|---|
| Small Feral | Scrapper | Wildling |
| Small Neutral | Scout | Courier |
| Small Refined | Squire | Maiden |
| Medium Feral | Prowler | Huntress |
| Medium Neutral | Strider | Ranger |
| Medium Refined | Gallant | Dame |
| Large Feral | Brute | Diremother |
| Large Neutral | Titan | Matron |
| Large Refined | Regent | Sovereign |

The production goal is at least one authored variant in every cell. No procedural choreography exists yet. Until real animation work is funded and authored, every cell truthfully reports **PLACEHOLDER ACTIVE** and previews `Emoji Bonk v0`: the two text emoji collide, bounce over one another, swap places, and emit `💦`, `💥`, and `💨`.

These 243 targets are an ordered **body-template** matrix, not a species-pair matrix. The creature registry is open-ended. Adding a monster maps it to stable archetype and anatomy metadata; it does not create a fixed roster cap or require a new square against every existing monster. Bespoke species variants may be added indefinitely.

## Planned procedural dimensions

- Size controls actor scale, reach, anchor spacing, and vertical offset.
- Feral/Neutral/Refined controls posture and pose offset.
- Neotenous/Peramorphous controls proportion, stride, and playback speed.
- Element and Genetic Stability control palette, particles, shader noise, and other VFX.
- Species controls paper-doll parts, materials, sockets, and additive flavor animation.

These values should not multiply the base script count.

The planned best-fit resolver and fallback ladder are specified in [Paired Paper-Doll Animation Pipeline](animation_pipeline.md). The player prioritisation system is specified in [Dev Metrics: Guild Star Ballot](dev_metrics.md).

## Exception tags

- **Bestial:** quadrupedal stance or extended torso.
- **Exotic:** slime, serpentine, floating, or otherwise non-humanoid core.
- **Winged:** upper-back mass and wing-clearance requirements.
- **Tauric:** dual-body or multi-limbed lower anatomy.

Tags are intended to modify or override future choreography. They do not create new top-level silhouette families unless production testing proves that a separate rig is necessary.

## Implementation sources

- `data/breeding_script_progress.json`: the read-only 243-cell board configuration, archetype registry, mixed-pair coupling briefs, and progress values.
- `data/species_body_map.json`: default body type and exception tags for all roster entries.
- `scripts/pairing_progress.gd`: board progress calculations and body-pair planning metadata.
- `scripts/breeding_engine.gd`: offspring generation and pairing-plan attachment.
