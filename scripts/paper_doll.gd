## Copyright © 2026 SeirVed. All rights reserved. See LICENSE.md.

@tool
class_name PaperDollRig
extends Node2D

const PROFILE_PATH := "res://data/paper_doll_profiles.json"
const CHARACTER_PATH := "res://data/paper_doll_characters.json"
const PART_SET_PATH := "res://data/paper_doll_part_sets.json"
const ARTWORK_PATH := "res://data/paper_doll_artwork.json"
const STUDIO_PATH := "res://data/paper_doll_studio.json"
const EMERGENCY_ART_PATH := "res://art/placeholder/unknown_character.png"
const ESSENTIAL_BODY_SLOTS := [
	"head", "torso", "upper_arm_left", "lower_arm_left", "hand_left",
	"upper_arm_right", "lower_arm_right", "hand_right", "upper_leg_left",
	"lower_leg_left", "foot_left", "upper_leg_right", "lower_leg_right", "foot_right",
]
const DEBUG_LINE := Color("#b5ac97")
const DEBUG_JOINT := Color("#e1b04c")
const REQUIRED_PROFILE_FIELDS := [
	"head_radius", "shoulder_width", "waist_width", "hip_width", "torso_height",
	"arm_length", "leg_length", "limb_width", "stance_width", "stride_degrees",
	"bob", "cadence", "body_scale", "height_inches", "heads_tall",
]
const VALID_ANCHORS := [
	"root", "pelvis", "torso", "head", "shoulder_left", "shoulder_right",
	"elbow_left", "elbow_right", "hand_left", "hand_right", "hip_left",
	"hip_right", "knee_left", "knee_right", "foot_left", "foot_right",
	"effect_origin",
]

static var _profiles: Dictionary = {}
static var _characters: Dictionary = {}
static var _part_sets: Dictionary = {}
static var _artwork: Dictionary = {}
static var _studio_data: Dictionary = {}

var role_id := "male"
var size_id := "medium"
var character_id := ""
var profile: Dictionary = {}
var character_data: Dictionary = {}
var resolved_part_sets: Array[Dictionary] = []
var animation_speed := 1.0
var walking := true
var debug_skeleton := false
var editor_guides := false
var editor_preview := false
var _phase := 0.0
var _height_scale := 1.0
var _cast_height_inches := 0.0
var _anchors: Dictionary = {}
var _art_root: Node2D
var _art_specs: Array[Dictionary] = []
var _art_sprites: Array[Sprite2D] = []
var _fallback_sprite: Sprite2D
var _missing_emergency_texture := false
var _art_ready := false
var _rest_offsets: Dictionary = {}
var _motion_frames: Array = []
var _motion_duration_ticks := 0
var _overlay_offsets: Dictionary = {}


func _ready() -> void:
	_art_root = Node2D.new()
	_art_root.name = "ClippedArtwork"
	add_child(_art_root)
	if profile.is_empty():
		configure(role_id, size_id)
	else:
		_rebuild_artwork()
	_refresh_pose()
	set_process(true)


func configure(new_role: String, new_size: String) -> void:
	role_id = new_role
	size_id = new_size
	character_id = ""
	character_data = {}
	resolved_part_sets.clear()
	_height_scale = 1.0
	_cast_height_inches = 0.0
	profile = get_profile(role_id, size_id)
	_rest_offsets = {}
	_load_studio_data()
	var walk_template: Dictionary = _studio_data.get("motion_templates", {}).get("walk_humanoid_v1", {})
	_motion_frames = walk_template.get("frames", []).duplicate(true)
	_motion_duration_ticks = int(walk_template.get("duration_ticks", 0))
	if profile.is_empty():
		push_error("Missing paper-doll profile: %s/%s" % [role_id, size_id])
	if _art_root != null:
		_rebuild_artwork()
	_refresh_pose()


func configure_character(new_character_id: String, enabled_kinds: PackedStringArray = PackedStringArray()) -> void:
	var data := get_character(new_character_id)
	if data.is_empty():
		# A missing definition must not leave a previously selected character behind.
		configure("male", "medium")
		push_warning("Missing paper-doll character %s; emergency art selected" % new_character_id)
		return
	configure_character_record(new_character_id, data, enabled_kinds)


