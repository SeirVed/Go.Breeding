# SFW and NSFW Distribution Model

> **Status: approved architecture; storefront configuration undecided.** No commercial build or adult-content package is currently shipped.

## Product structure

Maintain one proprietary Godot codebase with separately packaged content profiles:

- **SFW:** shared systems, safe presentation, layered emoji, and Emoji Bonk v0.
- **NSFW:** the shared game plus separately delivered paid artwork, dialogue, paper-dolls, and animation.

The free build must not contain locked or encrypted paid assets. NSFW material belongs in a private source/asset location and a separate release depot or package. Both editions remain Copyright © 2026 SeirVed, All Rights Reserved; purchasing either edition does not transfer ownership.

## Storefront options

The implementation should remain capable of supporting:

1. a paid NSFW game with a linked free SFW demo;
2. a free SFW base game with separately downloaded paid NSFW DLC, if the storefront approves the precise arrangement;
3. two independent applications if age-gating, territory, payment, or marketing rules require complete separation.

Storefront topology must not be hard-coded into genetics, saves, creature data, or animation selection.

## Build boundaries

- Shared mechanics and safe data live in the canonical project.
- SFW and NSFW manifests list every included content package explicitly.
- Export validation fails if an SFW build references an NSFW asset or identifier.
- Paid assets are never committed to a public repository.
- Saves use stable content IDs. An SFW build may preserve unavailable NSFW references but must render safe substitutes.
- The NSFW profile may replace Emoji Bonk v0 with the best compatible paid paper-doll animation.

## Licensing boundary

The public repository is source-visible, not open source. It grants no right to publish builds or derivative games. Official binaries will carry a separate end-user agreement permitting personal installation and play while prohibiting unauthorised redistribution, resale, repackaging, and asset extraction to the extent permitted by law.
