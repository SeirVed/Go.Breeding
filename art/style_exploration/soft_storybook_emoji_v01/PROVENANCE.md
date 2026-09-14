# Soft Storybook Emoji v0.1 — Provenance

> **Status: exploratory AI-generated concept art.** These images are not final production sprites.

Generated on 2026-09-12 with Codex's built-in OpenAI image-generation workflow from original project direction written for Go.Breeding.

The second stress-test lineup and Dragon studies were generated on 2026-09-13 with the same workflow and original project direction.

## Inputs and derivation

- `style-key-lineup.png` was generated from a new written brief describing Cat, Cow, Elf, and Golem/Titan archetypes in an original Soft Storybook Emoji visual language.
- The four scale studies were generated using `style-key-lineup.png` as a character and style reference.
- The Cow and Titan sheets received a background-extraction edit using their own generated concept sheets as edit targets.
- `style-key-lineup-02.png` was derived from the approved visual grammar and the first lineup as a style reference. It introduces Insectkin, Phoenix, Dragon, and Void-born; none of the first lineup's characters were copied into it.
- `dragon-scale-study.png` was derived from the Dragon in the second lineup as an identity reference.
- `dragon-animation-keyframe-16x9.png` was derived from the Dragon guide as a single animation-ready pose. The generated 1672 × 941 image was cropped by 8 horizontal and 5 vertical pixels to an exact 1664 × 936 (16:9) canvas; no character pixels were edited.
- No Breeding Season image, FLA, sprite, or extracted asset was supplied to the image generator or copied into these files. Legacy files were inspected only to understand high-level production ideas such as readable expressions and modular character construction.
- No Microsoft Teams or other vendor emoji image was supplied as an input. The brief explicitly prohibited copying vendor emoji geometry or another studio's visual design.

## Files

| File | Purpose | Alpha status |
|---|---|---|
| `style-key-lineup.png` | Shared four-character style anchor | Verified non-opaque alpha |
| `cat-scale-study-concept-opaque.png` | Tiny, medium, large, and portrait scale treatment | Opaque; generated checkerboard is painted into the image |
| `cow-scale-study.png` | Tiny, medium, large, and portrait scale treatment | Verified non-opaque alpha after background extraction |
| `elf-scale-study-concept-opaque.png` | Tiny, medium, large, and portrait scale treatment | Opaque; generated checkerboard is painted into the image |
| `titan-scale-study.png` | Tiny, medium, large, and portrait scale treatment | Verified non-opaque alpha after background extraction |
| `style-key-lineup-02.png` | Insectkin/Phoenix/Dragon/Void-born style stress test | Opaque RGB review image |
| `dragon-scale-study.png` | Tiny, medium, large, and portrait Dragon treatment | Opaque RGB review image |
| `dragon-animation-keyframe-16x9.png` | Exact 16:9 still for motion testing | Opaque RGB review image |

## Dragon motion test

The ignored local artifacts under `artifacts/seedance/` were generated through Wiro's `bytedance/seedance-2-5` endpoint at 480p, four seconds, MP4, silent, unwatermarked. They are research outputs, not a runtime animation or proof of the planned paper-doll system.

- Task `3247623` used the same still as both first and last frames. It returned 854 × 480 but embedded a white grid across the image. The failed visual result is retained locally as diagnostic evidence.
- Task `3247972` used only the first frame. It returned a clean 480 × 854 portrait clip despite a 16:9 source and requested ratio. Character identity and the prompted shirt-adjustment/wink motion remained readable.
- Each successful Wiro task reported a cost of USD $0.42.
- Credentials remained in the protected local Codex secrets folder and were never copied into the repository, prompt, artifact metadata, or console output.

See `artifacts/seedance/README.md` in a working copy for the exact prompt and local artifact inventory. The `artifacts/` tree is deliberately gitignored.

## Reproduction guidance

The canonical reusable visual grammar and prompt template are in `docs/art_style.md`. Future concepts should use a plain solid review background not present in the character palette. Transparency should be produced and verified as a separate step.
