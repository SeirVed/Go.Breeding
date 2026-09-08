# Changelog

All notable prototype changes are collected here. Earlier production models are retained as history even where a later version replaced them.

## 0.2.4 — Jack, Jill & Bonk

- Added three old-town production boards: **Jack & Jill**, **Jack & Jack**, and **Jill & Jill**.
- Expanded the tracker to 243 directional commissions: 81 mixed, 81 male/male, and 81 female/female.
- Kept Regular upper triangles and Inverted lower triangles as separately addressable targets.
- Added independent board-qualified progress keys so equivalent body pairs on different boards do not share completion accidentally.
- Corrected all current UI and design language from “procedural fallback” to **PLACEHOLDER ACTIVE**.
- Added `Emoji Bonk v0`, rendered entirely with live text emoji.
- The temporary Breed presentation now makes the selected parent emoji rush together, collide, bounce over one another, swap positions, spray `💦`, `💥`, and `💨`, and then reveal the offspring.
- Reused Emoji Bonk on the enlarged commission notice as an honest preview of the current placeholder.
- Added safeguards against charging for multiple Breed actions while the placeholder sequence is already playing.
- Added smoke coverage for all three boards, 243 total targets, directional keys, and notice selection.

## 0.2.3 — Hear Ye, Pair Ye

- Named all nine male body archetypes: Scrapper, Scout, Squire, Prowler, Strider, Gallant, Brute, Titan, and Regent.
- Named all nine female body archetypes: Wildling, Courier, Maiden, Huntress, Ranger, Dame, Diremother, Matron, and Sovereign.
- Added a unique title and movement-theme brief for all 81 Jack & Jill couplings.
- Rebuilt Dev Progress as an old-time wooden town commission board.
- Put a pinned paper with a text-emoji pair in every matrix square.
- Added coupling-name tooltips and clickable enlarged parchment notices.
- Added read-only percentage, order, body types, authored-script count, and implementation-status fields.

## 0.2.2 — Role Reversal

- Expanded the body-pair matrix from 45 unordered combinations to 81 directional targets.
- Made Role A/body-row and Role B/body-column order part of the pairing key.
- Defined the upper triangle as Regular and the lower triangle as Inverted.
- Treated `Small > Large` and `Large > Small` as different biomechanical commissions.
- Preserved parent ordering in breeding-plan and offspring-result readouts.
- Added tests proving forward and inverted size pairings resolve differently.

## 0.2.1 — Body Language

- Replaced the mistaken player-style species checklist with a read-only animation-production matrix.
- Restored the documented Small, Medium, and Large size bands.
- Restored the Feral, Neutral (formerly Regular), and Refined morphology bands.
- Established nine reusable base silhouettes from the 3 × 3 body grid.
- Added body-type mappings for all 44 creature concepts.
- Added Bestial, Exotic, Winged, and Tauric exception tags.
- Added scale, posture, and body-pair planning metadata to breeding results.
- Separated production progress from player actions: breeding cannot mark development work complete.

## 0.2.0 — Pair-a-Dice

- Consolidated canonical species, unlocks, archive concepts, and examples into one 44-type registry.
- Added a temporary developer Gallery entry to the main menu.
- Added the first four-column emoji creature gallery and species-pair checklist; this approach was replaced in 0.2.1.
- Added temporary developer Check All and Reset controls; these were subsequently removed.
- Added the playable Breeding Pen at Hearthglen Ranch.
- Added full-registry Parent A and Parent B selectors with emoji portraits.
- Added deterministic parent-species inheritance using tier and genome-pressure weighting.
- Added inherited stat biases, elemental affinity, morphology, development, stability, and mutation rolls.
- Added breeding costs, offspring history, autosaving, and a deterministic result card.

## 0.1.1 — New Beningings: Emoji Replacement

- Replaced every ASCII illustration with scalable emoji compositions.
- Added independent positioning, scale, rotation, ordering, and opacity for emoji layers.
- Added layered emoji scenes to the main menu, prologue, world map, and destinations.
- Converted map markers and HUD accents to emoji.
- Preserved the intentionally misspelled early-meme codename **New Beningings**.

## 0.1.0 — New Beningings

- Created the initial Godot 4 project framework.
- Added the main menu: New Game, Continue, Load Game, Options, and Exit.
- Added a three-slot JSON save system with automatic Continue detection.
- Added the three-page placeholder introduction.
- Added the data-driven world map with Ranch, Town, Forest, Lake, and locked Mountains.
- Added placeholder destination screens ready for later activity modules.
- Added persistent master-volume, fullscreen, and text-speed settings.
- Added the original ASCII-style placeholder presentation later replaced by emoji.
