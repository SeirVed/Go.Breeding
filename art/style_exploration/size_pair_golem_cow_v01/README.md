# Titan × Ranger Size-Pair Study v0.1

> Status: paid research in progress. The large male golem maps to **Titan** (Large Neutral); the medium female cow maps to **Ranger** (Medium Neutral).

This test adds a missing production rule to the paired-motion pipeline: actors remain emotionally focused on one another and never acknowledge the camera or fourth wall.

## Source strategy

The pre-existing golem scale sheet matched the intended style, but the available adult cow study belonged to a taller, more rendered tier. The built-in GPT image generator therefore authored one matching, fully clothed production-chibi staging frame from three references:

1. golem scale sheet — identity, boulder construction, moss, glow, and Large silhouette;
2. isolated SFW cow master — identity, markings, clothing, and Medium feminine silhouette;
3. production-chibi style key — edge weight, flat colour masses, and simplification.

The result is `golem-cow-paired-staging-sfw-v01.png`. Seedance receives it as a first frame rather than as one item in a loose multi-reference stack. This tests whether an authored contact pose gives better choreography and size preservation than prompt-only staging.

## Motion target

The golem supplies leverage and support while the cow supplies most secondary motion. Two slow lift-and-settle cycles emphasize weight, reach, dangling hooves, stable stone footing, and the difference between Large→Medium choreography and same-size motion. Contact remains clothed and concealed.

## Result

| Model | Task ID | Cost | Outcome |
|---|---:|---:|---|
| Seedance 2.5, 480p, four seconds | 3279808 | $0.42 | Scale, species, clothing, boulder anatomy, planted support, dangling hooves, inward eyelines, and no-fourth-wall rule held. The chest core pulse and final private nuzzle read clearly. The requested two lift cycles collapsed into one gentle lift/lean/settle progression, so this is a successful staging and character test rather than authored loop coverage. |

The exact MP4, receipt, and eight-frame QA sheet are retained under the git-ignored `artifacts/seedance/size_pair_golem_cow_2026-09-14/` research folder.
