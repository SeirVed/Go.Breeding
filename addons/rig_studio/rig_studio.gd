## Copyright © 2026 SeirVed. All rights reserved. See LICENSE.md.
@tool
class_name RigStudioScreen
extends Control

const ARTWORK_PATH := "res://data/paper_doll_artwork.json"
const STUDIO_PATH := "res://data/paper_doll_studio.json"
const CHARACTERS_PATH := "res://data/paper_doll_characters.json"
const VERBS_PATH := "res://data/animation_verbs.json"
const ANATOMY_PATH := "res://data/anatomy_components.json"
const PairingProgressScript := preload("res://scripts/pairing_progress.gd")
const TICKS_PER_SECOND := 240
const MULTI_TEMPLATE_ID := "multi_actor_scene_v1"
const PARTS := [
	{"slot": "full_body", "anchor": "root", "label": "Full-body draft"},
	{"slot": "head", "anchor": "head", "label": "Head"},
	{"slot": "torso", "anchor": "torso", "label": "Torso"},
	{"slot": "upper_arm_left", "anchor": "shoulder_left", "end_anchor": "elbow_left", "label": "Upper arm L"},
	{"slot": "lower_arm_left", "anchor": "elbow_left", "end_anchor": "hand_left", "label": "Lower arm L"},
	{"slot": "hand_left", "anchor": "hand_left", "label": "Hand L"},
	{"slot": "upper_arm_right", "anchor": "shoulder_right", "end_anchor": "elbow_right", "label": "Upper arm R"},
	{"slot": "lower_arm_right", "anchor": "elbow_right", "end_anchor": "hand_right", "label": "Lower arm R"},
	{"slot": "hand_right", "anchor": "hand_right", "label": "Hand R"},
	{"slot": "upper_leg_left", "anchor": "hip_left", "end_anchor": "knee_left", "label": "Upper leg L"},
	{"slot": "lower_leg_left", "anchor": "knee_left", "end_anchor": "foot_left", "label": "Lower leg L"},
	{"slot": "foot_left", "anchor": "foot_left", "label": "Foot L"},
	{"slot": "upper_leg_right", "anchor": "hip_right", "end_anchor": "knee_right", "label": "Upper leg R"},
	{"slot": "lower_leg_right", "anchor": "knee_right", "end_anchor": "foot_right", "label": "Lower leg R"},
	{"slot": "foot_right", "anchor": "foot_right", "label": "Foot R"},
	{"slot": "ear_left", "anchor": "head", "label": "Ear L"},
	{"slot": "ear_right", "anchor": "head", "label": "Ear R"},
	{"slot": "tail", "anchor": "pelvis", "label": "Tail"},
	{"slot": "eyes", "anchor": "head", "label": "Eyes / face"},
	{"slot": "outfit", "anchor": "torso", "label": "Outfit layer"},
]

var _artwork_data: Dictionary = {}
var _studio_data: Dictionary = {}
var _characters: Dictionary = {}
var _verb_definitions: Dictionary = {}
var _anatomy_catalog: Dictionary = {}
var _pairing_progress
var _artwork_mtime := 0
var _studio_mtime := 0
var _characters_mtime := 0
var _character_id := ""
var _scene_mode := "single_builder"
var _selected_actor_id := ""
var _mode := "Rig"
var _selected_slot := ""
var _selected_part_index := -1
var _frame_index := 0
var _preview_phase := 0.0
var _playing := false
var _dirty := false
var _updating_inspector := false
var _updating_cast_ui := false
var _updating_character_anatomy := false
var _undo_stack: Array[Dictionary] = []
var _redo_stack: Array[Dictionary] = []

var _stage: RigStudioStage
var _multi_stage: RigStudioMultiStage
var _scene_picker: OptionButton
var _character_picker: OptionButton
var _mode_buttons: Dictionary = {}
var _attached_list: ItemList
var _missing_list: ItemList
var _status: Label
var _selection: Label
var _part_label: Label
var _attach_button: Button
var _unassign_button: Button
var _scale_field: SpinBox
var _x_field: SpinBox
var _y_field: SpinBox
var _z_field: SpinBox
var _timeline: RigStudioTimelinePanel
var _file_dialog: FileDialog
var _new_character_dialog: ConfirmationDialog
var _new_character_name: LineEdit
var _single_inventory: ScrollContainer
var _cast_inventory: ScrollContainer
var _single_builder_panel: RigStudioSingleBuilderPanel
var _animation_editor_panel: RigStudioAnimationEditorPanel
var _cast_actor_list: ItemList
var _actor_character_picker: OptionButton
var _role_picker: OptionButton
var _size_picker: OptionButton
var _height_field: SpinBox
var _stage_x_field: SpinBox
var _stage_y_field: SpinBox
var _cast_note: Label


func _ready() -> void:
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	_pairing_progress = PairingProgressScript.new()
	add_child(_pairing_progress)
	if _pairing_progress.body_types.is_empty():
		_pairing_progress._ready()
	_load_documents()
	_build_ui()
	_refresh_character_picker()
	if not _character_id.is_empty():
		_apply_preview()
		_refresh_inventory()
	_apply_multi_preview()
	_refresh_mode()
	_refresh_timeline()
	set_process(true)


