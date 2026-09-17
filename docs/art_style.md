# Soft Storybook Emoji Art Direction

> **Status: exploratory visual specification with one generic motion prototype.** Static concept studies and the six-profile Paper-Doll Walk Lab exist. Species production sprites and final character designs are not locked.

## Purpose

Create an original visual family that reads immediately like emoji at small sizes and reveals distinct, hand-illustrated characters when enlarged. Every creature should look native to the same warm clockwork-fantasy world without becoming a copy of any platform vendor's emoji set or another game's artwork.

Working name: **Soft Storybook Emoji**.

## Core visual grammar

- Build recognition from the outer silhouette first.
- Use rounded, exaggerated anatomy and large, readable facial features.
- Draw with clean vector-like painted shapes rather than realistic rendering or pixel art.
- Use a dark version of each local colour for the outer contour; avoid universal pure-black outlines.
- Keep interior lines sparse and lighter/thinner than the silhouette contour.
- Give each major form one broad shadow region and one restrained highlight region.
- Allow only subtle gradients that clarify volume. Avoid glossy 3D-clay rendering and microtexture.
- Suggest fur, hair, feathers, leaves, scales, cloth, or stone with a few large graphic shapes.
- Use a warm, moderately saturated palette with one strong identity accent.
- Keep the expression friendly, mischievous, or emotionally legible rather than neutral and mannequin-like.

## Character recipe

Every design needs three layers of identity:

1. **Species read:** choose two or three dominant signals such as ears + tail + muzzle, horns + patches + broad muzzle, or boulders + moss + glowing core.
2. **Individual read:** choose one colour accent, one restrained accessory, and one characteristic expression or posture.
3. **World read:** retain the shared contour, shading, shape language, warmth, and detail budget.

Do not add detail merely because the canvas is large. The large version should clarify the same design, not reveal a different costume.

## Presentation tiers

These are separate static interpretations of one design, not an animation or rigging specification.

| Tier | Intended display | Framing | Detail rule |
|---|---:|---|---|
| Tiny emoji | 32–48 px | Head plus the strongest species marker | Eyes, mouth, silhouette, and at most four dominant colour regions |
| Medium sprite | 96–160 px | Full body, neutral three-quarter view | Preserve gesture and species markers; remove tiny seams and surface marks |
| Large character | 384–768 px | Full body, same three-quarter view | Full approved design with modest material cues; no new identity features |
| Headshot | 256–512 px | Head and shoulders | Highest facial-expression fidelity; preserve the same proportions and palette |

The tiny and medium tiers must be judged at their actual display size. A downscaled large illustration is not automatically a successful emoji.

## Two-tier asset policy

The project intentionally uses two rendering tiers. They share identity but do not share production obligations.

### Source-control promotion rule

Production-approved runtime art may be committed and pushed with the code it supports. Test renders, paid generations, reference sheets and unproven style studies remain local under ignored research/artifact paths. Promotion requires that an asset has a declared runtime purpose, passes its transparency/pivot/scale checks, is referenced by a tested manifest, and is described honestly as draft or final. Human Zero is the first promoted draft cutout; its small deterministic SVG sources are public production assets, while Catgirl and paid motion studies remain local research.

### Tier A — in-game production master

- Approximately 3–3.5 heads tall for ordinary humanoid bodies.
- Oversized head and eyes, compact torso, short limbs, and one dominant silhouette gesture.
- Thick near-black or locally dark outer contour; sparse interior lines.
- Two or three flat values per material and almost no texture.
- Fur, feather, scale, plant, stone, and cosmic details collapse into a few large graphic clumps.
- Must remain recognisable at 96 px tall and straightforward to recolour or redraw.
- This tier is the source for sprites, portraits, expressions, costumes, breeding placeholders, and eventual animation templates.

### Tier B — promotional render

- May use taller proportions, richer lighting, storybook texture, environmental depth, and more detailed material rendering.
- Intended for storefront capsules, banners, Patreon posts, update art, and character reveals.
- Must be derived from an approved Tier A identity.
- Must never silently replace the production master or become the required quality bar for every game variant.

`art/style_exploration/vertical_slice_v01/production-chibi-style-key-v02.png` is the current Tier A target. `sfw-key-art-concept.png` in the same folder is a Tier B example.

### Production-master rejection triggers

Reject or simplify a proposed Tier A design if any of these are true:

- It needs painterly lighting to read.
- Hair, fur, feathers, scales, or clothing require many small repeated marks.
- The character stops reading when reduced to 96 px.
- Recolouring an outfit would require repainting adjacent anatomy.
- A competent non-specialist cannot reproduce a new expression from the guide.
- Female lower-body mass drifts into exaggerated bodybuilder anatomy unless that individual character explicitly calls for it.

## Shape and proportion rules

