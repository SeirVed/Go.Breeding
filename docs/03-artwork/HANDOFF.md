# Handoff — Artwork

[Area index](README.md) · [All areas](../README.md)

**Snapshot:** 2026-09-28, based on repository `b7bb9bc`, source inspection and existing documentation. No new gameplay or visual validation was performed for this handoff. Recheck the current checkout before acting.

**Start:** read [AGENTS.md](../../AGENTS.md), this handoff and the linked references. The user's new request determines scope and mode; suggested next steps below are not an instruction to begin implementation. Keep this handoff current when the area changes.

## Purpose

Produce consistent, appealing emoji/storybook characters and environments that remain practical to edit and animate. Visual fidelity and character appeal are acceptance criteria in their own right.

## Read first

- [Art direction](art_style.md), [production groups](art_production_groups.md), [appearance system](appearance_system.md).
- [Dummy catalog contract](crash_dummy_parts.md), [runtime artwork contract](../04-animation-rig-studio/paper_doll_parts.md).
- [Artwork bindings](../../data/paper_doll_artwork.json), [offline storage policy](../../art/offline/README.md).

## Current state

Human Zero is a fourteen-piece runtime draft, not final player art. Generic crash-dummy masters and species/face studies remain offline. Production groups cover Core, Face & Expression, form variants, species features, secondary forms, extensions, alternate foundations, presentation and unusual instances. A catalog definition does not mean artwork exists.

The current concept-to-modular-SVG workflow is under review. Recent facial studies passed some technical checks but did not earn owner approval. Do not promote a study or resume incremental facial repairs based only on earlier success language. On the owner's machine, read `docs/10-research-experiments/private/svg-process-reset.md` for the latest correction and actual reference paths. If unavailable, state the missing context rather than treating the work as approved.

## Preserve and clarify

Use compact proportions, strong silhouettes, restrained shading and deliberate expressions; richer promotional art does not set the runtime detail budget. A three-quarter face is allowed. SVG masters must remain individually editable, with raster atlases derived from them. Complete hidden surfaces must support animation, while reassembly retains the approved design. Rig geometry is invisible in ordinary play.

## Suggested next task and acceptance

Discuss the conversion process using the original concept and assembled study side by side. Reassess method and fidelity before adding variants or rig controls. The owner's current art direction is a process brainstorm, not permission to lock Candidate 23. Agree a bounded trial and visual criteria; judge the assembled character at intended display sizes as well as inspecting individual pieces. Coordinate pivots and layer contracts with Animation. Keep unapproved media local.
