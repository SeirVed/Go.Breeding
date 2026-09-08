# Dev Metrics: Guild Star Ballot

> **Status: planned.** No voting backend, identity service, or live telemetry exists in the current build. The board UI and local commission metadata exist; every animation commission is currently `PLACEHOLDER ACTIVE`.

## Purpose

The Guild Star Ballot lets players tell the developers which breeding-animation commissions they most want next. It is a prioritisation signal, not a promise, purchase, entitlement, or binding production queue.

## Player ballot

Each player has one global ballot containing exactly three reusable tokens:

- one Gold Star (`G`), worth 3 demand points;
- one Silver Star (`S`), worth 2 demand points;
- one Bronze Star (`B`), worth 1 demand point.

Players may place those stars on up to three distinct cells across any board—Jack & Jill, Jack & Jack, or Jill & Jill—and may move or leave them unassigned whenever they like. Moving a star removes its previous placement. A player cannot stack two of their own stars on one cell. Stars return to the ballot when a target is retired or completed so that historical enthusiasm does not become a permanently trapped vote.

The UI should always show the player's current three placements and make replacement explicit: “Move Gold Star from X to Y?”

## What a cell means

A cell identifies an **ordered body-archetype pairing**, not a fixed pair of species. There are nine male-frame archetypes and nine female-frame archetypes, producing 81 directional cells on each of three boards and 243 baseline commission targets in total.

The creature registry is open-ended. The current roster count is only a snapshot, never a cap. New monsters receive stable IDs and map to the existing body templates through size, morphology, anatomy tags, and role order. A new species may later earn bespoke variants without changing the definition of the baseline board.

## Public aggregates

Every cell should expose the raw current totals:

- Gold, Silver, and Bronze stars;
- unique current voters;
- weighted demand score: `3G + 2S + B`;
- implementation status and progress;
- last meaningful progress date.

Raw counts remain visible beside the weighted score so the weighting is never a hidden ranking trick. Ties remain ties unless a clearly documented secondary sort is selected.

## Derived planning views

The developer dashboard may aggregate current ballots by:

- board: mixed-gender, Jack & Jack, or Jill & Jill;
- direction: Regular or Inverted;
- ordered size pairing: Small→Large is distinct from Large→Small;
- ordered morphology pairing: Feral→Refined is distinct from Refined→Feral;
- individual source and destination archetype;
- exception tags such as Bestial, Exotic, Winged, and Tauric;
- 7-day and 30-day momentum;
- demand relative to implementation progress and estimated production cost.

These views answer both “which exact cell?” and “which kinds of pairings are popular?” A high score informs the work queue but does not automatically outrank feasibility, safety, narrative dependencies, or asset reuse.

## Data model

Use stable string identifiers; never use display names or roster indexes as database keys.

```json
{
  "voter_id": "pseudonymous-install-or-account-id",
  "revision": 12,
  "updated_at": "server timestamp",
  "gold": "jack_jill:small_feral:large_neutral",
  "silver": "jill_jill:medium_refined:small_neutral",
  "bronze": "jack_jack:large_feral:medium_feral"
}
```

The server stores the current ballot as the source of truth and may keep an append-only change log for momentum, abuse investigation, and reproducible aggregate rebuilds. The public API exposes aggregates, not voter identities.

## Synchronisation and validation

- Submit the complete ballot atomically with a revision or idempotency key.
- The server validates board IDs, archetype IDs, no more than one placement per rank, and distinct non-null cells.
- Server timestamps and current aggregate state are authoritative.
- The client may cache an offline ballot and clearly label it “pending sync.”
- Updates are rate-limited. Repeated retries must not double-count.
- Admin progress editing uses separate authenticated endpoints and credentials; no secret ships in the game client.

## Identity and privacy

The first implementation may use a random pseudonymous ID stored in Godot's `user://` directory. That is convenient, not tamper-proof: reinstalling can create another identity. Device fingerprinting is out of scope. Optional accounts can provide stronger one-player-one-ballot semantics later.

Collect the minimum needed to operate and defend the ballot. Publish a plain-language privacy notice and retention policy before enabling telemetry. Do not sell ballot data, quietly weight patrons more heavily, or combine it with unrelated behavioural tracking. If patron and community views are compared, label both populations and methodology openly.

## Transparency contract

- Publish the scoring formula and aggregation dimensions.
- Mark sample/demo counts unmistakably; never present them as player votes.
- Separate **playable coverage** from **bespoke animation progress**. Emoji Bonk is coverage, not a completed custom script.
- Record major metric-definition changes in the changelog.
- Provide a way to clear a local ballot and, once accounts exist, delete associated ballot data.

## Deployment constraint

A static GitHub Pages build cannot securely accept or store votes by itself. Live ballots require a small HTTPS API and persistent database (or an equivalent authenticated service). Hosting and provider choice remain undecided.
