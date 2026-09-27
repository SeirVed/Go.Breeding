# Modular Anatomy Asset Library

> **Status: architecture and paid-research prototype.** Two chibi adult conversions and two chibi motion studies exist locally under the git-ignored `artifacts/` tree. The runtime overlay renderer and production library are not implemented yet.

## Goal

Animate each creature body once, then independently select clothing, chest form, chest detail, pelvis form, and genital detail. This lets one authored motion support clothed SFW, unclothed-but-featureless SFW, and explicit NSFW presentation without regenerating the animation.

## Layer contract

From back to front, a typical character may contain:

1. base body and species silhouette;
2. species surface markings and attachments;
3. `chest_form` — breast/pectoral volume without explicit detail;
4. `chest_detail` — optional explicit surface detail;
5. `pelvis_form` — smooth, furred, feathered, scaled, plated, or otherwise non-explicit transition;
6. `pelvis_detail` — optional vulva, penis/testes, cloacal, or species-specific explicit detail;
7. clothing and equipment;
8. foreground limbs, tails, wings, and effects.

The exact z-order may vary by pose, but explicit detail must never be baked into the base body or motion frames.

## Presentation profiles

| Profile | Body | Chest form | Chest detail | Pelvis form | Pelvis detail | Clothing |
|---|---|---|---|---|---|---|
| `SFW_CLOTHED` | Yes | As required under costume | Hidden | Non-explicit | Hidden | Yes |
| `SFW_UNCLOTHED` | Yes | Non-explicit | Hidden | Smooth/species-safe | Hidden | No |
| `NSFW` | Yes | Selected | Selected | Selected | Selected | Optional |

This separation also permits deliberately featureless mannequin/reference renders without forcing underwear or other clothing onto a creature.

## Reusable library axes

Do not generate anatomy separately for every species. Build a compact geometry library and adapt its material treatment.

- **Module:** chest form, chest detail, pelvis form, pelvis detail.
- **Body plan:** humanoid biped, digitigrade biped, serpentine, tauric, quadruped, amorphous, constructed.
- **Size:** small, regular, large.
- **View:** front, three-quarter left/right, side left/right, rear where required.
- **Surface:** skin, short fur, long fur, scales, feathers, chitin, plant, stone, cosmic/exotic.
- **Deformation:** neutral plus only the compressed, stretched, or active states required by an animation template.

Geometry and surface are intentionally separate. A regular three-quarter chest form should be recoloured and edge-blended for several species instead of regenerated for each fur colour.

## Recommended first library nucleus

- 9 non-explicit chest forms: three sizes × front/three-quarter/side.
- 9 chest-detail overlays matching those forms.
- 6 vulva overlays: three views × two simplified geometry families.
- 18 penis/testes overlays: three sizes × three views × neutral/active.
- 4 species-transition mask families: fur, scale, feather, exotic material.
- Dedicated serpent/tauric transitions only where ordinary biped patches fail.

That is a few dozen curated shapes, not a few dozen generations per creature.

## Asset package

Each approved patch should contain:

- transparent RGBA colour image;
- grayscale feather/occlusion mask;
- optional separate shadow and highlight layers;
- normalized anchors and bounding box;
- compatibility tags and intended presentation profile;
- source and provenance metadata;
- SFW review thumbnail when the raw asset should remain outside a public repository.

The machine-readable contract lives in `schemas/anatomy_patch.schema.json`. Explicit raster files remain local under `artifacts/anatomy_library/`; public data may reference stable asset IDs without containing the images.

## Authoring pipeline

1. Start from the approved chibi production master.
2. Crop only the chest or pelvis working region at two-to-four times final game resolution.
3. Generate several candidates locally with inpainting or reuse a paid research donor.
4. Curate anatomy and silhouette before colour work.
5. Flatten the candidate toward the chibi palette and contour budget.
6. Extract RGBA, mask, anchors, and provenance.
7. Warp and colour-match the patch onto the canonical body.
8. Downsample and inspect at 96 px and 160 px.
9. Test the patch through all applicable presentation profiles and at least one motion template.

## Local-first generation

The existing local Stable Diffusion installation already contains cartoon/furry checkpoints, inpainting ControlNet, IP-Adapter, and anatomy-specific LoRAs. The preferred cost order is:

1. reuse an approved local anatomy patch;
2. adapt a retained paid research donor;
3. locally inpaint several candidates and curate them;
4. use Wiro only for an unsupported morphology or a comparison study.

Provider generations are never discarded merely because they miss the production target. They remain labelled research and may become donors for later local work.

## Animation contract

Animation templates move named body anchors rather than fixed anatomy pixels. Chest and pelvis patches inherit their root anchor, local scale, rotation, deformation state, z-order, and optional secondary-motion parameters from the template. Switching presentation profile must not alter timing, contact points, camera, or actor positions.

An overlay failing compatibility must fall back to a non-explicit form; it must never guess an anatomically incompatible patch.
