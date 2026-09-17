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


func setup(studio: Control, characters: Dictionary) -> void:
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