func configure_character_record(new_character_id: String, data: Dictionary, enabled_kinds: PackedStringArray = PackedStringArray()) -> void:
	configure(str(data.get("role", "female")), str(data.get("size", "medium")))
	character_id = new_character_id
	character_data = data
	_load_studio_data()
	var character_studio: Dictionary = _studio_data.get("characters", {}).get(character_id, {})
	_rest_offsets = character_studio.get("rig_offsets", {}).duplicate(true)
	var walk_template: Dictionary = _studio_data.get("motion_templates", {}).get("walk_humanoid_v1", {})
	_motion_frames = walk_template.get("frames", []).duplicate(true)
	_motion_duration_ticks = int(walk_template.get("duration_ticks", 0))
	for part_set_id in data.get("part_sets", []):
		var part_set := get_part_set(str(part_set_id))
		if not part_set.is_empty() and (enabled_kinds.is_empty() or str(part_set.get("kind", "")) in enabled_kinds):
			resolved_part_sets.append(part_set)
	var base_height := float(profile.get("height_inches", 72.0))
	_height_scale = float(data.get("height_inches", base_height)) / base_height
	if _art_root != null:
		_rebuild_artwork()
	_refresh_pose()


func configure_cast_actor(new_role: String, new_size: String, height_inches: float, art_character_id: String = "", character_record: Dictionary = {}) -> void:
	# Cast presentation is independent of registry defaults. It does not rewrite
	# the character, profile or artwork documents.
	if not art_character_id.is_empty() and not character_record.is_empty():
		configure_character_record(art_character_id, character_record)
		role_id = new_role
		size_id = new_size
		profile = get_profile(new_role, new_size)
	elif not art_character_id.is_empty() and not get_character(art_character_id).is_empty():
		configure_character(art_character_id)
		role_id = new_role
		size_id = new_size
		profile = get_profile(new_role, new_size)
	else:
		configure(new_role, new_size)
	_cast_height_inches = maxf(1.0, height_inches)
	_height_scale = _cast_height_inches / maxf(1.0, float(profile.get("height_inches", 72.0)))
	if _art_root != null:
		_rebuild_artwork()
	_refresh_pose()


func set_debug_skeleton(enabled: bool) -> void:
	debug_skeleton = enabled
	if _art_root != null:
		_art_root.visible = not enabled
	queue_redraw()


func set_editor_guides(enabled: bool) -> void:
	editor_guides = enabled
	queue_redraw()


func set_editor_preview(enabled: bool) -> void:
	editor_preview = enabled
	if _art_root != null:
		_rebuild_artwork()
	_refresh_pose()


func set_rest_anchor_offsets(offsets: Dictionary) -> void:
	_rest_offsets = offsets.duplicate(true)
	_refresh_pose()


func set_motion_frames(frames: Array, duration_ticks: int = 0) -> void:
	_motion_frames = frames.duplicate(true)
	_motion_duration_ticks = maxi(0, duration_ticks)
	_refresh_pose()


func set_overlay_offsets(offsets: Dictionary) -> void:
	_overlay_offsets = offsets.duplicate(true)
	_refresh_pose()


func visual_scale() -> float:
	return float(profile.get("body_scale", 1.0)) * _height_scale


func set_animation_speed(value: float) -> void:
	animation_speed = clampf(value, 0.25, 2.0)


func set_walking(value: bool) -> void:
	walking = value
	_refresh_pose()


func set_cycle_phase(normalized_phase: float) -> void:
	_phase = fposmod(normalized_phase, 1.0) * TAU
	_refresh_pose()


func is_walking() -> bool:
	return walking


func profile_key() -> String:
	return "%s_%s" % [role_id, size_id]


func character_key() -> String:
	return character_id


func display_height_inches() -> float:
	if _cast_height_inches > 0.0:
		return _cast_height_inches
	return float(character_data.get("height_inches", profile.get("height_inches", 0.0)))


func get_anchor_local(anchor_name: String) -> Vector2:
	return _anchors.get(anchor_name, Vector2.ZERO)


func artwork_state() -> String:
	if debug_skeleton:
		return "debug_skeleton"
	if _art_ready:
		return "cutout"
	if editor_preview and not _art_sprites.is_empty():
		return "incomplete_cutout"
	if editor_preview:
		return "empty_editor_preview"
	return "emergency_placeholder"


func artwork_piece_count() -> int:
	return _art_sprites.size()


func has_emergency_art() -> bool:
	return _fallback_sprite != null and _fallback_sprite.texture != null


