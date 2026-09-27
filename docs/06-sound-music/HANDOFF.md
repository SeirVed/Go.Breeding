# Handoff — Sound & Music

[Area index](README.md) · [All areas](../README.md)

**Snapshot:** 2026-09-28, based on repository `b7bb9bc`, source inspection and existing documentation. No new gameplay or visual validation was performed for this handoff. Recheck the current checkout before acting.

**Start:** read [AGENTS.md](../../AGENTS.md), this handoff and the linked references. The user's new request determines scope and mode; suggested next steps below are not an instruction to begin implementation. Keep this handoff current when the area changes.

## Purpose

Establish a coherent audio identity and useful feedback without making the interface noisy or repetitive.

## Read first

- [Design vision](../00-project-hq/design_vision.md).
- [Options screen](../../scripts/main.gd): `show_options` and `set_volume`.
- [Persistent settings](../../scripts/game_state.gd): `apply_settings`.
- [Asset distribution boundaries](../09-release-business/distribution_model.md).

## Current state

Master volume is stored in settings and applied to the Godot Master bus, including mute at the low end. That is real settings plumbing. Source inspection found no `AudioStreamPlayer`, audio-stream references or music/effect playback implementation in the inspected scripts, scenes and plugin. No dedicated music/effects library or sound brief is catalogued here. Do not describe the volume slider as a completed audio system.

## Decisions still open

Musical direction, ambience, cue list, channel/bus structure, asset sources, intensity and repetition rules remain to be agreed. A warm, small clockwork world is visual/world context, not an approved instrumentation choice.

## Suggested next task and acceptance

Draft a minimal sound brief and cue list for one playable flow. If implementation is requested, begin with a few UI/gameplay cues and explicit playback ownership. Verify persistent volume, silence when muted, no duplicated/overlapping triggers, scene-exit cleanup and restrained repetition. Coordinate cue timing with Gameplay/UI and provenance with Release. Keep experimental recordings and paid research outputs local until promoted. New paid generation or licensing requires a current task-specific budget, not an assumed historical allowance.
