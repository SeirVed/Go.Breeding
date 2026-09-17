## Copyright © 2026 SeirVed. All rights reserved. See LICENSE.md.
@tool
extends EditorPlugin

var _screen: RigStudioScreen


func _enter_tree() -> void:
	_screen = RigStudioScreen.new()
	_screen.name = "Rig Studio"
	_screen.size_flags_vertical = Control.SIZE_EXPAND_FILL
	EditorInterface.get_editor_main_screen().add_child(_screen)
	_screen.hide()


func _exit_tree() -> void:
	if _screen != null:
		_screen.queue_free()
		_screen = null


func _has_main_screen() -> bool:
	return true


func _get_plugin_name() -> String:
	return "Rig Studio"


func _make_visible(visible: bool) -> void:
	if _screen != null:
		_screen.visible = visible
