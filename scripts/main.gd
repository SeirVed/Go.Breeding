## Copyright © 2026 SeirVed. All rights reserved. See LICENSE.md.

extends Control

const BG := Color("#111713")
const PANEL := Color("#1c261f")
const PANEL_LIGHT := Color("#26332a")
const INK := Color("#eee2c2")
const MUTED := Color("#a8ac91")
const ACCENT := Color("#d6a84b")
const GREEN := Color("#76946a")
const DANGER := Color("#b86f62")

var screen_root: Control
var title_label: Label
var subtitle_label: Label
var selected_location: Dictionary = {}
var locations: Array = []
var previous_screen := "menu"
var toast_label: Label
var emoji_font: SystemFont


func _ready() -> void:
	emoji_font = SystemFont.new()
	emoji_font.font_names = PackedStringArray(["Segoe UI Emoji"])
	load_locations()
	build_shell()
	show_main_menu()
	if OS.get_cmdline_user_args().has("--capture-preview"):
		capture_preview.call_deferred()
	if OS.get_cmdline_user_args().has("--capture-map"):
		GameState.new_game(0, false)
		show_map()
		capture_preview.call_deferred()
	if OS.get_cmdline_user_args().has("--capture-gallery"):
		show_gallery()
		capture_preview.call_deferred()
	if OS.get_cmdline_user_args().has("--capture-breeding"):
		GameState.new_game(0, false)
		show_breeding_pen()
		capture_preview.call_deferred()
	if OS.get_cmdline_user_args().has("--capture-offspring"):
		GameState.persistence_enabled = false
		GameState.new_game(0, false)
		show_breeding_pen()
		capture_offspring.call_deferred()
	if OS.get_cmdline_user_args().has("--capture-bonk"):
		GameState.persistence_enabled = false
		GameState.new_game(0, false)
		show_breeding_pen()
		capture_bonk.call_deferred()
	if OS.get_cmdline_user_args().has("--smoke-test"):
		run_smoke_test.call_deferred()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if screen_root != null and screen_root.name == "MainMenu":
			return
		show_main_menu()
		get_viewport().set_input_as_handled()


func load_locations() -> void:
	var file := FileAccess.open("res://data/locations.json", FileAccess.READ)
	if file == null:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if parsed is Array:
		locations = parsed


func build_shell() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var background := ColorRect.new()
	background.color = BG
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var grain := emoji_label("🌱     🍃       🌱        🍂       🌱       🍃", 22)
	grain.modulate = Color(1, 1, 1, 0.12)
	grain.position = Vector2(28, 584)
	add_child(grain)

	screen_root = Control.new()
	screen_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(screen_root)

	toast_label = Label.new()
	toast_label.visible = false
	toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast_label.add_theme_color_override("font_color", BG)
	toast_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.35))
	toast_label.add_theme_constant_override("shadow_offset_x", 1)
	toast_label.add_theme_constant_override("shadow_offset_y", 2)
	toast_label.add_theme_font_size_override("font_size", 16)
	toast_label.position = Vector2(426, 585)
	toast_label.size = Vector2(300, 38)
	toast_label.add_theme_stylebox_override("normal", box(ACCENT, 8, 0))
	add_child(toast_label)


func clear_screen(screen_name: String) -> void:
	for child in screen_root.get_children():
		screen_root.remove_child(child)
		child.queue_free()
	screen_root.name = screen_name


func capture_preview() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(0.15).timeout
	DirAccess.make_dir_recursive_absolute("res://artifacts")
	var image := get_viewport().get_texture().get_image()
	var filename := "v0.2.4-main-menu.png"
	if OS.get_cmdline_user_args().has("--capture-map"):
		filename = "v0.2.4-map.png"
	elif OS.get_cmdline_user_args().has("--capture-gallery"):
		filename = "v0.2.4-dev-progress.png"
	elif OS.get_cmdline_user_args().has("--capture-breeding"):
		filename = "v0.2.4-breeding.png"
	elif OS.get_cmdline_user_args().has("--capture-offspring"):
		filename = "v0.2.4-offspring.png"
	elif OS.get_cmdline_user_args().has("--capture-bonk"):
		filename = "v0.2.4-emoji-bonk.png"
	var error := image.save_png("res://artifacts/" + filename)
	print("PREVIEW_CAPTURE: ", error_string(error))
	get_tree().quit(0 if error == OK else 1)


func capture_offspring() -> void:
	await get_tree().process_frame
	var parent_a := screen_root.find_child("ParentASelector", true, false) as OptionButton
	var parent_b := screen_root.find_child("ParentBSelector", true, false) as OptionButton
	var result_panel := screen_root.find_child("BreedingResult", true, false) as PanelContainer
	if parent_a == null or parent_b == null or result_panel == null:
		push_error("Could not locate breeding controls for preview")
		get_tree().quit(1)
		return
	perform_breeding(parent_a, parent_b, result_panel)
	await get_tree().create_timer(3.2).timeout
	await capture_preview()


func capture_bonk() -> void:
	await get_tree().process_frame
	var parent_a := screen_root.find_child("ParentASelector", true, false) as OptionButton
	var parent_b := screen_root.find_child("ParentBSelector", true, false) as OptionButton
	var result_panel := screen_root.find_child("BreedingResult", true, false) as PanelContainer
	if parent_a == null or parent_b == null or result_panel == null:
		push_error("Could not locate breeding controls for bonk preview")
		get_tree().quit(1)
		return
	perform_breeding(parent_a, parent_b, result_panel)
	await get_tree().create_timer(0.45).timeout
	await capture_preview()


