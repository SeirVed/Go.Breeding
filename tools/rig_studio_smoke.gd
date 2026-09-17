## Copyright © 2026 SeirVed. All rights reserved. See LICENSE.md.
extends SceneTree

const Screen := preload("res://addons/rig_studio/rig_studio.gd")
const CAPTURE_PATH := "res://artifacts/rig-studio-v0.2.0.png"
const SINGLE_CAPTURE_PATH := "res://artifacts/rig-studio-v0.2.0-single-builder.png"


func _init() -> void:
	print("RIG_STUDIO_SMOKE: initializing")
	call_deferred("_run")


func _run() -> void:
	var screen = Screen.new()
	root.add_child(screen)
	screen.size = Vector2(root.size)
	await process_frame
	var state: Dictionary = screen.smoke_state()
	if state.characters < 2 or state.frames != 8 or state.essential_missing != 0 or state.multi_rigs != 2 or state.editor_only:
		_fail("Character inventory, timeline or editor-only guard failed")
		return
	if screen._stage.rig.artwork_state() != "cutout" or screen._stage.rig.artwork_piece_count() != 14 or screen._stage.rig.has_emergency_art():
		_fail("The Human Default Template did not mount its complete 14-piece cutout")
		return
	if str(screen._character_picker.get_item_metadata(0)) != "__add_new__" or screen._character_id != "default_template" or str(screen._characters.default_template.get("species_id", "")) != "human":
		_fail("Single Builder did not start with Add New and the Human Default Template")
		return
	screen._new_character_name.text = "Human Player Smoke"
	screen._create_character()
	if not screen._characters.has("human_player_smoke") or screen._character_id != "human_player_smoke":
		_fail("Add New did not clone the Default Template into a character")
		return
	screen._header_action("Undo")
	if screen._characters.has("human_player_smoke"):
		_fail("Character creation undo failed")
		return
	var serpentine_index := -1
	for item in screen._single_builder_panel.topology_picker.item_count:
		if str(screen._single_builder_panel.topology_picker.get_item_metadata(item)) == "serpentine":
			serpentine_index = item
			break
	screen._change_character_topology(serpentine_index)
	if str(screen._characters.default_template.get("topology", "")) != "serpentine":
		_fail("Mutually exclusive body-foundation selection was not stored")
		return
	screen._header_action("Undo")
	var tail_index := -1
	for item in screen._single_builder_panel.attachment_picker.item_count:
		if str(screen._single_builder_panel.attachment_picker.get_item_metadata(item)) == "tail":
			tail_index = item
			break
	screen._single_builder_panel.attachment_picker.select(tail_index)
	screen._add_character_attachment()
	if "tail" not in screen._characters.default_template.get("attachments", []):
		_fail("Additive anatomy component was not stored separately from topology")
		return
	screen._single_builder_panel.attachment_list.select(0)
	screen._remove_character_attachment()
	if "tail" in screen._characters.default_template.get("attachments", []):
		_fail("Removing an additive anatomy component failed")
		return
	screen._select_mode("Rig")
	var resting: Vector2 = screen._stage.rig.get_anchor_local("head")
	if not screen.stage_begin_drag("head"):
		_fail("Rig anchor drag did not start")
		return
	screen.stage_drag_anchor("head", Vector2(8.0, -5.0))
	screen.stage_end_drag()
	if screen._stage.rig.get_anchor_local("head").distance_to(resting + Vector2(8.0, -5.0)) > 0.2:
		_fail("Rig rest offset failed to move the actual preview anchor")
		return
	screen._header_action("Undo")
	if screen._stage.rig.get_anchor_local("head").distance_to(resting) > 0.2:
		_fail("Rig edit undo failed")
		return
	screen._select_mode("Animate")
	screen._select_frame(2)
	var pose_start: Vector2 = screen._stage.rig.get_anchor_local("head")
	if not screen.stage_begin_drag("head"):
		_fail("Motion-keyframe drag did not start")
		return
	screen.stage_drag_anchor("head", Vector2(4.0, 2.0))
	screen.stage_end_drag()
	if screen._stage.rig.get_anchor_local("head").distance_to(pose_start + Vector2(4.0, 2.0)) > 0.2:
		_fail("Keyframe offset failed to move the actual preview anchor")
		return
	if screen._current_frames()[2].get("offsets", {}).is_empty():
		_fail("Keyframe was not retained in shared motion data")
		return
	screen._header_action("Undo")
	if not screen._current_frames()[2].get("offsets", {}).is_empty():
		_fail("Motion-keyframe undo failed")
		return
	# Keep the Human template intact while exercising incomplete-art authoring on
	# the intentionally artless Catgirl declaration.
	screen._character_id = "catgirl_base"
	screen._select_character_in_picker("catgirl_base")
	screen._apply_preview()
	screen._refresh_inventory()
	screen._select_frame(0)
	screen._select_mode("Art")
	if screen.stage_begin_drag("head"):
		_fail("Art mode must not silently edit rig geometry")
		return
	screen._selected_slot = "head"
	screen._attach_png("res://art/placeholder/unknown_character.png")
	if screen._stage.rig.artwork_state() != "incomplete_cutout" or screen._stage.rig.missing_essential_slots().size() != 13:
		_fail("A single image must remain an incomplete authoring preview")
		return
	screen._selected_slot = "full_body"
	screen._attach_png("res://art/placeholder/unknown_character.png")
	if screen._stage.rig.artwork_state() != "cutout" or not screen._stage.rig.missing_essential_slots().is_empty():
		_fail("A valid full-body draft did not satisfy the alternate readiness gate")
		return
	screen._unassign_part()
	if screen._stage.rig.artwork_state() != "incomplete_cutout":
		_fail("Unassigning the full-body draft did not restore incomplete status")
		return
	screen._header_action("Undo")
	if screen._stage.rig.artwork_state() != "cutout":
		_fail("Art assignment undo failed")
		return
	var artwork_mtime := FileAccess.get_modified_time("res://data/paper_doll_artwork.json")
	screen._save_all()
	if FileAccess.get_modified_time("res://data/paper_doll_artwork.json") != artwork_mtime:
		_fail("A non-editor UI wrote authoring data into project resources")
		return
	var probe_path := "res://artifacts/rig-studio-json-probe.json"
	if not screen._write_json(probe_path, {"probe": "only ignored QA data"}) or screen._load_json(probe_path).get("probe", "") != "only ignored QA data":
		_fail("Authoring JSON writer failed its ignored-artifact round trip")
		return
	screen._choose_scene(1)
	if screen.smoke_state().scene_mode != "animation_editor" or screen._multi_stage.actor_count() != 2 or screen._mode != "Rig" or not screen._mode_buttons["Art"].disabled:
		_fail("Switching to the multi-rig authoring stage failed")
		return
	var actor_a = screen._multi_stage.get_actor_rig("A")
	var actor_b = screen._multi_stage.get_actor_rig("B")
	if actor_a == null or actor_b == null or actor_a.profile_key() != "male_large" or actor_b.profile_key() != "female_medium" or not is_equal_approx(actor_a.display_height_inches(), 102.0) or not is_equal_approx(actor_b.display_height_inches(), 65.0):
		_fail("Initial cast did not retain independent roles, bands and exact heights")
		return
	screen._selected_actor_id = "A"
	screen._change_actor_size(0)
	actor_a = screen._multi_stage.get_actor_rig("A")
	actor_b = screen._multi_stage.get_actor_rig("B")
	if actor_a.profile_key() != "male_small" or not is_equal_approx(actor_a.display_height_inches(), 42.0) or not is_equal_approx(actor_b.display_height_inches(), 65.0):
		_fail("Changing Actor A's size band altered Actor B or failed to scale A")
		return
	screen._change_actor_number(43.5, "height_inches")
	if not is_equal_approx(screen._multi_stage.get_actor_rig("A").display_height_inches(), 43.5):
		_fail("Actor-specific exact-height control failed")
		return
	screen._header_action("Undo")
	screen._header_action("Undo")
	if screen._multi_stage.get_actor_rig("A").profile_key() != "male_large" or not is_equal_approx(screen._multi_stage.get_actor_rig("A").display_height_inches(), 102.0):
		_fail("Cast size/height undo failed")
		return
	screen._add_cast_actor()
	screen._add_cast_actor()
	if screen._multi_stage.actor_count() != 4 or screen._multi_stage.get_actor_rig("C") == null or screen._multi_stage.get_actor_rig("D") == null:
		_fail("The animation scene did not expand past two rigs")
		return
	screen._remove_cast_actor()
	if screen._multi_stage.actor_count() != 3:
		_fail("Removing a selected cast rig failed")
		return
	screen._header_action("Undo")
	if screen._multi_stage.actor_count() != 4:
		_fail("Cast removal undo failed")
		return
	screen._select_mode("Animate")
	screen._select_frame(2)
	screen.multi_stage_select_actor("B", "head")
	var a_head: Vector2 = screen._multi_stage.get_actor_rig("A").get_anchor_local("head")
	var b_head: Vector2 = screen._multi_stage.get_actor_rig("B").get_anchor_local("head")
	if not screen.multi_stage_begin_drag("B", "head"):
		_fail("Actor B motion drag did not start")
		return
	screen.multi_stage_drag_anchor("B", "head", Vector2(6.0, -3.0), Vector2.ZERO)
	screen.multi_stage_end_drag()
	if screen._multi_stage.get_actor_rig("B").get_anchor_local("head").distance_to(b_head + Vector2(6.0, -3.0)) > 0.2 or screen._multi_stage.get_actor_rig("A").get_anchor_local("head").distance_to(a_head) > 0.2:
		_fail("Multi-rig keyframe offsets leaked between actors")
		return
	var a_stage: Vector2 = screen._multi_stage.get_actor_rig("A").position
	var b_stage: Vector2 = screen._multi_stage.get_actor_rig("B").position
	screen.multi_stage_select_actor("B", "root")
	if not screen.multi_stage_begin_drag("B", "root"):
		_fail("Actor B stage-root motion drag did not start")
		return
	screen.multi_stage_drag_anchor("B", "root", Vector2.ZERO, Vector2(32.0, 0.0))
	screen.multi_stage_end_drag()
	if screen._multi_stage.get_actor_rig("B").position.distance_to(b_stage + Vector2(32.0, 0.0)) > 0.2 or screen._multi_stage.get_actor_rig("A").position.distance_to(a_stage) > 0.2:
		_fail("Actor B stage motion failed or moved Actor A")
		return
	var keyed_b: Dictionary = screen._current_multi_frames()[2].get("actors", {}).get("B", {})
	if keyed_b.get("offsets", {}).is_empty() or keyed_b.get("stage_offset", []).size() != 2 or screen._current_multi_frames()[2].get("actors", {}).has("A"):
		_fail("Independent actor keyframes were not stored in the multi-rig record")
		return
	screen._multi_stage.set_phase(0.3125)
	if screen._multi_stage.get_actor_rig("B").position.distance_to(b_stage + Vector2(16.0, 0.0)) > 0.2:
		_fail("Actor stage motion failed to interpolate between two keyframes")
		return
	screen._multi_stage.set_phase(0.25)
	screen.multi_stage_select_actor("B", "head")
	screen.multi_stage_select_actor("B", "torso", true)
	var selected_head: Vector2 = screen._multi_stage.get_actor_rig("B").get_anchor_local("head")
	var selected_torso: Vector2 = screen._multi_stage.get_actor_rig("B").get_anchor_local("torso")
	if screen._multi_stage.selected_anchors.size() != 2 or not screen.multi_stage_begin_drag("B", "torso"):
		_fail("Shift-style multi-node selection did not retain two nodes")
		return
	screen.multi_stage_drag_anchor("B", "torso", Vector2(2.0, 4.0), Vector2.ZERO)
	screen.multi_stage_end_drag()
	if screen._multi_stage.get_actor_rig("B").get_anchor_local("head").distance_to(selected_head + Vector2(2.0, 4.0)) > 0.2 or screen._multi_stage.get_actor_rig("B").get_anchor_local("torso").distance_to(selected_torso + Vector2(2.0, 4.0)) > 0.2:
		_fail("Dragging a multi-node selection did not move every selected node")
		return
	screen._propagate_pose(3, false)
	var propagated: Dictionary = screen._current_multi_frames()[3].get("actors", {}).get("B", {}).get("offsets", {})
	if not propagated.has("head") or not propagated.has("torso") or screen._current_multi_frames()[3].get("actors", {}).get("B", {}).has("stage_offset"):
		_fail("Propagate did not copy only the selected actor-local nodes")
		return
	var before_key_count := screen._current_multi_frames().size()
	screen._add_inbetween()
	if screen._current_multi_frames().size() != before_key_count + 1:
		_fail("Add In-between did not create a variable timed key")
		return
	screen._remove_key()
	if screen._current_multi_frames().size() != before_key_count:
		_fail("Remove Key did not restore the variable timeline length")
		return
	screen._toggle_onion(true)
	if not screen._multi_stage.ghost_previous["B"].visible or not screen._multi_stage.ghost_next["B"].visible:
		_fail("Selected-actor onion skins did not become visible")
		return
	screen._timeline.select_view_mode("advanced", true)
	if screen._timeline.view_mode != "advanced" or str(screen._multi_template().get("timeline_mode", "")) != "advanced":
		_fail("Simple/Advanced timeline state was not retained")
		return
	var verb_phase := 0.265625
	screen._multi_stage.set_phase(verb_phase)
	var pelvis_without_verb: Vector2 = screen._multi_stage.get_actor_rig("A").get_anchor_local("pelvis")
	screen._selected_actor_id = "A"
	screen._frame_index = 2
	screen._add_verb("pelvis_pulse")
	screen._multi_stage.set_phase(verb_phase)
	if screen._current_verbs().size() != 1 or screen._multi_stage.get_actor_rig("A").get_anchor_local("pelvis").distance_to(pelvis_without_verb) < 1.0:
		_fail("Composable verb block did not produce visible motion")
		return
	if str(screen._verb_definitions.hold_anchors.get("status", "")) != "contract_only":
		_fail("Unimplemented contact verbs must remain honestly marked contract-only")
		return
	print("RIG_STUDIO_V020: builder creation, variable keys, multi-select, onion skins, propagation and verb composition passed")
	print("MULTI_RIG_SMOKE: independent cast sizes, arbitrary rig count, keyed actor poses and stage motion passed")
	print("RIG_STUDIO_SMOKE: editor UI, anchor drag, shared keyframe, undo and mode separation passed")
	if OS.get_cmdline_user_args().has("--capture-rig-studio"):
		screen._load_documents()
		screen._undo_stack.clear()
		screen._redo_stack.clear()
		screen._selected_slot = ""
		screen._selected_part_index = -1
		screen._selected_actor_id = "A"
		screen._frame_index = 0
		screen._preview_phase = 0.0
		screen._dirty = false
		var capture_single := OS.get_cmdline_user_args().has("--capture-single-builder")
		screen._choose_scene(0 if capture_single else 1)
		if capture_single:
			screen._apply_preview()
			screen._refresh_inventory()
		else:
			screen._apply_multi_preview()
			screen._refresh_cast_ui()
		screen._refresh_timeline()
		DisplayServer.window_set_size(Vector2i(1280, 720))
		screen.size = Vector2(float(ProjectSettings.get_setting("display/window/size/viewport_width")), float(ProjectSettings.get_setting("display/window/size/viewport_height")))
		await process_frame
		print("RIG_STUDIO_LAYOUT: viewport=%s screen=%s root=%s split=%s stage=%s right=%s" % [root.size, screen.size, screen.get_child(0).size, screen.get_child(0).get_child(1).size, screen._stage.size, screen.get_child(0).get_child(1).get_child(1).size])
		await RenderingServer.frame_post_draw
		var image := root.get_texture().get_image()
		if image.save_png(SINGLE_CAPTURE_PATH if capture_single else CAPTURE_PATH) != OK:
			_fail("Could not save Rig Studio visual capture")
			return
	quit(0)


func _fail(reason: String) -> void:
	push_error("RIG_STUDIO_SMOKE: %s" % reason)
	quit(1)
