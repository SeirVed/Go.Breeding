# Modular Character Art Production Groups

> **Status: planned production contract.** This is an authoring order and part-ownership specification, not a claim that any creature has approved modular art or facial animation. The existing crash-dummy SVGs are local studies. No cow cutout from the generated whole-sheet bovine study is production-ready.

## Two independent labels

Every part has both a **functional group** (what it does on the rig) and an **art state** (planned, study, approved, mounted, or runtime-tested). A rendered SVG is not automatically approved or playable. The 173 local crash-dummy masters are a catalog study, **not** 173 required drawings for every species. Definitions can be mirrored, reused, omitted, repeated, or replaced by another foundation.

The universal crash dummy is an **authoring reference**, not the current gameplay emergency image. Gameplay still uses the single unknown-character silhouette when no complete cutout exists. A creature kit replaces visible pieces on the same invisible rig; it must never expose the guide skeleton in normal play. Source SVGs are independently editable. A production atlas is generated from approved SVGs and exact rectangles, never treated as a paintable source image; offline study atlases may contain unapproved pieces. Whole-sheet image-generation studies may guide style but cannot be assumed to preserve part identity, pivots, labels, transparency, or seam geometry.

## Functional groups

| Group | Responsibility | Representative catalog parts | Assembly rule |
|---|---|---|---|
| **0 · Mount contract** | Invisible pivots, sockets, overlap, masks, draw order, mirroring, scale and contact metadata. | Head, jaw, eye, shoulder, elbow, wrist, hip, knee, ankle, tail-root anchors. | Specify and test before polishing art; no visible sprite is required for a socket. |
| **1 · Core** | Smallest complete articulated body for one foundation. | `head_shell`, `neck`, `torso`, `abdomen`, `pelvis`/`hip_back`, upper/lower arms and legs, `hand`, `foot`, joint covers. | One neutral front assembly first; no baked face, species appendage, breasts, genitals or clothing. |
| **2 · Face & expression** | Animatable facial pieces mounted to the head. | `face_eye`, `face_pupil`, `face_lid`, `face_brow`, `face_nose`, `face_mouth`, `face_jaw`, optional `face_tongue`/`face_cheek`. | Each paired feature can be instanced left/right; eyelids blink independently, mouth and jaw move without replacing the head. |
| **3 · Main form variants** | Primary silhouette alternatives and proportion presets. | Neutral/MASC/FEMM face, chest, torso, pelvis and hip-back forms; shoulder, ribcage, waist, pelvis and limb-mass channels. | Small/Medium/Large is normally rig scale plus proportions, **not** three identical SVG copies. Add a new master only when the silhouette or joint seam materially changes. |
| **4 · Species kit** | Recognisable creature identity on the selected foundation. | Cow muzzle, ears, horns, hooves, tail and hide; equivalent species-specific head/limb surfaces. | Species art fills core/facial slots or attaches at declared sockets. It does not silently add a second face to a torso cell. |
| **5 · Soft form & anatomy** | Independent volume and presentation-swappable anatomy. | `breast`, `belly`, `glute`, `smooth_pelvis`, genital and chest-detail modules. | Chest volume mounts to the thorax, not abdomen; hip volume mounts to rear pelvis. Keep these separate from structural form for scaling and secondary motion. |
| **6 · Extended appendages** | Optional silhouette and movement chains. | Wings/feathers, antennae, fins, shell/plates/spines, tusks, trunk and tentacles. | Each chain has a base, segment(s), tip where needed, plus its own occlusion and pivot test. |
| **7 · Alternate foundations** | Topology replacements, not ordinary attachments. | Digitigrade/unguligrade legs, serpentine lower body, tauric join/body, quadruped body, amorphous core. | Explicitly replace incompatible core parts and validate a complete alternate assembly. |
| **8 · Presentation & effects** | Outfits, surface markings, wear and non-body effects. | Clothing, surface/damage overlays, halo and effect overlays. | These mount over approved anatomy and cannot repair a missing body silhouette. |
| **9 · Wildcard/mutant** | Unusual counts and placement of otherwise defined parts. | Extra-limb sockets, repeated heads/limbs, body lobes and pseudopods. | Reuse repeatable definitions as instances; make a new SVG only for genuinely new geometry. |

