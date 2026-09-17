## Copyright © 2026 SeirVed. All rights reserved. See LICENSE.md.

extends Node

const PROGRESS_PATH := "res://data/breeding_script_progress.json"
const SPECIES_MAP_PATH := "res://data/species_body_map.json"
const PRODUCTION_RECORDS_PATH := "res://data/pairing_production_records.json"
const VERBS_PATH := "res://data/animation_verbs.json"
const STORYBOARD_GRAMMAR_PATH := "res://data/pairing_storyboard_grammar.json"
const SIZE_SCALE := {"Small": 0.82, "Medium": 1.0, "Large": 1.22}
const MORPH_LEAN := {"Feral": -8.0, "Neutral": 0.0, "Refined": 5.0}
const BOARD_IDS := ["jack_jill", "jack_jack", "jill_jill"]

var body_types: Array = []
var scripts: Dictionary = {}
var progress: Dictionary = {}
var archetypes: Dictionary = {}
var couplings: Dictionary = {}
var species_map: Dictionary = {}
var pairing_groups: Dictionary = {}
var production_records: Array = []
var production_records_by_id: Dictionary = {}
var verb_definitions: Dictionary = {}
var storyboard_grammar: Dictionary = {}


func _ready() -> void:
	body_types.clear()
	scripts.clear()
	progress.clear()
	archetypes.clear()
	couplings.clear()
	species_map.clear()
	pairing_groups.clear()
	production_records.clear()
	production_records_by_id.clear()
	verb_definitions.clear()
	storyboard_grammar.clear()
	var progress_file := FileAccess.open(PROGRESS_PATH, FileAccess.READ)
	var map_file := FileAccess.open(SPECIES_MAP_PATH, FileAccess.READ)
	var records_file := FileAccess.open(PRODUCTION_RECORDS_PATH, FileAccess.READ)
	var verbs_file := FileAccess.open(VERBS_PATH, FileAccess.READ)
	var storyboard_file := FileAccess.open(STORYBOARD_GRAMMAR_PATH, FileAccess.READ)
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
		pairing_groups = progress.get("pairing_groups", {})
	if mapping is Dictionary:
		species_map = mapping
	if records_file != null:
		var records = JSON.parse_string(records_file.get_as_text())
		if records is Array:
			production_records = records
			for record in production_records:
				production_records_by_id[record.get("record_id", "")] = record
	if verbs_file != null:
		var verbs_document = JSON.parse_string(verbs_file.get_as_text())
		if verbs_document is Dictionary:
			verb_definitions = verbs_document.get("verbs", {})
	if storyboard_file != null:
		var storyboard_document = JSON.parse_string(storyboard_file.get_as_text())
		if storyboard_document is Dictionary:
			storyboard_grammar = storyboard_document


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


func list_pairing_groups() -> Array:
	var result: Array = []
	for board_id in BOARD_IDS:
		var group := get_pairing_group(board_id)
		if not group.is_empty():
			result.append(group)
	return result


func get_pairing_group(board_or_group: String) -> Dictionary:
	var query := board_or_group.strip_edges().to_lower()
	if pairing_groups.has(query):
		var direct: Dictionary = pairing_groups[query].duplicate(true)
		direct["board_id"] = query
		return direct
	for board_id in pairing_groups:
		var candidate: Dictionary = pairing_groups[board_id]
		if str(candidate.get("key", "")).to_lower() == query or str(candidate.get("name", "")).to_lower() == query:
			var resolved: Dictionary = candidate.duplicate(true)
			resolved["board_id"] = board_id
			return resolved
	return {}


func get_board_id_for_group(group_key: String) -> String:
	return str(get_pairing_group(group_key).get("board_id", ""))


func resolve_body_id(role: String, body_or_archetype: String) -> String:
	var query := body_or_archetype.strip_edges().to_lower()
	if not get_body_type(query).is_empty():
		return query
	for body in body_types:
		var candidate := get_archetype(role, body.id)
		if str(candidate.get("name", "")).to_lower() == query:
			return body.id
	return ""


