# Handoff — Testing & Builds

[Area index](README.md) · [All areas](../README.md)

**Snapshot:** 2026-09-28, based on repository `b7bb9bc`, source inspection and existing documentation. No new gameplay or visual validation was performed for this handoff. Recheck the current checkout before acting.

**Start:** read [AGENTS.md](../../AGENTS.md), this handoff and the linked references. The user's new request determines scope and mode; suggested next steps below are not an instruction to begin implementation. Keep this handoff current when the area changes.

## Purpose

Provide reproducible evidence that a particular checkout works, while distinguishing engineering checks from visual quality, balance and finished content.

## Read first

- [Build checks](build_checks.md), [checker implementation](../../scripts/build_check.ps1).
- [Rig Studio smoke test](../../tools/rig_studio_smoke.gd), [game smoke entry](../../scripts/main.gd): `run_smoke_test`.
- [Export preset](../../export_presets.cfg), [version record](../../VERSION.md).

## Current state

The existing checker covers engine discovery, editor/plugin import, in-memory Rig Studio behaviour, source smoke, a private Windows export with package auditing and exported-runtime smoke. Logs are local under `artifacts/build-checks/`; the QA executable is under ignored `export/`. The script currently names a 0.2.4 build-check executable.

The documented command is `pwsh -File ./scripts/build_check.ps1`. The pinned Windows install is `C:\Games\Dev\Godot`; consult the build guide for export-template and writable-temp requirements. Existing logs or old passing reports do not verify a changed checkout.

## Boundaries and known pitfalls

The checker treats logged export errors as failures even when Godot's exit code suggests success. Editor tools, offline media, private docs and credentials must stay out of playable packages. Whole SVGs decoding or sprites swapping does not prove rig assembly, animation quality or fidelity to an art reference.

During the prior local SVG probe, the console executable exposed errors that were not captured through the windowed invocation. Inspect actual result files/logs and process completion; empty output is not evidence of success.

## Suggested next task and acceptance

Run the checks appropriate to the requested change and report checkout, command, exit status, logs and unresolved limitations. Documentation changes need link/path checks; meaningful source/data/export changes need the relevant build gates. Stop repeating successful unrelated tests. Use isolated save/test fixtures, close launched processes, and never upload research artifacts as part of a test report.
