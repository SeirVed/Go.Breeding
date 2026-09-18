## Copyright © 2026 SeirVed. All rights reserved. See LICENSE.md.
@tool
class_name RigStudioAnimationEditorPanel
extends ScrollContainer

var actor_list: ItemList
var actor_character_picker: OptionButton
var role_picker: OptionButton
var size_picker: OptionButton
var height_field: SpinBox
var stage_x_field: SpinBox
var stage_y_field: SpinBox
var note: Label
var storyboard_board_picker: OptionButton
var storyboard_first_picker: OptionButton
var storyboard_second_picker: OptionButton
var storyboard_phase_picker: OptionButton
var storyboard_note: Label


func setup(studio: Control, characters: Dictionary, body_types: Array = []) -> void:
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	var cast := VBoxContainer.new()
	cast.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cast.add_theme_constant_override("separation", 7)
	add_child(cast)
	_caption(cast, "ACTORS · ONE TO MANY")
	actor_list = ItemList.new()
	actor_list.custom_minimum_size.y = 114
	actor_list.item_selected.connect(studio._choose_cast_actor)
	cast.add_child(actor_list)
	var cast_actions := HBoxContainer.new()
	cast.add_child(cast_actions)
	_button(cast_actions, "+ Add actor", studio._add_cast_actor)
	_button(cast_actions, "− Remove selected", studio._remove_cast_actor)
	_caption(cast, "SELECTED ACTOR · INDEPENDENT CAST PROFILE")
	actor_character_picker = OptionButton.new()
	actor_character_picker.item_selected.connect(studio._change_actor_character)
	cast.add_child(actor_character_picker)
	refresh_characters(characters)
	var category_row := HBoxContainer.new()
	cast.add_child(category_row)
	var role_column := VBoxContainer.new()
	category_row.add_child(role_column)
	_caption(role_column, "Role")
	role_picker = OptionButton.new()
	role_picker.add_item("Male")
	role_picker.add_item("Female")
	role_picker.item_selected.connect(studio._change_actor_role)
	role_column.add_child(role_picker)
	var band_column := VBoxContainer.new()
	category_row.add_child(band_column)
	_caption(band_column, "Size band")
	size_picker = OptionButton.new()
	for band in ["Small <4′", "Medium 4–<8′", "Large 8′+"]:
		size_picker.add_item(band)
	size_picker.item_selected.connect(studio._change_actor_size)
	band_column.add_child(size_picker)
	var values := HBoxContainer.new()
	values.add_theme_constant_override("separation", 5)
	cast.add_child(values)
	height_field = _spin(values, "Exact height · in", 1.0, 240.0, 0.5, "height_inches", studio)
	stage_x_field = _spin(values, "Stage X", -1000.0, 1000.0, 1.0, "stage_x", studio)
	stage_y_field = _spin(values, "Stage Y", -500.0, 500.0, 1.0, "stage_y", studio)
	note = Label.new()
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note.text = "Shift-click nodes to multi-select. Simple mode composes verb blocks; Advanced exposes timed keys, interpolation and Propagate."
	cast.add_child(note)
	_caption(cast, "PAIRING SCENE · PHASED PLACEHOLDER PLAN")
	storyboard_board_picker = OptionButton.new()
	for board in [{"id": "jack_jill", "label": "Jack & Jill · m+f"}, {"id": "jack_jack", "label": "Jack & Jack · m+m"}, {"id": "jill_jill", "label": "Jill & Jill · f+f"}]:
		storyboard_board_picker.add_item(board.label)
		storyboard_board_picker.set_item_metadata(storyboard_board_picker.item_count - 1, board.id)
	cast.add_child(storyboard_board_picker)
	var pairing_row := HBoxContainer.new()
	pairing_row.add_theme_constant_override("separation", 5)
	cast.add_child(pairing_row)
	storyboard_first_picker = _body_picker(pairing_row, "First", body_types)
	storyboard_second_picker = _body_picker(pairing_row, "Second", body_types)
	storyboard_phase_picker = OptionButton.new()
	for phase in [
		{"id": "", "label": "Entire scene · Intro → Loops → Climax → End"},
		{"id": "intro", "label": "Intro / Couple"},
		{"id": "loop_a", "label": "Loop A · Anchor"},
		{"id": "loop_b", "label": "Loop B · Variation"},
		{"id": "climax", "label": "Climax"},
		{"id": "end", "label": "End / Uncouple"},
	]:
		storyboard_phase_picker.add_item(phase.label)
		storyboard_phase_picker.set_item_metadata(storyboard_phase_picker.item_count - 1, phase.id)
	cast.add_child(storyboard_phase_picker)
	_button(cast, "Load phased scene into Actor A/B", studio._load_pairing_storyboard)
	storyboard_note = Label.new()
	storyboard_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	storyboard_note.text = "Loads the full phase graph or one isolated phase. Planned/contact-only beats remain visible but inert; this never creates commission progress."
	cast.add_child(storyboard_note)


func refresh_characters(characters: Dictionary) -> void:
	if actor_character_picker == null:
		return
	actor_character_picker.clear()
	actor_character_picker.add_item("Generic guide / no art")
	actor_character_picker.set_item_metadata(0, "")
	var keys := characters.keys()
	keys.sort()
	if "default_template" in keys:
		keys.erase("default_template")
		keys.push_front("default_template")
	for key in keys:
		actor_character_picker.add_item(str(characters[key].get("display_name", key)))
		actor_character_picker.set_item_metadata(actor_character_picker.item_count - 1, key)


func _caption(parent: Control, words: String) -> void:
	var label := Label.new()
	label.text = words
	parent.add_child(label)


func _button(parent: Control, words: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = words
	button.pressed.connect(callback)
	parent.add_child(button)
	return button


func _spin(parent: Control, title: String, minimum: float, maximum: float, step_value: float, field: String, studio: Control) -> SpinBox:
	var column := VBoxContainer.new()
	parent.add_child(column)
	_caption(column, title)
	var spin := SpinBox.new()
	spin.min_value = minimum
	spin.max_value = maximum
	spin.step = step_value
	spin.custom_minimum_size.x = 100
	spin.value_changed.connect(studio._change_actor_number.bind(field))
	column.add_child(spin)
	return spin


func _body_picker(parent: Control, title: String, body_types: Array) -> OptionButton:
	var column := VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(column)
	_caption(column, title)
	var picker := OptionButton.new()
	picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for body in body_types:
		picker.add_item("%s · %s" % [body.get("short", "?"), body.get("label", body.get("id", "body"))])
		picker.set_item_metadata(picker.item_count - 1, str(body.get("id", "")))
	column.add_child(picker)
	return picker