func run_smoke_test() -> void:
	GameState.persistence_enabled = false
	GameState.new_game(0, false)
	show_intro(0)
	show_intro(1)
	show_intro(2)
	show_gallery()
	var notice_button := screen_root.find_child("PairNotice_jack_jill_small_feral_to_small_neutral", true, false) as Button
	var notice_panel := screen_root.find_child("PairNotice", true, false) as PanelContainer
	if notice_button == null or notice_panel == null:
		push_error("Notice-board interaction controls missing")
		get_tree().quit(1)
		return
	notice_button.pressed.emit()
	if notice_panel.get_meta("pair_key", "") != "jack_jill|small_feral>small_neutral":
		push_error("Notice-board selection failed")
		get_tree().quit(1)
		return
	show_gallery("", "jack_jack")
	if screen_root.find_child("PairNotice_jack_jack_small_feral_to_small_neutral", true, false) == null:
		push_error("Jack & Jack board failed")
		get_tree().quit(1)
		return
	show_gallery("", "jill_jill")
	if screen_root.find_child("PairNotice_jill_jill_small_feral_to_small_neutral", true, false) == null:
		push_error("Jill & Jill board failed")
		get_tree().quit(1)
		return
	show_breeding_pen()
	var engine_result := BreedingEngine.breed(SpeciesDB.get_all()[0], SpeciesDB.get_all()[1], 1)
	if engine_result.is_empty() or not engine_result.has("stats"):
		push_error("Breeding engine smoke test failed")
		get_tree().quit(1)
		return
	if PairingProgress.body_types.size() != 9 or PairingProgress.total_pair_count() != 81 or PairingProgress.total_commission_count() != 243:
		push_error("Breeding-script progress matrix failed")
		get_tree().quit(1)
		return
	if PairingProgress.couplings.size() != 81 or PairingProgress.get_archetype("female", "small_neutral").name != "Courier":
		push_error("Coupling notice-board data failed")
		get_tree().quit(1)
		return
	var regular_plan: Dictionary = PairingProgress.build_pairing_plan("cat", "cow")
	var inverted_plan: Dictionary = PairingProgress.build_pairing_plan("cow", "cat")
	if regular_plan.pair_key != "small_neutral>large_neutral" or regular_plan.order != "Regular":
		push_error("Regular species-to-silhouette pairing map failed")
		get_tree().quit(1)
		return
	if inverted_plan.pair_key != "large_neutral>small_neutral" or inverted_plan.order != "Inverted" or regular_plan.pair_key == inverted_plan.pair_key:
		push_error("Species-to-silhouette pairing map failed")
		get_tree().quit(1)
		return
	show_map()
	select_location(get_location("town"))
	visit_selected()
	show_map()
	show_options()
	show_load_screen()
	if screen_root.name != "Slots":
		push_error("Smoke test failed")
		get_tree().quit(1)
		return
	print("SMOKE_TEST: all framework screens constructed successfully")
	GameState.persistence_enabled = true
	get_tree().quit(0)


func show_main_menu() -> void:
	clear_screen("MainMenu")
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 72)
	margin.add_theme_constant_override("margin_right", 72)
	margin.add_theme_constant_override("margin_top", 48)
	margin.add_theme_constant_override("margin_bottom", 44)
	screen_root.add_child(margin)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 70)
	margin.add_child(row)

	var hero := VBoxContainer.new()
	hero.custom_minimum_size.x = 590
	hero.add_theme_constant_override("separation", 8)
	row.add_child(hero)

	var kicker := label("A SYSTEMS-FIRST BREEDING SIM", 14, ACCENT)
	hero.add_child(kicker)
	hero.add_spacer(false)

	title_label = label("GO.\nBREEDING", 62, INK)
	title_label.add_theme_constant_override("line_spacing", -10)
	hero.add_child(title_label)

	var rule := HSeparator.new()
	rule.custom_minimum_size = Vector2(420, 18)
	rule.add_theme_color_override("separator", GREEN)
	hero.add_child(rule)

	subtitle_label = label("Version %s  —  %s" % [GameState.VERSION, GameState.CODENAME], 18, MUTED)
	hero.add_child(subtitle_label)

	var hero_layers := [
		{"emoji": "🌄", "position": [0.50, 0.34], "size": 116},
		{"emoji": "🌳", "position": [0.18, 0.54], "size": 72, "rotation": -5},
		{"emoji": "🏡", "position": [0.48, 0.54], "size": 94},
		{"emoji": "🌾", "position": [0.77, 0.60], "size": 70, "rotation": 8},
		{"emoji": "🐄", "position": [0.33, 0.80], "size": 58},
		{"emoji": "🌱", "position": [0.65, 0.84], "size": 40}
	]
	hero.add_child(emoji_composite(hero_layers, Vector2(520, 215)))

	var menu_panel := PanelContainer.new()
	menu_panel.custom_minimum_size = Vector2(330, 0)
	menu_panel.add_theme_stylebox_override("panel", box(PANEL, 14, 1, Color("#3d4b3e")))
	row.add_child(menu_panel)

	var menu_margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		menu_margin.add_theme_constant_override("margin_" + side, 28)
	menu_panel.add_child(menu_margin)

	var buttons := VBoxContainer.new()
	buttons.add_theme_constant_override("separation", 12)
	menu_margin.add_child(buttons)
	buttons.add_child(label("FIELD JOURNAL", 14, MUTED))
	buttons.add_child(menu_button("NEW GAME", show_new_game_slots, "Begin a fresh bloodline"))
	var continue_button := menu_button("CONTINUE", continue_latest, "Return to the latest save")
	continue_button.disabled = not GameState.has_any_save()
	buttons.add_child(continue_button)
	buttons.add_child(menu_button("LOAD GAME", show_load_screen, "Choose a journal entry"))
	buttons.add_child(menu_button("DEV PROGRESS", show_gallery, "Procedural breeding-script coverage"))
	buttons.add_child(menu_button("OPTIONS", show_options, "Display, sound, and text"))
	buttons.add_spacer(false)
	buttons.add_child(menu_button("EXIT", request_exit, "Close the game"))
	buttons.add_child(label("Tip: Esc always returns here.", 13, MUTED))


func show_new_game_slots() -> void:
	show_slot_screen(true)


func show_load_screen() -> void:
	show_slot_screen(false)


func show_slot_screen(is_new: bool) -> void:
	clear_screen("Slots")
	var column := centered_column(760, 48)
	column.add_child(section_title("Choose a New Journal" if is_new else "Open a Journal", "Three independent save slots"))
	for slot in GameState.SLOT_COUNT:
		var summary := GameState.get_slot_summary(slot)
		var button := Button.new()
		button.custom_minimum_size = Vector2(0, 105)
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.add_theme_font_size_override("font_size", 17)
		button.add_theme_color_override("font_color", INK)
		button.add_theme_stylebox_override("normal", box(PANEL, 10, 1, Color("#3d4b3e")))
		button.add_theme_stylebox_override("hover", box(PANEL_LIGHT, 10, 2, ACCENT))
		button.add_theme_stylebox_override("pressed", box(Color("#344235"), 10, 2, ACCENT))
		if summary.exists:
			button.text = "  SLOT %d     DAY %d · %s · YEAR %d\n  %d coins  |  Last location: %s  |  %s" % [slot + 1, summary.day, summary.season, summary.year, summary.coins, str(summary.location).capitalize(), friendly_time(summary.last_played)]
		else:
			button.text = "  SLOT %d     — EMPTY —\n  A blank page waits for a new beginning." % (slot + 1)
		if is_new:
			button.pressed.connect(start_new_game.bind(slot))
		else:
			button.disabled = not summary.exists
			button.pressed.connect(load_slot.bind(slot))
		column.add_child(button)
	column.add_child(back_button(show_main_menu))


