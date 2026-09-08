extends Node

const VERSION := "0.2.4"
const CODENAME := "Jack, Jill & Bonk"
const SAVE_DIR := "user://saves"
const SETTINGS_PATH := "user://settings.cfg"
const SLOT_COUNT := 3

var current_slot := 0
var game_data: Dictionary = {}
var persistence_enabled := true
var settings := {
	"master_volume": 0.8,
	"fullscreen": false,
	"text_speed": 1,
}


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)
	load_settings()
	apply_settings()


func new_game(slot: int = 0, persist: bool = true) -> void:
	current_slot = clampi(slot, 0, SLOT_COUNT - 1)
	game_data = {
		"version": VERSION,
		"day": 1,
		"season": "Spring",
		"year": 1,
		"coins": 250,
		"energy": 10,
		"energy_max": 10,
		"location": "ranch",
		"player_name": "Rancher",
		"unlocked_locations": ["ranch", "town", "forest", "lake"],
		"breeding_count": 0,
		"offspring": [],
		"created_at": Time.get_datetime_string_from_system(false, true),
		"last_played": Time.get_datetime_string_from_system(false, true),
	}
	if persist:
		save_game()


func save_game() -> bool:
	if game_data.is_empty():
		return false
	if not persistence_enabled:
		return true
	game_data["last_played"] = Time.get_datetime_string_from_system(false, true)
	var file := FileAccess.open(_slot_path(current_slot), FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(game_data, "\t"))
	return true


func load_game(slot: int) -> bool:
	var path := _slot_path(slot)
	if not FileAccess.file_exists(path):
		return false
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return false
	var parsed = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		return false
	current_slot = slot
	game_data = parsed
	return true


func get_slot_summary(slot: int) -> Dictionary:
	var path := _slot_path(slot)
	if not FileAccess.file_exists(path):
		return {"exists": false, "slot": slot}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {"exists": false, "slot": slot}
	var parsed = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		return {"exists": false, "slot": slot}
	return {
		"exists": true,
		"slot": slot,
		"day": int(parsed.get("day", 1)),
		"season": str(parsed.get("season", "Spring")),
		"year": int(parsed.get("year", 1)),
		"coins": int(parsed.get("coins", 0)),
		"location": str(parsed.get("location", "ranch")),
		"last_played": str(parsed.get("last_played", "Unknown")),
	}


func find_latest_slot() -> int:
	var latest_slot := -1
	var latest_time := ""
	for slot in SLOT_COUNT:
		var summary := get_slot_summary(slot)
		if summary.get("exists", false) and str(summary.get("last_played", "")) > latest_time:
			latest_time = str(summary.get("last_played", ""))
			latest_slot = slot
	return latest_slot


func has_any_save() -> bool:
	return find_latest_slot() >= 0


func save_settings() -> void:
	var config := ConfigFile.new()
	for key in settings:
		config.set_value("settings", key, settings[key])
	config.save(SETTINGS_PATH)


func load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) != OK:
		return
	for key in settings:
		settings[key] = config.get_value("settings", key, settings[key])


func apply_settings() -> void:
	var bus_index := AudioServer.get_bus_index("Master")
	var volume := clampf(float(settings.master_volume), 0.0, 1.0)
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(maxf(volume, 0.001)))
	AudioServer.set_bus_mute(bus_index, volume <= 0.001)
	var mode := DisplayServer.WINDOW_MODE_FULLSCREEN if settings.fullscreen else DisplayServer.WINDOW_MODE_WINDOWED
	DisplayServer.window_set_mode(mode)


func _slot_path(slot: int) -> String:
	return "%s/slot_%d.json" % [SAVE_DIR, slot + 1]
