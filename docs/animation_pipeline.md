# Paired Paper-Doll Animation Pipeline

> **Status: architecture plan.** `Emoji Bonk v0` is implemented as the universal placeholder. Real paper-doll rigs, retargeting, compatibility scoring, and bespoke choreography are not implemented yet.

## Goal

Author a paired 2D cutout—or “paper-doll”—animation once, then populate its Actor A and Actor B slots with compatible creature sprite variants. The system should always choose the most specific animation it can safely play while preserving an honest placeholder at the bottom of the ladder.

The creature registry is deliberately open-ended. The current roster is a snapshot, not an animation budget or species cap. New monsters join by declaring stable IDs, body archetypes, measurements, anchors, and anatomy tags.

## Resolution ladder

After rejecting incompatible templates, prefer:

1. bespoke ordered species-pair variant;
2. exact ordered pair of body archetypes;
3. ordered size + morphology template;
4. ordered size template;
5. board-category template;
6. universal paired paper-doll template;
7. `Emoji Bonk v0` with `PLACEHOLDER ACTIVE`.

Direction is part of the key at every tier: Small→Large and Large→Small are different biomechanical problems. Selection must be deterministic for the same actors, context, content version, and seed.

## Paired template structure

A template owns one shared stage and two named actor roots. Each actor exposes consistent anchors such as root, hips, torso, head, hands, feet, and effect origin. Shared timing and contact anchors prevent the two independently populated dolls from drifting apart.

Each creature skin supplies:

- ordered sprite layers and z-order;
- local anchor offsets and limb lengths;
- default scale and safe scale range;
- attachments such as ears, tails, horns, wings, extra limbs, or effects;
- required anatomy and exception tags;
- optional additive idle and reaction motion.

### Partner focus and fourth-wall rule

Paired breeding scenes default to private interaction rather than audience performance. Actor eyelines target the partner, a relevant contact point, or close naturally during a reaction. They do not look into the camera, wink at the player, present their bodies to the viewer, or otherwise acknowledge a fourth wall unless a specifically labelled variant deliberately overrides this rule. Camera-facing gallery portraits and character-select idles are a separate animation context and do not set the acting language for paired scenes.

### Presentation-independent anatomy layers

Animation timing and body motion must not bake in clothing or explicit anatomy. Each actor root may receive independent chest-form, chest-detail, pelvis-form, pelvis-detail, and clothing layers attached to named anchors. The same motion can therefore render as `SFW_CLOTHED`, `SFW_UNCLOTHED`, or `NSFW` without regenerating choreography.

Compatibility checks apply to anatomy overlays just as they do to animation templates. Missing or incompatible explicit detail falls back to a featureless/species-safe form; it never invents an attachment. See `anatomy_asset_library.md` and `schemas/anatomy_patch.schema.json`.

## Template metadata

Every animation template should declare:

- stable template ID and revision;
- board and ordered Actor A/Actor B roles;
- supported size and morphology bands;
- required, supported, and prohibited anatomy tags;
- anchor and scale tolerances;
- quality tier: Placeholder, Universal, Adapted, or Bespoke;
- production status and credits.

Compatibility is a hard gate before specificity scoring. A visually closer template must not be selected if its required anchors or anatomy are missing.

## Long-tail production model

The first real animation can be a universal paired template. Later work adds Large, Small, morphology, ordered archetype, exception-tag, and species-specific variants. Each addition improves a known part of the resolver without making the rest of the roster unusable.

The commission boards track the 243 ordered archetype targets; the Guild Star Ballot reports demand. New species and bespoke overrides may grow indefinitely without turning the board into an unbounded species-by-species matrix.

The board must report two distinct facts:

- **Playable coverage:** a safe animation or honest placeholder can run.
- **Bespoke progress:** a custom animation for this exact commission has been authored and reviewed.

“Fallback exists” must never be presented as “custom commission complete.”

## Generative motion studies

Short external video generations may be used to test whether a static character design remains readable in motion. These clips are reference experiments only. They are not paper-doll templates, production sprites, authored animation coverage, or evidence that the runtime resolver exists.

The local `scripts/wiro_seedance.py` helper submits or resumes Wiro Seedance tasks without committing credentials. It supports first/last frames, ordered sets of 1–30 reference images, 480p or 720p output, four-to-thirty-second durations, polling by task ID/token, and local download. Reference mode addresses inputs as `[Image 1]`, `[Image 2]`, and so on, and cannot be combined with first/last-frame guidance because the provider composes the opening shot itself. Source credentials must remain outside the repository in environment variables or the protected Codex secrets folder.

Provider outputs require visual QA. The 2026-09-13 Dragon experiment demonstrated two current hazards: identical first/last frames produced an embedded white grid, while a first-frame-only retry ignored the requested landscape ratio and returned portrait video. Neither result changes the planned runtime architecture.

The 2026-09-14 Phoenix and Naga chibi studies successfully retained compact silhouettes, thick contours, adult anatomy, and nonhuman topology over four-second first-frame-only animations. They remain research clips, not authored runtime coverage. The helper now stores receipts and retries a completed task's transient output-file 404 instead of resubmitting it.

The first Titan→Ranger study used an authored golem/cow staging image as Seedance's first frame. It preserved a clear Large-male/Medium-female mass difference, stable planted support, dangling hooves, and partner-only eyelines, but generalized two requested lift cycles into one soft lift/lean/nuzzle progression. This supports authored contact poses while reinforcing that generated clips remain motion reference rather than timing masters.
