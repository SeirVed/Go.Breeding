## Copyright © 2026 SeirVed. All rights reserved. See LICENSE.md.
@tool
class_name RigStudioSingleBuilderPanel
extends ScrollContainer

var attached_list: ItemList
var missing_list: ItemList
var part_label: Label
var attach_button: Button
var unassign_button: Button
var scale_field: SpinBox
var x_field: SpinBox
var y_field: SpinBox
var z_field: SpinBox
var topology_picker: OptionButton
var attachment_picker: OptionButton
var attachment_list: ItemList
var _catalog: Dictionary = {}


func setup(studio: Control, anatomy_catalog: Dictionary) -> void:
	_catalog = anatomy_catalog
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	var inventory := VBoxContainer.new()
	inventory.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inventory.add_theme_constant_override("separation", 6)
	add_child(inventory)
	_caption(inventory, "BODY FOUNDATION · EXCLUSIVE")
	topology_picker = OptionButton.new()
	var topology_ids: Array = _catalog.get("topologies", {}).keys()
	topology_ids.sort()
	for id_value in topology_ids:
		var id := str(id_value)
		var definition: Dictionary = _catalog.topologies[id]
		topology_picker.add_item("%s · %s" % [definition.get("display_name", id), definition.get("status", "draft")])
		topology_picker.set_item_metadata(topology_picker.item_count - 1, id)
	topology_picker.item_selected.connect(studio._change_character_topology)
	inventory.add_child(topology_picker)
	_caption(inventory, "ADDITIVE ANATOMY COMPONENTS")
	var attachment_actions := HBoxContainer.new()
	inventory.add_child(attachment_actions)
	attachment_picker = OptionButton.new()
	attachment_picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var attachment_ids: Array = _catalog.get("attachments", {}).keys()
	attachment_ids.sort()
	for id_value in attachment_ids:
		var id := str(id_value)
		var definition: Dictionary = _catalog.attachments[id]
		attachment_picker.add_item("%s · %s" % [definition.get("display_name", id), definition.get("status", "draft")])
		attachment_picker.set_item_metadata(attachment_picker.item_count - 1, id)
	attachment_actions.add_child(attachment_picker)
	var add_attachment := Button.new()
	add_attachment.text = "+ Add"
	add_attachment.pressed.connect(studio._add_character_attachment)
	attachment_actions.add_child(add_attachment)
	var remove_attachment := Button.new()
	remove_attachment.text = "− Remove"
	remove_attachment.pressed.connect(studio._remove_character_attachment)
	attachment_actions.add_child(remove_attachment)
	attachment_list = ItemList.new()
	attachment_list.custom_minimum_size.y = 58
	inventory.add_child(attachment_list)
	_caption(inventory, "CHARACTER PARTS · DEFAULT TEMPLATE STARTS HUMAN")
	attached_list = ItemList.new()
	attached_list.custom_minimum_size.y = 72
	attached_list.item_selected.connect(studio._choose_attached)
	inventory.add_child(attached_list)
	_caption(inventory, "MISSING / UNASSIGNED PARTS")
	missing_list = ItemList.new()
	missing_list.custom_minimum_size.y = 96
	missing_list.item_selected.connect(studio._choose_missing)
	inventory.add_child(missing_list)
	var actions := HBoxContainer.new()
	inventory.add_child(actions)
	attach_button = Button.new()
	attach_button.text = "Attach project PNG…"
	attach_button.pressed.connect(studio._choose_png)
	actions.add_child(attach_button)
	unassign_button = Button.new()
	unassign_button.text = "Unassign part"
	unassign_button.pressed.connect(studio._unassign_part)
	actions.add_child(unassign_button)
	_caption(inventory, "SELECTED IMAGE TRANSFORM")
	part_label = Label.new()
	inventory.add_child(part_label)
	var fields := HBoxContainer.new()
	fields.add_theme_constant_override("separation", 4)
	inventory.add_child(fields)
	scale_field = _spin(fields, "Scale", 0.05, 5.0, 0.05, 1.0, "scale", studio)
	x_field = _spin(fields, "X", -300.0, 300.0, 1.0, 0.0, "x", studio)
	y_field = _spin(fields, "Y", -300.0, 300.0, 1.0, 0.0, "y", studio)
	z_field = _spin(fields, "Layer", -100.0, 100.0, 1.0, 0.0, "z", studio)
	var note := Label.new()
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note.text = "Only Humanoid · plantigrade is implemented. Other foundations and most attachments are selectable design contracts, not working skeleton coverage yet."
	inventory.add_child(note)


func refresh_anatomy(character: Dictionary) -> void:
	var topology := str(character.get("topology", "humanoid_plantigrade"))
	for item in topology_picker.item_count:
		if str(topology_picker.get_item_metadata(item)) == topology:
			topology_picker.select(item)
			break
	attachment_list.clear()
	for attachment_value in character.get("attachments", []):
		var attachment := str(attachment_value)
		var definition: Dictionary = _catalog.get("attachments", {}).get(attachment, {})
		attachment_list.add_item("%s · %s" % [definition.get("display_name", attachment), definition.get("status", "draft")])
		attachment_list.set_item_metadata(attachment_list.item_count - 1, attachment)


func _caption(parent: Control, words: String) -> void:
	var label := Label.new()
	label.text = words
	parent.add_child(label)


func _spin(parent: Control, title: String, minimum: float, maximum: float, step_value: float, initial: float, field: String, studio: Control) -> SpinBox:
	var column := VBoxContainer.new()
	parent.add_child(column)
	_caption(column, title)
	var spin := SpinBox.new()
	spin.min_value = minimum
	spin.max_value = maximum
	spin.step = step_value
	spin.value = initial
	spin.custom_minimum_size.x = 82
	spin.value_changed.connect(studio._change_part_transform.bind(field))
	column.add_child(spin)
	return spin
