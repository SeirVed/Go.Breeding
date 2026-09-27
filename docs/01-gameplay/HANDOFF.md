# Handoff — Gameplay

[Area index](README.md) · [All areas](../README.md)

**Snapshot:** 2026-09-28, based on repository `b7bb9bc`, source inspection and existing documentation. No new gameplay or visual validation was performed for this handoff. Recheck the current checkout before acting.

**Start:** read [AGENTS.md](../../AGENTS.md), this handoff and the linked references. The user's new request determines scope and mode; suggested next steps below are not an instruction to begin implementation. Keep this handoff current when the area changes.

## Purpose

Make acquiring, pairing, evaluating offspring and investing in the ranch enjoyable and understandable. Rules and costs belong here; presentation belongs with UI and Animation.

## Read first

- [Breeding rules](breeding_logic.md), [traits](trait_system.md), [hidden traits](invisible_traits.md), [unlock paths](unlock_paths.md).
- [Prototype engine](../../scripts/breeding_engine.gd), [game state](../../scripts/game_state.gd), [UI flow](../../scripts/main.gd).
- [Species registry](../../data/species.json).

## Current state

`BreedingEngine.breed()` chooses one parent's species, blends several attributes, rolls stats/mutations and returns pairing metadata using seeded RNG. Its seed is a simple string hash involving pair, transaction and Parent A fields. It does not implement the HMAC/genome-history formula in the design document. The prototype has resource costs, offspring records and saving through the UI/state layer.

Parent selection currently uses species definitions; a full individual-creature lineage simulation is not established by that demonstration. Complete stability consequences, facilities, compatibility depth and laboratory routes remain planned.

## Preserve and clarify

Offspring species follows a parent; the design rejects arbitrary hybrid species. Outcomes should be deterministic for defined inputs and explainable. The roster is expandable. Ordered production-board pairs must not accidentally become unordered merely because another helper uses a sorted species key.

The design's fixed 16×16 compatibility example needs reconciliation with the open-ended registry before implementation. Documented alternative reproduction routes are not proof of implemented mechanics. Balancing numbers remain provisional.

## Suggested next task and acceptance

Define one playable ranch-day loop, then implement one missing rule within it. Specify parent input data, resources consumed, offspring output and save behaviour first. Verify repeatability for identical inputs, intentional directional behaviour, insufficient-resource handling and persistence. Use synthetic or isolated saves; do not overwrite the owner's playtest data. Coordinate schema changes with Technical Foundations and explanations with UI.