func get_pairing_lookup(board_or_group: String, first_body_or_name: String, second_body_or_name: String) -> Dictionary:
	var group := get_pairing_group(board_or_group)
	if group.is_empty():
		return {}
	var board_id := str(group.board_id)
	var first_role := str(group.row_role)
	var second_role := str(group.column_role)
	var first_body_id := resolve_body_id(first_role, first_body_or_name)
	var second_body_id := resolve_body_id(second_role, second_body_or_name)
	if first_body_id.is_empty() or second_body_id.is_empty():
		return {}
	var first_body := get_body_type(first_body_id)
	var second_body := get_body_type(second_body_id)
	var first_type := get_archetype(first_role, first_body_id)
	var second_type := get_archetype(second_role, second_body_id)
	var coupling := get_coupling(first_body_id, second_body_id, board_id, first_role, second_role)
	var display_name := "%s + %s" % [first_type.name, second_type.name]
	return {
		"commission_key": board_pair_key(board_id, first_body_id, second_body_id),
		"board_id": board_id,
		"group_key": group.key,
		"group_name": group.name,
		"pairing_name": display_name,
		"pairing_slug": "%s+%s" % [str(first_type.name).to_lower(), str(second_type.name).to_lower()],
		"pairing_type_key": pair_key(first_body_id, second_body_id),
		"pairing_type": "%s %s → %s %s" % [first_body.size, first_body.morph, second_body.size, second_body.morph],
		"size_pair": "%s>%s" % [str(first_body.size).to_lower(), str(second_body.size).to_lower()],
		"morph_pair": "%s>%s" % [str(first_body.morph).to_lower(), str(second_body.morph).to_lower()],
		"order": order_label(first_body_id, second_body_id),
		"coupling_name": coupling.get("name", display_name),
		"coupling_description": coupling.get("description", ""),
		"first": {"role": first_role, "body_id": first_body_id, "archetype": first_type.name, "emoji": first_type.emoji, "size": first_body.size, "morph": first_body.morph},
		"second": {"role": second_role, "body_id": second_body_id, "archetype": second_type.name, "emoji": second_type.emoji, "size": second_body.size, "morph": second_body.morph},
		"script_count": script_count(first_body_id, second_body_id, board_id),
		"progress_percent": progress_percent(first_body_id, second_body_id, board_id),
	}


func find_pairings(query: String = "", board_or_group: String = "") -> Array:
	var normalized_query := query.strip_edges().to_lower().replace(" × ", "+").replace(" + ", "+")
	var groups := list_pairing_groups()
	if not board_or_group.is_empty():
		var selected := get_pairing_group(board_or_group)
		groups = [selected] if not selected.is_empty() else []
	var result: Array = []
	for group in groups:
		for first_body in body_types:
			for second_body in body_types:
				var lookup := get_pairing_lookup(group.board_id, first_body.id, second_body.id)
				if normalized_query.is_empty():
					result.append(lookup)
					continue
				var searchable := [
					lookup.commission_key,
					lookup.group_key,
					lookup.group_name,
					lookup.pairing_name,
					lookup.pairing_slug,
					lookup.pairing_type_key,
					lookup.pairing_type,
					lookup.size_pair,
					lookup.morph_pair,
					lookup.coupling_name,
				]
				for value in searchable:
					var normalized_value := str(value).to_lower().replace(" × ", "+").replace(" + ", "+")
					if normalized_query == normalized_value or normalized_value.contains(normalized_query):
						result.append(lookup)
						break
	return result


func find_pairing(query: String, board_or_group: String = "") -> Dictionary:
	var matches := find_pairings(query, board_or_group)
	return matches[0] if not matches.is_empty() else {}


func get_production_record(record_id: String) -> Dictionary:
	return production_records_by_id.get(record_id, {})


