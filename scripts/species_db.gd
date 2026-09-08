## Copyright © 2026 SeirVed. All rights reserved. See LICENSE.md.

extends Node

const DATA_PATH := "res://data/species.json"

var species: Array = []
var by_id: Dictionary = {}


func _ready() -> void:
	var file := FileAccess.open(DATA_PATH, FileAccess.READ)
	if file == null:
		push_error("Could not open species registry")
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if not parsed is Array:
		push_error("Species registry is not an array")
		return
	species = parsed
	for entry in species:
		by_id[entry.id] = entry


func get_all() -> Array:
	return species


func get_species(id: String) -> Dictionary:
	return by_id.get(id, {})


func find_species_index(id: String) -> int:
	for index in species.size():
		if species[index].id == id:
			return index
	return 0


func pair_key(first: String, second: String) -> String:
	var ids := [first, second]
	ids.sort()
	return "%s+%s" % ids


func unique_pair_count() -> int:
	return species.size() * (species.size() + 1) / 2
