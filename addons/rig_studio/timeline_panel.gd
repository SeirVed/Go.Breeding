## Copyright © 2026 SeirVed. All rights reserved. See LICENSE.md.
@tool
class_name RigStudioTimelinePanel
extends VBoxContainer

signal key_selected(index: int)
signal play_toggled
signal reset_key_requested
signal add_key_requested
signal inbetween_requested
signal duplicate_key_requested
signal remove_key_requested
signal key_tick_changed(tick: int)
signal interpolation_changed(kind: String)
signal propagate_requested(target_index: int, all_following: bool)
signal onion_changed(enabled: bool)
signal view_mode_changed(mode: String)
signal add_verb_requested(verb_id: String)
signal remove_verb_requested(index: int)

var view_mode := "simple"
var _updating := false
var _frame_buttons: Array[Button] = []
var _key_row: HBoxContainer
var _advanced: VBoxContainer
var _caption: Label
var _play_button: Button
var _position_label: Label
var _onion: CheckButton
var _tick_field: SpinBox
var _target_field: SpinBox
var _all_following: CheckBox
var _interpolation: OptionButton
var _verb_box: VBoxContainer
var _verb_picker: OptionButton
var _verb_list: ItemList
var _simple_button: Button
var _advanced_button: Button


func _ready() -> void:
	add_theme_constant_override("separation", 5)
	var heading := HBoxContainer.new()
	add_child(heading)
	_caption = Label.new()
	_caption.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading.add_child(_caption)
	_simple_button = Button.new()
	_simple_button.text = "Simple"
	_simple_button.toggle_mode = true
	_simple_button.button_pressed = true
	_simple_button.pressed.connect(_set_view_mode.bind("simple"))
	heading.add_child(_simple_button)
	_advanced_button = Button.new()
	_advanced_button.text = "Advanced"
	_advanced_button.toggle_mode = true
	_advanced_button.pressed.connect(_set_view_mode.bind("advanced"))
	heading.add_child(_advanced_button)
	_onion = CheckButton.new()
	_onion.text = "Onion skins"
	_onion.toggled.connect(func(enabled: bool): onion_changed.emit(enabled))
	heading.add_child(_onion)
	var key_scroll := ScrollContainer.new()
	key_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	key_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	key_scroll.custom_minimum_size.y = 42
	add_child(key_scroll)
	_key_row = HBoxContainer.new()
	_key_row.add_theme_constant_override("separation", 4)
	key_scroll.add_child(_key_row)
	var simple_actions := HBoxContainer.new()
	add_child(simple_actions)
	_add_button(simple_actions, "+ Key", add_key_requested.emit)
	_add_button(simple_actions, "+ In-between", inbetween_requested.emit)
	_add_button(simple_actions, "− Key", remove_key_requested.emit)
	_play_button = _add_button(simple_actions, "▶ Play", play_toggled.emit)
	_add_button(simple_actions, "Reset", reset_key_requested.emit)
	_position_label = Label.new()
	simple_actions.add_child(_position_label)
	_advanced = VBoxContainer.new()
	_advanced.add_theme_constant_override("separation", 4)
	add_child(_advanced)
	var key_details := HBoxContainer.new()
	_advanced.add_child(key_details)
	_add_button(key_details, "Duplicate", duplicate_key_requested.emit)
	_tick_field = _add_spin(key_details, "Tick", 0, 100000, 1)
	_tick_field.value_changed.connect(_on_tick_changed)
	_interpolation = OptionButton.new()
	for kind in ["Smooth", "Linear", "Hold / Step"]:
		_interpolation.add_item(kind)
	_interpolation.item_selected.connect(_on_interpolation_changed)
	key_details.add_child(_interpolation)
	var propagation := HBoxContainer.new()
	_advanced.add_child(propagation)
	var propagate_label := Label.new()
	propagate_label.text = "Propagate selected nodes to key"
	propagation.add_child(propagate_label)
	_target_field = SpinBox.new()
	_target_field.min_value = 1
	_target_field.max_value = 1
	_target_field.step = 1
	_target_field.custom_minimum_size.x = 68
	propagation.add_child(_target_field)
	_all_following = CheckBox.new()
	_all_following.text = "all following"
	propagation.add_child(_all_following)
	_add_button(propagation, "Propagate →", _emit_propagate)
	_verb_box = VBoxContainer.new()
	_verb_box.add_theme_constant_override("separation", 4)
	add_child(_verb_box)
	var verb_heading := Label.new()
	verb_heading.text = "VERB BLOCKS · COMPOSABLE MOTION DRAFT"
	_verb_box.add_child(verb_heading)
	var verb_actions := HBoxContainer.new()
	_verb_box.add_child(verb_actions)
	_verb_picker = OptionButton.new()
	_verb_picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	verb_actions.add_child(_verb_picker)
	_add_button(verb_actions, "+ Add verb", _emit_add_verb)
	_add_button(verb_actions, "− Verb", _emit_remove_verb)
	_verb_list = ItemList.new()
	_verb_list.custom_minimum_size.y = 62
	_verb_box.add_child(_verb_list)
	_advanced.hide()