func _load_json(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed = JSON.parse_string(file.get_as_text())
	return parsed if parsed is Dictionary else {}


func _load_documents() -> void:
	_artwork_data = _load_json(ARTWORK_PATH)
	_studio_data = _load_json(STUDIO_PATH)
	_characters = _load_json(CHARACTERS_PATH)
	_verb_definitions = _load_json(VERBS_PATH).get("verbs", {})
	_anatomy_catalog = _load_json(ANATOMY_PATH)
	if not _artwork_data.has("characters"):
		_artwork_data["characters"] = {}
	if not _studio_data.has("characters"):
		_studio_data["characters"] = {}
	if not _studio_data.has("motion_templates"):
		_studio_data["motion_templates"] = {}
	_artwork_mtime = FileAccess.get_modified_time(ARTWORK_PATH)
	_studio_mtime = FileAccess.get_modified_time(STUDIO_PATH)
	_characters_mtime = FileAccess.get_modified_time(CHARACTERS_PATH)


func _build_ui() -> void:
	var root := VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("separation", 10)
	add_child(root)
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 8)
	root.add_child(header)
	var title := Label.new()
	title.text = "RIG STUDIO  ·  v0.3.0"
	title.add_theme_font_size_override("font_size", 20)
	header.add_child(title)
	_scene_picker = OptionButton.new()
	_scene_picker.add_item("Single Builder")
	_scene_picker.set_item_metadata(0, "single_builder")
	_scene_picker.add_item("Animation Editor")
	_scene_picker.set_item_metadata(1, "animation_editor")
	_scene_picker.item_selected.connect(_choose_scene)
	header.add_child(_scene_picker)
	_character_picker = OptionButton.new()
	_character_picker.custom_minimum_size.x = 150
	_character_picker.item_selected.connect(_choose_character)
	header.add_child(_character_picker)
	for mode in ["Rig", "Art", "Animate"]:
		var button := Button.new()
		button.text = mode
		button.toggle_mode = true
		button.pressed.connect(_select_mode.bind(mode))
		header.add_child(button)
		_mode_buttons[mode] = button
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(spacer)
	for action in ["Undo", "Redo", "Save All"]:
		var button := Button.new()
		button.text = action
		button.pressed.connect(_header_action.bind(action))
		header.add_child(button)
	var split := HSplitContainer.new()
	split.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	split.size_flags_vertical = Control.SIZE_EXPAND_FILL
	split.split_offset = 0
	root.add_child(split)
	var stage_stack := Control.new()
	stage_stack.custom_minimum_size = Vector2(500, 430)
	stage_stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stage_stack.size_flags_vertical = Control.SIZE_EXPAND_FILL
	split.add_child(stage_stack)
	_stage = RigStudioStage.new()
	_stage.studio = self
	_stage.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	stage_stack.add_child(_stage)
	_multi_stage = RigStudioMultiStage.new()
	_multi_stage.studio = self
	_multi_stage.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	stage_stack.add_child(_multi_stage)
	_multi_stage.hide()
	var right := VBoxContainer.new()
	right.custom_minimum_size.x = 360
	right.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right.add_theme_constant_override("separation", 8)
	split.add_child(right)
	_status = Label.new()
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	right.add_child(_status)
	_selection = Label.new()
	right.add_child(_selection)
	_single_builder_panel = RigStudioSingleBuilderPanel.new()
	_single_builder_panel.setup(self, _anatomy_catalog)
	_single_inventory = _single_builder_panel
	right.add_child(_single_inventory)
	_attached_list = _single_builder_panel.attached_list
	_missing_list = _single_builder_panel.missing_list
	_part_label = _single_builder_panel.part_label
	_attach_button = _single_builder_panel.attach_button
	_unassign_button = _single_builder_panel.unassign_button
	_scale_field = _single_builder_panel.scale_field
	_x_field = _single_builder_panel.x_field
	_y_field = _single_builder_panel.y_field
	_z_field = _single_builder_panel.z_field
	_animation_editor_panel = RigStudioAnimationEditorPanel.new()
	_animation_editor_panel.setup(self, _characters, _pairing_progress.body_types)
	_cast_inventory = _animation_editor_panel
	right.add_child(_cast_inventory)
	_cast_actor_list = _animation_editor_panel.actor_list
	_actor_character_picker = _animation_editor_panel.actor_character_picker
	_role_picker = _animation_editor_panel.role_picker
	_size_picker = _animation_editor_panel.size_picker
	_height_field = _animation_editor_panel.height_field
	_stage_x_field = _animation_editor_panel.stage_x_field
	_stage_y_field = _animation_editor_panel.stage_y_field
	_cast_note = _animation_editor_panel.note
	_cast_inventory.hide()
	_timeline = RigStudioTimelinePanel.new()
	right.add_child(_timeline)
	_timeline.key_selected.connect(_select_frame)
	_timeline.play_toggled.connect(_toggle_play)
	_timeline.reset_key_requested.connect(_reset_frame)
	_timeline.add_key_requested.connect(_add_key)
	_timeline.inbetween_requested.connect(_add_inbetween)
	_timeline.duplicate_key_requested.connect(_duplicate_key)
	_timeline.remove_key_requested.connect(_remove_key)
	_timeline.key_tick_changed.connect(_change_key_tick)
	_timeline.interpolation_changed.connect(_change_key_interpolation)
	_timeline.propagate_requested.connect(_propagate_pose)
	_timeline.onion_changed.connect(_toggle_onion)
	_timeline.view_mode_changed.connect(_change_timeline_mode)
	_timeline.add_verb_requested.connect(_add_verb)
	_timeline.remove_verb_requested.connect(_remove_verb)
	_file_dialog = FileDialog.new()
	_file_dialog.access = FileDialog.ACCESS_RESOURCES
	_file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	_file_dialog.current_dir = "res://art"
	_file_dialog.add_filter("*.png", "Transparent PNG")
	_file_dialog.file_selected.connect(_attach_png)
	add_child(_file_dialog)
	_new_character_dialog = ConfirmationDialog.new()
	_new_character_dialog.title = "Add Character from Default Template"
	_new_character_dialog.dialog_text = "Create a new Single Builder character. It begins as a human Default Template clone."
	_new_character_name = LineEdit.new()
	_new_character_name.placeholder_text = "Character name"
	_new_character_name.position = Vector2(12, 72)
	_new_character_name.size = Vector2(396, 34)
	_new_character_dialog.add_child(_new_character_name)
	_new_character_dialog.confirmed.connect(_create_character)
	add_child(_new_character_dialog)


func _refresh_character_picker() -> void:
	var requested_id := _character_id
	if _animation_editor_panel != null:
		_animation_editor_panel.refresh_characters(_characters)
	_character_picker.clear()
	_character_picker.add_item("＋ Add New…")
	_character_picker.set_item_metadata(0, "__add_new__")
	var keys := _characters.keys()
	keys.sort()
	if "default_template" in keys:
		keys.erase("default_template")
		keys.push_front("default_template")
	for key in keys:
		_character_picker.add_item(str(_characters[key].get("display_name", key)))
		_character_picker.set_item_metadata(_character_picker.item_count - 1, key)
	if not keys.is_empty():
		_character_id = requested_id if requested_id in keys else str(keys[0])
		_select_character_in_picker(_character_id)


func _choose_character(index: int) -> void:
	var chosen := str(_character_picker.get_item_metadata(index))
	if chosen == "__add_new__":
		_new_character_name.text = ""
		_new_character_dialog.popup_centered(Vector2i(420, 180))
		_select_character_in_picker(_character_id)
		return
	_character_id = chosen
	_selected_slot = ""
	_selected_part_index = -1
	_apply_preview()
	_refresh_inventory()


func _select_character_in_picker(id: String) -> void:
	for item in _character_picker.item_count:
		if str(_character_picker.get_item_metadata(item)) == id:
			_character_picker.select(item)
			return


func _create_character() -> void:
	var display_name := _new_character_name.text.strip_edges()
	if display_name.is_empty():
		return
	var base_id := display_name.to_snake_case()
	if base_id.is_empty():
		base_id = "new_character"
	var id := base_id
	var suffix := 2
	while _characters.has(id):
		id = "%s_%d" % [base_id, suffix]
		suffix += 1
	_push_undo()
	var source: Dictionary = _characters.get("default_template", {"species_id": "human", "role": "male", "size": "medium", "height_inches": 72.0, "topology": "humanoid_plantigrade", "part_sets": []}).duplicate(true)
	source["display_name"] = display_name
	source["kind"] = "character"
	_characters[id] = source
	_artwork_data["characters"][id] = {"parts": []}
	_studio_data["characters"][id] = {"rig_offsets": {}}
	_character_id = id
	_dirty = true
	_refresh_character_picker()
	_apply_preview()
	_refresh_inventory()


