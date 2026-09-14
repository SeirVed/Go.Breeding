# Bovine character pipeline study v01

Date: 2026-09-14

This study tests a two-stage character-art pipeline:

1. GPT-image establishes a safe-for-work canonical Bull/Cow species guide and the shared Soft Storybook Emoji visual language.
2. Three Wiro Seedream Uncensored image-to-image models receive that exact source and the exact same anatomical-derivation prompt.

The comparison is deliberately controlled: one source, one prompt, one output per model, 2K, 3:2, and no watermark.

## Canonical source

- `gpt-image-bovine-guide-sfw.png`
- `gpt-image-guide-prompt.txt`
- Style references: `../soft_storybook_emoji_v01/style-key-lineup.png` and `../soft_storybook_emoji_v01/cow-scale-study.png`

The source distinguishes a large rounded-power bull from a plush feminine cow while keeping their horns, ears, muzzle, patch language, hooves, eyes, palette, and small-scale simplification rules related.

## Seedream comparison

The shared transformation brief is saved in `seedream-anatomical-derivation-prompt.txt`.

| Model | Wiro task | Charged | Result |
| --- | ---: | ---: | --- |
| Seedream V4.5 Uncensored | 3259138 | $0.040 | Preserved the plush emoji rendering best, but omitted the requested anatomical detail and collapsed the model sheet to three figures. |
| Seedream V5 Lite Uncensored | 3259141 | $0.035 | Followed the source sheet and explicit brief most aggressively at the lowest price, but confused sex/anatomy in some views and retained source clothing in the tiny icon. Mandatory anatomy QA. |
| Seedream V5 Pro Uncensored | 3259137 | $0.090 | Produced the cleanest consistent front/three-quarter/back turnaround and strongest construction detail, but pushed both characters toward a more muscular anatomy than the source. |

Total successful-run cost: **$0.165**.

The downloaded outputs, receipts, and comparison image live under the git-ignored local path `artifacts/seedream/bovine_pipeline_2026-09-14/`. They are kept out of the public repository while the adult branch and release boundaries are still being decided.

## Working conclusion

- Use GPT-image for canonical clothed species identity, palette, expression, costume, and emoji-scale guides.
- Trial V5 Pro as the structural anatomy/turnaround pass, followed by a deliberate softness and proportion correction.
- Use V5 Lite for cheap explorations and alternate candidates, never as an unattended production master.
- Do not rely on the word “uncensored” as a capability guarantee; validate compliance, sex consistency, limb count, view consistency, patch maps, and body-type drift on every output.
- V4.5 may still be useful for safe-for-work unclothed mannequin/silhouette studies, but this run does not support using it for complete adult anatomy.

## Surgical cow proof

A second controlled test isolated the GPT-image cow before asking Seedream to make an anatomical underlay:

- Canonical isolated source: `gpt-image-cow-isolated-sfw.png`
- GPT-image isolation brief: `gpt-image-cow-isolation-prompt.txt`
- Seedream surgical brief: `cow-surgical-seedream-prompt.txt`
- Seedream V5 Pro task: `3260792`
- Charged: `$0.090`

The isolated source kept Seedream closely registered to the original character. `scripts/composite_seedream_surgical.py` then detected the rust top and indigo shorts, expanded and feathered the resulting garment mask, and used the Seedream result only as an underlay inside that mask. The core replacement region covers 20.25% of the canvas; 78.05% remains completely outside even the feathered mask.

This result supports the hybrid pipeline. GPT-image can remain authoritative for identity, expression, extremities, palette, edge language and the final visible surface. An adult-capable model supplies a narrowly scoped anatomy layer. Production character sources should export explicit authored clothing/body masks; the colour-derived convex-hull mask used here is a proof of concept, not the final asset format.

Raw output, receipt, QA mask, alignment overlay, hybrid composite and the three-step comparison are stored locally under the git-ignored path `artifacts/seedream/bovine_surgical_pass_2026-09-14/`.