func start_new_game(slot: int) -> void:
	GameState.new_game(slot)
	show_intro(0)


func continue_latest() -> void:
	var slot := GameState.find_latest_slot()
	if slot >= 0:
		load_slot(slot)


func load_slot(slot: int) -> void:
	if GameState.load_game(slot):
		show_map()


func show_intro(page: int) -> void:
	clear_screen("Intro")
	var pages := [
		{
			"chapter": "PROLOGUE · I",
			"title": "A deed, a key, and a field gone quiet.",
			"body": "The letter arrived at the end of winter. Aunt Mara had left you Hearthglen Ranch—its weathered barns, its overgrown pens, and every promise buried in the soil.",
			"emoji_layers": [
				{"emoji": "📜", "position": [0.21, 0.38], "size": 78, "rotation": -12},
				{"emoji": "🗝️", "position": [0.32, 0.68], "size": 58, "rotation": 15},
				{"emoji": "🏡", "position": [0.58, 0.43], "size": 106},
				{"emoji": "🌾", "position": [0.76, 0.67], "size": 66},
				{"emoji": "❄️", "position": [0.78, 0.20], "size": 35}
			]
		},
		{
			"chapter": "PROLOGUE · II",
			"title": "Some inheritances are alive.",
			"body": "In her field journal you find careful records: traits, temperaments, elemental affinities—and one final note. “A strong line is not found. It is tended.”",
			"emoji_layers": [
				{"emoji": "📖", "position": [0.46, 0.48], "size": 120},
				{"emoji": "🧬", "position": [0.47, 0.42], "size": 66, "rotation": -8},
				{"emoji": "🐄", "position": [0.24, 0.72], "size": 54},
				{"emoji": "🐎", "position": [0.72, 0.70], "size": 58},
				{"emoji": "✨", "position": [0.70, 0.22], "size": 40}
			]
		},
		{
			"chapter": "PROLOGUE · III",
			"title": "Spring, Day One.",
			"body": "The gates creak open. Briarwick stirs beyond the hill. Whatever Hearthglen becomes next begins with your first step.",
			"emoji_layers": [
				{"emoji": "🌅", "position": [0.50, 0.40], "size": 120},
				{"emoji": "🚪", "position": [0.25, 0.65], "size": 70},
				{"emoji": "👢", "position": [0.48, 0.75], "size": 52, "rotation": -9},
				{"emoji": "🏘️", "position": [0.75, 0.62], "size": 74},
				{"emoji": "🌱", "position": [0.64, 0.83], "size": 38}
			]
		}
	]
	var entry: Dictionary = pages[page]
	var column := centered_column(760, 62)
	column.add_child(label(entry.chapter, 14, ACCENT))
	column.add_child(label(entry.title, 36, INK))
	column.add_child(emoji_composite(entry.emoji_layers, Vector2(760, 190)))
	var body := label(entry.body, 19, MUTED)
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.custom_minimum_size.y = 100
	column.add_child(body)
	var nav := HBoxContainer.new()
	nav.alignment = BoxContainer.ALIGNMENT_END
	nav.add_theme_constant_override("separation", 12)
	if page > 0:
		nav.add_child(small_button("← BACK", show_intro.bind(page - 1)))
	var next_text := "OPEN THE MAP  →" if page == pages.size() - 1 else "CONTINUE  →"
	var next_action := show_map if page == pages.size() - 1 else show_intro.bind(page + 1)
	nav.add_child(small_button(next_text, next_action, true))
	column.add_child(nav)


func show_map() -> void:
	clear_screen("Map")
	selected_location = get_location(str(GameState.game_data.get("location", "ranch")))
	var header := PanelContainer.new()
	header.position = Vector2(32, 24)
	header.size = Vector2(1088, 64)
	header.add_theme_stylebox_override("panel", box(PANEL, 10, 1, Color("#3d4b3e")))
	screen_root.add_child(header)
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 24)
	header.add_child(top)
	var brand := label(" GO.BREEDING ", 22, ACCENT)
	brand.custom_minimum_size.x = 260
	top.add_child(brand)
	var day := label("SPRING · DAY %d · YEAR %d" % [int(GameState.game_data.day), int(GameState.game_data.year)], 16, INK)
	day.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	day.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	top.add_child(day)
	top.add_child(label("💰 %d     ⚡ %d/%d  " % [int(GameState.game_data.coins), int(GameState.game_data.energy), int(GameState.game_data.energy_max)], 16, MUTED))

	var map_panel := PanelContainer.new()
	map_panel.position = Vector2(32, 106)
	map_panel.size = Vector2(710, 500)
	map_panel.add_theme_stylebox_override("panel", box(Color("#172019"), 12, 1, Color("#3d4b3e")))
	screen_root.add_child(map_panel)
	var map_canvas := Control.new()
	map_canvas.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	map_canvas.mouse_filter = Control.MOUSE_FILTER_PASS
	map_panel.add_child(map_canvas)

	var map_title := label("THE HEARTHGLEN VALE", 15, Color("#506353"))
	map_title.position = Vector2(220, 22)
	map_title.size = Vector2(270, 28)
	map_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	map_canvas.add_child(map_title)
	var map_decor := [
		{"emoji": "⛰️", "position": [0.16, 0.20], "size": 62},
		{"emoji": "🌲", "position": [0.86, 0.26], "size": 54},
		{"emoji": "🌳", "position": [0.91, 0.43], "size": 46},
		{"emoji": "🌊", "position": [0.76, 0.80], "size": 74},
		{"emoji": "🌾", "position": [0.12, 0.80], "size": 52},
		{"emoji": "☁️", "position": [0.63, 0.17], "size": 46}
	]
	var decor := emoji_composite(map_decor, Vector2(680, 460), 1.0, 0.20)
	decor.position = Vector2(0, 18)
	map_canvas.add_child(decor)

	var unlocked: Array = GameState.game_data.get("unlocked_locations", [])
	for location in locations:
		var node := Button.new()
		var pos_data: Array = location.position
		node.position = Vector2(float(pos_data[0]) * 610.0, float(pos_data[1]) * 405.0) + Vector2(24, 24)
		node.size = Vector2(150, 62)
		node.text = "%s  %s" % [location.icon, location.name]
		node.disabled = not unlocked.has(location.id)
		node.add_theme_font_size_override("font_size", 15)
		node.add_theme_color_override("font_color", INK)
		node.add_theme_color_override("font_disabled_color", Color("#667066"))
		node.add_theme_stylebox_override("normal", box(PANEL, 9, 1, GREEN))
		node.add_theme_stylebox_override("hover", box(PANEL_LIGHT, 9, 2, ACCENT))
		node.add_theme_stylebox_override("disabled", box(Color("#151a16"), 9, 1, Color("#343b35")))
		node.pressed.connect(select_location.bind(location))
		map_canvas.add_child(node)

	var details := PanelContainer.new()
	details.position = Vector2(762, 106)
	details.size = Vector2(358, 500)
	details.add_theme_stylebox_override("panel", box(PANEL, 12, 1, Color("#3d4b3e")))
	screen_root.add_child(details)
	build_location_details(details)