func _choose_scene(index: int) -> void:
	_scene_picker.select(index)
	_scene_mode = str(_scene_picker.get_item_metadata(index))
	_playing = false
	_timeline.set_playing(false)
	if _scene_mode == "animation_editor" and _mode == "Art":
		_mode = "Rig"
	_stage.visible = _scene_mode == "single_builder"
	_multi_stage.visible = _scene_mode == "animation_editor"
	_character_picker.visible = _scene_mode == "single_builder"
	_single_inventory.visible = _scene_mode == "single_builder"
	_cast_inventory.visible = _scene_mode == "animation_editor"
	if _scene_mode == "animation_editor":
		_apply_multi_preview()
		_refresh_cast_ui()
	else:
		_apply_preview()
		_refresh_inventory()
	_refresh_mode()
	_refresh_timeline()


func _multi_template() -> Dictionary:
	return _studio_data["motion_templates"].get(MULTI_TEMPLATE_ID, {}).duplicate(true)


func _current_cast() -> Array:
	return _multi_template().get("actors", []).duplicate(true)


func _current_multi_frames() -> Array:
	var frames: Array = _multi_template().get("frames", []).duplicate(true)
	if frames.is_empty():
		frames = [{"tick": 0, "interpolation": "smooth", "actors": {}}, {"tick": 120, "interpolation": "smooth", "actors": {}}]
	_ensure_frame_metadata(frames, "actors")
	return frames


func _duration_ticks() -> int:
	var template: Dictionary = _multi_template() if _scene_mode == "animation_editor" else _studio_data["motion_templates"].get("walk_humanoid_v1", {})
	return maxi(1, int(template.get("duration_ticks", 240)))


func _current_verbs() -> Array:
	return _multi_template().get("verbs", []).duplicate(true)


func _set_verbs(verbs: Array) -> void:
	var template := _multi_template()
	template["verbs"] = verbs.duplicate(true)
	_studio_data["motion_templates"][MULTI_TEMPLATE_ID] = template
	_dirty = true
	_multi_stage.set_verbs(verbs)
	_refresh_cast_ui()
	_refresh_timeline()


func _ensure_frame_metadata(frames: Array, payload_key: String) -> void:
	for index in frames.size():
		if not frames[index].has("tick"):
			frames[index]["tick"] = index * 30
		if not frames[index].has("interpolation"):
			frames[index]["interpolation"] = "smooth"
		if not frames[index].has(payload_key):
			frames[index][payload_key] = {}


func _set_cast(actors: Array) -> void:
	var template := _multi_template()
	template["actors"] = actors.duplicate(true)
	_studio_data["motion_templates"][MULTI_TEMPLATE_ID] = template
	_dirty = true
	_apply_multi_preview()
	_refresh_cast_ui()


func _set_multi_frames(frames: Array) -> void:
	var template := _multi_template()
	template["frames"] = frames.duplicate(true)
	_studio_data["motion_templates"][MULTI_TEMPLATE_ID] = template
	_dirty = true
	_multi_stage.set_frames(frames, _duration_ticks())
	_multi_stage.set_phase(_preview_phase)
	_refresh_cast_ui()
	_refresh_timeline()


func _apply_multi_preview() -> void:
	if _multi_stage == null:
		return
	PaperDollRig.reload_authoring_data()
	var art_by_character := {}
	for actor in _current_cast():
		var character_key := str(actor.get("character_id", ""))
		if not character_key.is_empty():
			art_by_character[character_key] = _artwork_data["characters"].get(character_key, {}).get("parts", []).duplicate(true)
	_multi_stage.set_cast(_current_cast(), art_by_character, _characters)
	_multi_stage.set_frames(_current_multi_frames(), _duration_ticks())
	_multi_stage.set_verbs(_current_verbs())
	_multi_stage.set_onion_skin(_timeline.onion_enabled() if _timeline != null else false)
	if _timeline != null:
		_timeline.select_view_mode(str(_multi_template().get("timeline_mode", "simple")))
	_multi_stage.set_phase(_preview_phase)
	if _selected_actor_id.is_empty() or _multi_stage.get_actor_rig(_selected_actor_id) == null:
		_selected_actor_id = _multi_stage.selected_actor_id
	_multi_stage.select_actor(_selected_actor_id)


func _actor_index(id: String) -> int:
	var actors := _current_cast()
	for index in actors.size():
		if str(actors[index].get("id", "")) == id:
			return index
	return -1


func _selected_actor() -> Dictionary:
	var actors := _current_cast()
	var index := _actor_index(_selected_actor_id)
	return actors[index] if index >= 0 else {}


func _refresh_cast_ui() -> void:
	if _cast_actor_list == null or _multi_stage == null:
		return
	var actors := _current_cast()
	_cast_actor_list.clear()
	for index in actors.size():
		var actor: Dictionary = actors[index]
		var species := "generic" if str(actor.get("character_id", "")).is_empty() else str(_characters.get(str(actor.character_id), {}).get("display_name", actor.character_id))
		_cast_actor_list.add_item("ACTOR %s  ·  %s %s  ·  %s in  ·  %s" % [actor.get("id", "?"), str(actor.get("size", "medium")).capitalize(), str(actor.get("role", "male")), actor.get("height_inches", 72.0), species])
		_cast_actor_list.set_item_metadata(index, str(actor.get("id", "")))
		if str(actor.get("id", "")) == _selected_actor_id:
			_cast_actor_list.select(index)
	_updating_cast_ui = true
	var chosen := _selected_actor()
	var has_actor := not chosen.is_empty()
	if has_actor:
		var actor_character := str(chosen.get("character_id", ""))
		for item in _actor_character_picker.item_count:
			if str(_actor_character_picker.get_item_metadata(item)) == actor_character:
				_actor_character_picker.select(item)
				break
		_role_picker.select(1 if str(chosen.get("role", "male")) == "female" else 0)
		var band := str(chosen.get("size", "medium"))
		_size_picker.select(["small", "medium", "large"].find(band))
		var limits := _height_limits(band)
		_height_field.min_value = limits.x
		_height_field.max_value = limits.y
		_height_field.value = float(chosen.get("height_inches", 72.0))
		_stage_x_field.value = float(chosen.get("stage_x", 0.0))
		_stage_y_field.value = float(chosen.get("stage_y", 0.0))
	for field in [_height_field, _stage_x_field, _stage_y_field]:
		field.editable = has_actor
	_actor_character_picker.disabled = not has_actor
	_role_picker.disabled = not has_actor
	_size_picker.disabled = not has_actor
	_updating_cast_ui = false
	_status.text = "ANIMATION EDITOR · %d actors · %d verb blocks  |  %s" % [actors.size(), _current_verbs().size(), "UNSAVED" if _dirty else "saved"]
	var selected_nodes := ", ".join(_multi_stage.selected_anchors) if not _multi_stage.selected_anchors.is_empty() else "none"
	_selection.text = "Actor %s · %s in · %s %s · nodes %s · %s mode" % [chosen.get("id", "none"), chosen.get("height_inches", "—"), chosen.get("size", "—"), chosen.get("role", "—"), selected_nodes, _mode]


