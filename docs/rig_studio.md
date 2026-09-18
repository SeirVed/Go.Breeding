# Rig Studio v0.3.1

> **Status: functional editor-only authoring draft.** Character construction, variable timed keys, multi-actor staging, nine motion-verb prototypes, phased-scene loading, virtual contact sockets and a complete draft Human cutout are testable. Production-polished Human artwork, limb-chain IK, alternate skeleton topologies and gameplay animation selection are not implemented.

## What it is

Rig Studio is a custom Godot `EditorPlugin` made for Go.Breeding; it is not a modified third-party editor. It runs as a main Godot workspace and is excluded from playable exports. The plugin is split into a workspace shell, Single Builder panel, Animation Editor panel, reusable timeline, multi-rig viewport, Propagate operation and verb engine instead of keeping every concern in one script.

Open `project.godot` with the pinned Godot 4.7.2 editor at `C:\Games\Dev\Godot\Godot.exe`, then choose **Rig Studio** beside the normal 2D/3D/Script workspaces.

## Single Builder

Single Builder constructs and diagnoses one reusable paper doll. Its character selector begins with **+ Add New…**, which clones the Human-based **Default Template** into a new in-memory character. Save All writes character definitions, artwork assignments and authoring offsets only from the editor. The Default Template and Human character remain distinct concepts: the template is the source for new humanoids; a future Human Player is a playable identity created from it.

- **Rig:** Shift-click anchors for multi-selection, then drag to edit character rest offsets.
- **Art:** assign project PNGs to ordinary humanoid body slots and edit image transform/layer values.
- **Animate:** test the shared walk using variable timed keys.
- **Body foundation:** one exclusive topology selection. Only `humanoid_plantigrade` is implemented; digitigrade, unguligrade, serpentine, tauric, quadruped and amorphous entries are honest `contract_only` metadata.
- **Additive anatomy:** ears, horns, tail, wings, antennae, halo, fins and extra limbs can be declared independently. Existing art slots work for ears/horns; articulated add-ons remain contracts until their anchor chains exist.

The Default Template mounts the complete fourteen-piece Human Zero cutout. Incomplete characters remain visible over editor guides while authoring; gameplay uses the universal emergency silhouette until all 14 essential humanoid slots—or one valid `full_body` draft—are present.

## Animation Editor

Animation Editor stages one to many actors. Every actor independently selects a character, role, Small/Medium/Large band, exact height and resting stage position. Root keys animate stage motion; other node keys animate actor-local pose offsets. Shift-click selects several nodes and dragging preserves their relationship.

The timeline is no longer fixed to eight poses. Each key stores an integer tick, interpolation (`smooth`, `linear` or `hold`) and sparse actor pose data. Buttons add, duplicate, remove or insert an in-between key. **Simple** mode keeps fast key and verb-block controls visible; **Advanced** reveals exact tick/interpolation controls and **Propagate**. Propagate copies the selected nodes from the current key to a chosen key or all following keys as one undoable operation. Root stage motion is copied only when root is selected.

**Onion skins** show the selected actor at the preceding key in blue and following key in orange. They are editor-only duplicate previews, not exported artwork or runtime actors.

### Virtual contact sockets

Select exactly one source node, choose a different secondary actor plus two of its anchors, then press **Capture selected → secondary frame**. The first secondary anchor is the frame origin; the second defines its direction and current scale. Rig Studio records the source point as a normalized offset inside that frame, so the resulting virtual socket may sit between—or beyond—named anchors. Cyan guides display active sockets.

When the secondary pose rotates that reference direction or changes its span, the driven source point follows. The lock is stored under `contact_locks` in the multi-actor template and participates in Undo/Redo. One source anchor can own only one lock. Self-targeting, identical/collapsed reference anchors, invalid offsets and duplicate source ownership are rejected rather than silently fighting.

This is direct point correction from an order-independent base-pose snapshot. Target-frame anchors must therefore be unconstrained; chained or cyclic lock graphs are rejected until a graph solver exists. The prototype proves the contact-frame transform, persistence and authoring interaction. It does not bend an arm or leg to reach the corrected hand or foot, solve body support, prevent intersections, promote contact verbs from `contract_only`, or run in gameplay.

## Verb composition

`data/animation_verbs.json` is the composable-motion vocabulary. A verb block records a stable verb ID, timed range, participant-role mapping and parameters. Version 0.3.1 defines twenty-one verbs; nine have visible body-offset prototypes while contact-dependent verbs remain contracts. The original three preview examples are:

- `brace`;
- `pelvis_pulse` / Thrust;
- `reaction_bounce`.

Approach, Circle Partner, Plant Stance, Lower Centre, Rise and Sway Together now also preview. `reach_to`, `hold_anchors`, Support Lift, Supported Climb, Rotate/Exchange Lead, Settle Contact, Nuzzle, Release and Reset Loop remain `contract_only`. They deliberately do not claim working contact choreography. `data/pairing_storyboard_grammar.json` still supports flat planning sentences; `data/animation_scene_grammar.json` now composes the canonical Intro → Loop A → Loop B → Climax → End graph from 12 loop families and 24 A/B variants. See `docs/verb_storyboards.md` and `docs/parametric_choreography.md`. The intended evaluation order is base pose, body/root verbs, contact constraints, reaction verbs, secondary motion, then manual overrides. Baking verbs into destructive keys is not part of v0.3.1.

Animation Editor can load any compiled board/body-type scene into Actor A/B as one undoable authoring operation. A phase selector loads the entire graph or isolates Intro, Loop A, Loop B, Climax or End for focused work. It binds symbolic roles, adjusts the first two cast profiles, expands the timeline, retains the five phase records and lists all selected beats. This is a scaffold for refinement, not playable coverage; unresolved contract beats remain inert and stored source metadata keeps `runtime_ready: false`.

## Data and safety

- `data/paper_doll_characters.json` — Default Template and character definitions.
- `data/paper_doll_artwork.json` — actual image bindings.
- `data/paper_doll_studio.json` — rig offsets, variable timed keys, actors, verb instances and contact locks.
- `addons/rig_studio/contact_lock_solver.gd` — virtual-socket capture, validation and rotation/scale reconstruction.
- `data/anatomy_components.json` — exclusive topology and additive attachment contracts.
- `data/animation_verbs.json` — reusable verb definitions and implementation status.
- `data/animation_scene_grammar.json` — phase graph, loop recipes, 12 families, 24 variants and directional-size compatibility candidates.

Undo/Redo snapshots characters, artwork and studio motion data together. Save All refuses to overwrite any of those source files if they changed externally after Rig Studio loaded. The six-stage build check compiles the editor plugin, exercises creation, anatomy metadata, art readiness, variable keys, independent cast sizing, multi-node edits, onion skins, Propagate and visible verb motion, then verifies source and exported gameplay. Editor scripts remain excluded from the playable package.

## Current boundary

This is not yet a full inverse-kinematics or production constraint solver. Virtual sockets resolve one named point, but there is no limb-chain IK, mesh weighting, polygon deformation, automatic foot locking, support/penetration resolution, anatomy-aware verb adaptation, runtime animation resolver or production-polished Human art. Human Zero proves the fourteen-part mounting path; it is a replaceable draft, not the final player character. Simple and Advanced currently share the same key data; Advanced exposes more precision rather than a separate animation. Alternative topology choices are schema contracts until their skeletons and artwork are built.
