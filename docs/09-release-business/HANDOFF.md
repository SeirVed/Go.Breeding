# Handoff — Release & Business

[Area index](README.md) · [All areas](../README.md)

**Snapshot:** 2026-09-28, based on repository `b7bb9bc`, source inspection and existing documentation. No new gameplay or visual validation was performed for this handoff. Recheck the current checkout before acting.

**Start:** read [AGENTS.md](../../AGENTS.md), this handoff and the linked references. The user's new request determines scope and mode; suggested next steps below are not an instruction to begin implementation. Keep this handoff current when the area changes.

## Purpose

Manage distribution, ownership, storefront planning, community expectations and demand signals without letting commercial plans dictate unfinished game features.

## Read first

- [License](../../LICENSE.md), [copyright](../../COPYRIGHT.md), [third-party notices](../../THIRD_PARTY_NOTICES.md), [contribution policy](../../CONTRIBUTING.md).
- [Distribution architecture](distribution_model.md), [license decision](license_decision.md), [Guild Star Ballot](dev_metrics.md).

## Current state

The repository is source-visible proprietary, not open source. One codebase with separate free SFW and paid content packages is the intended architecture. Demo, DLC or separate-application storefront topology remains undecided. Do not infer storefront acceptance, legal enforceability or launch readiness from the design documents; verify current requirements when that work is requested.

The ballot is planned: one movable Gold, Silver and Bronze star per player globally across all boards, on distinct targets, with raw totals and a transparent 3/2/1 score. No voting backend, identity service or live telemetry exists. It is a demand signal, not a purchase or production promise.

## Preserve and clarify

The owner has paused public Pages hosting. Do not deploy a site or publish binaries by inference from ordinary Git push authorisation. Paid and unapproved research media stays local. Public documents must not expose internal balances or credentials. The credit ledger is in ignored `private/`; prior Git history still contains its former tracked version. Do not rewrite history or assume any remaining spend allocation from an old ledger.

## Suggested next task and acceptance

Choose a bounded release-readiness task, such as specifying package contents or identifying an unresolved storefront requirement. Keep evidence, recommendations and owner choices distinct. Coordinate package enforcement with Technical Foundations and demand UI with UI/UX. A release plan should state what is playable now and what remains proposed, without turning placeholder coverage into marketing claims.
