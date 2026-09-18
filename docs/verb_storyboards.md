# Verbs and Pairing Storyboards

> **Status: planning compiler implemented; runtime choreography incomplete.** The compiler produces 243 directional `PLACEHOLDER_PLAN` records. It does not replace Emoji Bonk, increment commission progress, or claim that contact animation exists.

## Verbs first

`data/animation_verbs.json` is the canonical motion vocabulary. Version 0.3.0 defines twenty-one small actions across travel, orientation, gesture, support, contact, transition, cyclic, reaction and reset categories. Each verb declares participant roles, affected channels, optional required anchors, defaults and one of two honest implementation states:

- `motion_prototype` — Rig Studio can visibly preview the body-offset portion;
- `contract_only` — the verb is valid planning language but still needs constraints, anchors, IK or a transition implementation.

The nine current motion prototypes are Approach, Circle Partner, Plant Stance, Lower Centre, Brace, Rise, Pelvis Pulse / Thrust, Reaction Bounce and Sway Together. Contact verbs such as Support Lift, Supported Climb, Settle Contact and Hold Anchors remain contracts.

## Then sentences

`data/pairing_storyboard_grammar.json` composes verbs rather than storing 243 unrelated animations. `PairingProgress.build_pairing_storyboard()` resolves:

1. the directional commission and board (`m+f`, `m+m` or `f+f`);
2. the first partner's Feral, Neutral or Refined opener;
3. equal scale, one-band directional differences or two-band directional extremes;
4. the board's lead/response voice;
5. contact settle, hold, cadence and reaction;
6. release and loop reset.

The output contains the source commission key, descriptor, readable sentence, timed beats, symbolic role bindings, default parameters, unresolved verbs and total ticks. Pelvis Pulse and Reaction Bounce share the `cadence` parallel window. Every other beat is ordered.

`instantiate_storyboard()` binds symbolic `first` and `second` references to concrete Rig Studio actor IDs such as `A` and `B`. A preview-only option removes `contract_only` beats so the nine implemented body-motion verbs can be evaluated without pretending the missing contact beats ran. The full instance list retains inert contracts for authoring and inspection.

Rig Studio's Animation Editor exposes board, first-body, second-body and phase selectors plus **Load phased scene into Actor A/B**. The flat storyboard remains available for diagnostics, while normal authoring now uses `build_pairing_scene()` and `data/animation_scene_grammar.json`. Loading the entire graph or one isolated phase is one undoable operation: it applies roles and size bands to the first two actors, extends the timeline, stores source metadata and inserts the selected beats. Implemented beats preview; inert contracts remain visible as the work queue. Loading never writes commission progress.

## Then phased scenes

Every current commission also compiles into Intro / Couple → Loop A → Loop B → Climax → End / Uncouple. The animation grammar declares 12 biomechanical loop families with Anchor and Variation forms, giving 24 independently trackable loop variants. Entry and exit contracts are stored on loop phases so future transition and contact solvers can reject incompatible joins instead of guessing.

All 24 variants remain `planned`; none is production-authored. `validate_scene_coverage()` verifies the family/variant count, recipe references, five-phase topology, 243 directional records, actor binding and the strict `runtime_ready: false` boundary. The canonical architectural contract lives in `docs/parametric_choreography.md`.

Directional order matters. `Scout → Titan` uses the larger second partner as support and a Supported Climb. `Titan → Scout` lowers the larger first partner and uses Support Lift. They are different storyboards even though the same archetypes appear.

## Board voices

Jack & Jill keeps the established 81 named coupling descriptions and adds a complementary lead/response beat. The same-sex boards now receive real generated direction instead of “awaiting design” filler:

- **Jack & Jack:** competitive reciprocity, leverage and visible lead exchanges; shared Feral, Neutral and Refined pairs shade toward roughhousing, workmanlike counterplay or courtly rivalry.
- **Jill & Jill:** mirrored reciprocity, flowing role exchange and deliberate hand-offs; shared morph pairs shade toward playful pursuit, cooperative balance or graceful symmetry.

Mixed morph pairs describe the first partner's initiative flowing into or meeting the second partner's counterplay. Size-order text names which partner supplies reach/support and which partner climbs, redirects or works inside that frame.

## Example placeholder sentence

`jack_jack|small_neutral>large_neutral` compiles to fourteen beats:

`Approach → Face Partner → Plant Stance → Supported Climb → Brace → Exchange Lead → Settle Contact → Hold Anchors → Pelvis Pulse / Thrust + Reaction Bounce → Sway Together → Nuzzle → Release → Reset Loop`

The compact sequence appears on each in-game Dev Progress notice. The full role-labelled sentence is its tooltip. Use the ignored QA dump for complete inspection:

```powershell
Godot.exe --headless --path . --script res://tools/storyboard_dump.gd
```

This writes `artifacts/pairing-storyboards-placeholder-v01.json` with all 243 records. Generated QA output is not source-controlled or exported.

## Readiness boundary

Every compiled record deliberately sets `status: PLACEHOLDER_PLAN` and `runtime_ready: false`. `validate_storyboard_coverage()` checks the dynamic board/body-type count, unique IDs, minimum beat count, known verb references and the non-ready guard. The runtime smoke test also proves that inverted size order changes the sentence and that both same-sex board voices are present.

The next implementation layer is semantic partner/contact anchors, then constraints for Reach To, Hold Anchors, Support Lift, Supported Climb, Rotate/Exchange Lead, Settle Contact and Reset Loop. Only after a sentence can be evaluated or baked without anchor drift may it become a universal playable template beneath bespoke overrides.
