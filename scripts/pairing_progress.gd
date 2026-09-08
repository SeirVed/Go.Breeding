## Copyright © 2026 SeirVed. All rights reserved. See LICENSE.md.

extends Node

const PROGRESS_PATH := "res://data/breeding_script_progress.json"
const SPECIES_MAP_PATH := "res://data/species_body_map.json"
const SIZE_SCALE := {"Small": 0.82, "Medium": 1.0, "Large": 1.22}
const MORPH_LEAN := {"Feral": -8.0, "Neutral": 0.0, "Refined": 5.0}
const BOARD_IDS := ["jack_jill", "jack_jack", "jill_jill"]

var body_types: Array = []
var scripts: Dictionary = {}
var progress: Dictionary = {}
var archetypes: Dictionary = {}
var couplings: Dictionary = {}
var species_map: Dictionary = {}


func _ready() -> void:
	var progress_file := FileAccess.open(PROGRESS_PATH, FileAccess.READ)
	var map_file := FileAccess.open(SPECIES_MAP_PATH, FileAccess.READ)
	if progress_file == null or map_file == null:
		push_error("Could not load breeding script progress data")
		return
	var progress = JSON.parse_string(progress_file.get_as_text())
	var mapping = JSON.parse_string(map_file.get_as_text())
	if progress is Dictionary:
		body_types = progress.get("body_types", [])
		scripts = progress.get("scripts", {})
		self.progress = progress.get("progress", {})
		archetypes = progress.get("archetypes", {})
		couplings = progress.get("couplings", {})
	if mapping is Dictionary:
		species_map = mapping


func pair_key(first: String, second: String) -> String:
	return "%s>%s" % [first, second]


func board_pair_key(board_id: String, first: String, second: String) -> String:
	return "%s|%s" % [board_id, pair_key(first, second)]


func script_count(first: String, second: String, board_id: String = "jack_jill") -> int:
	var key := board_pair_key(board_id, first, second)
	if scripts.has(key):
		return scripts.get(key, []).size()
	if board_id == "jack_jill":
		return scripts.get(pair_key(first, second), []).size()
	return 0


func progress_percent(first: String, second: String, board_id: String = "jack_jill") -> int:
	var key := board_pair_key(board_id, first, second)
	if progress.has(key):
		return clampi(int(progress.get(key, 0)), 0, 100)
	if board_id == "jack_jill":
		return clampi(int(progress.get(pair_key(first, second), 0)), 0, 100)
	return 0


func get_archetype(role: String, body_id: String) -> Dictionary:
	var role_types: Dictionary = archetypes.get(role, {})
	return role_types.get(body_id, {"name": body_id.capitalize(), "emoji": "📜"})


func get_coupling(first: String, second: String, board_id: String = "jack_jill", row_role: String = "male", column_role: String = "female") -> Dictionary:
	if board_id == "jack_jill" and couplings.has(pair_key(first, second)):
		return couplings[pair_key(first, second)]
	var first_type := get_archetype(row_role, first)
	var second_type := get_archetype(column_role, second)
	var first_body := get_body_type(first)
	var second_body := get_body_type(second)
	return {
		"name": "%s & %s" % [first_type.name, second_type.name],
		"description": "%s choreography commission: %s %s paired with %s %s. Its bespoke movement theme is still awaiting design." % ["Jack & Jack" if board_id == "jack_jack" else "Jill & Jill", first_body.size, first_body.morph, second_body.size, second_body.morph],
	}


func completed_pair_count(board_id: String = "jack_jill") -> int:
	var count := 0
	for first in body_types:
		for second in body_types:
			if progress_percent(first.id, second.id, board_id) >= 100:
				count += 1
			elif script_count(first.id, second.id, board_id) > 0:
				count += 1
	return count


func total_pair_count() -> int:
	return body_types.size() * body_types.size()


func completed_commission_count() -> int:
	var count := 0
	for board_id in BOARD_IDS:
		count += completed_pair_count(board_id)
	return count


func total_commission_count() -> int:
	return total_pair_count() * BOARD_IDS.size()


func body_index(id: String) -> int:
	for index in body_types.size():
		if body_types[index].id == id:
			return index
	return 0


func order_label(first: String, second: String) -> String:
	return "Regular" if body_index(first) <= body_index(second) else "Inverted"


func get_body_type(id: String) -> Dictionary:
	for body in body_types:
		if body.id == id:
			return body
	return {}


func get_species_profile(species_id: String) -> Dictionary:
	return species_map.get(species_id, {"body":"medium_neutral", "tags":[]})


func build_pairing_plan(species_a: String, species_b: String) -> Dictionary:
	var profile_a: Dictionary = get_species_profile(species_a)
	var profile_b: Dictionary = get_species_profile(species_b)
	var body_a := get_body_type(profile_a.body)
	var body_b := get_body_type(profile_b.body)
	var count := script_count(profile_a.body, profile_b.body)
	return {
		"pair_key": pair_key(profile_a.body, profile_b.body),
		"body_a": profile_a.body,
		"body_b": profile_b.body,
		"scale_a": SIZE_SCALE.get(body_a.get("size", "Medium"), 1.0),
		"scale_b": SIZE_SCALE.get(body_b.get("size", "Medium"), 1.0),
		"lean_a": MORPH_LEAN.get(body_a.get("morph", "Neutral"), 0.0),
		"lean_b": -float(MORPH_LEAN.get(body_b.get("morph", "Neutral"), 0.0)),
		"tags_a": profile_a.tags,
		"tags_b": profile_b.tags,
		"script_count": count,
		"mode": "Authored variant" if count > 0 else "Placeholder only",
		"order": order_label(profile_a.body, profile_b.body),
	}
