# Crash Dummy Universal Parts Contract

> **Status: semantic catalog and offline media pipeline.** The public repository defines every known part, topology and atlas label. SVG masters, raster chunks, generated atlases and assembled review examples remain local under `art/offline/crash_dummy_v01/` until individual assets are explicitly promoted.

The existing local study has 173 separate SVG masters, 173 raster chunks, 15 labelled family pages and five bounded runtime-atlas pages. The catalog now has **108 definitions / 182 expanded entries** after adding nine `reserved` facial-expression slots. Those nine have no SVGs; the older offline atlas snapshot has not been rebuilt to include their missing-art cards. The 173 rendered pieces are an art-completeness study of the earlier catalog, **not** a claim that reserved creature parts are approved, mounted in Rig Studio or playable. Reserved entries remain marked `reserved` even when an SVG study exists.

The functional authoring order and acceptance gates live in [Modular Character Art Production Groups](art_production_groups.md). A creature needs a coherent slice of the catalog, not one of every entry.

## Source order

1. `data/crash_dummy_part_catalog.json` defines semantic parts, variants, reuse and topology requirements.
2. One independent SVG master is authored for each expanded ID selected for production.
3. `tools/build_crash_dummy_atlas.py` renders those vectors directly at the requested density.
4. The tool emits individual PNG chunks, exact runtime-atlas rectangles and labelled family pages. Runtime textures are paged to at most 4096 × 4096 pixels; each entry records its page index and rectangle.
5. Rig Studio mounts chosen definitions as character-specific instances.

The raster atlas is generated output, never an editing source. Corrections happen in one SVG and propagate on the next build without degrading unrelated pieces.

## Definition versus instance

One mirrorable `upper_arm_neutral_front.svg` definition may become left, right, third, fourth or otherwise mutant limb instances. `repeatable` allows multiple instances; `mirrorable` permits negative-X reflection. Separate left/right media is reserved for genuinely asymmetric anatomy, markings or equipment.

Form and anatomy are independent dimensions. `neutral`, `masc` and `femm` are selectable starting shapes for structural pieces such as face, torso, chest, pelvis and hip back. They are presets, not sex locks: a character may mix those forms part by part and then apply species, archetype and individual proportion values.

Breasts, glutes and belly volume are separate soft-form modules rather than paint baked into the torso or pelvis. Each has its own scale channel and may later receive secondary-motion parameters without requiring a duplicate base body. A restrained Noble, a strongly dimorphic Primal and an individual exception can therefore share the same rig contract. `m_genital`, `f_genital`, `smooth_pelvis`, cloacal and species-specific modules remain independently swappable, so neither structural form nor soft-form selection hard-codes genital anatomy.

The initial morph channels are shoulder width, ribcage width, waist width, pelvis width, limb mass, breast scale, glute scale and belly scale. These values are authoring controls around curated SVG masters, not permission to distort one finished raster image. Rig Studio should retain the selected source form and channel values as editable character data.

Composition order is explicit: foundation → structural form → soft form → anatomy → species attachments → facial expression → presentation. This gives soft parts a stable parent transform while allowing animation verbs to add local secondary motion.

The old one-piece `face` plate remains a compatibility fallback for crash-dummy assemblies. New modular character faces instead use separate eye, pupil, lid, brow, nose, mouth, jaw and optional tongue/cheek slots. They are **planned catalog definitions only**: no approved facial SVGs, controller, blink, wink or gameplay expression animation exists. A new head shell must not bake in features intended for those slots; displaying the legacy face plate and modular face together is invalid. Species-specific muzzle geometry can mount through the same face contract without becoming a second face elsewhere on the body.

## Missing art remains visible

The labelled atlas expands every catalog definition even when no SVG exists. Missing initial masters receive an orange `INITIAL SVG MISSING` card; reserved future entries without art receive a neutral `PLANNED · NO SVG` card. A rendered reserved study is labelled `SVG STUDY · RESERVED` rather than production-ready. Runtime atlas metadata retains every expanded ID; missing entries have a null rectangle, while rendered entries have a page index and exact rectangle. This makes unused and mutant-ready parts auditable without falsely treating studies as finished game assets.

## Offline boundary

`art/offline/.gdignore`, `.gitignore` and `export_presets.cfg` jointly prevent local masters and generated media from entering Godot imports, public Git history or playable packages. Only catalog/schema/tool/document changes are pushed during this exploration phase.
