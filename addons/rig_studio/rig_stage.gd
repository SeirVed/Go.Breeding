## Copyright © 2026 SeirVed. All rights reserved. See LICENSE.md.
@tool
class_name RigStudioStage
extends Control

const BACKGROUND := Color("#17251f")
const GRID := Color("#30483a")
const SELECTED := Color("#ffcf73")
const PREVIEW_ZOOM := 1.8

var studio: Control
var rig: PaperDollRig
var selected_anchor := ""
var selected_anchors: Array[String] = []
var _dragging := false


func _ready() -> void:
	clip_contents = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	custom_minimum_size = Vector2(500, 430)
	rig = PaperDollRig.new()
	rig.name = "AuthoringPreviewRig"
	add_child(rig)
	rig.scale = Vector2.ONE * PREVIEW_ZOOM
	rig.set_process(false)
	rig.set_editor_preview(true)
	rig.set_editor_guides(true)
	_place_rig()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_place_rig()
		queue_redraw()


func _place_rig() -> void:
	if rig != null:
		rig.position = Vector2(size.x * 0.5, size.y * 0.82)


func select_anchor(anchor: String, additive: bool = false) -> void:
	selected_anchor = anchor
	if additive:
		if anchor in selected_anchors:
			selected_anchors.erase(anchor)
		else:
			selected_anchors.append(anchor)
	else:
		selected_anchors.assign([anchor])
	queue_redraw()


func _anchor_screen_position(anchor: String) -> Vector2:
	return rig.position + rig.get_anchor_local(anchor) * rig.visual_scale() * PREVIEW_ZOOM


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), BACKGROUND)
	for x in range(0, int(size.x), 40):
		draw_line(Vector2(x, 0), Vector2(x, size.y), GRID, 1.0)
	for y in range(0, int(size.y), 40):
		draw_line(Vector2(0, y), Vector2(size.x, y), GRID, 1.0)
	if rig != null:
		for anchor in selected_anchors:
			var point := _anchor_screen_position(anchor)
			draw_arc(point, 15.0, 0.0, TAU, 32, SELECTED, 2.5, true)


func _gui_input(event: InputEvent) -> void:
	if rig == null or studio == null:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var nearest := ""
			var distance := 17.0
			for anchor in PaperDollRig.VALID_ANCHORS:
				var candidate: float = event.position.distance_to(_anchor_screen_position(anchor))
				if candidate < distance:
					nearest = anchor
					distance = candidate
			if not nearest.is_empty():
				select_anchor(nearest, event.shift_pressed)
				studio.stage_select_anchor(nearest, event.shift_pressed)
				_dragging = studio.stage_begin_drag(nearest)
				accept_event()
		else:
			if _dragging:
				studio.stage_end_drag()
			_dragging = false
	elif event is InputEventMouseMotion and _dragging:
		var units: Vector2 = event.relative / maxf(0.001, rig.visual_scale() * PREVIEW_ZOOM)
		studio.stage_drag_anchor(selected_anchor, units)
		queue_redraw()
		accept_event()
