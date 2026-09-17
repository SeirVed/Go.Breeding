# Rig Studio v0.2.0

> **Status: functional editor-only authoring draft.** Character construction, variable timed keys, multi-actor staging and three motion-verb prototypes are testable. Finished Human artwork, contact constraints, alternate skeleton topologies and gameplay animation selection are not implemented.

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

An incomplete cutout is visible over editor guides here. Gameplay continues to use the universal emergency silhouette until all 14 essential humanoid slots—or one valid `full_body` draft—are present.

## Animation Editor

Animation Editor stages one to many actors. Every actor independently selects a character, role, Small/Medium/Large band, exact height and resting stage position. Root keys animate stage motion; other node keys animate actor-local pose offsets. Shift-click selects several nodes and dragging preserves their relationship.

The timeline is no longer fixed to eight poses. Each key stores an integer tick, interpolation (`smooth`, `linear` or `hold`) and sparse actor pose data. Buttons add, duplicate, remove or insert an in-between key. **Simple** mode keeps fast key and verb-block controls visible; **Advanced** reveals exact tick/interpolation controls and **Propagate**. Propagate copies the selected nodes from the current key to a chosen key or all following keys as one undoable operation. Root stage motion is copied only when root is selected.

**Onion skins** show the selected actor at the preceding key in blue and following key in orange. They are editor-only duplicate previews, not exported artwork or runtime actors.

## Verb composition

`data/animation_verbs.json` is the first composable-motion vocabulary. A verb block records a stable verb ID, timed range, participant-role mapping and parameters. The initial engine visibly previews:

- `brace`;
- `pelvis_pulse` / Thrust;
- `reaction_bounce`.

`reach_to`, `hold_anchors` and `release` are present as `contract_only` definitions. They deliberately do not claim working contact choreography. The intended evaluation order is base pose, body/root verbs, contact constraints, reaction verbs, secondary motion, then manual overrides. Baking verbs into destructive keys is not part of v0.2.0.

## Data and safety

- `data/paper_doll_characters.json` — Default Template and character definitions.
- `data/paper_doll_artwork.json` — actual image bindings.
- `data/paper_doll_studio.json` — rig offsets, variable timed keys, actors and verb instances.
- `data/anatomy_components.json` — exclusive topology and additive attachment contracts.
- `data/animation_verbs.json` — reusable verb definitions and implementation status.

Undo/Redo snapshots characters, artwork and studio motion data together. Save All refuses to overwrite any of those source files if they changed externally after Rig Studio loaded. The six-stage build check compiles the editor plugin, exercises creation, anatomy metadata, art readiness, variable keys, independent cast sizing, multi-node edits, onion skins, Propagate and visible verb motion, then verifies source and exported gameplay. Editor scripts remain excluded from the playable package.

## Current boundary

This is not yet a full inverse-kinematics or constraint solver. There is no mesh weighting, polygon deformation, automatic foot locking, partner contact resolution, anatomy-aware verb adaptation, runtime animation resolver or proper Human cutout. Simple and Advanced currently share the same key data; Advanced exposes more precision rather than a separate animation. Alternative topology choices are schema contracts until their skeletons and artwork are built.
