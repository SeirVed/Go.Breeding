## Copyright © 2026 SeirVed. All rights reserved. See LICENSE.md.
@tool
class_name RigStudioVerbEngine
extends RefCounted


static func offsets_for_actor(verbs: Array, tick: float, actor_id: String) -> Dictionary:
	var combined := {}
	for verb_value in verbs:
		var verb: Dictionary = verb_value
		var start := float(verb.get("start_tick", 0.0))
		var end := maxf(start + 1.0, float(verb.get("end_tick", start + 1.0)))
		if tick < start or tick > end:
			continue
		var progress := clampf((tick - start) / (end - start), 0.0, 1.0)
		var actors: Dictionary = verb.get("actors", {})
		var params: Dictionary = verb.get("params", {})
		match str(verb.get("verb_id", "")):
			"brace":
				if actor_id == str(actors.get("responder", actors.get("actor", "B"))):
					_add(combined, "torso", Vector2(0.0, -float(params.get("strength", 4.0))))
					_add(combined, "pelvis", Vector2(0.0, float(params.get("strength", 4.0)) * 0.5))
			"pelvis_pulse":
				if actor_id == str(actors.get("driver", "A")):
					var cycles := maxf(1.0, float(params.get("repetitions", 4.0)))
					var amplitude := float(params.get("amplitude", 8.0))
					_add(combined, "pelvis", Vector2(sin(progress * TAU * cycles) * amplitude, 0.0))
			"reaction_bounce":
				if actor_id == str(actors.get("responder", "B")):
					var cycles := maxf(1.0, float(params.get("repetitions", 4.0)))
					var amplitude := float(params.get("amplitude", 5.0))
					var delayed := maxf(0.0, progress - float(params.get("lag", 0.08)))
					var bounce := sin(delayed * TAU * cycles) * amplitude
					_add(combined, "pelvis", Vector2(0.0, bounce))
					_add(combined, "torso", Vector2(0.0, bounce * 0.6))
	return combined


static func _add(offsets: Dictionary, anchor: String, value: Vector2) -> void:
	var previous := Vector2.ZERO
	var stored: Variant = offsets.get(anchor, [0.0, 0.0])
	if stored is Array and stored.size() == 2:
		previous = Vector2(float(stored[0]), float(stored[1]))
	var total := previous + value
	offsets[anchor] = [snappedf(total.x, 0.1), snappedf(total.y, 0.1)]