func build_location_details(panel: PanelContainer) -> void:
	for child in panel.get_children():
		child.queue_free()
	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 24)
	panel.add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 14)
	margin.add_child(column)
	column.add_child(label("SELECTED DESTINATION", 13, ACCENT))
	column.add_child(label("%s  %s" % [selected_location.get("icon", "·"), selected_location.get("name", "Unknown")], 26, INK))
	column.add_child(emoji_composite(selected_location.get("emoji_layers", []), Vector2(310, 150), 0.72))
	var description := label(str(selected_location.get("description", "")), 16, MUTED)
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description.custom_minimum_size.y = 92
	column.add_child(description)
	column.add_spacer(false)
	column.add_child(small_button("TRAVEL HERE  →", visit_selected, true))
	var bottom := HBoxContainer.new()
	bottom.add_theme_constant_override("separation", 8)
	bottom.add_child(small_button("SAVE", manual_save))
	bottom.add_child(small_button("MENU", show_main_menu))
	column.add_child(bottom)


func select_location(location: Dictionary) -> void:
	selected_location = location
	var details := screen_root.get_child(2) as PanelContainer
	build_location_details(details)


func visit_selected() -> void:
	if selected_location.is_empty():
		return
	GameState.game_data.location = selected_location.id
	GameState.save_game()
	show_location()


func show_location() -> void:
	clear_screen("Location")
	var column := centered_column(820, 44)
	column.add_child(label("NOW VISITING", 14, ACCENT))
	column.add_child(label("%s  %s" % [selected_location.icon, selected_location.name], 38, INK))
	column.add_child(emoji_composite(selected_location.emoji_layers, Vector2(820, 220), 1.15))
	var description := label(selected_location.description, 18, MUTED)
	description.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(description)
	var placeholder := PanelContainer.new()
	placeholder.add_theme_stylebox_override("panel", box(Color("#151b17"), 8, 1, Color("#354137")))
	var note := label("🚧  FRAMEWORK PLACEHOLDER  🚧\nLocation activities, encounters, shops, and breeding systems plug in here.", 15, Color("#778177"))
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	placeholder.add_child(note)
	column.add_child(placeholder)
	if selected_location.id == "ranch":
		column.add_child(small_button("💞  OPEN BREEDING PEN", show_breeding_pen, true))
	column.add_child(small_button("←  RETURN TO MAP", show_map, true))


func show_gallery(_focus_id: String = "", board_id: String = "jack_jill") -> void:
	clear_screen("DevProgress")
	var board: Dictionary = pairing_board_config(board_id)
	var margin := MarginContainer.new()
	margin.position = Vector2(22, 16)
	margin.size = Vector2(1108, 616)
	screen_root.add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 8)
	margin.add_child(column)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 14)
	column.add_child(header)
	var heading := VBoxContainer.new()
	heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading.add_child(label("📜  TOWN COMMISSION BOARD", 29, INK))
	heading.add_child(label("BREEDING CHOREOGRAPHY NOTICES · DEV PROGRESS · READ ONLY", 12, ACCENT))
	header.add_child(heading)
	header.add_child(label("%d / %d TOTAL FINISHED" % [PairingProgress.completed_commission_count(), PairingProgress.total_commission_count()], 13, MUTED))
	header.add_child(small_button("← MENU", show_main_menu))
	var board_tabs := HBoxContainer.new()
	board_tabs.alignment = BoxContainer.ALIGNMENT_CENTER
	board_tabs.add_theme_constant_override("separation", 8)
	column.add_child(board_tabs)
	for option in [
		{"id":"jack_jill", "label":"♂ JACK & JILL ♀"},
		{"id":"jack_jack", "label":"♂ JACK & JACK ♂"},
		{"id":"jill_jill", "label":"♀ JILL & JILL ♀"},
	]:
		board_tabs.add_child(board_tab_button(option.label, option.id, board_id))

	var body := HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 10)
	column.add_child(body)

	var detail_panel := PanelContainer.new()
	detail_panel.name = "PairNotice"
	detail_panel.custom_minimum_size.x = 306
	detail_panel.add_theme_stylebox_override("panel", box(Color("#dfc78f"), 4, 2, Color("#684329")))

	var matrix_panel := PanelContainer.new()
	matrix_panel.custom_minimum_size.x = 792
	matrix_panel.add_theme_stylebox_override("panel", box(Color("#4a2e1c"), 8, 3, Color("#8a6237")))
	body.add_child(matrix_panel)
	var matrix_margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		matrix_margin.add_theme_constant_override("margin_" + side, 9)
	matrix_panel.add_child(matrix_margin)
	var matrix_column := VBoxContainer.new()
	matrix_column.add_theme_constant_override("separation", 5)
	matrix_margin.add_child(matrix_column)
	var board_title := label("%s  ·  %d / %d FINISHED\n%s" % [board.title, PairingProgress.completed_pair_count(board_id), PairingProgress.total_pair_count(), board.axis], 11, Color("#f1d596"))
	board_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	matrix_column.add_child(board_title)
	var grid := GridContainer.new()
	grid.columns = 10
	grid.add_theme_constant_override("h_separation", 3)
	grid.add_theme_constant_override("v_separation", 3)
	matrix_column.add_child(grid)
	grid.add_child(matrix_header(board.corner, true))
	for body_type in PairingProgress.body_types:
		var column_type: Dictionary = PairingProgress.get_archetype(board.column_role, body_type.id)
		grid.add_child(matrix_header(column_type.name))
	for row_index in PairingProgress.body_types.size():
		var row_body: Dictionary = PairingProgress.body_types[row_index]
		var row_type: Dictionary = PairingProgress.get_archetype(board.row_role, row_body.id)
		grid.add_child(matrix_header(row_type.name, true))
		for column_index in PairingProgress.body_types.size():
			var column_body: Dictionary = PairingProgress.body_types[column_index]
			grid.add_child(matrix_pair_cell(row_body, column_body, row_index, column_index, detail_panel, board_id, board.row_role, board.column_role))
	var legend := label("📌 Select a notice · cream = Regular · rose = Inverted · PLACEHOLDER ACTIVE · proper animations not yet made", 11, Color("#e2c58a"))
	legend.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	legend.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	matrix_column.add_child(legend)

	body.add_child(detail_panel)
	show_pair_notice(detail_panel, PairingProgress.body_types[0], PairingProgress.body_types[0], board_id, board.row_role, board.column_role)


