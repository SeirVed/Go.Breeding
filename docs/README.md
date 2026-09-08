# Documentation Index

This directory separates implemented behaviour from intended design. Status labels at the top of each document are part of the project transparency contract.

## Status vocabulary

- **Implemented:** present and testable in the current build.
- **Prototype:** present in a limited or temporary form.
- **Planned:** approved direction, not yet implemented.
- **Reference:** terminology or data-model guidance; not a completion claim.
- **Historical:** retained in `CHANGELOG.md` or `VERSION.md` as a record of what a release said at the time.

## Sources of truth

- Current shipped version: `VERSION.md`
- Release history and unreleased documentation changes: `CHANGELOG.md`
- Runtime creature registry: `data/species.json` (open-ended; count is a snapshot)
- Body mappings: `data/species_body_map.json`
- Commission-board configuration: `data/breeding_script_progress.json`
- What actually runs: scenes and scripts under `scenes/` and `scripts/`

When prose and runtime data disagree about the present build, runtime data and executable behaviour win; the documentation discrepancy is a bug.

## Design documents

- `design_vision.md` — project pillars, tone, and scope.
- `dev_map.md` — current milestone map with shipped/planned separation.
- `breeding_logic.md` — intended deterministic genetics and pairing rules.
- `trait_system.md`, `invisible_traits.md`, `unlock_paths.md` — genetics design specifications.
- `species_list.md` — curated examples; the runtime registry is not capped by it.
- `silhouettes.md`, `appearance_system.md` — body and rendering model.
- `breeding_animation_matrix.md` — three directional 9×9 commission boards.
- `animation_pipeline.md` — best-fit paired paper-doll resolver and honest fallback ladder.
- `dev_metrics.md` — Guild Star Ballot, aggregates, privacy, and backend requirements.
- `license_decision.md` — current no-license state and the pending GPL/AGPL recommendation.

## Current headline status

Version 0.2.4 contains the three 81-cell boards and the text-emoji `Emoji Bonk v0` breeding placeholder. No proper paired choreography, voting backend, live telemetry, or finished custom commission scripts exist yet.
