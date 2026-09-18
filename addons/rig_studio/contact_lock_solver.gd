## Copyright © 2026 SeirVed. All rights reserved. See LICENSE.md.
@tool
class_name RigStudioContactLockSolver
extends RefCounted

const MINIMUM_SPAN := 0.001


static func make_frame(origin: Vector2, axis_point: Vector2) -> Dictionary:
	var axis_vector: Vector2 = axis_point - origin
	var span: float = axis_vector.length()
	if span < MINIMUM_SPAN:
		return {"valid": false, "origin": origin, "span": span}
	var y_axis: Vector2 = axis_vector / span
	# Godot's 2D stage uses +Y downward. This keeps +X on screen-right when
	# the reference axis points downward.
	var x_axis := Vector2(y_axis.y, -y_axis.x)
	return {
		"valid": true,
		"origin": origin,
		"x_axis": x_axis,
		"y_axis": y_axis,
		"span": span,
	}


static func capture_normalized(point: Vector2, origin: Vector2, axis_point: Vector2) -> Dictionary:
	var frame := make_frame(origin, axis_point)
	if not bool(frame.get("valid", false)):
		return {"valid": false, "reason": "The secondary reference anchors overlap."}
	var delta: Vector2 = point - origin
	var span: float = float(frame.span)
	return {
		"valid": true,
		"local_offset": [
			delta.dot(frame.x_axis) / span,
			delta.dot(frame.y_axis) / span,
		],
	}


static func resolve_normalized(local_offset: Variant, origin: Vector2, axis_point: Vector2) -> Dictionary:
	var frame := make_frame(origin, axis_point)
	if not bool(frame.get("valid", false)):
		return {"valid": false, "reason": "The secondary reference anchors overlap."}
	if not local_offset is Array or local_offset.size() != 2:
		return {"valid": false, "reason": "The contact offset must contain normalized X and Y values."}
	var normalized := Vector2(float(local_offset[0]), float(local_offset[1]))
	var span: float = float(frame.span)
	var point: Vector2 = origin + frame.x_axis * normalized.x * span + frame.y_axis * normalized.y * span
	return {"valid": true, "point": point}


static func validate_lock(lock: Dictionary) -> PackedStringArray:
	var errors := PackedStringArray()
	for field in ["id", "source_actor", "source_anchor", "target_actor", "target_frame"]:
		if not lock.has(field):
			errors.append("missing %s" % field)
	if str(lock.get("source_actor", "")) == str(lock.get("target_actor", "")):
		errors.append("source and secondary actor must differ")
	var target_frame: Dictionary = lock.get("target_frame", {})
	for field in ["origin_anchor", "axis_anchor", "local_offset"]:
		if not target_frame.has(field):
			errors.append("target_frame missing %s" % field)
	if str(target_frame.get("origin_anchor", "")) == str(target_frame.get("axis_anchor", "")):
		errors.append("secondary origin and axis anchors must differ")
	var offset: Variant = target_frame.get("local_offset", [])
	if not offset is Array or offset.size() != 2:
		errors.append("target_frame local_offset must contain two values")
	return errors
