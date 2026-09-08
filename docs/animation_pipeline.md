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
