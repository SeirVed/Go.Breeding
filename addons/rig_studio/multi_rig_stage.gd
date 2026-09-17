## Copyright © 2026 SeirVed. All rights reserved. See LICENSE.md.
@tool
class_name RigStudioMultiStage
extends Control

const BACKGROUND := Color("#17251f")
const GRID := Color("#30483a")
const ACTIVE := Color("#ffcf73")
const INACTIVE := Color("#b5ac97")
const PREVIEW_ZOOM := 1.35

var studio
var actors: Array = []
var rigs: Dictionary = {}
var labels: Dictionary = {}
var ghost_previous: Dictionary = {}
var ghost_next: Dictionary = {}
var stage_motion_offsets: Dictionary = {}
var _frames: Array = []
var _duration_ticks := 240
var _verbs: Array = []
var _onion_enabled := false
var _phase := 0.0
var selected_actor_id := ""
var selected_anchor := ""
var selected_anchors: Array[String] = []
var _dragging := false


func _ready() -> void:
	clip_contents = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	custom_minimum_size = Vector2(500, 430)


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_place_rigs()
		queue_redraw()


func set_cast(new_actors: Array, art_by_character: Dictionary = {}, characters_by_id: Dictionary = {}) -> void:
	for rig in rigs.values() + ghost_previous.values() + ghost_next.values():
		remove_child(rig)
		rig.queue_free()
	for label in labels.values():
		remove_child(label)
		label.queue_free()
	rigs.clear()
	ghost_previous.clear()
	ghost_next.clear()
	labels.clear()
	stage_motion_offsets.clear()
	actors = new_actors.duplicate(true)
	for actor in actors:
		var id := str(actor.get("id", ""))
		if id.is_empty():
			continue
		var rig := _create_rig(actor, art_by_character, characters_by_id)
		rig.name = "CastRig_%s" % id
		add_child(rig)
		rigs[id] = rig
		var previous := _create_rig(actor, art_by_character, characters_by_id)
		previous.name = "OnionPrevious_%s" % id
		previous.modulate = Color(0.45, 0.72, 1.0, 0.26)
		previous.z_index = -2
		add_child(previous)
		ghost_previous[id] = previous
		var following := _create_rig(actor, art_by_character, characters_by_id)
		following.name = "OnionNext_%s" % id
		following.modulate = Color(1.0, 0.55, 0.35, 0.22)
		following.z_index = -1
		add_child(following)
		ghost_next[id] = following
		var caption := Label.new()
		caption.text = "ACTOR %s" % id
		caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(caption)
		labels[id] = caption
	if selected_actor_id.is_empty() or not rigs.has(selected_actor_id):
		selected_actor_id = str(actors[0].get("id", "")) if not actors.is_empty() else ""
	selected_anchor = ""
	selected_anchors.clear()
	_refresh_ghost_visibility()
	_place_rigs()
	queue_redraw()


func _create_rig(actor: Dictionary, art_by_character: Dictionary, characters_by_id: Dictionary) -> PaperDollRig:
	var rig := PaperDollRig.new()
	rig.scale = Vector2.ONE * PREVIEW_ZOOM
	var character_id := str(actor.get("character_id", ""))
	rig.configure_cast_actor(str(actor.get("role", "male")), str(actor.get("size", "medium")), float(actor.get("height_inches", 72.0)), character_id, characters_by_id.get(character_id, {}))
	rig.set_process(false)
	rig.set_editor_preview(true)
	rig.set_editor_guides(true)
	rig.set_rest_anchor_offsets(actor.get("rig_offsets", {}))
	if not str(actor.get("character_id", "")).is_empty():
		rig.use_artwork_parts_for_test(art_by_character.get(str(actor.character_id), []))
	return rig


