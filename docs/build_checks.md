# Build checks

The Windows build check proves that the current source parses, its framework interactions work, a private executable can be exported, and the exported executable passes the same smoke test.

Run from the repository root:

```powershell
pwsh -File .\scripts\build_check.ps1
```

The checker first uses the project's pinned self-contained editor at `C:\Games\Dev\Godot\Godot.exe`, then falls back to a matching executable on `PATH`.

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

The export log is also audited to ensure `art/style_exploration/`, the root `API.png`, the editable emergency SVG source and the editor-only `addons/rig_studio/` code are not packed, while the runtime emergency PNG and shared motion data are packed. Research media is intentionally blocked from Godot imports by `art/style_exploration/.gdignore` and is also excluded in `export_presets.cfg`. The artwork smoke test verifies that the one packaged emergency PNG appears whenever no complete cutout exists, while valid static and bone-following probes clip to the invisible rig.

Logs are written beneath `artifacts/build-checks/`; the QA executable is written beneath `export/`. Both locations are ignored by Git. Passing this check verifies construction and core data contracts, not final visuals, performance, balance, content completeness, or long-session save integrity.