- Prefer a stable three-quarter view for initial designs.
- Hands, feet, ears, horns, wings, tails, and other identifiers may be enlarged for readability.
- Small creatures can carry a larger head-to-body ratio and quicker curves.
- Large creatures should read through mass, broad shapes, and a lower visual centre of gravity—not through extra detail.
- Refined creatures favour upright, tapered shapes; feral creatures favour forward energy and sharper rhythm.
- Exotic, bestial, tauric, winged, amorphous, and constructed bodies may break humanoid proportions while retaining the same face, contour, palette, and shading grammar.

## Palette and rendering budget

Target a compact functional palette:

- 2–3 principal local colours.
- 1 identity accent.
- 1 eye/emissive colour where needed.
- One shadow and one highlight derived from each local colour.

Avoid photographic texture, individual hair strands, dense scale fields, noisy fur, tiny jewellery, and decoration that disappears below 128 px.

## Static generation template

Use this as the reusable starting prompt, replacing bracketed fields:

```text
Use case: stylized-concept
Asset type: static character design for a 2D monster-breeding game
Primary request: Create one original [SPECIES/ARCHETYPE] in the Soft Storybook Emoji style. It must read immediately as [SPECIES] at 48 px and reveal a distinct individual character when enlarged.
Subject: [BODY SHAPE], [TWO OR THREE SPECIES SIGNALS], [PALETTE], [ONE ACCENT], [ONE SIMPLE ACCESSORY], [EXPRESSION/PERSONALITY].
Style: polished 2D storybook emoji; clean vector-like painted shapes; rounded exaggerated anatomy; strong silhouette; dark local-colour outer contour; sparse interior lines; one broad cel-shadow and one restrained highlight per major form; only subtle gradients for volume; warm hand-illustrated personality.
Composition: isolated neutral three-quarter view, centred, complete silhouette, generous padding.
Material treatment: imply [FUR/HAIR/FEATHERS/SCALES/STONE/PLANT/CLOTH] with a few large graphic shapes, never microtexture.
Constraints: original visual language; no copied vendor emoji geometry; no copied game or studio style; no glossy 3D-clay look; no photorealism; no pixel art; no text; no watermark; no scenery; no extra characters; no animation frames; no excessive costume detail.
Background: plain solid review colour that does not occur in the character. Do not draw a checkerboard.
```

For a multi-scale study, add:

```text
Show four consistent static interpretations: tiny head icon, medium full-body sprite, large full-body character, and expressive headshot. Preserve the exact identity, markings, palette, costume, and proportions. Simplify deliberately as display size decreases. Arrange with generous spacing and no labels, grid, or border.
```

## Output workflow

1. Establish an anchor lineup using several radically different body families.
2. Approve the shared visual grammar before expanding the roster.
3. Generate each creature's large neutral design against a plain opaque review colour.
4. Derive and review the tiny, medium, and headshot interpretations against the approved design.
5. Verify readability at 48 px and 128 px.
6. Remove the review background as a separate, verified post-process when transparent assets are required.
7. Numerically verify that PNG output contains a non-opaque alpha channel; a visible checkerboard is not proof of transparency.
8. Keep transparent character images out of video generators unless their alpha handling is verified. Flatten onto a deliberate background first.

## Acceptance checklist

- Recognisable species silhouette at 48 px.
- Same individual is recognisable in every presentation tier.
- No presentation tier introduces different markings, costume pieces, or anatomy.
- At most two or three dominant species signals.
- One clear individual accent and one restrained accessory.
- Shared contour and two-step lighting remain consistent with the style family.
- No microtexture or detail that turns to noise at game scale.
- Character remains readable in greyscale silhouette.
- Background is either a declared review colour or verified alpha—not a painted transparency grid.

## Initial stress-test cast

- **Catgirl base:** 5′5″ Medium–Neutral, quick, ear-and-tail-led silhouette; the first planned species and wardrobe cutout stack for the invisible paper-doll rig. Its actual alpha-clean sprite pieces have not been authored yet.
- **Cow:** large, broad, horn-and-muzzle-led silhouette.
- **Elf:** medium, refined humanoid with ear-and-hair-led silhouette.
- **Golem/Titan:** enormous constructed body using mass, stone grouping, moss, and a restrained emissive core.

## Second stress-test cast

Selected from the canonical registry on 2026-09-13 to challenge the same grammar with four different silhouette families:

- **Insectkin:** compact adult humanoid, antennae, chitin grouping, and translucent wings.
- **Phoenix:** tall adult avian humanoid, flame-feather hair, folded wings, and tail plumage.
- **Dragon:** large adult dragonkin, swept horns, compact wings, heavy tail, scales, and simple clothing.
- **Void-born:** slender adult exotic humanoid, crescent hair mass, detached/ribbon forms, and a restrained star-field treatment.

The Dragon was randomly selected from this lineup for the first cross-scale guide and Seedance motion test. This selection is exploratory and does not promote Dragon above the rest of the registry.

The files under `art/style_exploration/soft_storybook_emoji_v01/` are exploratory references. The anchor lineup has verified transparency. The cow and titan sheets have verified transparency after background extraction. The cat and elf sheets retain an opaque generated checkerboard and are concept-only examples of scale treatment.