func pairing_board_config(board_id: String) -> Dictionary:
	match board_id:
		"jack_jack":
			return {"title":"JACK & JACK", "row_role":"male", "column_role":"male", "axis":"♂ JACK A ↓    ×    JACK B → ♂", "corner":"♂A \\ ♂B"}
		"jill_jill":
			return {"title":"JILL & JILL", "row_role":"female", "column_role":"female", "axis":"♀ JILL A ↓    ×    JILL B → ♀", "corner":"♀A \\ ♀B"}
		_:
			return {"title":"JACK & JILL", "row_role":"male", "column_role":"female", "axis":"♂ JACK ↓    ×    JILL → ♀", "corner":"♂ \\ ♀"}


func board_tab_button(text_value: String, target_board: String, current_board: String) -> Button:
	var node := Button.new()
	node.text = text_value
	node.custom_minimum_size = Vector2(210, 30)
	node.add_theme_font_size_override("font_size", 13)
	node.add_theme_color_override("font_color", INK)
	node.add_theme_color_override("font_hover_color", Color("#3d2918"))
	node.add_theme_color_override("font_disabled_color", Color("#3d2918"))
	node.add_theme_stylebox_override("normal", compact_box(Color("#4a2e1c"), 5, 1, Color("#8a6237")))
	node.add_theme_stylebox_override("hover", compact_box(Color("#dfc78f"), 5, 2, ACCENT))
	node.add_theme_stylebox_override("pressed", compact_box(Color("#cfb378"), 5, 2, Color("#684329")))
	node.add_theme_stylebox_override("disabled", compact_box(Color("#dfc78f"), 5, 2, ACCENT))
	node.disabled = target_board == current_board
	if not node.disabled:
		node.pressed.connect(show_gallery.bind("", target_board))
	return node


func matrix_header(text_value: String, row_header: bool = false) -> Label:
	var node := label(text_value, 10, Color("#f2d69a"))
	node.custom_minimum_size = Vector2(86 if row_header else 70, 38)
	node.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	node.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return node


func matrix_pair_cell(row_body: Dictionary, column_body: Dictionary, row_index: int, column_index: int, detail_panel: PanelContainer, board_id: String, row_role: String, column_role: String) -> Button:
	var cell := Button.new()
	cell.custom_minimum_size = Vector2(70, 38)
	var inverted := column_index < row_index
	var row_type: Dictionary = PairingProgress.get_archetype(row_role, row_body.id)
	var column_type: Dictionary = PairingProgress.get_archetype(column_role, column_body.id)
	var coupling: Dictionary = PairingProgress.get_coupling(row_body.id, column_body.id, board_id, row_role, column_role)
	var paper := Color("#d9b9ad") if inverted else Color("#e8d5a4")
	var ink := Color("#42283d") if inverted else Color("#3b2a18")
	cell.text = "📌  %s%s" % [row_type.emoji, column_type.emoji]
	cell.name = "PairNotice_%s_%s_to_%s" % [board_id, row_body.id, column_body.id]
	cell.tooltip_text = coupling.name
	cell.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	cell.add_theme_font_override("font", emoji_font)
	cell.add_theme_font_size_override("font_size", 14)
	cell.add_theme_color_override("font_color", ink)
	cell.add_theme_color_override("font_hover_color", ink)
	cell.add_theme_color_override("font_pressed_color", ink)
	cell.add_theme_stylebox_override("normal", compact_box(paper, 2, 1, paper.darkened(0.28)))
	cell.add_theme_stylebox_override("hover", compact_box(paper.lightened(0.12), 2, 2, Color("#f0b94d")))
	cell.add_theme_stylebox_override("pressed", compact_box(paper.darkened(0.08), 2, 2, Color("#6a4027")))
	cell.add_theme_stylebox_override("focus", compact_box(Color.TRANSPARENT, 2, 2, Color("#f0b94d")))
	cell.pressed.connect(show_pair_notice.bind(detail_panel, row_body, column_body, board_id, row_role, column_role))
	return cell


func show_pair_notice(panel: PanelContainer, row_body: Dictionary, column_body: Dictionary, board_id: String = "jack_jill", row_role: String = "male", column_role: String = "female") -> void:
	panel.set_meta("pair_key", PairingProgress.board_pair_key(board_id, row_body.id, column_body.id))
	for child in panel.get_children():
		panel.remove_child(child)
		child.queue_free()
	var paper_ink := Color("#3d2918")
	var paper_muted := Color("#725a3b")
	var row_type: Dictionary = PairingProgress.get_archetype(row_role, row_body.id)
	var column_type: Dictionary = PairingProgress.get_archetype(column_role, column_body.id)
	var coupling: Dictionary = PairingProgress.get_coupling(row_body.id, column_body.id, board_id, row_role, column_role)
	var percent: int = PairingProgress.progress_percent(row_body.id, column_body.id, board_id)
	var count: int = PairingProgress.script_count(row_body.id, column_body.id, board_id)
	var order_name: String = PairingProgress.order_label(row_body.id, column_body.id)
	var paper_margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		paper_margin.add_theme_constant_override("margin_" + side, 13)
	panel.add_child(paper_margin)
	var notice := VBoxContainer.new()
	notice.add_theme_constant_override("separation", 5)
	paper_margin.add_child(notice)
	var pin := emoji_label("📌", 23)
	pin.custom_minimum_size.y = 25
	notice.add_child(pin)
	notice.add_child(build_emoji_bonk(row_type.emoji, column_type.emoji, Vector2(270, 82)))
	var pairing := label("%s  ×  %s" % [row_type.name, column_type.name], 13, paper_muted)
	pairing.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	notice.add_child(pairing)
	var notice_title := label(coupling.name, 24, paper_ink)
	notice_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	notice_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	notice.add_child(notice_title)
	var description := label(coupling.description, 14, paper_ink)
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	notice.add_child(description)
	var rule := HSeparator.new()
	rule.add_theme_color_override("separator", Color("#8a6944"))
	notice.add_child(rule)
	notice.add_child(label("COMMISSION PROGRESS", 12, paper_muted))
	var progress_bar := ProgressBar.new()
	progress_bar.custom_minimum_size.y = 28
	progress_bar.value = percent
	progress_bar.show_percentage = true
	progress_bar.add_theme_color_override("font_color", paper_ink)
	progress_bar.add_theme_color_override("font_outline_color", Color("#f4e4b7"))
	progress_bar.add_theme_constant_override("outline_size", 2)
	progress_bar.add_theme_stylebox_override("background", box(Color("#b99f70"), 5, 0))
	progress_bar.add_theme_stylebox_override("fill", box(Color("#7c965d"), 5, 0))
	notice.add_child(progress_bar)
	var status := "COMPLETE" if percent >= 100 else ("IN PROGRESS" if percent > 0 else "NOT STARTED")
	var details := label("%s · %s ORDER\n%s %s  →  %s %s\n%d authored script%s · PLACEHOLDER ACTIVE\nEmoji Bonk v0 · proper animation pending funding" % [status, order_name.to_upper(), row_body.size, row_body.morph, column_body.size, column_body.morph, count, "" if count == 1 else "s"], 12, paper_muted)
	details.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	details.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	notice.add_child(details)