func _place_rigs() -> void:
	for actor in actors:
		var id := str(actor.get("id", ""))
		if not rigs.has(id):
			continue
		var rig: PaperDollRig = rigs[id]
		var motion: Vector2 = stage_motion_offsets.get(id, Vector2.ZERO)
		var base := Vector2(size.x * 0.5 + float(actor.get("stage_x", 0.0)), size.y * 0.82 + float(actor.get("stage_y", 0.0)))
		rig.position = base + motion
		if ghost_previous.has(id):
			ghost_previous[id].position = base + _stage_motion_at(_adjacent_phase(-1), id)
		if ghost_next.has(id):
			ghost_next[id].position = base + _stage_motion_at(_adjacent_phase(1), id)
		var caption: Label = labels[id]
		caption.position = _anchor_screen_position(id, "head") + Vector2(-40.0, -65.0)
		caption.modulate = ACTIVE if id == selected_actor_id else INACTIVE


func get_actor_rig(id: String) -> PaperDollRig:
	return rigs.get(id, null)


func actor_count() -> int:
	return rigs.size()


func select_actor(id: String, anchor: String = "", additive: bool = false) -> void:
	if not rigs.has(id):
		return
	if id != selected_actor_id:
		selected_anchors.clear()
	selected_actor_id = id
	selected_anchor = anchor
	if not anchor.is_empty():
		if additive:
			if anchor in selected_anchors:
				selected_anchors.erase(anchor)
			else:
				selected_anchors.append(anchor)
		else:
			selected_anchors.assign([anchor])
	elif not additive:
		selected_anchors.clear()
	_refresh_ghost_visibility()
	_place_rigs()
	queue_redraw()


func set_actor_offsets(id: String, offsets: Dictionary) -> void:
	var rig := get_actor_rig(id)
	if rig != null:
		rig.set_rest_anchor_offsets(offsets)
		_place_rigs()
		queue_redraw()


func set_frames(frames: Array, duration_ticks: int = 240) -> void:
	_frames = frames.duplicate(true)
	_duration_ticks = maxi(1, duration_ticks)
	for actor in actors:
		var id := str(actor.get("id", ""))
		var rig := get_actor_rig(id)
		if rig == null:
			continue
		var actor_frames := []
		for frame in frames:
			var actor_frame: Dictionary = frame.get("actors", {}).get(id, {})
			actor_frames.append({"tick": int(frame.get("tick", actor_frames.size() * 30)), "interpolation": str(frame.get("interpolation", "smooth")), "offsets": actor_frame.get("offsets", {})})
		rig.set_motion_frames(actor_frames, _duration_ticks)
		ghost_previous[id].set_motion_frames(actor_frames, _duration_ticks)
		ghost_next[id].set_motion_frames(actor_frames, _duration_ticks)
	_place_rigs()
	queue_redraw()


func set_verbs(verbs: Array) -> void:
	_verbs = verbs.duplicate(true)
	set_phase(_phase)


func set_onion_skin(enabled: bool) -> void:
	_onion_enabled = enabled
	_refresh_ghost_visibility()
	set_phase(_phase)


func set_phase(phase: float) -> void:
	_phase = fposmod(phase, 1.0)
	stage_motion_offsets.clear()
	var tick := _phase * _duration_ticks
	for actor in actors:
		var id := str(actor.get("id", ""))
		stage_motion_offsets[id] = _stage_motion_at(_phase, id)
		var rig: PaperDollRig = rigs[id]
		rig.set_overlay_offsets(RigStudioVerbEngine.offsets_for_actor(_verbs, tick, id))
		rig.set_cycle_phase(_phase)
		var previous_phase := _adjacent_phase(-1)
		var next_phase := _adjacent_phase(1)
		ghost_previous[id].set_overlay_offsets(RigStudioVerbEngine.offsets_for_actor(_verbs, previous_phase * _duration_ticks, id))
		ghost_previous[id].set_cycle_phase(previous_phase)
		ghost_next[id].set_overlay_offsets(RigStudioVerbEngine.offsets_for_actor(_verbs, next_phase * _duration_ticks, id))
		ghost_next[id].set_cycle_phase(next_phase)
	_place_rigs()
	queue_redraw()


