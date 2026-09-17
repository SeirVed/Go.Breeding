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
- Pairing production studies: `data/pairing_production_records.json`
- What actually runs: scenes and scripts under `scenes/` and `scripts/`

When prose and runtime data disagree about the present build, runtime data and executable behaviour win; the documentation discrepancy is a bug.

## Design documents

- `design_vision.md` — project pillars, tone, and scope.
- `dev_map.md` — current milestone map with shipped/planned separation.
- `breeding_logic.md` — intended deterministic genetics and pairing rules.
- `trait_system.md`, `invisible_traits.md`, `unlock_paths.md` — genetics design specifications.
- `species_list.md` — curated examples; the runtime registry is not capped by it.
- `silhouettes.md`, `appearance_system.md` — body and rendering model.
- `art_style.md` — exploratory Soft Storybook Emoji visual grammar, scale tiers, and reusable generation template.
- `breeding_animation_matrix.md` — three directional 9×9 commission boards.
- `animation_pipeline.md` — best-fit paired paper-doll resolver and honest fallback ladder.
- `paper_doll_walk_lab.md` — implemented six-profile shared-rig locomotion vertical slice and iteration record.
- `paper_doll_parts.md` — invisible rig, clip-on image manifest, one emergency silhouette, Catgirl cutout plan, and production-part gates.
- `rig_studio.md` — custom Godot Rig Studio v0.2.0: Single Builder, Animation Editor, timed keys, onion skins, Propagate, verbs and current limits.
- `pairing_production_pipeline.md` — reusable source-to-output gates, group/name/type lookups, and reproducible production records.
- `anatomy_asset_library.md` — modular SFW/NSFW chest, pelvis, clothing, and presentation-profile architecture.
- `dev_metrics.md` — Guild Star Ballot, aggregates, privacy, and backend requirements.
- `license_decision.md` — adopted proprietary licensing decision and rationale.
- `distribution_model.md` — shared-code, separate-content SFW/NSFW release architecture.
- `build_checks.md` — repeatable source smoke test, clean private export, export audit, and exported-build smoke test.

## Current headline status

Version 0.2.4 contains the three 81-cell boards and the text-emoji `Emoji Bonk v0` breeding placeholder. No proper paired choreography, voting backend, live telemetry, or finished custom commission scripts exist yet.