func build_emoji_bonk(left_emoji: String, right_emoji: String, stage_size: Vector2 = Vector2(270, 82)) -> Control:
	var stage := Control.new()
	stage.custom_minimum_size = stage_size
	stage.clip_contents = true
	var backdrop := Panel.new()
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	backdrop.add_theme_stylebox_override("panel", compact_box(Color("#c4a874"), 7, 1, Color("#9b7b4e")))
	stage.add_child(backdrop)
	var left_actor := emoji_label(left_emoji, 39)
	left_actor.size = Vector2(62, 62)
	left_actor.position = Vector2(14, 12)
	left_actor.pivot_offset = left_actor.size * 0.5
	stage.add_child(left_actor)
	var right_actor := emoji_label(right_emoji, 39)
	right_actor.size = Vector2(62, 62)
	right_actor.position = Vector2(stage_size.x - 76, 12)
	right_actor.pivot_offset = right_actor.size * 0.5
	stage.add_child(right_actor)
	var burst := emoji_label("💦  💥  💨", 23)
	burst.size = Vector2(150, 42)
	burst.position = Vector2((stage_size.x - 150) * 0.5, 20)
	burst.modulate.a = 0.0
	stage.add_child(burst)
	var left_start := left_actor.position
	var right_start := right_actor.position
	var tween := stage.create_tween().bind_node(stage).set_loops()
	tween.tween_interval(0.22)
	tween.tween_property(left_actor, "position", Vector2(94, 12), 0.28).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(right_actor, "position", Vector2(114, 12), 0.28).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_callback(func(): burst.modulate.a = 1.0)
	tween.tween_property(left_actor, "position", Vector2(124, -3), 0.20).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(right_actor, "position", Vector2(101, 31), 0.20).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(left_actor, "rotation", -0.22, 0.20)
	tween.parallel().tween_property(right_actor, "rotation", 0.18, 0.20)
	tween.tween_interval(0.12)
	tween.tween_property(left_actor, "position", Vector2(101, 31), 0.20).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(right_actor, "position", Vector2(124, -3), 0.20).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(left_actor, "rotation", 0.18, 0.20)
	tween.parallel().tween_property(right_actor, "rotation", -0.22, 0.20)
	tween.tween_property(burst, "modulate:a", 0.0, 0.18)
	tween.tween_property(left_actor, "position", left_start, 0.28).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(right_actor, "position", right_start, 0.28).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(left_actor, "rotation", 0.0, 0.22)
	tween.parallel().tween_property(right_actor, "rotation", 0.0, 0.22)
	tween.tween_interval(0.35)
	return stage


func show_breeding_pen() -> void:
	clear_screen("BreedingPen")
	if GameState.game_data.is_empty():
		GameState.new_game(0, false)
	var margin := MarginContainer.new()
	margin.position = Vector2(38, 24)
	margin.size = Vector2(1076, 598)
	screen_root.add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 12)
	margin.add_child(column)
	var header := HBoxContainer.new()
	column.add_child(header)
	var title_group := VBoxContainer.new()
	title_group.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_group.add_child(label("💞  BREEDING PEN", 31, INK))
	title_group.add_child(label("Deterministic genetics · Emoji Bonk placeholder plays until authored choreography exists", 13, MUTED))
	header.add_child(title_group)
	header.add_child(label("💰 %d   ·   ⚡ %d/%d" % [int(GameState.game_data.coins), int(GameState.game_data.energy), int(GameState.game_data.energy_max)], 15, ACCENT))

	var selectors := HBoxContainer.new()
	selectors.add_theme_constant_override("separation", 14)
	column.add_child(selectors)
	var parent_a := build_parent_selector("PARENT A", 0)
	var parent_b := build_parent_selector("PARENT B", 1)
	selectors.add_child(parent_a.root)
	var action_column := VBoxContainer.new()
	action_column.custom_minimum_size.x = 210
	action_column.alignment = BoxContainer.ALIGNMENT_CENTER
	action_column.add_theme_constant_override("separation", 10)
	action_column.add_child(emoji_label("💞", 58))
	var formula := label("25 coins · 2 energy\nSame inputs + generation\n= same outcome", 13, MUTED)
	formula.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	action_column.add_child(formula)
	selectors.add_child(action_column)
	selectors.add_child(parent_b.root)

	var result_panel := PanelContainer.new()
	result_panel.name = "BreedingResult"
	result_panel.custom_minimum_size.y = 190
	result_panel.add_theme_stylebox_override("panel", box(PANEL, 10, 1, Color("#3d4b3e")))
	column.add_child(result_panel)
	build_breeding_result(result_panel, {})
	var breed_button := small_button("💞  BREED SELECTED PAIR", perform_breeding.bind(parent_a.selector, parent_b.selector, result_panel), true)
	action_column.add_child(breed_button)
	var nav := HBoxContainer.new()
	nav.add_theme_constant_override("separation", 8)
	nav.add_child(small_button("← RANCH", show_location))
	nav.add_child(small_button("DEV PROGRESS", show_gallery))
	column.add_child(nav)


