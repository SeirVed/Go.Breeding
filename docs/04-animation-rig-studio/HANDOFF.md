# Handoff — Animation & Rig Studio

[Area index](README.md) · [All areas](../README.md)

**Snapshot:** 2026-09-28, based on repository `b7bb9bc`, source inspection and existing documentation. No new gameplay or visual validation was performed for this handoff. Recheck the current checkout before acting.

**Start:** read [AGENTS.md](../../AGENTS.md), this handoff and the linked references. The user's new request determines scope and mode; suggested next steps below are not an instruction to begin implementation. Keep this handoff current when the area changes.

## Purpose

Build reusable authoring and motion systems around invisible rigs with interchangeable artwork. Keep character construction separate from multi-actor animation editing.

## Read first

- [Rig Studio](rig_studio.md), [artwork contract](paper_doll_parts.md), [walk lab](paper_doll_walk_lab.md).
- [Animation architecture](parametric_choreography.md), [coverage rules](verb_storyboards.md), [selection plan](animation_pipeline.md).
- [Plugin source](../../addons/rig_studio), [runtime doll](../../scripts/paper_doll.gd), [studio data](../../data/paper_doll_studio.json).

## Current state

Rig Studio v0.3.1 is a custom Godot editor plugin. It has Single Builder with Add New/Default Template, multi-actor staging, exact heights, timed keys, Simple/Advanced controls, onion skins, multi-selection, Propagate, undo and guarded saving. Twenty-one motion verbs are defined; nine have body-motion prototypes. Compiled scene records are planning material, not authored runtime coverage.

Virtual contact sockets preserve an offset in another actor's two-anchor frame through translation, rotation and scale. They correct a point; they do not solve a limb chain. Chained/cyclic constraints, support and collision solving, alternate skeleton implementations, the facial sub-rig and gameplay best-fit selection remain unfinished. Current gameplay uses the emoji placeholder.

## Preserve and clarify

Small is below four feet, Medium is around six feet with exact variation, and Large is eight feet or above. The Catgirl test identity is five feet five inches. Size is independent of species art. Directional A/B roles matter. Hidden runtime rigs, the one emergency-art path and the distinction between a declared topology and an implemented skeleton must survive changes.

## Suggested next task and acceptance

Choose one concrete editor or runtime capability from the current request. The existing contact prototype could support a bounded limb-IK task; facial controls depend on agreed art/mount contracts. Neither is automatically selected by this handoff. Validate transforms, undo, save/reload and existing motion behaviour. Run the documented build checks for implementation changes. Never increase commission completion merely because a plan compiles or an editor preview moves.
