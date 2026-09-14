# Seedream surgical character tests v01

Date: 2026-09-14

This folder records two independent extensions of the Bull/Cow surgical anatomy proof. Each character has its own GPT-image source, isolation prompt, Seedream prompt, Wiro task, mask, composite and comparison. They were never combined into one generation.

## Insectkin

- Source: `gpt-image-insectkin-isolated-sfw.png`
- Source prompt: `gpt-image-insectkin-isolation-prompt.txt`
- Seedream prompt: `insectkin-surgical-seedream-prompt.txt`
- Wiro model: `bytedance/seedream-v5-pro-uncensored`
- Wiro task: `3261851`
- Charged: `$0.090`
- Core anatomy-underlay mask: `8.31%`
- Total feathered edit region: `9.38%`
- Untouched GPT-image region: `90.62%`

Result: strong success. Seedream retained the pose and registered closely enough for the tiny central clothing mask. The GPT-image face, antennae, wings, fluffy collar, biological teal chitin, limbs and feet remain authoritative. This demonstrates that natural armour and appendages do not inherently break the hybrid workflow when clothing occupies a small, well-defined region.

## Dragon

- Random test selection: adult male Dragonkin
- Source: `gpt-image-dragon-isolated-sfw.png`
- Source prompt: `gpt-image-dragon-isolation-prompt.txt`
- Seedream prompt: `dragon-surgical-seedream-prompt.txt`
- Wiro model: `bytedance/seedream-v5-pro-uncensored`
- Wiro task: `3261853`
- Charged: `$0.090`
- Core anatomy-underlay mask: `36.47%`
- Total feathered edit region: `39.21%`
- Untouched GPT-image region: `60.79%`

Result: usable but less surgical. The head, horns, grin, ear ring, wings, exposed claws and tail register well. Because the source outfit covered most of the torso and legs, the donor controls a much larger portion of the final anatomy and introduces a more muscular body than the clothed source proves. An expanded trouser mask was required to remove a remaining brown edge on the left leg.

## Conclusion

The key predictor is garment coverage, not species complexity. Insectkin was easier than Dragonkin because 90% of her distinctive design could remain untouched. Future GPT-image masters should expose or clearly describe more of the intended body construction beneath small removable clothing layers. Characters wearing full shirts and trousers need authored body silhouettes or an intermediate tight neutral bodysuit reference before the anatomy pass.

The exact raw outputs, Wiro receipts, alignment overlays, QA masks, composites and individual three-step comparisons live under the git-ignored local directory `artifacts/seedream/surgical_tests_2026-09-14/`.

Total Wiro cost for these two successful tests: **$0.180**.