func build_parent_selector(title_text: String, initial_index: int) -> Dictionary:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(412, 238)
	panel.add_theme_stylebox_override("panel", box(PANEL, 10, 1, Color("#3d4b3e")))
	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 14)
	panel.add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 7)
	margin.add_child(column)
	column.add_child(label(title_text, 13, ACCENT))
	var selector := OptionButton.new()
	selector.name = "ParentASelector" if title_text == "PARENT A" else "ParentBSelector"
	selector.custom_minimum_size.y = 40
	for spec in SpeciesDB.get_all():
		selector.add_item("%s  %s  ·  %s" % ["".join(spec.emoji), spec.name, str(spec.tier).capitalize()])
	selector.selected = initial_index
	column.add_child(selector)
	var portrait := PanelContainer.new()
	portrait.custom_minimum_size.y = 128
	portrait.add_theme_stylebox_override("panel", box(Color("#151b17"), 8, 0))
	column.add_child(portrait)
	refresh_parent_portrait(portrait, SpeciesDB.get_all()[initial_index])
	selector.item_selected.connect(func(index: int): refresh_parent_portrait(portrait, SpeciesDB.get_all()[index]))
	return {"root": panel, "selector": selector}


func refresh_parent_portrait(panel: PanelContainer, spec: Dictionary) -> void:
	for child in panel.get_children():
		panel.remove_child(child)
		child.queue_free()
	var content := HBoxContainer.new()
	panel.add_child(content)
	content.add_child(emoji_composite(species_emoji_layers(spec.emoji), Vector2(190, 120), 0.70))
	var stats := label("%s\n%s affinity\n%s-biased genes\nStability %+.2f" % [spec.name, spec.element, spec.bias, float(spec.stability)], 13, MUTED)
	stats.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	content.add_child(stats)


func perform_breeding(parent_a: OptionButton, parent_b: OptionButton, result_panel: PanelContainer) -> void:
	if bool(result_panel.get_meta("breeding_busy", false)):
		show_toast("The emoji are still bonking")
		return
	if int(GameState.game_data.coins) < 25 or int(GameState.game_data.energy) < 2:
		show_toast("Not enough coins or energy")
		return
	var spec_a: Dictionary = SpeciesDB.get_all()[parent_a.selected]
	var spec_b: Dictionary = SpeciesDB.get_all()[parent_b.selected]
	GameState.game_data.coins = int(GameState.game_data.coins) - 25
	GameState.game_data.energy = int(GameState.game_data.energy) - 2
	GameState.game_data.breeding_count = int(GameState.game_data.get("breeding_count", 0)) + 1
	var result := BreedingEngine.breed(spec_a, spec_b, int(GameState.game_data.breeding_count))
	var offspring: Array = GameState.game_data.get("offspring", [])
	offspring.append(result)
	if offspring.size() > 50:
		offspring.pop_front()
	GameState.game_data.offspring = offspring
	GameState.save_game()
	build_breeding_placeholder(result_panel, spec_a, spec_b)
	show_toast("PLACEHOLDER ACTIVE · emoji bonk in progress")
	await get_tree().create_timer(2.35).timeout
	if is_instance_valid(result_panel) and result_panel.is_inside_tree():
		build_breeding_result(result_panel, result)
		show_toast("New offspring recorded")


func build_breeding_placeholder(panel: PanelContainer, spec_a: Dictionary, spec_b: Dictionary) -> void:
	panel.set_meta("breeding_busy", true)
	for child in panel.get_children():
		panel.remove_child(child)
		child.queue_free()
	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 12)
	panel.add_child(margin)
	var column := VBoxContainer.new()
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_theme_constant_override("separation", 4)
	margin.add_child(column)
	var heading := label("PLACEHOLDER BREEDING ANIMATION · EMOJI BONK v0", 12, ACCENT)
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(heading)
	var bonk := build_emoji_bonk("".join(spec_a.emoji), "".join(spec_b.emoji))
	bonk.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	column.add_child(bonk)
	var caption := label("💨  They bash, bounce, swap, and splash. Proper animation arrives when its commission is funded.  💦", 12, MUTED)
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(caption)


func build_breeding_result(panel: PanelContainer, result: Dictionary) -> void:
	panel.set_meta("breeding_busy", false)
	for child in panel.get_children():
		panel.remove_child(child)
		child.queue_free()
	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 14)
	panel.add_child(margin)
	if result.is_empty():
		var waiting := label("🥚  Select two species and begin a new lineage.", 18, MUTED)
		waiting.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		waiting.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		margin.add_child(waiting)
		return
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 18)
	margin.add_child(row)
	row.add_child(emoji_composite(species_emoji_layers(result.emoji), Vector2(210, 154), 0.86))
	var identity := VBoxContainer.new()
	identity.custom_minimum_size.x = 250
	identity.add_child(label("OFFSPRING · GENERATION %d" % int(result.generation), 12, ACCENT))
	identity.add_child(label(result.species_name, 27, INK))
	identity.add_child(label("%s · %s · %s" % [result.element, axis_name(float(result.feral), "Feral", "Refined"), axis_name(float(result.development), "Neotenous", "Peramorphous")], 13, MUTED))
	identity.add_child(label("Stability %+.2f   ·   Mutation: %s" % [float(result.stability), result.mutation], 13, GREEN if float(result.stability) >= 0.0 else DANGER))
	row.add_child(identity)
	var plan: Dictionary = result.get("pairing_plan", {})
	var stat_text := "GENETIC BASELINE\nSTR %d   VIT %d   SPD %d\nMAG %d   DEF %d   CHA %d\n\n%s · %s\n%s" % [int(result.stats.STR), int(result.stats.VIT), int(result.stats.SPD), int(result.stats.MAG), int(result.stats.DEF), int(result.stats.CHA), plan.get("pair_key", "unmapped"), plan.get("order", "Regular"), plan.get("mode", "Placeholder only")]
	row.add_child(label(stat_text, 14, INK))


func axis_name(value: float, low_name: String, high_name: String) -> String:
	if value < -0.2:
		return low_name
	if value > 0.2:
		return high_name
	return "Neutral"


func show_options() -> void:
	clear_screen("Options")
	var column := centered_column(680, 64)
	column.add_child(section_title("Options", "Stored automatically on this machine"))
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", box(PANEL, 12, 1, Color("#3d4b3e")))
	column.add_child(panel)
	var form := GridContainer.new()
	form.columns = 2
	form.add_theme_constant_override("h_separation", 28)
	form.add_theme_constant_override("v_separation", 22)
	panel.add_child(form)
	form.add_child(label("MASTER VOLUME", 15, INK))
	var volume := HSlider.new()
	volume.min_value = 0
	volume.max_value = 100
	volume.value = float(GameState.settings.master_volume) * 100.0
	volume.custom_minimum_size = Vector2(330, 36)
	volume.value_changed.connect(set_volume)
	form.add_child(volume)
	form.add_child(label("FULLSCREEN", 15, INK))
	var fullscreen := CheckButton.new()
	fullscreen.text = "Enabled"
	fullscreen.button_pressed = bool(GameState.settings.fullscreen)
	fullscreen.toggled.connect(set_fullscreen)
	form.add_child(fullscreen)
	form.add_child(label("TEXT SPEED", 15, INK))
	var speed := OptionButton.new()
	speed.add_item("Relaxed")
	speed.add_item("Standard")
	speed.add_item("Swift")
	speed.selected = int(GameState.settings.text_speed)
	speed.item_selected.connect(set_text_speed)
	form.add_child(speed)
	column.add_child(back_button(show_main_menu))


