# Handoff — UI & UX

[Area index](README.md) · [All areas](../README.md)

**Snapshot:** 2026-09-28, based on repository `b7bb9bc`, source inspection and existing documentation. No new gameplay or visual validation was performed for this handoff. Recheck the current checkout before acting.

**Start:** read [AGENTS.md](../../AGENTS.md), this handoff and the linked references. The user's new request determines scope and mode; suggested next steps below are not an instruction to begin implementation. Keep this handoff current when the area changes.

## Purpose

Make the game and its developer tools easy to navigate, with readable state and honest feedback about unfinished features.

## Read first

- [Main UI implementation](../../scripts/main.gd), [main scene](../../scenes/main.tscn), [state/settings](../../scripts/game_state.gd).
- [Board definitions](../04-animation-rig-studio/breeding_animation_matrix.md), [progress data](../../data/breeding_script_progress.json).
- [Planned ballot](../09-release-business/dev_metrics.md).

## Current state

Most UI is built programmatically in `scripts/main.gd`. Main menu, three save slots, intro, map/location screens, options, Gallery/Dev Progress and breeding result screens exist as prototypes. Developer progress includes overview, commission, character and animation views. The world map is still draft content with example controls.

Commission presentation uses an old-town notice board with named axes, paper cells, emoji pairs, tooltips and detail notices. There are three directional boards: Jack & Jill, Jack & Jack and Jill & Jill. Progress is a developer record, not a gameplay completion checklist.

## Preserve and clarify

Show `PLACEHOLDER ACTIVE` for unfinished presentation. Do not imply that a procedural fallback, authored scene or voting backend exists. Emoji composites should read as one character rather than a long text string. Prototype layout is adjustable. Accessibility and smaller-screen support require review; they are not established by desktop screenshots.

## Suggested next task and acceptance

Pick one screen and define its user journey before polishing it. Check navigation/back behaviour, selected state, disabled actions, text readability, resizing and save feedback. A GUI mockup is input for interpretation, not an immutable layout. Coordinate gameplay effects with Gameplay, ballot implementation with Release/Technical Foundations and Rig Studio controls with Animation. Avoid cosmetic reorganisation of the entire UI during a focused task.
