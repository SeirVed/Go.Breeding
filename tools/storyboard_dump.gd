## Copyright © 2026 SeirVed. All rights reserved. See LICENSE.md.
extends SceneTree

const OUTPUT_PATH := "res://artifacts/pairing-storyboards-placeholder-v01.json"
const PairingProgressScript := preload("res://scripts/pairing_progress.gd")


func _init() -> void:
	call_deferred("_dump")


func _dump() -> void:
	var pairing_progress = PairingProgressScript.new()
	root.add_child(pairing_progress)
	await process_frame
	var errors := pairing_progress.validate_storyboard_coverage()
	if not errors.is_empty():
		push_error("STORYBOARD_DUMP: %s" % "; ".join(errors))
		quit(1)
		return
	var storyboards := pairing_progress.all_pairing_storyboards()
	var document := {
		"generated": true,
		"status": "PLACEHOLDER_PLAN",
		"count": storyboards.size(),
		"warning": "Planning output only. This file does not claim playable animation coverage.",
		"storyboards": storyboards,
	}
	var file := FileAccess.open(OUTPUT_PATH, FileAccess.WRITE)
	if file == null:
		push_error("STORYBOARD_DUMP: could not open %s" % OUTPUT_PATH)
		quit(1)
		return
	file.store_string(JSON.stringify(document, "  ") + "\n")
	file.flush()
	if file.get_error() != OK:
		push_error("STORYBOARD_DUMP: could not finish %s" % OUTPUT_PATH)
		quit(1)
		return
	print("STORYBOARD_DUMP: wrote %d PLACEHOLDER_PLAN records to %s" % [storyboards.size(), OUTPUT_PATH])
	quit(0)