The groups are authoring responsibilities, not ten mandatory atlas pages or a fixed creature count. A part can participate in two concerns: a cow muzzle is species-specific art **and** mounts through the facial-expression contract. The catalog's existing `family` field is a narrower atlas/sorting label; this document is the production sequence across those families.

## Face contract

The `head_shell` is the shape and occlusion surface. For a new modular character it must not contain painted eyes, mouth, nose, ears or horns if those are separately mounted. The existing `face` plate remains a compatibility/placeholder option for old crash-dummy assemblies; a modular face and the whole `face` plate are mutually exclusive on one head.

The catalog's current foundation lists still require `face` for the legacy assembly. Modular facial coverage is a planned alternative; the runtime readiness resolver must explicitly recognise a complete modular face before that plate can be omitted in gameplay. Merely adding the catalog slots does not change readiness or animate expressions.

- Eye, pupil, lid and brow are separate **mirrorable instances**, so left and right can blink, wink, glance and emote independently. Each eye gets a local anchor; pupils and lids inherit that eye's transform.
- Mouth and jaw are separate central controls. A smile, open mouth, pant or speech-like shape may use a small curated set of shape variants and/or transforms, rather than a new full head for every expression.
- Nose/muzzle geometry is species-dependent. A bovine muzzle may be a stable base with the mouth moving over or below it. Optional tongue and cheek pieces are authored only when a motion needs them.
- Expression controls operate in head-local coordinates and survive head translation, rotation and scale. Draw order and clipping are tested in neutral, blink, wink, mouth-open and head-turned poses.
- The first face pass is front-view only. Back, side and three-quarter art are added when a real animation requires them, not multiplied blindly across every expression.

The newly catalogued `face_*` parts are `reserved`: names and intended mounts exist, but no approved SVG, facial controller, expression timeline or runtime coverage is claimed.

## Order of work and acceptance gates

1. **Lock one slot contract.** Record logical bounds, pivot, parent/child sockets, optional/replacement status, mirror rule, z-order, overlap/occlusion, scale range, and source provenance. Verify it against the invisible rig.
2. **Author one SVG at a time in a small assembly batch.** Make neutral front Core and a minimal Face & Expression slice. Rasterize each source SVG directly at the target density; inspect its alpha and source-to-atlas rectangle.
3. **Assemble immediately.** Review neutral, extreme joint rotations, walk frames, a blink/wink, and an open mouth at full-character, portrait and map-token sizes. Fix source SVGs and mounts before increasing part count.
4. **Add the species kit.** The first cow vertical slice needs one head shell, facial slots/muzzle, neck, torso/abdomen/pelvis, one mirrorable arm and leg chain, hand/hoof, ears/horns and only a tail if its chain genuinely works. Do not redraw left/right copies without an asymmetry reason.
5. **Then add form, back view and optional groups.** Add only variants supported by a visible need. Test the same animation and cutout resolver after each batch; a beautiful isolated part is not a pass if the assembled body gaps or doubles a face.
6. **Promote deliberately.** `study` → `approved source` → `atlas-built` → `mounted` → `runtime-tested` are separate states. Only tested production art is eligible for the repository/runtime package under the existing media policy.

The first acceptance result is **one coherent, genuinely cut-and-mounted cow**, not a filled 173-cell atlas. The previous whole-sheet bovine study failed this gate: several torso, chest, pelvis and tail-labelled cells became extra cow heads, and the source sheet was too small for clean modular gameplay art. That study remains research rather than being quietly repackaged as production pieces.