func _height_limits(band: String) -> Vector2:
	match band:
		"small": return Vector2(1.0, 47.5)
		"large": return Vector2(96.0, 240.0)
		_: return Vector2(48.0, 95.5)


func _load_pairing_storyboard() -> void:
	if _scene_mode != "animation_editor" or _animation_editor_panel == null:
		return
	var actors := _current_cast()
	if actors.size() < 2:
		_animation_editor_panel.storyboard_note.text = "A pairing sentence needs at least two actors."
		return
	var board_picker := _animation_editor_panel.storyboard_board_picker
	var first_picker := _animation_editor_panel.storyboard_first_picker
	var second_picker := _animation_editor_panel.storyboard_second_picker
	var board_id := str(board_picker.get_item_metadata(board_picker.selected))
	var first_body_id := str(first_picker.get_item_metadata(first_picker.selected))
	var second_body_id := str(second_picker.get_item_metadata(second_picker.selected))
	var scene: Dictionary = _pairing_progress.build_pairing_scene(board_id, first_body_id, second_body_id)
	if scene.is_empty():
		_animation_editor_panel.storyboard_note.text = "The selected phased scene did not compile."
		return
	var phase_picker := _animation_editor_panel.storyboard_phase_picker
	var phase_id := str(phase_picker.get_item_metadata(phase_picker.selected))
	_push_undo()
	var lookup: Dictionary = _pairing_progress.get_pairing_lookup(board_id, first_body_id, second_body_id)
	var height_defaults := {"small": 42.0, "medium": 72.0, "large": 102.0}
	for actor_index in 2:
		var side: Dictionary = lookup.get("first" if actor_index == 0 else "second", {})
		var actor: Dictionary = actors[actor_index]
		var size_id := str(side.get("size", "Medium")).to_lower()
		actor["role"] = str(side.get("role", "male"))
		actor["size"] = size_id
		actor["height_inches"] = float(height_defaults.get(size_id, 72.0))
		actors[actor_index] = actor
	var instances: Array = _pairing_progress.instantiate_scene(scene, str(actors[0].get("id", "A")), str(actors[1].get("id", "B")), phase_id)
	if instances.is_empty():
		_animation_editor_panel.storyboard_note.text = "The selected phase contains no authoring beats."
		return
	var template := _multi_template()
	template["actors"] = actors
	var loaded_duration := int(scene.get("duration_ticks", 240))
	if not phase_id.is_empty():
		loaded_duration = 1
		for instance in instances:
			loaded_duration = maxi(loaded_duration, int(instance.get("end_tick", 1)))
	template["duration_ticks"] = loaded_duration
	template["verbs"] = instances
	template["scene_phases"] = scene.get("phases", []).duplicate(true)
	template["active_phase"] = phase_id
	template["storyboard_source"] = {
		"scene_id": scene.get("scene_id", ""),
		"commission_key": scene.get("commission_key", ""),
		"loop_family_id": scene.get("loop_family_id", ""),
		"architecture_version": scene.get("architecture_version", "0.1.0"),
		"status": scene.get("status", "PLACEHOLDER_PLAN"),
		"runtime_ready": false,
	}
	_studio_data["motion_templates"][MULTI_TEMPLATE_ID] = template
	_selected_actor_id = str(actors[0].get("id", "A"))
	_frame_index = 0
	_preview_phase = 0.0
	_dirty = true
	_apply_multi_preview()
	_refresh_cast_ui()
	_refresh_timeline()
	var phase_label := "entire scene" if phase_id.is_empty() else phase_id.replace("_", " ")
	_animation_editor_panel.storyboard_note.text = "%s · %s · %s · %d beats · PLACEHOLDER_PLAN · unresolved contact verbs remain inert." % [scene.get("pairing_name", "Pairing"), scene.get("loop_family_name", "Loop family"), phase_label, instances.size()]


func _choose_cast_actor(index: int) -> void:
	if _updating_cast_ui:
		return
	_selected_actor_id = str(_cast_actor_list.get_item_metadata(index))
	_multi_stage.select_actor(_selected_actor_id)
	_refresh_cast_ui()


func _new_cast_id(actors: Array) -> String:
	var used := {}
	for actor in actors:
		used[str(actor.get("id", ""))] = true
	for value in range(65, 91):
		var candidate := String.chr(value)
		if not used.has(candidate):
			return candidate
	var number := actors.size() + 1
	while used.has("R%d" % number):
		number += 1
	return "R%d" % number


func _add_cast_actor() -> void:
	_push_undo()
	var actors := _current_cast()
	var id := _new_cast_id(actors)
	var suggested_x := 0.0
	for candidate in [0.0, 280.0, -280.0, 420.0, -420.0]:
		var occupied := false
		for actor in actors:
			if absf(float(actor.get("stage_x", 0.0)) - candidate) < 70.0:
				occupied = true
				break
		if not occupied:
			suggested_x = candidate
			break
	actors.append({"id": id, "character_id": "", "role": "male", "size": "medium", "height_inches": 72.0, "stage_x": suggested_x, "stage_y": 0.0, "rig_offsets": {}})
	_selected_actor_id = id
	_set_cast(actors)


func _remove_cast_actor() -> void:
	var actors := _current_cast()
	var index := _actor_index(_selected_actor_id)
	if actors.size() <= 1 or index < 0:
		return
	_push_undo()
	var removed_id := _selected_actor_id
	actors.remove_at(index)
	var template := _multi_template()
	template["actors"] = actors
	var frames := _current_multi_frames()
	for frame in frames:
		var cast_frame: Dictionary = frame.get("actors", {})
		cast_frame.erase(removed_id)
		frame["actors"] = cast_frame
	template["frames"] = frames
	_studio_data["motion_templates"][MULTI_TEMPLATE_ID] = template
	_selected_actor_id = str(actors[0].get("id", ""))
	_dirty = true
	_apply_multi_preview()
	_refresh_cast_ui()


func _change_actor_character(index: int) -> void:
	if _updating_cast_ui:
		return
	var key := str(_actor_character_picker.get_item_metadata(index))
	_push_undo()
	var actors := _current_cast()
	var actor: Dictionary = actors[_actor_index(_selected_actor_id)]
	actor["character_id"] = key
	if _characters.has(key):
		var source: Dictionary = _characters[key]
		actor["role"] = str(source.get("role", "female"))
		actor["size"] = str(source.get("size", "medium"))
		actor["height_inches"] = float(source.get("height_inches", 72.0))
	actors[_actor_index(_selected_actor_id)] = actor
	_set_cast(actors)


