## Copyright © 2026 SeirVed. All rights reserved. See LICENSE.md.
extends SceneTree

const PaperDollRigScript := preload("res://scripts/paper_doll.gd")
const CAPTURE_PATH := "res://artifacts/human-zero-v0.1.png"


func _init() -> void:
	call_deferred("_capture")


func _capture() -> void:
	root.size = Vector2i(600, 600)
	var background := ColorRect.new()
	background.color = Color("#132019")
	background.size = Vector2(600, 600)
	root.add_child(background)

	var rig = PaperDollRigScript.new()
	rig.position = Vector2(300, 505)
	rig.scale = Vector2.ONE * 2.15
	rig.configure_character("default_template")
	rig.set_process(false)
	rig.set_walking(false)
	rig.set_cycle_phase(0.08)
	root.add_child(rig)

	await process_frame
	await RenderingServer.frame_post_draw
	if rig.artwork_state() != "cutout" or rig.artwork_piece_count() != 14:
		push_error("HUMAN_ZERO_CAPTURE: production cutout was not ready")
		quit(1)
		return
	var image := root.get_texture().get_image()
	if image.save_png(CAPTURE_PATH) != OK:
		push_error("HUMAN_ZERO_CAPTURE: could not save capture")
		quit(1)
		return
	print("HUMAN_ZERO_CAPTURE: saved %s" % CAPTURE_PATH)
	quit(0)
