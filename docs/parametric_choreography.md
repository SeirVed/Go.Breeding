# Parametric Choreography Architecture

> **Status: authoring architecture and validated placeholder compiler.** The vocabulary, 12 loop families, 24 A/B loop variants, five-phase scene shape and 243 directional scene plans exist as data. Rig Studio has an editor-only virtual contact-socket prototype, but no loop variant is production-authored, limb-chain IK and the runtime best-fit resolver do not exist, and `Emoji Bonk v0` remains the only playable breeding presentation.

## Purpose

Go.Breeding must not require one wholly independent animation for every species pair. The production system therefore separates appearance, motion, interaction meaning and scene selection. New creatures should inherit the best compatible motion automatically, while exceptional anatomy can add targeted extensions without invalidating the baseline library.

The project calls this the **2D Parametric Choreography System**:

```text
character artwork
    attaches to
standard invisible rig + optional anatomy modules
    performs
verbs parameterized by adverbs
    assembled into
loop sentences
    assembled into
phased scene graphs
    corrected by
contact + directional-size solver
    selected by
best-fit runtime resolver
```

This architecture combines established ideas rather than betting the project on an untested animation theory:

- [Verbs and Adverbs](https://eecs.vuse.vanderbilt.edu/people/bobbyb/pubs/VandAdv98.html) names reusable parameterized motions and connects them through valid transition graphs.
- [SmartBody / Behavior Markup Language](https://ifmas.csc.liv.ac.uk/Proceedings/aamas08/proceedings/pdf/paper/AAMAS08_0779.pdf) schedules higher-level behaviour descriptions into synchronized character motion.
- [Blender Nonlinear Animation](https://docs.blender.org/manual/en/4.3/editors/nla/introduction.html) treats named actions as reusable, time-scalable and transitionable strips.
- [Spine skins](https://us.esotericsoftware.com/spine-skins) reuse one skeleton with interchangeable artwork, optional bones and proportion constraints.
- [Unreal Motion Warping](https://dev.epicgames.com/documentation/unreal-engine/motion-warping-in-unreal-engine) corrects motion toward named spatial targets inside controlled time windows.
- [OSF scene graphs](https://github.com/ozooma10/osf-animation/blob/main/docs/SCENE_SCHEMA.md) demonstrate role-aware linear stages, loops, reusable scenes and graph transitions for multi-actor animation.

These are design precedents only. Go.Breeding does not copy their code or assets.

## The six layers

### 1. Rig ABI

The invisible rig is the animation application binary interface. Ordinary humanoids share stable node and anchor names. Wings, horns, tails, serpentine bodies, tauric bodies and other exceptions add declared modules instead of silently changing the meaning of common anchors.

A character may use different artwork and proportions, but a shared verb can only target anchors promised by its rig contract.

### 2. Artwork skins

Character art clips onto named rig slots. Animation never keys a particular Cat, Cow or Elf image directly. A universal emergency image appears only if no usable character art exists; it is a null-safety device, not a normal production fallback.

### 3. Verbs and adverbs

A **verb** is a small semantic motion such as Approach, Plant Stance, Brace, Hold Anchors or Sway Together. Its record declares participant roles, affected channels, required anchors and implementation status.

An **adverb** is a parameter applied to a verb: tempo, amplitude, repetition count, direction, phase, strength, reach or future acting style. Adverbs vary motion without multiplying source clips unnecessarily.

Current status terms are strict:

- `motion_prototype` — Rig Studio can show a provisional body-offset result;
- `contract_only` — the semantic operation is declared but its contact, IK or transition behaviour is not implemented;
- `authored` — future production motion that has passed visual and technical review;
- `runtime_ready` — future authored motion that also passes compatibility, transition and export gates.

Only the latter two may count as completed animation work. A prototype never completes a commission.

### 4. Loop sentences

The baseline humanoid/plantigrade library contains 12 biomechanical loop families:

| Family | Support model |
|---|---|
| Grounded Front-Aligned | Both grounded |
| Grounded Rear-Aligned | Both grounded |
| Standing Front | Both standing |
| Standing Rear | Both standing |
| First Mounted | Second supports |
| Second Mounted | First supports |
| Seated / Lap-Supported | Seated support |
| Side / Reclined | Shared ground |
| First Supporting / Lifting | First supports |
| Second Supporting / Lifting | Second supports |
| Extreme-Scale Climb / Support | Extreme-scale platform |
| Reciprocal / Lead-Swapping Hold | Reciprocal support |

Each family declares an **A / Anchor** and **B / Variation** form, producing 24 independently trackable loop variants. A and B may change lead, cadence, acting or support while retaining compatible entry and exit contracts.

Every loop must eventually declare:

- entry and exit pose/contact contracts;
- required rig topology and anchors;
- supported directional size relations;
- repeatability and safe transition windows;
- participating actor roles;
- verb sequence and adverb defaults;
- implementation, review and runtime-readiness state.

All 24 current variants are `planned`, not authored.

### 5. Phased scene graph

Every compiled pairing scene currently uses this canonical shape:

```text
Intro / Couple
    → Loop A / Anchor
    → Loop B / Variation
    → Climax
    → End / Uncouple
```

Intro, climax and end are one-shot phase shells. Loop phases are repeatable nodes. Later scenes may contain additional loops, branches or optional transitions without changing the meaning of the five baseline phases.

The compiler preserves five distinct directional scale relations:

1. equal;
2. first actor one size band larger;
3. second actor one size band larger;
4. first actor two size bands larger;
5. second actor two size bands larger.

Large→Small and Small→Large therefore never collapse into one biomechanical record.

### 6. Contact correction and best-fit resolution

Rig Studio v0.3.1 implements the first authoring-only point-correction slice. A contact lock contains:

- one driven `source_actor` and `source_anchor`;
- one different `target_actor`;
- `origin_anchor` and `axis_anchor` on that secondary actor, which define an oriented local frame;
- a two-dimensional `local_offset`, normalized by the current distance between those two reference anchors;
- explicit rotation/scale inheritance, weight and `authoring_prototype` status.

The contact point does **not** need to be another named anchor. Capture projects the current source point into the secondary frame. Evaluation reconstructs it from the secondary frame every pose, so the virtual socket follows translation, rotation and uniform size changes. A single source anchor may own only one lock; self-targets, collapsed reference frames, malformed offsets and duplicate ownership are invalid. The current solver directly corrects the named point from an order-independent base-pose snapshot, so target-frame anchors must be unconstrained and chained/cyclic graphs are rejected. It does not yet solve the source limb chain, support weight, penetration, directional-size tolerances or gameplay playback.

Evaluation order target:

1. sample the authored base pose;
2. apply body/root verbs;
3. solve declared partner contacts and support anchors;
4. apply reaction verbs;
5. apply secondary motion;
6. apply character- or scene-specific overrides;
7. validate drift, penetration and silhouette limits.

The future resolver will score candidates by topology, directional size relation, required anchors, presentation profile and authored specificity. A bespoke exact match wins; compatible generic animation remains available beneath it. If nothing is safe and runtime-ready, the game uses `Emoji Bonk v0` rather than invisible actors or a false claim of procedural choreography.

## Machine-readable sources

- `data/animation_verbs.json` — semantic verb vocabulary and honest implementation state.
- `data/pairing_storyboard_grammar.json` — legacy flat-sentence compiler inputs and five directional size patterns.
- `data/animation_scene_grammar.json` — canonical phase order, reusable recipes, 12 loop families, 24 variants, compatibility candidates and climax/end shells.
- `scripts/pairing_progress.gd` — compiles and validates all 243 directional phase plans.
- `data/paper_doll_characters.json` — character topology, size, role and attachment declarations.
- `data/paper_doll_artwork.json` — artwork mounted to character slots.
- `data/paper_doll_studio.json` — authoring-stage cast, poses, verb instances and imported scene metadata.
- `addons/rig_studio/contact_lock_solver.gd` — pure capture/reconstruction math for normalized virtual sockets.

`build_pairing_scene()` selects a compatible loop family deterministically from board, morphology and directional size relation. It emits five phases, flattened timed beats, contracts, source IDs and unresolved verbs. `instantiate_scene()` binds symbolic `first` and `second` roles to concrete Rig Studio actor IDs and can load either the whole graph or one isolated phase.

`validate_scene_coverage()` currently proves:

- exactly 12 unique families and 24 variants are declared;
- every recipe reference exists;
- all 243 directional board cells compile;
- each record contains the canonical five phases;
- none incorrectly claims runtime readiness;
- full scenes and both loop phases bind to concrete actors.

## Progress accounting

The project maintains separate ledgers because they answer different questions:

- **Commission board:** Which of the 243 directional pairing demands has a finished authored result?
- **Character board:** Which creatures have registry data, body mapping, builder records and usable artwork?
- **Animation board:** Which verbs, loop variants, phase shells, solvers and compiled plans exist, and at what honest implementation state?

A compiled plan is not a completed commission. A character registry row is not usable artwork. A motion prototype is not an authored verb. This separation is enforced in both documentation and the in-game Dev Progress hub.

## Next implementation order

1. Add limb-chain IK and explicit support/tolerance records above the proven virtual-socket transform.
2. Author one complete Grounded Front-Aligned A loop for two equal Medium Human rigs.
3. Verify contact correction and a clean repeat boundary across the whole loop.
4. Retarget the loop to one-band and two-band directional size tests.
5. Author its B variation and phase transitions.
6. Add runtime best-fit selection while retaining Emoji Bonk as the final safety fallback.
7. Repeat family by family, promoting status only after review and build validation.
