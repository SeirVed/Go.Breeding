## Copyright © 2026 SeirVed. All rights reserved. See LICENSE.md.
@tool
class_name RigStudioPosePropagator
extends RefCounted


static func single_pose(frames: Array, source_index: int, target_indices: Array[int], anchors: Array[String]) -> Array:
	var result := frames.duplicate(true)
	if source_index < 0 or source_index >= result.size():
		return result
	var source_offsets: Dictionary = result[source_index].get("offsets", {})
	for target_index in target_indices:
		if target_index < 0 or target_index >= result.size() or target_index == source_index:
			continue
		var target_offsets: Dictionary = result[target_index].get("offsets", {}).duplicate(true)
		_copy_offsets(source_offsets, target_offsets, anchors)
		result[target_index]["offsets"] = target_offsets
	return result


static func actor_pose(frames: Array, source_index: int, target_indices: Array[int], actor_id: String, anchors: Array[String]) -> Array:
	var result := frames.duplicate(true)
	if source_index < 0 or source_index >= result.size() or actor_id.is_empty():
		return result
	var source_cast: Dictionary = result[source_index].get("actors", {})
	var source_actor: Dictionary = source_cast.get(actor_id, {})
	var source_offsets: Dictionary = source_actor.get("offsets", {})
	for target_index in target_indices:
		if target_index < 0 or target_index >= result.size() or target_index == source_index:
			continue
		var target_cast: Dictionary = result[target_index].get("actors", {}).duplicate(true)
		var target_actor: Dictionary = target_cast.get(actor_id, {}).duplicate(true)
		var target_offsets: Dictionary = target_actor.get("offsets", {}).duplicate(true)
		_copy_offsets(source_offsets, target_offsets, anchors)
		if anchors.is_empty() or "root" in anchors:
			if source_actor.has("stage_offset"):
				target_actor["stage_offset"] = source_actor.stage_offset.duplicate(true)
			else:
				target_actor.erase("stage_offset")
		target_actor["offsets"] = target_offsets
		target_cast[actor_id] = target_actor
		result[target_index]["actors"] = target_cast
	return result


static func _copy_offsets(source: Dictionary, target: Dictionary, anchors: Array[String]) -> void:
	var chosen: Array = anchors if not anchors.is_empty() else source.keys()
	for anchor_value in chosen:
		var anchor := str(anchor_value)
		if anchor == "root":
			continue
		if source.has(anchor):
			target[anchor] = source[anchor].duplicate(true)
		else:
			target.erase(anchor)
