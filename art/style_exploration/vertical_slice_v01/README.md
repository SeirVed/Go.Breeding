# Vertical Slice Cast v0.1

This folder is a production-risk and storefront-art experiment for the **Soft Storybook Emoji** direction. It deliberately tests four body/material families before the project commits to a forty-plus-creature asset pipeline.

## Cast

| Character | Pipeline stress | Source status |
|---|---|---|
| Adult female Cat courier | Fur, tail, ordinary mammal silhouette, clothing layers | Accepted concept master |
| Adult female Phoenix | Feathers, wings, talons, large tail plume | Accepted concept master |
| Adult female Void-born | Non-solid/starfield material, floating effects | Accepted concept master |
| Adult male Naga ranch keeper | Humanoid-to-serpent transition, no human legs, broad coil | Accepted concept master |

The original cat draft is preserved as `cat-female-source-rejected-thighs.png` so the rejected over-muscular lower-body drift remains visible. `cat-female-source.png` is the corrected, softer-proportioned revision.

## Commercial proof

`sfw-key-art-concept.png` is an early, text-free storefront composition. It demonstrates that the cast can share one thumbnail-readable ensemble while retaining different materials and body plans. It is deliberately classified as **promo art**, not the in-game production style: the rich rendering is too costly to reproduce across variants and animation. The characters still need final names and separately typeset logo treatment before shipping.

`production-chibi-style-key-v02.png` pulls the same identities back toward the approved emoji/chibi target: shorter proportions, thicker contours, flatter material treatment, fewer shape decisions, and cleaner small-size silhouettes. This is the current production target.

`cat-production-scale-guide-v02.png` applies that target to four concrete display uses: tiny head icon, deliberately simplified 96 px full-body sprite, larger static full body, and expressive headshot. It is the first proof that the richer identity can collapse into game-scale art without merely shrinking a painted illustration.

## Paid derivative test

Four Seedream V5 Pro tests are prepared at $0.09 each. They test whether the SFW masters can produce usable local adult-anatomy donors without destroying species identity. Explicit outputs and exact provider receipts belong under the git-ignored `artifacts/seedream/vertical_slice_2026-09-14/` tree.

The provider upload was authorized and all four tests completed successfully. Exact task IDs and costs are recorded in `docs/wiro_credit_ledger.md`.

The results prove that Seedream can preserve all four broad morphologies, including the naga's no-leg topology and the Void-born's starfield material. It does not reliably preserve background, proportions, accessory coverage, or the simplified production style. These outputs are therefore useful as **local anatomy donors only**, not replacement character masters.

The two planned Seedance idle-motion tests are paused until isolated masters are derived from the chibi production key. Animating the richer source tier would validate the wrong production target.

## Production conclusions already visible

- A single style can comfortably cover fur, feathers, cosmic matter, and serpent anatomy.
- The source generator repeatedly ignores requested transparent backgrounds; background removal and edge cleanup must be a deterministic pipeline step.
- Female lower-body mass needs explicit review. Prompting alone does not reliably prevent thigh-heavy drift.
- Modular garments should keep crisp boundaries and avoid crossing wings, tails, hands, or the humanoid-to-nonhuman transition.
- Storefront compositions can use the same masters without prematurely locking sprite-sheet or paper-doll architecture.
