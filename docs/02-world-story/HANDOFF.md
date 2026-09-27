# Handoff — World & Story

[Area index](README.md) · [All areas](../README.md)

**Snapshot:** 2026-09-28, based on repository `b7bb9bc`, source inspection and existing documentation. No new gameplay or visual validation was performed for this handoff. Recheck the current checkout before acting.

**Start:** read [AGENTS.md](../../AGENTS.md), this handoff and the linked references. The user's new request determines scope and mode; suggested next steps below are not an instruction to begin implementation. Keep this handoff current when the area changes.

## Purpose

Give the ranch and surrounding world clear identities and useful activities that support the systems. The design is not currently a visual novel or romance campaign.

## Read first

- [Design vision](../00-project-hq/design_vision.md).
- [Species design roster](species_list.md) and [runtime species](../../data/species.json).
- [Location registry](../../data/locations.json), [unlock design](../01-gameplay/unlock_paths.md).
- [Screen implementation](../../scripts/main.gd): `show_intro`, `show_map`, `show_location`.

## Current state

The registry contains Hearthglen Ranch, Briarwick Town, Whisperwood, Moonmere Lake and The Crown Peaks. The initial save unlocks the first four. These are draft names/descriptions and example destinations; current buttons do not establish finished activities. The introduction is a placeholder. No completed quest or narrative framework is claimed.

The species document is curated design context; `data/species.json` is the runtime registry. Counts are snapshots, never a final species cap.

## Preserve and clarify

Retain the small clockwork-world tone and readable elemental ecology. Species identity, visual design and gameplay rules have separate owners but need consistent IDs and terminology. Do not cement placeholder geography, gate conditions or activities just because they are already drawn on the map.

## Suggested next task and acceptance

Write a short destination brief for one location: player purpose, available activity, entry/exit, prerequisites and the smallest playable result. Agree it before expanding lore or producing final art. Acceptance means the location supports an actual part of the core loop and its UI clearly distinguishes working actions from planned ones. Coordinate activity effects with Gameplay and navigation with UI.