func _change_actor_role(index: int) -> void:
	if _updating_cast_ui:
		return
	_set_actor_property("role", "female" if index == 1 else "male")


func _change_actor_size(index: int) -> void:
	if _updating_cast_ui:
		return
	var band: String = ["small", "medium", "large"][index]
	_push_undo()
	var actors := _current_cast()
	var actor: Dictionary = actors[_actor_index(_selected_actor_id)]
	actor["size"] = band
	actor["height_inches"] = {"small": 42.0, "medium": 72.0, "large": 102.0}[band]
	actors[_actor_index(_selected_actor_id)] = actor
	_set_cast(actors)


func _change_actor_number(value: float, field: String) -> void:
	if _updating_cast_ui:
		return
	_set_actor_property(field, value)


func _set_actor_property(field: String, value: Variant) -> void:
	var index := _actor_index(_selected_actor_id)
	if index < 0:
		return
	_push_undo()
	var actors := _current_cast()
	var actor: Dictionary = actors[index]
	actor[field] = value
	actors[index] = actor
	_set_cast(actors)


func _character_art_entry() -> Dictionary:
	return _artwork_data["characters"].get(_character_id, {}).duplicate(true)


func _current_parts() -> Array:
	return _character_art_entry().get("parts", []).duplicate(true)


func _set_parts(parts: Array) -> void:
	var entry := _character_art_entry()
	entry["parts"] = parts.duplicate(true)
	_artwork_data["characters"][_character_id] = entry
	_dirty = true
	_apply_preview()
	_refresh_inventory()


func _current_rig_offsets() -> Dictionary:
	return _studio_data["characters"].get(_character_id, {}).get("rig_offsets", {}).duplicate(true)


func _set_rig_offsets(offsets: Dictionary) -> void:
	var entry: Dictionary = _studio_data["characters"].get(_character_id, {})
	entry["rig_offsets"] = offsets.duplicate(true)
	_studio_data["characters"][_character_id] = entry
	_dirty = true
	_stage.rig.set_rest_anchor_offsets(offsets)
	_refresh_inventory()


func _current_frames() -> Array:
	var template: Dictionary = _studio_data["motion_templates"].get("walk_humanoid_v1", {})
	var frames: Array = template.get("frames", []).duplicate(true)
	if frames.is_empty():
		frames = [{"tick": 0, "interpolation": "smooth", "offsets": {}}, {"tick": 120, "interpolation": "smooth", "offsets": {}}]
	_ensure_frame_metadata(frames, "offsets")
	return frames


func _set_frames(frames: Array) -> void:
	var template: Dictionary = _studio_data["motion_templates"].get("walk_humanoid_v1", {})
	template["display_name"] = "Shared Humanoid Walk · Draft"
	template["duration_ticks"] = int(template.get("duration_ticks", 240))
	template["frames"] = frames.duplicate(true)
	_studio_data["motion_templates"]["walk_humanoid_v1"] = template
	_dirty = true
	_stage.rig.set_motion_frames(frames, _duration_ticks())
	_refresh_inventory()
	_refresh_timeline()


func _apply_preview() -> void:
	if _stage == null or _stage.rig == null or _character_id.is_empty():
		return
	PaperDollRig.reload_authoring_data()
	_stage.rig.configure_character_record(_character_id, _characters.get(_character_id, {}))
	_stage.rig.set_process(false)
	_stage.rig.set_editor_preview(true)
	_stage.rig.set_editor_guides(true)
	_stage.rig.set_rest_anchor_offsets(_current_rig_offsets())
	_stage.rig.set_motion_frames(_current_frames(), _duration_ticks())
	_stage.rig.use_artwork_parts_for_test(_current_parts())
	_stage.rig.set_cycle_phase(_preview_phase)
	_stage.queue_redraw()


func _refresh_inventory() -> void:
	if _stage == null or _stage.rig == null:
		return
	var parts := _current_parts()
	_updating_character_anatomy = true
	_single_builder_panel.refresh_anatomy(_characters.get(_character_id, {}))
	_updating_character_anatomy = false
	_attached_list.clear()
	var valid_slots := {}
	for part in parts:
		var slot := str(part.get("slot", ""))
		var path := str(part.get("path", ""))
		var usable := ResourceLoader.exists(path)
		_attached_list.add_item("%s  ·  %s%s" % [slot, path.get_file(), "  [BROKEN]" if not usable else ""])
		if usable:
			valid_slots[slot] = true
	_missing_list.clear()
	for preset in PARTS:
		if not valid_slots.has(str(preset.slot)):
			_missing_list.add_item("%s  ·  %s" % [preset.label, preset.slot])
			_missing_list.set_item_metadata(_missing_list.item_count - 1, str(preset.slot))
	var missing := _stage.rig.missing_essential_slots()
	var readiness := "READY · full essential body" if missing.is_empty() else "INCOMPLETE · %d essential slots missing" % missing.size()
	_status.text = "SINGLE BUILDER · %s   |   %d valid images   |   %s" % [readiness, _stage.rig.artwork_piece_count(), "UNSAVED" if _dirty else "saved"]
	_selection.text = "Selected nodes: %s  |  %s mode" % [", ".join(_stage.selected_anchors) if not _stage.selected_anchors.is_empty() else "none", _mode]
	_refresh_inspector()


func _change_character_topology(index: int) -> void:
	if _updating_character_anatomy or _character_id.is_empty():
		return
	var topology := str(_single_builder_panel.topology_picker.get_item_metadata(index))
	var character: Dictionary = _characters.get(_character_id, {}).duplicate(true)
	if str(character.get("topology", "humanoid_plantigrade")) == topology:
		return
	_push_undo()
	character["topology"] = topology
	_characters[_character_id] = character
	_dirty = true
	_refresh_inventory()


func _add_character_attachment() -> void:
	if _character_id.is_empty() or _single_builder_panel.attachment_picker.item_count == 0:
		return
	var attachment := str(_single_builder_panel.attachment_picker.get_item_metadata(_single_builder_panel.attachment_picker.selected))
	var character: Dictionary = _characters.get(_character_id, {}).duplicate(true)
	var attachments: Array = character.get("attachments", []).duplicate(true)
	if attachment in attachments:
		return
	_push_undo()
	attachments.append(attachment)
	character["attachments"] = attachments
	_characters[_character_id] = character
	_dirty = true
	_refresh_inventory()


func _remove_character_attachment() -> void:
	var selected := _single_builder_panel.attachment_list.get_selected_items()
	if selected.is_empty() or _character_id.is_empty():
		return
	var character: Dictionary = _characters.get(_character_id, {}).duplicate(true)
	var attachments: Array = character.get("attachments", []).duplicate(true)
	var attachment := str(_single_builder_panel.attachment_list.get_item_metadata(int(selected[0])))
	if attachment not in attachments:
		return
	_push_undo()
	attachments.erase(attachment)
	character["attachments"] = attachments
	_characters[_character_id] = character
	_dirty = true
	_refresh_inventory()


