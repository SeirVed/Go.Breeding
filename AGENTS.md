# Go.Breeding working guide

## Find the right context

- Start with `docs/README.md`, then the owning area's README and relevant specifications. Do not load every area by default.
- `docs/00-project-hq/navigation.json` maps areas, canonical files and former document paths. Resolve older references through that map.
- Code remains in `scripts/`, scenes in `scenes/`, registries in `data/`, schemas in `schemas/`, and Rig Studio in `addons/rig_studio/`.
- Use one chat per coherent outcome. Follow `docs/00-project-hq/task-template.md` for substantial tasks and handoffs.

## Work and evidence

- Honour the current mode: brainstorming is not implementation authorisation.
- Reassess the overall goal when repeated local fixes do not improve the result. Technical checks and visual approval are separate evidence.
- Preserve accepted decisions in canonical documents; mark proposals, studies and implementation status honestly. Do not label a feature or artwork approved based on the agent's own assessment.
- Reopen authoritative images for visual work. A summary of an image is not its replacement.
- The creature registry is open-ended. Keep prototype, planning and authored coverage distinct; unfinished playable presentation remains `PLACEHOLDER ACTIVE`.

## Files, checks and source control

- Use area indexes as links to existing technical files; do not duplicate source code or art into docs.
- Keep raw chats in `docs/chat_archive/`, internal records in `docs/**/private/`, and unapproved artwork in the existing offline locations. Private skills remain outside Git. No public Pages deployment is authorised.
- Check `git diff` and stage explicit paths. Do not publish offline studies or private records. Commit and push completed, verified work under the owner's standing instruction.
- For runtime/editor/data changes, use the checks described in `docs/08-testing-builds/build_checks.md`; the main command is `pwsh -File ./scripts/build_check.ps1`.
- Documentation-only work needs link/path validation and diff review. Do not run unrelated full builds without a reason.
