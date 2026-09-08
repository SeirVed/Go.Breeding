# Go.Breeding 0.2.4 — Jack, Jill & Bonk

Three commission boards and the honest breeding placeholder.

## Changed in 0.2.4

- Added the keeper board names **Jack & Jill**, **Jack & Jack**, and **Jill & Jill**.
- Expanded production tracking from 81 mixed-pair targets to 243 directional commissions across the three boards.
- Added male/male and female/female matrices with independently addressable progress keys.
- Removed claims that an unfinished procedural animation fallback exists.
- Every unfinished commission now reports **PLACEHOLDER ACTIVE** and 0% progress.
- Added the looping, text-emoji `Emoji Bonk v0` preview to commission notices.
- Pressing Breed now plays the selected parents colliding, bouncing atop one another, swapping positions, and spraying `💦`, `💥`, and `💨` before the offspring appears.
- Preserved deterministic offspring generation, resource costs, saving, and directional body-pair metadata behind the placeholder presentation.

## Previous milestone: 0.2.3 Hear Ye, Pair Ye

Interactive town-notice production board.

## Changed in 0.2.3

- Named all nine male and nine female body archetypes.
- Added a title and movement brief for all 81 directional couplings.
- Rebuilt Dev Progress as an old-town wooden commission board.
- Added 81 pinned-paper emoji buttons with title tooltips.
- Added a large parchment detail notice with pairing names, descriptions, order, authored-script count, implementation status, and percentage progress.
- Initialized all explicit progress values at 0%.

## Previous milestone: 0.2.2 Role Reversal

Directional biomechanics and production-matrix correction.

## Changed in 0.2.2

- Expanded the body-pair production matrix from 45 unordered targets to 81 directional targets.
- Defined rows as Interaction Role A and columns as Interaction Role B.
- Marked the upper triangle Regular and the lower triangle Inverted without treating either half as a duplicate.
- Preserved parent order in body-pair planning metadata and offspring result readouts.
- Added smoke coverage proving Small Neutral > Large Neutral differs from its inverse.

## Previous milestone: 0.2.1 Body Language

Production-matrix correction and body-pair planning foundation.

## Changed in 0.2.1

- Replaced the player-style 990-species-pair checklist with a read-only developer progress matrix.
- Restored the documented Small/Medium/Large × Feral/Neutral/Refined silhouette model.
- Tracks 45 unique unordered body-pair script targets, including same-body pairs.
- Added a complete species-to-body mapping for the then-current 44-concept roster snapshot; 44 is not a cap.
- Added Bestial, Exotic, Winged, and Tauric exception tags.
- Added provisional scale and posture planning metadata for every species pairing; no finished animation system was present.
- Breeding no longer changes production progress; progress comes only from the authored-script manifest.

## Previous milestone: 0.2.0 Pair-a-Dice

## Added in 0.2.0

- A unified 44-type registry snapshot covering canonical, unlock, archive, and example creatures, designed for continued additions.
- Main-menu Gallery entry marked as a temporary developer feature.
- Four-column emoji creature Gallery with per-species pairing completion.
- Full partner checklist for every creature: 990 unique unordered pairs including self-pairs.
- Developer Check All and Reset controls.
- Breeding Pen accessible from Hearthglen Ranch.
- Selectable Parent A and Parent B from the full registry.
- Deterministic parent-species inheritance with tier/genome-pressure weighting.
- Inherited stat biases, elemental affinity, morphology, development, stability, and mutation rolls.
- Offspring records, resource costs, autosave, Gallery discovery, and automatic pair-checklist updates.

## Previous milestone: 0.1.1 New Beningings

## Changed in 0.1.1

- Replaced all ASCII illustrations with scalable emoji compositions.
- Added independent positioning, scaling, rotation, ordering, and opacity for emoji layers.
- Added emoji scenes for the main menu, every prologue page, the world map, and each destination.
- Updated map markers and HUD accents to use emoji.
- Corrected the codename to its intentionally incorrect spelling: **New Beningings**.

## Framework included

- Main menu: New Game, Continue, Load Game, Options, Exit
- Three-slot JSON save system with automatic Continue detection
- Three-page placeholder prologue
- Data-driven world map with Ranch, Town, Forest, Lake, and locked Mountains
- Placeholder location screens ready for feature modules
- Persistent volume, fullscreen, and text-speed settings

## Framework layout

- `scenes/` contains the main launch scene.
- `scripts/game_state.gd` owns saves, settings, and session data.
- `scripts/main.gd` owns the current prototype UI flow and emoji compositor.
- `data/locations.json` is the extensible map/location registry.
