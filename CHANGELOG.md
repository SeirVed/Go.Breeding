# Changelog

## Unreleased — Documentation and Dev Metrics

- Expanded the reusable motion vocabulary to twenty-one verbs. Nine have visible Rig Studio body-motion prototypes; contact and constraint work remains explicitly `contract_only`.
- Added a board-, direction-, size- and morph-aware sentence compiler that generates and validates 243 `PLACEHOLDER_PLAN` storyboards. Jack & Jack and Jill & Jill now have distinct same-sex descriptor voices and lead-exchange themes instead of generic awaiting-design text.
- Added compact placeholder verb sequences to Dev Progress notices plus an ignored JSON dump tool for inspecting every role-labelled sentence. Planning records remain `runtime_ready: false` and do not alter authored-script progress.
- Added **Human Zero**, a complete fourteen-piece `storybook_emoji_v1` Default Template cutout with deterministic transparent SVG sources. Runtime, Rig Studio and exported-build tests now fail if the Human silently falls back to the universal mystery silhouette.
- Hardened private export validation: fresh QA targets prevent stale embedded payloads, all `tools/` scripts stay out of playable packages, and Godot's false-success `project.binary` export error is promoted to a build failure.
- Rebuilt the custom editor plugin as **Rig Studio v0.2.0**: split Single Builder, Animation Editor, timeline, Propagate and verb-engine modules; Human Default Template plus Add New; exclusive topology/additive anatomy contracts; variable timed keys and interpolation; Simple/Advanced timeline views; Shift multi-node selection; selected-actor onion skins; one-to-many casts; and data-driven verb blocks. Brace, Pelvis Pulse/Thrust and Reaction Bounce visibly preview, while contact-dependent verbs remain honestly `contract_only`.
- Added an editor-only multi-rig animation scene to Rig Studio. Authoring can add/remove cast rigs, choose independent character identities, roles, size bands, exact heights and stage positions, and key each actor's pose/stage motion across eight draft frames. This is not paired gameplay choreography or commission coverage yet.
- Added an editor-only **Rig Studio** Godot workspace from the hand-drawn mockup: character selector, visible authoring anchors, Rig/Art/Animate modes, attached/missing part inventories, project-PNG assignment, image transforms, eight shared walk keyframes, playback, reset, undo/redo and guarded save.
- Stored character rest offsets and shared humanoid walk-keyframe offsets separately; the runtime rig interpolates authored offsets over its existing procedural walk while remaining invisible in gameplay.
- Gated runtime cutouts on all 14 essential humanoid body slots or one valid full-body draft. Incomplete art stays visible only in the editor preview; gameplay retains the one universal emergency silhouette.
- Extended the build check to compile the editor plugin, exercise in-memory Rig Studio interactions and exclude editor-only authoring code from the playable export.
- Restored a repeatable Godot 4.7.2 source/export/runtime build check with private-media package auditing and a clean local Windows QA executable.
- Added the six-profile Paper-Doll Walk Lab with corrected Small-under-4′, Medium-centred-near-6′ and Large-8′+ scale bands, plus an exact 5′5″ Catgirl control.
- Separated the paper doll into an invisible geometry/motion rig, declared species/wardrobe part sets and a distinct runtime image manifest; rig profiles no longer contain skin, hair, palette or clothing decisions.
- Added the Cat Parts Workbench and declared orange-tabby/ranch-scout kits. Its former code-drawn base/species/full-character comparison was topology research, not production clip-on art.
- Made the rig invisible in normal character rendering; explicit developer skeleton mode hides artwork. Valid static and bone-clipped image probes follow anchors, while characters with zero valid art display one transparent universal emergency image, including broken-path cases.
- Recorded the Catgirl cutout as **not authored yet**. The art manifest contains only Human Zero; the generated Cat parts board remains research, not working sprite pieces.
- Added a local generated Catgirl parts research board and promotion gates; the opaque checkerboard concept is explicitly not treated as production alpha art.
- Abstracted the source-to-output pairing workflow into a reusable gated production pipeline covering matched masters, presentation profiles, static contact-pose approval, motion QA, paper-doll authoring, and runtime integration.
- Added data-driven pairing-group records and runtime lookups by board/group (`m+f`, `m+m`, `f+f`), role-aware archetype name (`Titan + Ranger`), ordered body type, size pair, morphology pair, coupling title, and stable commission key.
- Added a provider-neutral Python pairing lookup CLI so external art, generation, and audit tooling resolves the same catalog as the Godot runtime.
- Added a versioned pairing-production-record schema and research registry with explicit cast overrides, contracts, artifacts, provider costs, and independent character/body/pose/motion/integration gate results.
- Converted the Gallery board tabs and notice metadata to use the canonical lookup records, eliminating the duplicate hard-coded board configuration.
- Split the visual pipeline into reproducible chibi/emoji production masters and richer promo-only renders so storefront polish does not become the per-sprite animation budget.
- Proved a two-reference chibi NSFW conversion workflow with Phoenix and Naga, retaining short proportions, thick contours, feather masses, and serpentine no-leg topology.
- Added two paid four-second 480p chibi Seedance research idles with exact receipts and QA contact sheets; these remain research assets, not authored runtime coverage.
- Hardened the Wiro runner with prompt files, provenance receipts, and retry handling for transient post-processing 404s without resubmitting paid tasks.
- Added ordered 1–30 image Seedance reference mode with `[Image N]` receipt labels and explicit exclusion from first/last-frame mode.
- Completed two Phoenix/Naga multi-reference paired-motion studies: V1 validated five-image identity/style conditioning but drifted toward a clothed affectionate embrace; V2 reduced the stack to three references and produced a cleaner, more readable concealed adult-innuendo loop while retaining the emoji/chibi style and naga topology.
- Added the first ordered size-pair motion study, **Titan → Ranger**, using an authored golem/cow chibi staging frame; the result preserved the Large-male/Medium-female scale gap, inward eyelines, planted support, and species anatomy, while demonstrating that generated motion still generalizes counted lift cycles into a softer progression.
- Added a global paired-scene acting rule for this study: partners focus on each other, never look at the camera, wink at the audience, or otherwise acknowledge the fourth wall.
- Defined modular `SFW_CLOTHED`, `SFW_UNCLOTHED`, and `NSFW` presentation profiles using independent chest, pelvis, genital-detail, and clothing layers.
- Added a machine-readable anatomy-patch schema plus a deterministic local extraction/compositing tool, and seeded the ignored local library from retained paid research outputs.
- Established the exploratory **Soft Storybook Emoji** visual direction with a four-species stress-test lineup, multi-scale Cat/Cow/Elf/Titan studies, a reusable prompt template, and an explicit small-size acceptance checklist.
- Added a second Insectkin/Phoenix/Dragon/Void-born stress-test lineup, a four-tier Dragon guide, and an exact 16:9 Dragon motion keyframe.
- Added a credential-safe Wiro Seedance submit/resume helper and recorded the first Dragon motion QA, including the current first/last-frame grid and aspect-ratio quirks.
- Recorded generated-asset provenance and alpha-channel verification; Cat and Elf scale sheets remain clearly labelled opaque concept studies rather than production sprites.
- Adopted an explicit proprietary, All Rights Reserved license for all original Go.Breeding material from version 0.1.0 onward.
- Added ownership, authorised-distribution, third-party provenance, and contribution-control documents to deter unauthorised commercial repackaging and preserve a clean rights chain.
- Formalised one shared codebase with separately packaged SFW and NSFW content profiles; storefront configuration remains undecided.
- Formalised the planned Guild Star Ballot: one reusable Gold, Silver, and Bronze star per player across all three commission boards.
- Defined public raw counts, the transparent `3G + 2S + B` demand score, pairing-type aggregates, momentum views, privacy limits, validation, and backend requirements.
- Specified the paired paper-doll compatibility and best-fit ladder, with `Emoji Bonk v0` honestly retained as the last-resort placeholder.
- Clarified that 243 is the baseline ordered body-template target count, while the creature registry and bespoke species variants remain open-ended.
- Added repository-wide status labels and replaced obsolete static-PNG and fixed-roster roadmap language.
- Replaced the earlier GPL/AGPL proposal before adoption because commercial redistribution rights conflict with the owner's anti-flipping requirement.

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
- Added body-type mappings for the then-current 44-creature registry snapshot; the registry is not capped at 44.
- Added Bestial, Exotic, Winged, and Tauric exception tags.
- Added scale, posture, and body-pair planning metadata to breeding results.
- Separated production progress from player actions: breeding cannot mark development work complete.

## 0.2.0 — Pair-a-Dice

- Consolidated canonical species, unlocks, archive concepts, and examples into a 44-type registry snapshot designed to grow.
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