func find_production_records(query: String = "", board_or_group: String = "") -> Array:
	var normalized_query := query.strip_edges().to_lower()
	var selected_group := get_pairing_group(board_or_group) if not board_or_group.is_empty() else {}
	var result: Array = []
	for record in production_records:
		var lookup: Dictionary = record.get("lookup", {})
		if not selected_group.is_empty() and lookup.get("board_id", "") != selected_group.board_id:
			continue
		if normalized_query.is_empty():
			result.append(record)
			continue
		var searchable := [record.get("record_id", ""), record.get("status", ""), record.get("decision", ""), lookup.get("commission_key", ""), lookup.get("pairing_name", ""), lookup.get("pairing_slug", ""), lookup.get("pairing_type_key", ""), lookup.get("group_key", ""), lookup.get("coupling_name", "")]
		for value in searchable:
			if str(value).to_lower().contains(normalized_query):
				result.append(record)
				break
	return result


func get_coupling(first: String, second: String, board_id: String = "jack_jill", row_role: String = "male", column_role: String = "female") -> Dictionary:
	if board_id == "jack_jill" and couplings.has(pair_key(first, second)):
		return couplings[pair_key(first, second)]
	var first_type := get_archetype(row_role, first)
	var second_type := get_archetype(column_role, second)
	var first_body := get_body_type(first)
	var second_body := get_body_type(second)
	return {
		"name": "%s & %s" % [first_type.name, second_type.name],
		"description": _same_sex_description(board_id, first_body, second_body),
	}


func _same_sex_description(board_id: String, first_body: Dictionary, second_body: Dictionary) -> String:
	var relation: String = _size_relation(first_body, second_body)
	var size_phrase: String = str({
		"equal": "Matched scale keeps the exchange reciprocal and easy to reverse",
		"first_larger": "The first partner supplies reach and support while the second works inside that frame",
		"second_larger": "The second partner supplies reach and support while the first climbs and redirects",
	}.get(relation, "The scale relationship drives the staging"))
	var first_morph := str(first_body.get("morph", "Neutral"))
	var second_morph := str(second_body.get("morph", "Neutral"))
	var shared_morph := first_morph == second_morph
	var voice := ""
	if board_id == "jack_jack":
		voice = {
			"Feral": "competitive roughhousing and quick reversals",
			"Neutral": "workmanlike leverage and visible lead swaps",
			"Refined": "courtly rivalry and controlled reciprocity",
		}.get(first_morph, "competitive reciprocity") if shared_morph else "%s initiative meeting %s counterplay" % [first_morph.to_lower(), second_morph.to_lower()]
	else:
		voice = {
			"Feral": "playful pursuit and instinctive mirroring",
			"Neutral": "cooperative balance and flowing role exchange",
			"Refined": "graceful symmetry and deliberate hand-offs",
		}.get(first_morph, "mirrored reciprocity") if shared_morph else "%s initiative flowing into %s counterplay" % [first_morph.to_lower(), second_morph.to_lower()]
	return "%s; %s." % [size_phrase, voice]


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