func _stage_motion_at(phase: float, id: String) -> Vector2:
	if _frames.size() < 2:
		return Vector2.ZERO
	var sample := _frame_sample(phase)
	var current: Dictionary = _frames[sample.current].get("actors", {}).get(id, {})
	var next: Dictionary = _frames[sample.next].get("actors", {}).get(id, {})
	return _stage_vector(current.get("stage_offset", [0.0, 0.0])).lerp(_stage_vector(next.get("stage_offset", [0.0, 0.0])), sample.weight)


func _frame_sample(phase: float) -> Dictionary:
	var target := fposmod(phase, 1.0) * _duration_ticks
	var current_index := 0
	var next_index := 0
	for index in _frames.size():
		if float(_frames[index].get("tick", 0)) <= target:
			current_index = index
		else:
			next_index = index
			break
	if next_index == 0 and current_index == _frames.size() - 1:
		next_index = 0
	var current_tick := float(_frames[current_index].get("tick", 0))
	var next_tick := float(_frames[next_index].get("tick", 0))
	if next_index == 0 and current_index == _frames.size() - 1:
		next_tick += _duration_ticks
	var weight := clampf((target - current_tick) / maxf(1.0, next_tick - current_tick), 0.0, 1.0)
	match str(_frames[current_index].get("interpolation", "smooth")):
		"hold": weight = 0.0
		"smooth": weight = smoothstep(0.0, 1.0, weight)
	return {"current": current_index, "next": next_index, "weight": weight}


func _adjacent_phase(direction: int) -> float:
	if _frames.is_empty():
		return _phase
	var sample := _frame_sample(_phase)
	var index: int = sample.current
	index = posmod(index + direction, _frames.size())
	return float(_frames[index].get("tick", 0)) / _duration_ticks


func _refresh_ghost_visibility() -> void:
	for id in ghost_previous:
		ghost_previous[id].visible = _onion_enabled and str(id) == selected_actor_id
		ghost_next[id].visible = _onion_enabled and str(id) == selected_actor_id


func _stage_vector(value: Variant) -> Vector2:
	if value is Array and value.size() == 2:
		return Vector2(float(value[0]), float(value[1]))
	return Vector2.ZERO


func _anchor_screen_position(id: String, anchor: String) -> Vector2:
	var rig := get_actor_rig(id)
	if rig == null:
		return Vector2.ZERO
	return rig.position + rig.get_anchor_local(anchor) * rig.visual_scale() * PREVIEW_ZOOM


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), BACKGROUND)
	for x in range(0, int(size.x), 40):
		draw_line(Vector2(x, 0), Vector2(x, size.y), GRID, 1.0)
	for y in range(0, int(size.y), 40):
		draw_line(Vector2(0, y), Vector2(size.x, y), GRID, 1.0)
	if not selected_actor_id.is_empty():
		for anchor in selected_anchors:
			var point := _anchor_screen_position(selected_actor_id, anchor)
			draw_arc(point, 15.0, 0.0, TAU, 32, ACTIVE, 2.5, true)


func _gui_input(event: InputEvent) -> void:
	if studio == null:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var nearest_actor := ""
			var nearest_anchor := ""
			var distance := 18.0
			for id in rigs:
				for anchor in PaperDollRig.VALID_ANCHORS:
					var candidate: float = event.position.distance_to(_anchor_screen_position(str(id), anchor))
					if candidate < distance:
						nearest_actor = str(id)
						nearest_anchor = anchor
						distance = candidate
			if not nearest_actor.is_empty():
				select_actor(nearest_actor, nearest_anchor, event.shift_pressed)
				studio.multi_stage_select_actor(nearest_actor, nearest_anchor, event.shift_pressed)
				_dragging = studio.multi_stage_begin_drag(nearest_actor, nearest_anchor)
				accept_event()
		else:
			if _dragging:
				studio.multi_stage_end_drag()
			_dragging = false
	elif event is InputEventMouseMotion and _dragging:
		var rig := get_actor_rig(selected_actor_id)
		if rig == null:
			return
		var units: Vector2 = event.relative / maxf(0.001, rig.visual_scale() * PREVIEW_ZOOM)
		studio.multi_stage_drag_anchor(selected_actor_id, selected_anchor, units, event.relative)
		queue_redraw()
		accept_event()
