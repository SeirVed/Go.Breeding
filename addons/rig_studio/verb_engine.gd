## Copyright © 2026 SeirVed. All rights reserved. See LICENSE.md.
@tool
class_name RigStudioVerbEngine
extends RefCounted

const BODY_ANCHORS := [
	"root", "pelvis", "torso", "head", "shoulder_left", "shoulder_right",
	"elbow_left", "elbow_right", "hand_left", "hand_right", "hip_left",
	"hip_right", "knee_left", "knee_right", "foot_left", "foot_right",
]


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
			"approach":
				if actor_id == str(actors.get("mover", "A")):
					var distance := float(params.get("distance", 18.0))
					var direction := float(params.get("direction", 1.0))
					_add_many(combined, BODY_ANCHORS, Vector2(-cos(progress * PI * 0.5) * distance * direction, 0.0))
			"circle_partner":
				if actor_id == str(actors.get("mover", "A")):
					var radius := float(params.get("radius", 10.0))
					var direction := float(params.get("direction", 1.0))
					_add_many(combined, BODY_ANCHORS, Vector2(sin(progress * PI) * radius * direction, -sin(progress * TAU) * radius * 0.18))
			"plant_stance":
				if actor_id == str(actors.get("actor", "A")):
					var amount := sin(progress * PI)
					var width := float(params.get("width", 6.0)) * amount
					var drop := float(params.get("drop", 2.0)) * amount
					_add(combined, "pelvis", Vector2(0.0, drop))
					for anchor in ["hip_left", "knee_left", "foot_left"]:
						_add(combined, anchor, Vector2(-width, drop))
					for anchor in ["hip_right", "knee_right", "foot_right"]:
						_add(combined, anchor, Vector2(width, drop))
			"lower_center":
				if actor_id == str(actors.get("actor", "A")):
					var depth := sin(progress * PI) * float(params.get("depth", 6.0))
					_add_many(combined, ["pelvis", "torso", "head"], Vector2(0.0, depth))
			"brace":
				if actor_id == str(actors.get("responder", actors.get("actor", "B"))):
					_add(combined, "torso", Vector2(0.0, -float(params.get("strength", 4.0))))
					_add(combined, "pelvis", Vector2(0.0, float(params.get("strength", 4.0)) * 0.5))
			"rise":
				if actor_id == str(actors.get("actor", "A")):
					var height := sin(progress * PI) * float(params.get("height", 6.0))
					_add_many(combined, ["pelvis", "torso", "head"], Vector2(0.0, -height))
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
			"sway_together":
				if actor_id == str(actors.get("first", "A")) or actor_id == str(actors.get("second", "B")):
					var cycles := maxf(1.0, float(params.get("repetitions", 2.0)))
					var amplitude := float(params.get("amplitude", 4.0))
					var phase := float(params.get("phase", 0.0))
					var sway := sin((progress + phase) * TAU * cycles) * amplitude
					_add(combined, "pelvis", Vector2(sway, 0.0))
					_add(combined, "torso", Vector2(sway * 0.8, 0.0))
					_add(combined, "head", Vector2(sway * 0.55, 0.0))
	return combined


static func _add(offsets: Dictionary, anchor: String, value: Vector2) -> void:
	var previous := Vector2.ZERO
	var stored: Variant = offsets.get(anchor, [0.0, 0.0])
	if stored is Array and stored.size() == 2:
		previous = Vector2(float(stored[0]), float(stored[1]))
	var total := previous + value
	offsets[anchor] = [snappedf(total.x, 0.1), snappedf(total.y, 0.1)]


static func _add_many(offsets: Dictionary, anchors: Array, value: Vector2) -> void:
	for anchor in anchors:
		_add(offsets, str(anchor), value)