func set_volume(value: float) -> void:
	GameState.settings.master_volume = value / 100.0
	GameState.apply_settings()
	GameState.save_settings()


func set_fullscreen(enabled: bool) -> void:
	GameState.settings.fullscreen = enabled
	GameState.apply_settings()
	GameState.save_settings()


func set_text_speed(index: int) -> void:
	GameState.settings.text_speed = index
	GameState.save_settings()


func manual_save() -> void:
	if GameState.save_game():
		show_toast("Journal saved")


func show_toast(message: String) -> void:
	toast_label.text = message
	toast_label.visible = true
	var timer := get_tree().create_timer(1.8)
	timer.timeout.connect(func(): toast_label.visible = false)


func request_exit() -> void:
	get_tree().quit()


func get_location(id: String) -> Dictionary:
	for location in locations:
		if location.id == id:
			return location
	return locations[0] if not locations.is_empty() else {}


func friendly_time(value: String) -> String:
	return value.replace("T", " ").trim_suffix("Z")


func centered_column(width: float, top_margin: float) -> VBoxContainer:
	var margin := MarginContainer.new()
	margin.position = Vector2((1152.0 - width) / 2.0, top_margin)
	margin.size = Vector2(width, 648.0 - top_margin * 1.45)
	screen_root.add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 16)
	margin.add_child(column)
	return column


func section_title(title: String, subtitle: String) -> VBoxContainer:
	var group := VBoxContainer.new()
	group.add_theme_constant_override("separation", 5)
	group.add_child(label(title, 38, INK))
	group.add_child(label(subtitle, 16, MUTED))
	return group


func label(text_value: String, size_value: int, color: Color) -> Label:
	var node := Label.new()
	node.text = text_value
	node.add_theme_font_size_override("font_size", size_value)
	node.add_theme_color_override("font_color", color)
	return node


func species_emoji_layers(emojis: Array) -> Array:
	var layers: Array = []
	var positions := {
		1: [[0.50, 0.50]],
		2: [[0.40, 0.52], [0.62, 0.44]],
		3: [[0.34, 0.58], [0.62, 0.42], [0.69, 0.68]],
		4: [[0.30, 0.42], [0.66, 0.38], [0.36, 0.70], [0.70, 0.68]],
	}
	var layout: Array = positions.get(mini(emojis.size(), 4), positions[1])
	for index in mini(emojis.size(), 4):
		layers.append({
			"emoji": str(emojis[index]),
			"position": layout[index],
			"size": 94 if emojis.size() == 1 else 68,
			"rotation": -5.0 if index % 2 == 0 else 5.0,
		})
	return layers


func emoji_label(text_value: String, size_value: int) -> Label:
	var node := Label.new()
	node.text = text_value
	node.add_theme_font_override("font", emoji_font)
	node.add_theme_font_size_override("font_size", size_value)
	node.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	node.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return node


func emoji_composite(layers: Array, canvas_size: Vector2, scale_factor: float = 1.0, opacity: float = 1.0) -> Control:
	var canvas := Control.new()
	canvas.custom_minimum_size = canvas_size
	canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for layer in layers:
		var item := emoji_label(str(layer.get("emoji", "✨")), int(float(layer.get("size", 48)) * scale_factor))
		var normalized: Array = layer.get("position", [0.5, 0.5])
		var box_size := Vector2(150, 150) * scale_factor
		item.size = box_size
		item.position = Vector2(float(normalized[0]) * canvas_size.x, float(normalized[1]) * canvas_size.y) - box_size * 0.5
		item.pivot_offset = box_size * 0.5
		item.rotation = deg_to_rad(float(layer.get("rotation", 0.0)))
		item.modulate.a = opacity
		canvas.add_child(item)
	return canvas


func menu_button(text_value: String, action: Callable, tooltip: String) -> Button:
	var node := Button.new()
	node.text = text_value
	node.tooltip_text = tooltip
	node.custom_minimum_size = Vector2(0, 54)
	node.alignment = HORIZONTAL_ALIGNMENT_LEFT
	node.add_theme_font_size_override("font_size", 18)
	node.add_theme_color_override("font_color", INK)
	node.add_theme_color_override("font_hover_color", ACCENT)
	node.add_theme_color_override("font_disabled_color", Color("#5f675f"))
	node.add_theme_stylebox_override("normal", box(Color.TRANSPARENT, 7, 0))
	node.add_theme_stylebox_override("hover", box(PANEL_LIGHT, 7, 1, GREEN))
	node.add_theme_stylebox_override("pressed", box(Color("#334035"), 7, 1, ACCENT))
	node.add_theme_stylebox_override("disabled", box(Color.TRANSPARENT, 7, 0))
	node.pressed.connect(action)
	return node


func small_button(text_value: String, action: Callable, accent: bool = false) -> Button:
	var node := Button.new()
	node.text = text_value
	node.custom_minimum_size = Vector2(150, 46)
	node.add_theme_font_size_override("font_size", 15)
	node.add_theme_color_override("font_color", BG if accent else INK)
	node.add_theme_color_override("font_hover_color", BG if accent else ACCENT)
	var base_color := ACCENT if accent else PANEL_LIGHT
	node.add_theme_stylebox_override("normal", box(base_color, 7, 1, ACCENT if accent else GREEN))
	node.add_theme_stylebox_override("hover", box(base_color.lightened(0.12), 7, 2, INK if accent else ACCENT))
	node.add_theme_stylebox_override("pressed", box(base_color.darkened(0.12), 7, 2, ACCENT))
	node.pressed.connect(action)
	return node


func back_button(action: Callable) -> Button:
	return small_button("←  BACK", action)


func box(color: Color, radius: int, border_width: int, border_color: Color = Color.TRANSPARENT) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	style.border_width_left = border_width
	style.border_width_right = border_width
	style.border_width_top = border_width
	style.border_width_bottom = border_width
	style.border_color = border_color
	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	return style


func compact_box(color: Color, radius: int, border_width: int, border_color: Color = Color.TRANSPARENT) -> StyleBoxFlat:
	var style := box(color, radius, border_width, border_color)
	style.content_margin_left = 2
	style.content_margin_right = 2
	style.content_margin_top = 2
	style.content_margin_bottom = 2
	return style