func _choose_attached(index: int) -> void:
	_selected_part_index = index
	_selected_slot = str(_current_parts()[index].get("slot", ""))
	_missing_list.deselect_all()
	_refresh_inspector()


func _choose_missing(index: int) -> void:
	_selected_slot = str(_missing_list.get_item_metadata(index))
	_selected_part_index = -1
	_attached_list.deselect_all()
	_refresh_inspector()


func _refresh_inspector() -> void:
	var parts := _current_parts()
	var has_part := _selected_part_index >= 0 and _selected_part_index < parts.size()
	_attach_button.disabled = _selected_slot.is_empty()
	_unassign_button.disabled = not has_part
	_part_label.text = _selected_slot if not _selected_slot.is_empty() else "Select a part or missing slot"
	_updating_inspector = true
	if has_part:
		var part: Dictionary = parts[_selected_part_index]
		var offset: Array = part.get("offset", [0.0, 0.0])
		_scale_field.value = float(part.get("scale", 1.0))
		_x_field.value = float(offset[0])
		_y_field.value = float(offset[1])
		_z_field.value = float(part.get("z", 0.0))
	for field in [_scale_field, _x_field, _y_field, _z_field]:
		field.editable = has_part
	_updating_inspector = false


func _choose_png() -> void:
	if _selected_slot.is_empty():
		return
	_file_dialog.popup_centered_ratio(0.75)


func _preset_for_slot(slot: String) -> Dictionary:
	for preset in PARTS:
		if str(preset.slot) == slot:
			return preset
	return {}


func _attach_png(path: String) -> void:
	if _selected_slot.is_empty() or not path.begins_with("res://") or path.get_extension().to_lower() != "png":
		_status.text = "Choose an imported PNG inside this Godot project."
		return
	_push_undo()
	var preset := _preset_for_slot(_selected_slot)
	var spec := {"slot": _selected_slot, "path": path, "anchor": str(preset.get("anchor", "torso")), "scale": 1.0, "offset": [0.0, 0.0], "z": 0}
	if preset.has("end_anchor"):
		var end := str(preset.end_anchor)
		spec["end_anchor"] = end
		spec["rest_length"] = maxf(1.0, _stage.rig.get_anchor_local(str(preset.anchor)).distance_to(_stage.rig.get_anchor_local(end)))
	var parts := _current_parts()
	var replace_index := -1
	for index in parts.size():
		if str(parts[index].get("slot", "")) == _selected_slot:
			replace_index = index
			break
	if replace_index >= 0:
		parts[replace_index] = spec
		_selected_part_index = replace_index
	else:
		parts.append(spec)
		_selected_part_index = parts.size() - 1
	_set_parts(parts)


func _unassign_part() -> void:
	var parts := _current_parts()
	if _selected_part_index < 0 or _selected_part_index >= parts.size():
		return
	_push_undo()
	parts.remove_at(_selected_part_index)
	_selected_part_index = -1
	_set_parts(parts)


func _change_part_transform(value: float, field: String) -> void:
	if _updating_inspector or _selected_part_index < 0:
		return
	var parts := _current_parts()
	if _selected_part_index >= parts.size():
		return
	_push_undo()
	var part: Dictionary = parts[_selected_part_index]
	match field:
		"scale": part["scale"] = value
		"z": part["z"] = int(value)
		"x", "y":
			var offset: Array = part.get("offset", [0.0, 0.0])
			offset[0 if field == "x" else 1] = value
			part["offset"] = offset
	parts[_selected_part_index] = part
	_set_parts(parts)


func _select_mode(mode: String) -> void:
	if _scene_mode == "animation_editor" and mode == "Art":
		return
	_mode = mode
	_refresh_mode()
	if _scene_mode == "animation_editor":
		_refresh_cast_ui()
	else:
		_refresh_inventory()


func _refresh_mode() -> void:
	for mode in _mode_buttons:
		_mode_buttons[mode].button_pressed = mode == _mode
		_mode_buttons[mode].disabled = _scene_mode == "animation_editor" and mode == "Art"


func stage_select_anchor(anchor: String, additive: bool = false) -> void:
	_stage.select_anchor(anchor, additive)
	_refresh_inventory()


func stage_begin_drag(_anchor: String) -> bool:
	if _mode == "Art" or _playing:
		return false
	_push_undo()
	return true


func stage_drag_anchor(anchor: String, delta: Vector2) -> void:
	var anchors: Array[String] = _stage.selected_anchors.duplicate()
	if anchors.is_empty():
		anchors.assign([anchor])
	if _mode == "Rig":
		var offsets := _current_rig_offsets()
		for selected in anchors:
			offsets[selected] = _move_offset(offsets.get(selected, [0.0, 0.0]), delta)
		_set_rig_offsets(offsets)
	elif _mode == "Animate":
		var frames := _current_frames()
		var offsets: Dictionary = frames[_frame_index].get("offsets", {})
		for selected in anchors:
			offsets[selected] = _move_offset(offsets.get(selected, [0.0, 0.0]), delta)
		frames[_frame_index]["offsets"] = offsets
		_set_frames(frames)
	_stage.queue_redraw()


func _move_offset(previous: Variant, delta: Vector2) -> Array:
	var old := Vector2(float(previous[0]), float(previous[1])) if previous is Array and previous.size() == 2 else Vector2.ZERO
	var moved := old + delta
	return [snappedf(moved.x, 0.1), snappedf(moved.y, 0.1)]


func stage_end_drag() -> void:
	_refresh_inventory()


func multi_stage_select_actor(id: String, anchor: String, additive: bool = false) -> void:
	_selected_actor_id = id
	_multi_stage.select_actor(id, anchor, additive)
	_refresh_cast_ui()


func multi_stage_begin_drag(_id: String, _anchor: String) -> bool:
	if _mode == "Art" or _playing:
		return false
	_push_undo()
	return true


func multi_stage_drag_anchor(id: String, anchor: String, local_delta: Vector2, screen_delta: Vector2) -> void:
	var anchors: Array[String] = _multi_stage.selected_anchors.duplicate()
	if anchors.is_empty():
		anchors.assign([anchor])
	if _mode == "Rig":
		var actors := _current_cast()
		var index := _actor_index(id)
		if index < 0:
			return
		var actor: Dictionary = actors[index]
		if "root" in anchors:
			actor["stage_x"] = snappedf(float(actor.get("stage_x", 0.0)) + screen_delta.x, 0.1)
			actor["stage_y"] = snappedf(float(actor.get("stage_y", 0.0)) + screen_delta.y, 0.1)
		var offsets: Dictionary = actor.get("rig_offsets", {})
		for selected in anchors:
			if selected != "root":
				offsets[selected] = _move_offset(offsets.get(selected, [0.0, 0.0]), local_delta)
		actor["rig_offsets"] = offsets
		actors[index] = actor
		var template := _multi_template()
		template["actors"] = actors
		_studio_data["motion_templates"][MULTI_TEMPLATE_ID] = template
		_dirty = true
		_multi_stage.actors = actors.duplicate(true)
		if anchors.any(func(value: String): return value != "root"):
			_multi_stage.set_actor_offsets(id, actor.get("rig_offsets", {}))
		_multi_stage.set_phase(_preview_phase)
		_refresh_cast_ui()
	elif _mode == "Animate":
		var frames := _current_multi_frames()
		var cast_frame: Dictionary = frames[_frame_index].get("actors", {})
		var actor_frame: Dictionary = cast_frame.get(id, {})
		if "root" in anchors:
			actor_frame["stage_offset"] = _move_offset(actor_frame.get("stage_offset", [0.0, 0.0]), screen_delta)
		var motion_offsets: Dictionary = actor_frame.get("offsets", {})
		for selected in anchors:
			if selected != "root":
				motion_offsets[selected] = _move_offset(motion_offsets.get(selected, [0.0, 0.0]), local_delta)
		actor_frame["offsets"] = motion_offsets
		cast_frame[id] = actor_frame
		frames[_frame_index]["actors"] = cast_frame
		_set_multi_frames(frames)


