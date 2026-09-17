# Build checks

The Windows build check proves that the current source parses, its framework interactions work, a private executable can be exported, and the exported executable passes the same smoke test.

Run from the repository root:

```powershell
pwsh -File .\scripts\build_check.ps1
```

The checker first uses the project's pinned self-contained editor at `C:\Games\Dev\Godot\Godot.exe`, then falls back to a matching executable on `PATH`. Because the pinned build is self-contained, export needs write access to `C:\Games\Dev\Godot\editor_data\temp`; a restricted shell must run the checker with that narrowly scoped permission.

If Godot is not discoverable by command name, supply it explicitly:

```powershell
pwsh -File .\scripts\build_check.ps1 -GodotPath "C:\path\to\Godot_v4.7.2-stable_win64.exe"
```

The check requires Godot 4.7.2 and its matching Windows export templates. It performs six gates:

1. Verify the engine version.
2. Import resources and compile/initialize the Rig Studio editor plugin.
3. Run a headless, in-memory Rig Studio interaction test: Single Builder creation and Human Default Template, exclusive/additive anatomy metadata, artwork readiness, multi-node editing, variable keys, interpolation and undo; plus Animation Editor cast add/remove, independent role/size/exact height, onion skins, Propagate and visible verb composition.
4. Run the source project's built-in `--smoke-test` flow.
5. Produce an ignored, private Windows QA executable.
6. Run the smoke test from that exported executable.

The export log is also audited to ensure `art/style_exploration/`, the root `API.png`, the editable emergency SVG source, editor-only `addons/rig_studio/` code and every `tools/` QA script are not packed, while the runtime emergency PNG, Human Zero textures and shared motion data are packed. The checker treats Godot's logged `project.binary` temporary-file failure as fatal even if Godot returns exit code zero. Research media is intentionally blocked from Godot imports by `art/style_exploration/.gdignore` and is also excluded in `export_presets.cfg`. The artwork smoke test verifies that Human Zero mounts all fourteen parts without fallback, and that the one packaged emergency PNG still appears whenever another character has no complete cutout.

Logs are written beneath `artifacts/build-checks/`; the QA executable is written beneath `export/`. Both locations are ignored by Git. Passing this check verifies construction and core data contracts, not final visuals, performance, balance, content completeness, or long-session save integrity.
