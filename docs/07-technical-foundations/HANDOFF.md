# Handoff — Technical Foundations

[Area index](README.md) · [All areas](../README.md)

**Snapshot:** 2026-09-28, based on repository `b7bb9bc`, source inspection and existing documentation. No new gameplay or visual validation was performed for this handoff. Recheck the current checkout before acting.

**Start:** read [AGENTS.md](../../AGENTS.md), this handoff and the linked references. The user's new request determines scope and mode; suggested next steps below are not an instruction to begin implementation. Keep this handoff current when the area changes.

## Purpose

Maintain a stable Godot/data foundation so content can expand without hard-coded creature counts or fragile editor/runtime coupling.

## Read first

- [Project configuration](../../project.godot), [game state](../../scripts/game_state.gd), [species loader](../../scripts/species_db.gd), [pairing progress](../../scripts/pairing_progress.gd).
- [Registries](../../data), [schemas](../../schemas), [repository guide](../00-project-hq/repository-guide.md).
- [Build procedure](../08-testing-builds/build_checks.md).

## Current state

The project declares game version 0.2.4, a Godot 4.7 feature level and the compatibility renderer. The documented pinned editor is 4.7.2. Autoloads are GameState, SpeciesDB and PairingProgress; the entry scene is `scenes/main.tscn`.

GameState writes three JSON slots under `user://saves` and settings under `user://settings.cfg`. Loading checks that parsed content is a dictionary; this is not a comprehensive schema-validation or migration system. Data registries, editor tooling and runtime are separate file groups. Documentation is excluded from imports/exports.

## Preserve and clarify

Use stable string IDs for persistent content; array position and display names are not identifiers. Preserve saves and authoring data. Rig Studio guards writes against external modifications, so coordinate changes while the editor is open. Secret files, local study media, private docs, builds and caches remain outside normal commits.

SFW/paid content profiles are an architectural intention; comprehensive package separation and future asset substitution must be verified before claiming enforcement. No live voting/account service exists.

## Suggested next task and acceptance

For persistence work, define a save-version and migration policy with valid, old, malformed and missing-content examples. For other work, begin at the relevant source contract rather than restructuring the whole project. Verify deterministic IDs, compatibility, failure behaviour and appropriate source/export checks. Tests must use isolated data or disabled persistence. Consult the user before any destructive migration of existing local records.