func multi_stage_end_drag() -> void:
	_refresh_cast_ui()


func _select_frame(index: int) -> void:
	_playing = false
	_timeline.set_playing(false)
	var frames := _active_frames()
	_frame_index = clampi(index, 0, maxi(0, frames.size() - 1))
	_preview_phase = float(frames[_frame_index].get("tick", 0)) / _duration_ticks()
	if _scene_mode == "animation_editor":
		_multi_stage.set_phase(_preview_phase)
	else:
		_stage.rig.set_cycle_phase(_preview_phase)
		_stage.queue_redraw()
	_refresh_timeline()


func _toggle_play() -> void:
	_playing = not _playing
	_timeline.set_playing(_playing)


func _process(delta: float) -> void:
	if _playing:
		var duration_seconds := maxf(0.01, float(_duration_ticks()) / TICKS_PER_SECOND)
		_preview_phase = fposmod(_preview_phase + delta / duration_seconds, 1.0)
		_frame_index = _frame_index_at_tick(_preview_phase * _duration_ticks())
		if _scene_mode == "animation_editor":
			_multi_stage.set_phase(_preview_phase)
		elif _stage != null and _stage.rig != null:
			_stage.rig.set_cycle_phase(_preview_phase)
			_stage.queue_redraw()
		_refresh_timeline()


func _refresh_timeline() -> void:
	if _timeline == null:
		return
	var frames := _active_frames()
	_frame_index = clampi(_frame_index, 0, maxi(0, frames.size() - 1))
	var caption := "ANIMATION EDITOR · VARIABLE TIMED KEYS" if _scene_mode == "animation_editor" else "SINGLE BUILDER · WALK DEBUG KEYS"
	_timeline.configure(caption, frames, _frame_index, _duration_ticks(), _current_verbs() if _scene_mode == "animation_editor" else [], _verb_definitions, _scene_mode == "animation_editor")


func _reset_frame() -> void:
	_push_undo()
	if _scene_mode == "animation_editor":
		var multi_frames := _current_multi_frames()
		var tick := int(multi_frames[_frame_index].get("tick", 0))
		var interpolation := str(multi_frames[_frame_index].get("interpolation", "smooth"))
		multi_frames[_frame_index] = {"tick": tick, "interpolation": interpolation, "actors": {}}
		_set_multi_frames(multi_frames)
	else:
		var frames := _current_frames()
		var tick := int(frames[_frame_index].get("tick", 0))
		var interpolation := str(frames[_frame_index].get("interpolation", "smooth"))
		frames[_frame_index] = {"tick": tick, "interpolation": interpolation, "offsets": {}}
		_set_frames(frames)


func _active_frames() -> Array:
	return _current_multi_frames() if _scene_mode == "animation_editor" else _current_frames()


func _set_active_frames(frames: Array) -> void:
	if _scene_mode == "animation_editor":
		_set_multi_frames(frames)
	else:
		_set_frames(frames)


func _frame_index_at_tick(tick: float) -> int:
	var frames := _active_frames()
	var found := 0
	for index in frames.size():
		if float(frames[index].get("tick", 0)) <= tick:
			found = index
		else:
			break
	return found


func _empty_frame(tick: int) -> Dictionary:
	return {"tick": tick, "interpolation": "smooth", "actors": {}} if _scene_mode == "animation_editor" else {"tick": tick, "interpolation": "smooth", "offsets": {}}


func _set_duration_ticks(value: int) -> void:
	if _scene_mode == "animation_editor":
		var template := _multi_template()
		template["duration_ticks"] = maxi(2, value)
		_studio_data["motion_templates"][MULTI_TEMPLATE_ID] = template
	else:
		var template: Dictionary = _studio_data["motion_templates"].get("walk_humanoid_v1", {})
		template["duration_ticks"] = maxi(2, value)
		_studio_data["motion_templates"]["walk_humanoid_v1"] = template


func _insert_frame(tick: int, source: Dictionary = {}, record_undo: bool = true) -> void:
	if record_undo:
		_push_undo()
	var frames := _active_frames()
	var insert_at := frames.size()
	for index in frames.size():
		if int(frames[index].get("tick", 0)) >= tick:
			insert_at = index
			break
	var frame := source.duplicate(true) if not source.is_empty() else _empty_frame(tick)
	frame["tick"] = tick
	frames.insert(insert_at, frame)
	_set_duration_ticks(maxi(_duration_ticks(), tick + 30))
	_frame_index = insert_at
	_set_active_frames(frames)
	_select_frame(_frame_index)


func _add_key() -> void:
	_push_undo()
	var frames := _active_frames()
	var tick := int(frames[_frame_index].get("tick", 0)) + 30
	for index in range(_frame_index + 1, frames.size()):
		if int(frames[index].get("tick", 0)) <= tick:
			frames[index]["tick"] = int(frames[index].get("tick", 0)) + 30
	_set_duration_ticks(maxi(_duration_ticks(), int(frames[-1].get("tick", 0)) + 30))
	_set_active_frames(frames)
	_insert_frame(tick, {}, false)


func _add_inbetween() -> void:
	_push_undo()
	var frames := _active_frames()
	var current_tick := int(frames[_frame_index].get("tick", 0))
	var next_tick := _duration_ticks() if _frame_index == frames.size() - 1 else int(frames[_frame_index + 1].get("tick", current_tick + 30))
	if next_tick - current_tick < 2:
		for index in range(_frame_index + 1, frames.size()):
			frames[index]["tick"] = int(frames[index].get("tick", 0)) + 30
		next_tick += 30
		_set_duration_ticks(_duration_ticks() + 30)
		_set_active_frames(frames)
	_insert_frame(current_tick + int((next_tick - current_tick) / 2.0), {}, false)


