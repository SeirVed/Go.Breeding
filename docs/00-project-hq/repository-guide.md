# Repository and chat organisation

[All areas](../README.md) · [Project HQ](README.md)

## Two views of the same project

The numbered folders under `docs/` organise work by subject. The existing technical directories organise files by their role in Godot. Area indexes connect the two; do not create a second copy of code or art inside a documentation folder.

| Location | Role | Git treatment |
|---|---|---|
| `docs/00-project-hq/` through `docs/12-archive/` | Specifications, decisions, handoffs and navigation | Public, reviewed text |
| `scenes/`, `scripts/` | Runtime scenes, code and supporting scripts | Tracked |
| `data/`, `schemas/` | Canonical registries and data contracts | Tracked; preserve stable IDs |
| `addons/rig_studio/` | Godot authoring plugin | Tracked; excluded from playable exports |
| `tools/` | Authoring helpers and validation tools | Tracked tools; local caches ignored; excluded from exports |
| Approved runtime art under `art/` | Accepted playable assets | Only individually promoted media |
| `art/offline/`, research media in `art/style_exploration/` | Editable studies, references and unproven media | Local; existing ignore rules apply |
| `docs/**/private/`, `docs/chat_archive/` | Internal records, private handoffs, raw chats | Local and ignored |
| `artifacts/`, `export/`, `.godot/` | Logs, builds and engine cache | Local and ignored |
| Root README, license, copyright, changelog and version | Repository entry points and release/legal records | Stay at the root |

Git does not require a particular directory template. This structure preserves the project's technical conventions and gives human and automated readers the same documentation entry points. `docs/.gdignore` and the export exclusion keep documentation out of game resources.

## Naming and ownership

- Folder order is stable: `00` through `12`. Use readable headings and simple lowercase filenames.
- One canonical home per document. Link across areas instead of copying specifications.
- Use descriptive task notes such as `save-slot-migration.md`; Git retains text history.
- Use `Area | concrete outcome` for chat titles. The same project folder provides file access, not automatic knowledge of every previous conversation.
- Update the [navigation map](navigation.json) when adding canonical specifications or moving documents. Add a readable link to the owning area's README too.
- Navigation map paths are relative to the repository root. Markdown links are relative to their containing document.

## Finishing or handing off

Record the goal, actual changes, verification, open questions and next action using the [task template](task-template.md). Distinguish owner decisions from suggestions and technical checks from visual approval. Reopen visual references in the next chat; prose cannot replace artwork.

Current specifications stay in their owning area. Completed task records and superseded proposals can move to [Archive](../12-archive/README.md), with a replacement link where relevant. Use [Inbox](../11-inbox/README.md) for unassigned ideas.

## Private material

`private/` folders are ignored at every level under `docs/`. Ignore rules apply to untracked files; a previously tracked file must also be removed from Git's index. Removing a file from the latest tree does not erase previous commits. Do not rewrite repository history as part of ordinary organisation.

Private skills stay outside this repository. Sensitive records, credentials and offline art must not be pasted into public task notes. A local file is not backed up merely because the repository is on GitHub.

## This organisation pass

Existing specifications moved into their owning areas and internal references were updated. Code, data registries, asset paths and Godot resource IDs stay in their established locations. The project board and `docs/Make.md` keep their existing entry paths. Original document locations are recorded in [navigation.json](navigation.json) for older references.