func build_pairing_plan(species_a: String, species_b: String, board_or_group: String = "jack_jill") -> Dictionary:
	var profile_a: Dictionary = get_species_profile(species_a)
	var profile_b: Dictionary = get_species_profile(species_b)
	var body_a := get_body_type(profile_a.body)
	var body_b := get_body_type(profile_b.body)
	var lookup := get_pairing_lookup(board_or_group, profile_a.body, profile_b.body)
	var board_id := str(lookup.get("board_id", "jack_jill"))
	var count := script_count(profile_a.body, profile_b.body, board_id)
	return {
		"pair_key": pair_key(profile_a.body, profile_b.body),
		"commission_key": lookup.get("commission_key", board_pair_key(board_id, profile_a.body, profile_b.body)),
		"pairing_name": lookup.get("pairing_name", ""),
		"pairing_type": lookup.get("pairing_type", ""),
		"group_key": lookup.get("group_key", ""),
		"group_name": lookup.get("group_name", ""),
		"coupling_name": lookup.get("coupling_name", ""),
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


func build_pairing_storyboard(board_or_group: String, first_body_id: String, second_body_id: String) -> Dictionary:
	var lookup := get_pairing_lookup(board_or_group, first_body_id, second_body_id)
	if lookup.is_empty() or storyboard_grammar.is_empty():
		return {}
	var first_body := get_body_type(first_body_id)
	var second_body := get_body_type(second_body_id)
	var relation := _size_relation(first_body, second_body)
	var board_id := str(lookup.get("board_id", "jack_jill"))
	var board_signature: Dictionary = storyboard_grammar.get("board_signatures", {}).get(board_id, {})
	var specs: Array = []
	specs.append_array(storyboard_grammar.get("morph_openers", {}).get(str(first_body.get("morph", "Neutral")), []))
	specs.append_array(storyboard_grammar.get("size_patterns", {}).get(relation, []))
	specs.append_array(board_signature.get("beats", []))
	specs.append_array(storyboard_grammar.get("core_loop", []))
	specs.append_array(storyboard_grammar.get("outro", []))
	var beats := _compile_storyboard_beats(specs)
	var unresolved := PackedStringArray()
	for beat in beats:
		if str(beat.get("implementation_status", "contract_only")) != "motion_prototype":
			var verb_id := str(beat.get("verb_id", ""))
			if verb_id not in unresolved:
				unresolved.append(verb_id)
	var descriptor := "%s %s uses %s; %s" % [
		lookup.get("group_name", "Pairing"),
		lookup.get("pairing_name", ""),
		board_signature.get("descriptor", "reciprocal staging"),
		str(lookup.get("coupling_description", "")).trim_suffix("."),
	]
	return {
		"storyboard_id": "placeholder.%s" % str(lookup.get("commission_key", "")).replace("|", ".").replace(">", "-to-"),
		"status": str(storyboard_grammar.get("status", "PLACEHOLDER_PLAN")),
		"runtime_ready": false,
		"commission_key": lookup.get("commission_key", ""),
		"board_id": board_id,
		"group_key": lookup.get("group_key", ""),
		"pairing_name": lookup.get("pairing_name", ""),
		"coupling_name": lookup.get("coupling_name", ""),
		"order": lookup.get("order", ""),
		"size_relation": relation,
		"descriptor": descriptor + ".",
		"sentence": _storyboard_sentence(beats, lookup),
		"duration_ticks": _storyboard_duration(beats),
		"unresolved_verbs": unresolved,
		"beats": beats,
	}


func all_pairing_storyboards() -> Array:
	var result: Array = []
	for board_id in BOARD_IDS:
		for first_body in body_types:
			for second_body in body_types:
				result.append(build_pairing_storyboard(board_id, str(first_body.id), str(second_body.id)))
	return result


func instantiate_storyboard(storyboard: Dictionary, first_actor_id: String = "A", second_actor_id: String = "B", include_contracts: bool = true) -> Array:
	var instances: Array = []
	for beat in storyboard.get("beats", []):
		if not include_contracts and str(beat.get("implementation_status", "contract_only")) != "motion_prototype":
			continue
		var actors := {}
		for role in beat.get("roles", {}):
			var symbolic_actor := str(beat.roles[role])
			actors[str(role)] = first_actor_id if symbolic_actor == "first" else second_actor_id
		instances.append({
			"id": "%s.beat_%02d" % [storyboard.get("storyboard_id", "storyboard"), int(beat.get("index", instances.size()))],
			"verb_id": beat.get("verb_id", ""),
			"start_tick": beat.get("start_tick", 0),
			"end_tick": beat.get("end_tick", 1),
			"actors": actors,
			"params": beat.get("params", {}).duplicate(true),
			"source_status": beat.get("implementation_status", "contract_only"),
		})
	return instances


func build_pairing_verb_instances(board_or_group: String, first_body_id: String, second_body_id: String, first_actor_id: String = "A", second_actor_id: String = "B", include_contracts: bool = true) -> Array:
	return instantiate_storyboard(build_pairing_storyboard(board_or_group, first_body_id, second_body_id), first_actor_id, second_actor_id, include_contracts)


func validate_storyboard_coverage() -> PackedStringArray:
	var errors := PackedStringArray()
	if verb_definitions.is_empty():
		errors.append("Animation verb vocabulary is empty")
	if storyboard_grammar.is_empty():
		errors.append("Pairing storyboard grammar is empty")
	var seen := {}
	var storyboards := all_pairing_storyboards()
	var expected := BOARD_IDS.size() * body_types.size() * body_types.size()
	if storyboards.size() != expected:
		errors.append("Expected %d directional storyboards, built %d" % [expected, storyboards.size()])
	for storyboard in storyboards:
		if storyboard.is_empty():
			errors.append("Storyboard compiler returned an empty record")
			continue
		var id := str(storyboard.get("storyboard_id", ""))
		if id.is_empty() or seen.has(id):
			errors.append("Storyboard ID is empty or duplicated: %s" % id)
		seen[id] = true
		var beats: Array = storyboard.get("beats", [])
		if beats.size() < 10:
			errors.append("%s has fewer than ten verb beats" % id)
		for beat in beats:
			var verb_id := str(beat.get("verb_id", ""))
			if not verb_definitions.has(verb_id):
				errors.append("%s references missing verb %s" % [id, verb_id])
		if bool(storyboard.get("runtime_ready", true)):
			errors.append("%s incorrectly claims runtime readiness" % id)
		var instances := instantiate_storyboard(storyboard, "QA_A", "QA_B")
		if instances.size() != beats.size():
			errors.append("%s did not instantiate every planned beat" % id)
		for instance in instances:
			for actor_id in instance.get("actors", {}).values():
				if str(actor_id) not in ["QA_A", "QA_B"]:
					errors.append("%s retained an unresolved symbolic actor" % id)
	return errors


func _size_relation(first_body: Dictionary, second_body: Dictionary) -> String:
	var rank := {"Small": 0, "Medium": 1, "Large": 2}
	var first_rank := int(rank.get(str(first_body.get("size", "Medium")), 1))
	var second_rank := int(rank.get(str(second_body.get("size", "Medium")), 1))
	if first_rank == second_rank:
		return "equal"
	return "first_larger" if first_rank > second_rank else "second_larger"


func _compile_storyboard_beats(specs: Array) -> Array:
	var result: Array = []
	var cursor := 0
	var parallel_windows := {}
	var ticks_per_beat := int(storyboard_grammar.get("ticks_per_beat", 30))
	for index in specs.size():
		var spec: Dictionary = specs[index]
		var verb_id := str(spec.get("verb_id", ""))
		var definition: Dictionary = verb_definitions.get(verb_id, {})
		var duration := maxi(1, int(spec.get("duration_beats", 1))) * ticks_per_beat
		var group := str(spec.get("parallel_group", ""))
		var start_tick := cursor
		if not group.is_empty() and parallel_windows.has(group):
			start_tick = int(parallel_windows[group].start)
		else:
			cursor += duration
			if not group.is_empty():
				parallel_windows[group] = {"start": start_tick, "end": cursor}
		var end_tick := start_tick + duration
		if not group.is_empty() and parallel_windows.has(group):
			end_tick = int(parallel_windows[group].end)
		var params: Dictionary = definition.get("defaults", {}).duplicate(true)
		params.merge(spec.get("params", {}), true)
		result.append({
			"index": index,
			"verb_id": verb_id,
			"display_name": definition.get("display_name", verb_id.capitalize()),
			"implementation_status": definition.get("status", "missing"),
			"start_tick": start_tick,
			"end_tick": end_tick,
			"parallel_group": group,
			"roles": spec.get("roles", {}).duplicate(true),
			"params": params,
		})
	return result


func _storyboard_duration(beats: Array) -> int:
	var duration := 0
	for beat in beats:
		duration = maxi(duration, int(beat.get("end_tick", 0)))
	return duration


func _storyboard_sentence(beats: Array, lookup: Dictionary) -> String:
	var clauses := PackedStringArray()
	var first_name := str(lookup.get("first", {}).get("archetype", "First"))
	var second_name := str(lookup.get("second", {}).get("archetype", "Second"))
	for beat in beats:
		var participants := PackedStringArray()
		for participant in beat.get("roles", {}).values():
			var label := first_name if str(participant) == "first" else second_name
			if label not in participants:
				participants.append(label)
		var subject := " + ".join(participants) if not participants.is_empty() else "Pair"
		clauses.append("%s: %s" % [subject, beat.get("display_name", beat.get("verb_id", "Verb"))])
	return " → ".join(clauses)