func missing_essential_slots() -> PackedStringArray:
	var present := {}
	for spec in _art_specs:
		present[str(spec.get("slot", ""))] = true
	var missing := PackedStringArray()
	if present.has("full_body"):
		return missing
	for slot in ESSENTIAL_BODY_SLOTS:
		if not present.has(slot):
			missing.append(slot)
	return missing


func use_artwork_parts_for_test(parts: Array) -> void:
	# Authoring preview and smoke probes exercise the production part loader.
	_rebuild_artwork(parts, true)
	_refresh_pose()


static func get_profile(role: String, size: String) -> Dictionary:
	_load_profiles()
	var role_profiles: Dictionary = _profiles.get(role, {})
	return role_profiles.get(size, {}).duplicate(true)


static func profile_count() -> int:
	_load_profiles()
	var count := 0
	for role_profiles in _profiles.values():
		if role_profiles is Dictionary:
			count += role_profiles.size()
	return count


static func get_character(key: String) -> Dictionary:
	_load_characters()
	return _characters.get(key, {}).duplicate(true)


static func character_count() -> int:
	_load_characters()
	return _characters.size()


static func get_part_set(key: String) -> Dictionary:
	_load_part_sets()
	return _part_sets.get(key, {}).duplicate(true)


static func part_set_count() -> int:
	_load_part_sets()
	return _part_sets.size()


static func get_artwork_parts(key: String) -> Array:
	_load_artwork()
	var characters: Dictionary = _artwork.get("characters", {})
	var entry: Dictionary = characters.get(key, {})
	return entry.get("parts", []).duplicate(true)


static func reload_authoring_data() -> void:
	_artwork = {}
	_studio_data = {}


static func validate_profiles() -> PackedStringArray:
	_load_profiles()
	var errors := PackedStringArray()
	for role in ["male", "female"]:
		var role_profiles: Dictionary = _profiles.get(role, {})
		for size in ["small", "medium", "large"]:
			var key := "%s/%s" % [role, size]
			var candidate = role_profiles.get(size, null)
			if not candidate is Dictionary:
				errors.append("Missing profile %s" % key)
				continue
			var candidate_profile: Dictionary = candidate
			for field in REQUIRED_PROFILE_FIELDS:
				if not candidate_profile.has(field):
					errors.append("%s missing %s" % [key, field])
	return errors


static func validate_characters() -> PackedStringArray:
	_load_characters()
	_load_part_sets()
	var errors := PackedStringArray()
	for key in _characters:
		var data: Dictionary = _characters[key]
		for field in ["display_name", "species_id", "role", "size", "height_inches", "part_sets"]:
			if not data.has(field):
				errors.append("%s missing %s" % [key, field])
		if float(data.get("height_inches", 0.0)) <= 0.0:
			errors.append("%s has invalid height_inches" % key)
		for part_set_id in data.get("part_sets", []):
			if not _part_sets.has(str(part_set_id)):
				errors.append("%s references missing part set %s" % [key, part_set_id])
	return errors


static func validate_part_sets() -> PackedStringArray:
	_load_part_sets()
	var errors := PackedStringArray()
	for key in _part_sets:
		var data: Dictionary = _part_sets[key]
		for field in ["display_name", "kind", "pieces", "anchors", "palette"]:
			if not data.has(field):
				errors.append("%s missing %s" % [key, field])
	return errors


static func validate_artwork_contract() -> PackedStringArray:
	_load_artwork()
	var errors := PackedStringArray()
	if not ResourceLoader.exists(EMERGENCY_ART_PATH):
		errors.append("Universal emergency character art is missing")
	for key in _artwork.get("characters", {}):
		var entry: Dictionary = _artwork["characters"][key]
		var seen_slots := {}
		for part in entry.get("parts", []):
			if not part is Dictionary:
				errors.append("%s has a non-object artwork part" % key)
				continue
			var slot := str(part.get("slot", ""))
			if slot.is_empty():
				errors.append("%s has artwork without a slot" % key)
			elif seen_slots.has(slot):
				errors.append("%s repeats artwork slot %s" % [key, slot])
			else:
				seen_slots[slot] = true
			var path := str(part.get("path", ""))
			if path.is_empty() or not ResourceLoader.exists(path):
				errors.append("%s has missing artwork resource %s" % [key, path])
			if not VALID_ANCHORS.has(str(part.get("anchor", ""))):
				errors.append("%s has an unknown artwork anchor" % key)
			if part.has("end_anchor") and not VALID_ANCHORS.has(str(part.end_anchor)):
				errors.append("%s has an unknown bone end" % key)
	return errors


