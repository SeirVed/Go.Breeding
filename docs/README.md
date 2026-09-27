# Go.Breeding — Start here

Browse by subject below. Each folder has a short README linking its specifications and working files. These are real project folders; they do not create nested chats in the Codex sidebar.

[Project HQ](00-project-hq/README.md) · [Project board](project-board.html) · [Task / handoff template](00-project-hq/task-template.md) · [Repository guide](00-project-hq/repository-guide.md)

## Areas

| Folder | What belongs here |
|---|---|
| [Project HQ](00-project-hq/README.md) | Direction, priorities, project status and decisions that cross disciplines. |
| [Gameplay](01-gameplay/README.md) | Rules, genetics, ranch management, progression and economy. |
| [World & Story](02-world-story/README.md) | Locations, species identities, lore, dialogue, events and quests. |
| [Artwork](03-artwork/README.md) | Visual direction, character kits, environments, facial parts, SVG masters and atlases. |
| [Animation & Rig Studio](04-animation-rig-studio/README.md) | Rig geometry, attachments, motion, facial controls, timelines, reusable verbs and authoring tools. |
| [UI & UX](05-ui-ux/README.md) | Menus, navigation, galleries, developer boards, controls, readability and accessibility. |
| [Sound & Music](06-sound-music/README.md) | Music, ambience, effects, feedback sounds and audio controls. |
| [Technical Foundations](07-technical-foundations/README.md) | Persistence, content schemas, loading, performance, platform support and engineering contracts. |
| [Testing & Builds](08-testing-builds/README.md) | Build instructions, bug reproduction, integration checks, exports and verification evidence. |
| [Release & Business](09-release-business/README.md) | Licensing, distribution, storefronts, supporter model and demand metrics. |
| [Research & Experiments](10-research-experiments/README.md) | Unproven methods, tool comparisons and bounded experiments before production adoption. |
| [Inbox · Unsorted Ideas](11-inbox/README.md) | Capture suggestions quickly, then route them to the owning area. |
| [Archive · Completed & Superseded](12-archive/README.md) | Finished task notes and replaced proposals retained for context. |

## Starting a task

1. Open the area's README and the relevant specification or visual reference.
2. Start a chat for one coherent outcome; use `Area | outcome` as its title.
3. For a longer task, copy the [task template](00-project-hq/task-template.md) into that area using a descriptive filename.
4. On completion or handoff, record actual results, unresolved questions and the next step. Put accepted decisions in the canonical specification and link to them.

Chats are discussions. Specifications record accepted design; runtime data and executable behaviour establish what the current build actually does. A technical test passing does not establish visual approval.

## Status vocabulary

- **Implemented:** present and testable in the current build.
- **Prototype:** present in a limited or temporary form.
- **Planned:** accepted direction, not implemented.
- **Research / Study:** an experiment; not approved production work.
- **Proposed:** an idea awaiting a decision.
- **Reference:** terminology or guidance, not a completion claim.
- **Historical:** a record retained for context, not current instructions.

## Sources of truth

| Question | Start here |
|---|---|
| Current release and history | [VERSION.md](../VERSION.md), [CHANGELOG.md](../CHANGELOG.md) |
| Intent and priorities | [Design vision](00-project-hq/design_vision.md), [development map](00-project-hq/dev_map.md) |
| Current creature definitions | [Species registry](../data/species.json), [body mappings](../data/species_body_map.json) |
| Commission progress | [Progress data](../data/breeding_script_progress.json) |
| Production studies | [Production records](../data/pairing_production_records.json) |
| What executes | [Scenes](../scenes), [scripts](../scripts), [editor plugin](../addons/rig_studio) |
| File locations and previous document paths | [Navigation map](00-project-hq/navigation.json) |

When prose and runtime behaviour disagree about the current build, verify the implementation and correct the documentation. A folder index is a navigation aid, not new evidence that a feature works.

## Local and public material

Public design documents and source code are versioned. Each area may use an ignored `private/` folder for internal notes and records. Raw conversation exports stay in ignored `docs/chat_archive/`; offline artwork stays in `art/offline/`. Never use an index link as permission to publish its target. See the [repository guide](00-project-hq/repository-guide.md).

The [project board](project-board.html) remains at its existing address for bookmarks. It is a manually maintained planning snapshot; dated specifications and current runtime evidence may be newer. No Pages hosting is enabled by this reorganisation.
