# Chibi NSFW Pipeline v0.1

> Status: paid research in progress. Adult outputs and videos live under the git-ignored `artifacts/` tree.

## Objective

Preserve the short, flat, thick-edged in-game emoji/chibi language while producing adult anatomy and motion. The richer paid morphology tests are retained and reused as anatomical references rather than discarded.

## Two-reference conversion

Each Seedream request receives:

1. **Chibi SFW source** — authoritative for identity, pose, proportions, contour weight, palette, and simplification.
2. **Paid adult research donor** — authoritative only for mature anatomy and species-specific transitions.

The prompt explicitly forbids inheriting the donor's taller proportions, texture, lighting, background, or rendering detail.

## Current subjects

- **Phoenix:** tests adult anatomy surrounded by feathers, wings, talons, and a large tail silhouette.
- **Naga:** tests male anatomy at a humanoid-to-serpent transition with no human legs.

## Motion gate

Only conversions that retain the chibi silhouette and approximately three-head-tall visual language advance to Seedance. Motion tests use 480p, four seconds, no generated audio, and simple locked-camera movement. All outputs remain labelled testing/research regardless of quality.

## Completed research tasks

| Model | Character | Task ID | Cost | Result |
|---|---|---:|---:|---|
| Seedream V5 Pro | Naga two-reference conversion | 3275216 | $0.09 | Chibi proportions and serpent topology retained |
| Seedream V5 Pro | Phoenix two-reference conversion | 3275217 | $0.09 | Chibi proportions and feather masses retained |
| Seedance 2.5 | Naga 480p four-second idle | 3275291 | $0.42 | One coil retained; no human legs appeared |
| Seedance 2.5 | Phoenix 480p four-second idle | 3275302 | $0.42 | Silhouette and feather masses remained stable |
| Seedance 2.5 | Phoenix/Naga paired motion V1, five references | 3276022 | $0.42 | Multi-reference identity held; motion was affectionate/static and SFW clothing leaked back in |
| Seedance 2.5 | Phoenix/Naga paired motion V2, three references | 3276230 | $0.42 | Cleaner nude chibi silhouettes, stable single coil, and readable concealed adult innuendo; rhythm remained gentler than the requested three hard beats |

The exact adult stills, MP4s, receipts, and QA sheets are stored under `artifacts/seedream/chibi_nsfw_pipeline_2026-09-14/` and `artifacts/seedance/chibi_nsfw_pipeline_2026-09-14/`.

## Paired-motion finding

Seedance 2.5 reference mode successfully accepted five ordered images using `[Image N]` prompt labels. For this style, however, more references were not automatically better: the two clothed SFW identity sheets in V1 reintroduced costume details and diluted the requested action. V2 used only the two converted character masters and one shared production-style key. That smaller stack gave the stronger result.

The generator preserved character identity, thick contours, flat colour masses, and the naga's single-coil topology across both tests. It was much less literal about choreography counts. Written requests for three distinct rise/drop cycles became a smooth generalized sway, so future production loops should use authored key poses or first/last-frame controls once the exact pairing composition is established.