static func _read_dictionary(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Could not open paper-doll data: %s" % path)
		return {}
	var parsed = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		return parsed
	push_error("Paper-doll data must be a dictionary: %s" % path)
	return {}


static func _load_profiles() -> void:
	if _profiles.is_empty():
		_profiles = _read_dictionary(PROFILE_PATH)


static func _load_characters() -> void:
	if _characters.is_empty():
		_characters = _read_dictionary(CHARACTER_PATH)


static func _load_part_sets() -> void:
	if _part_sets.is_empty():
		_part_sets = _read_dictionary(PART_SET_PATH)


static func _load_artwork() -> void:
	if _artwork.is_empty():
		_artwork = _read_dictionary(ARTWORK_PATH)


static func _load_studio_data() -> void:
	if _studio_data.is_empty():
		_studio_data = _read_dictionary(STUDIO_PATH)


func _rebuild_artwork(override_parts: Array = [], force_override := false) -> void:
	if _art_root == null:
		return
	for child in _art_root.get_children():
		_art_root.remove_child(child)
		child.queue_free()
	_art_specs.clear()
	_art_sprites.clear()
	_fallback_sprite = null
	_missing_emergency_texture = false
	_art_ready = false
	var specs := override_parts if force_override else get_artwork_parts(character_id)
	for raw_spec in specs:
		if not raw_spec is Dictionary:
			continue
		var spec: Dictionary = raw_spec
		var path := str(spec.get("path", ""))
		var anchor := str(spec.get("anchor", ""))
		if not VALID_ANCHORS.has(anchor) or not ResourceLoader.exists(path):
			push_warning("Skipping unusable artwork part %s for %s" % [path, character_id])
			continue
		if spec.has("end_anchor") and not VALID_ANCHORS.has(str(spec.end_anchor)):
			push_warning("Skipping artwork with invalid bone end %s" % path)
			continue
		var texture := load(path) as Texture2D
		if texture == null:
			push_warning("Artwork is not a texture: %s" % path)
			continue
		var sprite := Sprite2D.new()
		sprite.name = str(spec.get("slot", "Part_%d" % _art_sprites.size()))
		sprite.texture = texture
		sprite.z_index = clampi(int(spec.get("z", 0)), -4096, 4096)
		if spec.has("end_anchor"):
			sprite.centered = false
			sprite.offset = Vector2(-texture.get_width() * 0.5, 0.0)
		_art_root.add_child(sprite)
		_art_specs.append(spec)
		_art_sprites.append(sprite)
	_art_ready = missing_essential_slots().is_empty()
	for sprite in _art_sprites:
		sprite.visible = _art_ready or editor_preview
	if not _art_ready and not editor_preview:
		var emergency := load(EMERGENCY_ART_PATH) as Texture2D
		if emergency != null:
			_fallback_sprite = Sprite2D.new()
			_fallback_sprite.name = "UniversalEmergencyArt"
			_fallback_sprite.texture = emergency
			_art_root.add_child(_fallback_sprite)
		else:
			# Last-resort hard error marker prevents an invisible actor even if the
			# single emergency asset is removed or an export becomes corrupted.
			_missing_emergency_texture = true
			push_error("Universal emergency art could not be loaded")
	_art_root.visible = not debug_skeleton


func _process(delta: float) -> void:
	if walking and not profile.is_empty():
		_phase = fmod(_phase + delta * float(profile.get("cadence", 1.0)) * animation_speed * TAU, TAU)
		_refresh_pose()


func _refresh_pose() -> void:
	if profile.is_empty():
		return
	var head_radius := float(profile.head_radius)
	var shoulder_width := float(profile.shoulder_width)
	var torso_height := float(profile.torso_height)
	var arm_length := float(profile.arm_length)
	var leg_length := float(profile.leg_length)
	var stance_width := float(profile.stance_width)
	var stride := deg_to_rad(float(profile.stride_degrees))
	var bob := absf(sin(_phase)) * float(profile.bob) if walking else 0.0
	var swing := sin(_phase) * stride if walking else 0.0
	var counter_swing := -swing * 0.78
	var root := Vector2(0.0, -bob)
	var pelvis := root + Vector2(0.0, -leg_length)
	var shoulders := pelvis + Vector2(0.0, -torso_height)
	var head_center := shoulders + Vector2(0.0, -head_radius * 0.88)
	var left_hip := pelvis + Vector2(-stance_width * 0.5, 0.0)
	var right_hip := pelvis + Vector2(stance_width * 0.5, 0.0)
	var upper_leg := leg_length * 0.52
	var lower_leg := leg_length - upper_leg
	var left_knee := left_hip + Vector2(sin(swing), cos(swing)) * upper_leg
	var right_knee := right_hip + Vector2(sin(-swing), cos(-swing)) * upper_leg
	var left_bend := deg_to_rad(14.0) * maxf(0.0, sin(_phase)) if walking else 0.0
	var right_bend := deg_to_rad(14.0) * maxf(0.0, -sin(_phase)) if walking else 0.0
	var left_lower_angle := swing * 0.35 - left_bend
	var right_lower_angle := -swing * 0.35 + right_bend
	var left_foot := left_knee + Vector2(sin(left_lower_angle), cos(left_lower_angle)) * lower_leg
	var right_foot := right_knee + Vector2(sin(right_lower_angle), cos(right_lower_angle)) * lower_leg
	var left_shoulder := shoulders + Vector2(-shoulder_width * 0.5, 7.0)
	var right_shoulder := shoulders + Vector2(shoulder_width * 0.5, 7.0)
	var upper_arm := arm_length * 0.53
	var lower_arm := arm_length - upper_arm
	var left_elbow := left_shoulder + Vector2(sin(counter_swing), cos(counter_swing)) * upper_arm
	var right_elbow := right_shoulder + Vector2(sin(-counter_swing), cos(-counter_swing)) * upper_arm
	var left_forearm_angle := counter_swing * 0.32 + deg_to_rad(5.0)
	var right_forearm_angle := -counter_swing * 0.32 - deg_to_rad(5.0)
	var left_hand := left_elbow + Vector2(sin(left_forearm_angle), cos(left_forearm_angle)) * lower_arm
	var right_hand := right_elbow + Vector2(sin(right_forearm_angle), cos(right_forearm_angle)) * lower_arm
	_anchors = {
		"root": root, "pelvis": pelvis, "torso": (pelvis + shoulders) * 0.5,
		"head": head_center, "shoulder_left": left_shoulder,
		"shoulder_right": right_shoulder, "elbow_left": left_elbow,
		"elbow_right": right_elbow, "hand_left": left_hand,
		"hand_right": right_hand, "hip_left": left_hip, "hip_right": right_hip,
		"knee_left": left_knee, "knee_right": right_knee,
		"foot_left": left_foot, "foot_right": right_foot,
		"effect_origin": pelvis + Vector2(0.0, -torso_height * 0.28),
	}
	_apply_anchor_offsets()
	_update_artwork_nodes()
	if debug_skeleton or editor_guides or _missing_emergency_texture:
		queue_redraw()


func _apply_anchor_offsets() -> void:
	var motion: Dictionary = {}
	if _motion_frames.size() >= 2 and walking:
		var sample := _motion_sample(fposmod(_phase / TAU, 1.0))
		var current_index: int = sample.current
		var next_index: int = sample.next
		var weight: float = sample.weight
		var current: Dictionary = _motion_frames[current_index].get("offsets", {})
		var next: Dictionary = _motion_frames[next_index].get("offsets", {})
		for anchor in VALID_ANCHORS:
			var from := _offset_vector(current.get(anchor, [0.0, 0.0]))
			var to := _offset_vector(next.get(anchor, [0.0, 0.0]))
			motion[anchor] = from.lerp(to, weight)
	for anchor in VALID_ANCHORS:
		_anchors[anchor] += _offset_vector(_rest_offsets.get(anchor, [0.0, 0.0])) + motion.get(anchor, Vector2.ZERO) + _offset_vector(_overlay_offsets.get(anchor, [0.0, 0.0]))


func _motion_sample(normalized_phase: float) -> Dictionary:
	if _motion_duration_ticks <= 0 or not _motion_frames[0].has("tick"):
		var position := normalized_phase * _motion_frames.size()
		return {"current": int(floorf(position)) % _motion_frames.size(), "next": (int(floorf(position)) + 1) % _motion_frames.size(), "weight": position - floorf(position)}
	var target := normalized_phase * _motion_duration_ticks
	var current_index := 0
	var next_index := 0
	for index in _motion_frames.size():
		if float(_motion_frames[index].get("tick", 0)) <= target:
			current_index = index
		else:
			next_index = index
			break
	if next_index == 0 and current_index == _motion_frames.size() - 1:
		next_index = 0
	var current_tick := float(_motion_frames[current_index].get("tick", 0))
	var next_tick := float(_motion_frames[next_index].get("tick", 0))
	var sample_tick := target
	if next_index == 0 and current_index == _motion_frames.size() - 1:
		next_tick += _motion_duration_ticks
		if sample_tick < current_tick:
			sample_tick += _motion_duration_ticks
	var weight := clampf((sample_tick - current_tick) / maxf(1.0, next_tick - current_tick), 0.0, 1.0)
	match str(_motion_frames[current_index].get("interpolation", "smooth")):
		"hold": weight = 0.0
		"smooth": weight = smoothstep(0.0, 1.0, weight)
	return {"current": current_index, "next": next_index, "weight": weight}


func _offset_vector(value: Variant) -> Vector2:
	if value is Array and value.size() == 2:
		return Vector2(float(value[0]), float(value[1]))
	return Vector2.ZERO


func _update_artwork_nodes() -> void:
	if _art_root == null:
		return
	var rig_scale := float(profile.get("body_scale", 1.0)) * _height_scale
	_art_root.scale = Vector2.ONE * rig_scale
	if _fallback_sprite != null:
		var total_height := float(profile.leg_length) + float(profile.torso_height) + float(profile.head_radius) * 1.9
		var texture_height := maxf(1.0, float(_fallback_sprite.texture.get_height()))
		_fallback_sprite.scale = Vector2.ONE * (total_height / texture_height)
		_fallback_sprite.position = _anchors.root + Vector2(0.0, -total_height * 0.5)
	for index in _art_sprites.size():
		var spec := _art_specs[index]
		var sprite := _art_sprites[index]
		var start: Vector2 = _anchors.get(str(spec.get("anchor", "torso")), _anchors.torso)
		var offset_data: Array = spec.get("offset", [0.0, 0.0])
		var offset := Vector2(float(offset_data[0]), float(offset_data[1])) if offset_data.size() == 2 else Vector2.ZERO
		sprite.position = start + offset
		var base_scale := float(spec.get("scale", 1.0))
		if spec.has("end_anchor"):
			var finish: Vector2 = _anchors.get(str(spec.end_anchor), start)
			var bone: Vector2 = finish - start
			var rest_length := maxf(1.0, float(spec.get("rest_length", sprite.texture.get_height())))
			sprite.rotation = Vector2.DOWN.angle_to(bone)
			sprite.scale = Vector2(base_scale, bone.length() / rest_length * base_scale)
		else:
			sprite.rotation_degrees = float(spec.get("rotation_degrees", 0.0))
			sprite.scale = Vector2.ONE * base_scale


func _draw() -> void:
	if profile.is_empty() or (not debug_skeleton and not editor_guides and not _missing_emergency_texture):
		return
	var rig_scale := float(profile.get("body_scale", 1.0)) * _height_scale
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE * rig_scale)
	if _missing_emergency_texture and not debug_skeleton:
		# This is a corrupted-build safeguard, not the ordinary placeholder.
		draw_circle(_anchors.head, float(profile.head_radius), Color("#bb3f49"))
		draw_line(_anchors.head + Vector2(-9, -9), _anchors.head + Vector2(9, 9), Color.WHITE, 4.0, true)
		draw_line(_anchors.head + Vector2(9, -9), _anchors.head + Vector2(-9, 9), Color.WHITE, 4.0, true)
	else:
		for bone in [["shoulder_left", "elbow_left"], ["elbow_left", "hand_left"], ["shoulder_right", "elbow_right"], ["elbow_right", "hand_right"], ["hip_left", "knee_left"], ["knee_left", "foot_left"], ["hip_right", "knee_right"], ["knee_right", "foot_right"], ["pelvis", "torso"], ["torso", "head"]]:
			draw_line(_anchors[bone[0]], _anchors[bone[1]], DEBUG_LINE, 4.0, true)
		for anchor in VALID_ANCHORS:
			if anchor == "effect_origin":
				continue
			draw_circle(_anchors[anchor], 3.0, DEBUG_JOINT)
		draw_circle(_anchors.head, float(profile.head_radius), Color(DEBUG_LINE, 0.12))
		draw_arc(_anchors.head, float(profile.head_radius), 0.0, TAU, 24, DEBUG_LINE, 2.0, true)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
