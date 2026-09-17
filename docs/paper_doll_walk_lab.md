# Paper-Doll Walk Lab

> **Status: implemented rig/locomotion vertical slice.** One invisible pose provider supports six humanlike body profiles, a complete draft Human cutout, one emergency image and a looping walk. No creature cutout, breeding animation or exceptional-morphology rig is complete.

## Purpose

The Walk Lab develops style and animation structure together. It tests whether the Soft Storybook Emoji grammar can survive reusable cutout motion before dozens of static character masters are approved.

The main menu's `WALK LAB` entry displays:

- male small, medium, and large profiles;
- female small, medium, and large profiles;
- one synchronized walk cycle at three review speeds;
- pause and one-eighth-cycle stepping for pose inspection.

## Shared rig contract

All six profiles use the same logical layers and named anchors:

- root;
- pelvis and torso;
- head;
- left/right shoulders, elbows, hands;
- left/right hips, knees, feet;
- effect origin.

The prototype computes anchors without drawing a mannequin in normal gameplay. Valid static or bone-clipped image parts follow those anchors; without a complete cutout, the one universal emergency image appears. The Walk Lab's joint-only debug view hides artwork, while the editor-only Rig Studio deliberately shows guides together with partial art. Profile data changes proportions, stance, stride, bob, cadence and overall scale without carrying character appearance.

Profile values live in `data/paper_doll_profiles.json`. Reusable kit declarations live in `data/paper_doll_part_sets.json`, character compositions in `data/paper_doll_characters.json`, actual image bindings in `data/paper_doll_artwork.json`, and editable rest/motion offsets in `data/paper_doll_studio.json`. Runtime clipping and walk timing live in `scripts/paper_doll.gd`. The game development screens live in `scripts/main.gd`; the authoring screen lives in `addons/rig_studio/` and is excluded from exports. See `docs/paper_doll_parts.md` and `docs/rig_studio.md` for the artwork and authoring contracts.

## Size behaviour

- **Small:** below 4′0″; the 3′6″ review control has the largest head ratio, shortest limbs, quickest cadence and widest stride.
- **Medium:** 4′0″ to below 8′0″, centred near 6′0″. The first Catgirl skin is explicitly 5′5″ and scales within this band without changing topology.
- **Large:** 8′0″+; the 8′6″ review control has the smallest head ratio, longest and widest limbs, broadest stance, restrained stride, slowest cadence and heaviest bob.

Male and female profiles share timing topology. Current silhouette differences use shoulder, waist and hip relationships rather than separate animation clips. These are provisional production categories, not claims about every character inside a category.

## Iteration record

### Pass 1 — shared profile foundation

- Added all six data profiles and one code-drawn renderer.
- Confirmed Godot could import and parse the new resources.

### Pass 2 — playable Walk Lab

- Added the main-menu laboratory, synchronized looping motion and speed controls.
- Added all six runtime dolls to the smoke test.
- Full source/export/runtime build check passed.

### Pass 3 — visual correction

The first rendered capture showed two failures: the sixth card clipped, and single-segment arms and legs crossed like rigid sticks.

- Removed inherited panel padding and tightened card widths.
- Split limbs into upper/lower segments.
- Added elbow and knee anchors.
- Added phase-dependent knee bend and forearm counter-swing.
- Added profile validation and an eight-step pose-review control.

### Pass 4 — mannequin/identity separation

- Removed all skin, hair, outfit and accent fields from the six rig profiles.
- Used a neutral artist-mannequin treatment with visible construction joints as a temporary development study.
- Split Catgirl Base into an orange-tabby species kit and ranch-scout wardrobe kit.
- Added the Cat Parts Workbench; its original base/species/full-character comparison was a code-drawn topology study, not production detachable image art.
- Added part-set and character-reference validation to source and exported smoke tests.

### Pass 5 — invisible skeleton and single emergency image

- Removed visible mannequin drawing from normal character rendering; joint markers now require explicit debug mode, which hides art.
- Added an image manifest and static/bone-following `Sprite2D` part bindings.
- Added one transparent universal mystery silhouette when an identity has zero valid art; broken paths do not crash or expose the skeleton.
- Changed the workbench to show debug skeleton, no-art fallback and broken-art fallback honestly. No Catgirl cutout has been authored yet.
- Verified empty/broken and valid static/bone probe cases in source and exported runtime builds.

### Pass 6 — editor-only Rig Studio and cutout readiness

- Added a Godot main-screen authoring tab based on the hand-drawn pose canvas, attached/missing inventory, character selector and eight-keyframe timeline.
- Separated character-specific rest-anchor offsets from shared walk-keyframe offsets, with runtime interpolation over the procedural base walk.
- Added PNG attach, transform adjustment, unassign, in-memory undo/redo and editor-only manifest save.
- Required all 14 essential humanoid slots or one valid full-body draft before partial art suppresses the runtime emergency image; editor preview shows unfinished pieces and guides instead.
- Tested UI interaction without writing production data, and excluded authoring scripts from the playable package.

### Pass 7 — multi-rig animation scene draft

- Added an authoring-only scene with an open-ended actor list rather than assuming every animation uses one rig or exactly two.
- Made character identity, role, Small/Medium/Large band, exact height and resting stage position independently editable per actor.
- Added actor-specific rest-anchor edits and eight-frame pose/stage offsets, with independent interpolation and undo.
- Verified two unequal default rigs, changed one rig without affecting the other, expanded the cast to four, removed/restored one, and keyed only Actor B's head and stage motion.
- Kept paired contact, body-topology exceptions and runtime scene selection outside this pass.

### Pass 8 — Rig Studio v0.2.0 composition tools

- Split the monolithic authoring proof into Single Builder, Animation Editor, timeline, Propagate and verb-engine components.
- Added a Human-based Default Template and an Add New flow while retaining Catgirl as a later derived identity.
- Replaced the fixed eight-pose assumption with variable timed keys, exact ticks and Smooth/Linear/Hold interpolation.
- Added Simple and Advanced timeline views, Shift multi-node selection, selected-actor onion skins and selected-node Propagate.
- Added exclusive topology plus additive anatomy metadata. Only ordinary plantigrade humanoid topology is implemented; all exceptional skeleton choices remain contract-only.
- Added six initial verb definitions: three visible motion prototypes and three honest contact/transition contracts.

## Acceptance boundary

This slice is successful when all six profiles:

- construct from one renderer;
- remain inside their review cards;
- visibly differ by proportion and motion character rather than uniform scaling;
- expose the same required anchors;
- loop, pause and step without changing profile identity;
- pass source, export-content and exported-runtime checks.

It does **not** yet validate real species cutouts, tails, wings, digitigrade legs, tauric bodies, naga bodies, clothing swaps, directional locomotion, foot locking, full-body sprite substitution or paired contact.

## Next loop

Author the first basic alpha-clean Human Default Template cutout, bind its full essential body to the manifest, and review the variable-key walk before refining it. Create the Human Player from that template, then extend the proven foundation into Catgirl, Cow and Golem/Titan. Use Elf as an ordinary Medium control and a genuinely sub-four-foot species for Small. Any cutout that needs new anchors or exposes a poor proportion feeds changes back into the shared rig before the Tier-A style is declared locked.