func _duplicate_key() -> void:
	_push_undo()
	var frames := _active_frames()
	var copy: Dictionary = frames[_frame_index].duplicate(true)
	var tick := int(copy.get("tick", 0)) + 30
	for index in range(_frame_index + 1, frames.size()):
		frames[index]["tick"] = int(frames[index].get("tick", 0)) + 30
	_set_duration_ticks(_duration_ticks() + 30)
	_set_active_frames(frames)
	_insert_frame(tick, copy, false)


func _remove_key() -> void:
	var frames := _active_frames()
	if frames.size() <= 2:
		return
	_push_undo()
	frames.remove_at(_frame_index)
	_frame_index = mini(_frame_index, frames.size() - 1)
	_set_active_frames(frames)
	_select_frame(_frame_index)


func _change_key_tick(tick: int) -> void:
	var frames := _active_frames()
	var minimum := int(frames[_frame_index - 1].get("tick", 0)) + 1 if _frame_index > 0 else 0
	var maximum := int(frames[_frame_index + 1].get("tick", _duration_ticks())) - 1 if _frame_index < frames.size() - 1 else _duration_ticks() - 1
	var clamped := clampi(tick, minimum, maxi(minimum, maximum))
	if clamped == int(frames[_frame_index].get("tick", 0)):
		return
	_push_undo()
	frames[_frame_index]["tick"] = clamped
	_set_active_frames(frames)
	_select_frame(_frame_index)


func _change_key_interpolation(kind: String) -> void:
	var frames := _active_frames()
	if str(frames[_frame_index].get("interpolation", "smooth")) == kind:
		return
	_push_undo()
	frames[_frame_index]["interpolation"] = kind
	_set_active_frames(frames)


func _propagate_pose(target_index: int, all_following: bool) -> void:
	var frames := _active_frames()
	var targets: Array[int] = []
	if all_following:
		for index in range(_frame_index + 1, frames.size()):
			targets.append(index)
	else:
		targets.append(clampi(target_index, 0, frames.size() - 1))
	_push_undo()
	if _scene_mode == "animation_editor":
		frames = RigStudioPosePropagator.actor_pose(frames, _frame_index, targets, _selected_actor_id, _multi_stage.selected_anchors)
	else:
		frames = RigStudioPosePropagator.single_pose(frames, _frame_index, targets, _stage.selected_anchors)
	_set_active_frames(frames)


func _toggle_onion(enabled: bool) -> void:
	_multi_stage.set_onion_skin(enabled and _scene_mode == "animation_editor")


func _change_timeline_mode(mode: String) -> void:
	if _scene_mode != "animation_editor":
		return
	var template := _multi_template()
	template["timeline_mode"] = mode
	_studio_data["motion_templates"][MULTI_TEMPLATE_ID] = template
	_dirty = true


func _add_verb(verb_id: String) -> void:
	if _scene_mode != "animation_editor" or not _verb_definitions.has(verb_id):
		return
	_push_undo()
	var verbs := _current_verbs()
	var definition: Dictionary = _verb_definitions[verb_id]
	var actors := {}
	var cast := _current_cast()
	for role_value in definition.get("roles", []):
		var role := str(role_value)
		actors[role] = str(cast[mini(actors.size(), cast.size() - 1)].get("id", "A")) if not cast.is_empty() else "A"
	var start_tick := int(_active_frames()[_frame_index].get("tick", 0))
	verbs.append({"id": "verb_%d" % (verbs.size() + 1), "verb_id": verb_id, "start_tick": start_tick, "end_tick": mini(_duration_ticks(), start_tick + 60), "actors": actors, "params": definition.get("defaults", {}).duplicate(true)})
	_set_verbs(verbs)


func _remove_verb(index: int) -> void:
	var verbs := _current_verbs()
	if index < 0 or index >= verbs.size():
		return
	_push_undo()
	verbs.remove_at(index)
	_set_verbs(verbs)


func _push_undo() -> void:
	_undo_stack.append({"artwork": _artwork_data.duplicate(true), "studio": _studio_data.duplicate(true), "characters": _characters.duplicate(true)})
	if _undo_stack.size() > 40:
		_undo_stack.pop_front()
	_redo_stack.clear()


func _restore_snapshot(snapshot: Dictionary) -> void:
	_artwork_data = snapshot.artwork.duplicate(true)
	_studio_data = snapshot.studio.duplicate(true)
	_characters = snapshot.get("characters", _characters).duplicate(true)
	_dirty = true
	_selected_part_index = -1
	_refresh_character_picker()
	_select_character_in_picker(_character_id)
	if _scene_mode == "animation_editor":
		_apply_multi_preview()
		_refresh_cast_ui()
	else:
		_apply_preview()
		_refresh_inventory()


func _header_action(action: String) -> void:
	match action:
		"Save All": _save_all()
		"Undo":
			if not _undo_stack.is_empty():
				_redo_stack.append({"artwork": _artwork_data.duplicate(true), "studio": _studio_data.duplicate(true), "characters": _characters.duplicate(true)})
				_restore_snapshot(_undo_stack.pop_back())
		"Redo":
			if not _redo_stack.is_empty():
				_undo_stack.append({"artwork": _artwork_data.duplicate(true), "studio": _studio_data.duplicate(true), "characters": _characters.duplicate(true)})
				_restore_snapshot(_redo_stack.pop_back())


func _write_json(path: String, data: Dictionary) -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(data, "  ") + "\n")
	file.flush()
	return file.get_error() == OK


func _save_all() -> void:
	if not Engine.is_editor_hint():
		_status.text = "Save is editor-only; exported games cannot author project resources."
		return
	if FileAccess.get_modified_time(ARTWORK_PATH) != _artwork_mtime or FileAccess.get_modified_time(STUDIO_PATH) != _studio_mtime or FileAccess.get_modified_time(CHARACTERS_PATH) != _characters_mtime:
		_status.text = "Project data changed outside Rig Studio. Reopen the editor screen before saving."
		return
	if not _write_json(ARTWORK_PATH, _artwork_data) or not _write_json(STUDIO_PATH, _studio_data) or not _write_json(CHARACTERS_PATH, _characters):
		_status.text = "Could not write one or more project data files."
		return
	_artwork_mtime = FileAccess.get_modified_time(ARTWORK_PATH)
	_studio_mtime = FileAccess.get_modified_time(STUDIO_PATH)
	_characters_mtime = FileAccess.get_modified_time(CHARACTERS_PATH)
	_dirty = false
	PaperDollRig.reload_authoring_data()
	if _scene_mode == "animation_editor":
		_refresh_cast_ui()
	else:
		_refresh_inventory()


func smoke_state() -> Dictionary:
	return {"characters": _character_picker.item_count - 1, "frames": _timeline.key_button_count(), "mode": _mode, "essential_missing": _stage.rig.missing_essential_slots().size(), "multi_rigs": _multi_stage.actor_count(), "scene_mode": _scene_mode, "timeline_mode": _timeline.view_mode, "verbs": _current_verbs().size(), "editor_only": Engine.is_editor_hint()}