func configure(caption: String, frames: Array, current_index: int, duration_ticks: int, verbs: Array, verb_definitions: Dictionary, animation_context: bool) -> void:
	_updating = true
	_caption.text = caption
	for child in _key_row.get_children():
		child.queue_free()
	_frame_buttons.clear()
	for index in frames.size():
		var frame: Dictionary = frames[index]
		var button := Button.new()
		button.text = "%d\n@%d" % [index + 1, int(frame.get("tick", index * 30))]
		button.tooltip_text = "Key %d · tick %d" % [index + 1, int(frame.get("tick", index * 30))]
		button.toggle_mode = true
		button.button_pressed = index == current_index
		button.pressed.connect(func(): key_selected.emit(index))
		_key_row.add_child(button)
		_frame_buttons.append(button)
	var safe_index := clampi(current_index, 0, maxi(0, frames.size() - 1))
	var tick := int(frames[safe_index].get("tick", 0)) if not frames.is_empty() else 0
	_tick_field.max_value = maxi(1, duration_ticks)
	_tick_field.value = tick
	_target_field.max_value = maxi(1, frames.size())
	_target_field.value = mini(frames.size(), safe_index + 2)
	var interpolation_kind := str(frames[safe_index].get("interpolation", "smooth")) if not frames.is_empty() else "smooth"
	_interpolation.select({"smooth": 0, "linear": 1, "hold": 2}.get(interpolation_kind, 0))
	_position_label.text = "key %d/%d · tick %d/%d" % [safe_index + 1, frames.size(), tick, duration_ticks]
	_verb_box.visible = animation_context
	_verb_picker.clear()
	var ids := verb_definitions.keys()
	ids.sort()
	for id_value in ids:
		var id := str(id_value)
		_verb_picker.add_item(str(verb_definitions[id].get("display_name", id)))
		_verb_picker.set_item_metadata(_verb_picker.item_count - 1, id)
	_verb_list.clear()
	for verb_value in verbs:
		var verb: Dictionary = verb_value
		var definition: Dictionary = verb_definitions.get(str(verb.get("verb_id", "")), {})
		_verb_list.add_item("%s · %d→%d · %s" % [definition.get("display_name", verb.get("verb_id", "Verb")), int(verb.get("start_tick", 0)), int(verb.get("end_tick", 0)), definition.get("status", "draft")])
	_updating = false


func set_playing(playing: bool) -> void:
	_play_button.text = "⏸ Pause" if playing else "▶ Play"


func onion_enabled() -> bool:
	return _onion.button_pressed


func key_button_count() -> int:
	return _frame_buttons.size()


func select_view_mode(mode: String, notify: bool = false) -> void:
	mode = "advanced" if mode == "advanced" else "simple"
	view_mode = mode
	_simple_button.button_pressed = mode == "simple"
	_advanced_button.button_pressed = mode == "advanced"
	_advanced.visible = mode == "advanced"
	if notify:
		view_mode_changed.emit(mode)


func _set_view_mode(mode: String) -> void:
	select_view_mode(mode, true)


func _add_button(parent: Control, words: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = words
	button.pressed.connect(callback)
	parent.add_child(button)
	return button


func _add_spin(parent: Control, words: String, minimum: float, maximum: float, step_value: float) -> SpinBox:
	var label := Label.new()
	label.text = words
	parent.add_child(label)
	var spin := SpinBox.new()
	spin.min_value = minimum
	spin.max_value = maximum
	spin.step = step_value
	spin.custom_minimum_size.x = 92
	parent.add_child(spin)
	return spin


func _on_tick_changed(value: float) -> void:
	if not _updating:
		key_tick_changed.emit(int(value))


func _on_interpolation_changed(index: int) -> void:
	if not _updating:
		interpolation_changed.emit(["smooth", "linear", "hold"][index])


func _emit_propagate() -> void:
	propagate_requested.emit(int(_target_field.value) - 1, _all_following.button_pressed)


func _emit_add_verb() -> void:
	if _verb_picker.item_count > 0:
		add_verb_requested.emit(str(_verb_picker.get_item_metadata(_verb_picker.selected)))


func _emit_remove_verb() -> void:
	if not _verb_list.get_selected_items().is_empty():
		remove_verb_requested.emit(int(_verb_list.get_selected_items()[0]))
