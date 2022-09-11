extends Node

const PATH = "user://"
const animation_time : float = 0.4
const degrees_by_rotation_frame : int = 3
const speed_up_distance : int = 500
const speed_up_increment : int = 250
const faded_opacity : float = 0.85

const starting_life : int = 20
const critical_life_total : int = 9
const starting_hand_size : int = 5
const main_deck_max : int = 40
const grave_deck_max : int = 15
const MAX_COPIES : int = 9
const max_map_icons : int = 9
const max_enemies_to_defeat : int = 3
const starting_floor : int = 1
const max_floors : int = 6

const version_number : float = 0.23
const auto_session_log_clear : bool = false
const debugging_enabled : bool = true

const starting_player : int = 0
const always_win : bool = false
const banlist_enabled : bool = true

const resolution : Vector2 = Vector2(1920, 1080)
const resolution_margins : Vector2 = resolution / 2
const card_rect : Vector2 = Vector2(200, 300)
const highlight_card_rect : Vector2 = 2 * card_rect
const card_in_hand_roof : int = -190
const map_icon_margin : int = 150
const reveal_x_margin : int = 200
const reveal_y_margin : int = 310
const starting_reveal_y : int = -120
const hand_position = Vector2(0, 190)
const voided_location = Vector2 (-540, -300)
const minumum_volume : int = -30
const zero_volume : int = -80
const shorten_name_max_length : int = 15
const gain_control_margin : int = 300 + 2 * 60

const gate_open_label : String = "Gate (OPEN)"

const number_shortcuts : Array = ["1", "2", "3", "4", "5"]
const up_keys : Array = ["W", "Up"]
const down_keys : Array = ["S", "Down"]
const left_keys : Array = ["A", "Left"]
const right_keys : Array = ["D", "Right"]
const arrow_shortcuts : Array = up_keys + down_keys + left_keys + right_keys
const toggle_settings_key : String = "Escape"

const gameplay_shortcuts : Dictionary = {
	"A" : "activate",
	"C" : "cancel",
	"M" : "deck",
	"G" : "graveyard",
	"P" : "phase_procedure",
	toggle_settings_key : "settings",
	"Enter" : "surrender",
	"S" : "white_flag"
}

const setting_shortcuts : Dictionary = {
	"speed_up" : "Right",
	"speed_down" : "Left",
	"volume_up" : "Up",
	"volume_down" : "Down",
	"enable_display_spin" : "S",
	"AI_opponent" : "A",
	"autoplay" : "P",
	"auto_confirm" : "C",
	"quit" : "Q",
}

const card_collection_shortcuts : Dictionary = {
	"Shift" : "search"
}

const empty_effect : Dictionary = {
	"id" : "Null",
	"superclass" : "Default",
	"subclass" : "Default",
	"source" : ["Null"],
	"amount" : 1,
	"constant" : 0,
	"tag" : "Null",
	"target" : "self",
	"player" : "self",
	"condition" : "Null",
	"restriction" : "Null",
	"location" : "Default",
	"timing" : "next_turn",
	"relocation" : "Default",
	"instant_position" : "Null",
	"column" : [0],
	"reference" : "Null",
	"reference_target" : "self",
	"reference_tag" : "Null",
	"reference_card" : null,
	"negate_effects" : "Null",
	"power_gain" : 0,
	"reduction" : 0,
	"multiplier" : 1.0,
	"wanted_effect" : {"Default" : null}
}

const empty_card_collection : Dictionary = {
	"All" : [],
	"Main" : [],
	"Grave" : []
}

const AI_attack_target_filters : Array = [
	{
		"type" : "Graveyard",
		"boolean" : false
	},
	{
		"type" : "Field",
		"type_id" : "attacked",
		"boolean" : false
	},
	{
		"type" : "Field"
	},
	{
		"type" : "Detach"
	}
]

const AI_destroy_target_filters : Array = [
	{
		"type" : "Field"
	},
	{
		"type" : "Detach"
	}
]

const AI_play_filters : Array = [
	{
		"type" : "Field"
	},
	{
		"type" : "Hand",
		"boolean" : false
	}
]

const AI_field_material_restrictions : Array = [
	{
		"type" : "Death",
		"boolean" : false
	},
]

const AI_field_material_filters : Array = [
	{
		"type" : "Graveyard"
	},
	{
		"type" : "Field",
		"type_id" : "Negate",
		"boolean" : false
	},
	{
		"type" : "Field",
		"boolean" : false
	}
]

const AI_hand_material_filters : Array = [
	{
		"type" : "Graveyard"
	}
]

const AI_void_enemy_grave_filters : Array = [
	{
		"type" : "Graveyard"
	},
	{
		"type" : "Void"
	}
]

const AI_attacker_reverser_filters : Array = [
	{
		"type" : "Once",
		"type_id" : "reverse_attack"
	}
]

const AI_material_filters : Array = [
	{
		"type" : "Once",
		"boolean" : false
	}
]

var all_cards : Array
var legal_cards : Array
var main_cards : Array
var grave_cards : Array
var card_mouse_follows : int
var selected_card : Card
var current_scene : String

func _ready():
	var empty_session_log : Dictionary = {"version_number" : version_number}
	if get_session_log().version_number != version_number or auto_session_log_clear:
		if auto_session_log_clear:
			empty_session_log["master_volume"] = minumum_volume
		set_session_log(empty_session_log)
		set_roguelike_log()
	initialize_card_database()
	initialize_debugging()

func get_all_cards():
	return copy_array(all_cards)

func initialize_card_database():
	all_cards = get_database("AllCards")
	legal_cards = copy_array(all_cards)
	if banlist_enabled:
		for card in get_database("Banlist"):
			legal_cards.erase(card)
	for card in legal_cards:
		if is_fusion_name(card):
			grave_cards.append(card)
			continue
		main_cards.append(card)

func initialize_debugging():
	if !debugging_enabled:
		return
	debug_enemy_formulas()
	debug_secret_packs()

func debug_enemy_formulas():
	var formula : Dictionary
	for floor_number in range(1, max_floors + 1):
		for enemy in get_enemy_names(floor_number):
			formula = get_enemy_formula(repair_icon_name(enemy).resource)
			for card in copy_dictionary(formula.Main, formula.Grave):
				if !all_cards.has(card):
					debug("Card name '" + card + "' in enemy '" + enemy + "' not recognized.")

func debug_secret_packs():
	var current_line : int = 23
	for card in get_data("SecretPackCards"):
		if !all_cards.has(card):
			debug("Unknown card name '" + card + "' in 'SecretPackCards.gd' line '" + current_line + "'.")
		current_line += 1

func get_tween_values(do_make_visible: bool, target_zone, starting_opacity : float = 0, ending_opacity : float = 1):
	var current_opacity : float = target_zone.modulate.a
	if !do_make_visible:
		ending_opacity = starting_opacity
		starting_opacity = current_opacity
	elif current_opacity > 0:
		starting_opacity = current_opacity
	
	return["modulate:a", starting_opacity, ending_opacity, animation_time]

func get_tween_values_faded(do_make_faded : bool, target_zone):
	return get_tween_values(do_make_faded, target_zone, faded_opacity, 1)

func get_decklist(player_number : int = 1, slot : int = 0):
	slot = get_default_slot(slot, player_number)
	var data : Dictionary = data_reader("read", get_deck_file_name(player_number, slot))
	if data.status == "Success":
		return repair_decklist(data.data)
	return {
		"Main" : [],
		"Grave" : []
	}

func gameplay_decklist(player_number : int, random : RandomNumberGenerator):
	var decklist : Dictionary = get_decklist(player_number)
	if decklist.Main == [] and decklist.Grave == []:
		decklist = random_decklist(random)
	return decklist

func random_decklist(random : RandomNumberGenerator):
	var secret_packs : Dictionary = build_secret_packs()
	var opened_secret_packs : Dictionary = {
		"Main" : [],
		"Grave" : []
	}
	var decklist : Dictionary
	var random_pack : Array
	var subdeck_id : String
	for pack in range(3):
		random_pack = random_key(secret_packs, random)
		for card_name in random_pack:
			match is_fusion_name(card_name):
				true:
					subdeck_id = "Grave"
				false:
					subdeck_id = "Main"
			if !opened_secret_packs[subdeck_id].has(card_name):
				opened_secret_packs[subdeck_id].append(card_name)
	decklist = {
		"Main" : fill_subdeck("Main", opened_secret_packs, random),
		 "Grave" : fill_subdeck("Grave", opened_secret_packs, random)
	}
	return alphabetize_decklist(decklist)

func fill_subdeck(subdeck_id : String, opened_secret_packs : Dictionary,
random : RandomNumberGenerator):
	var decklist : Dictionary
	var deck_size : int
	var card_pool : Array
	var random_card : String
	var source : Array
	var secret_pack_pool : Array = opened_secret_packs[subdeck_id]
	match subdeck_id:
		"Main":
			deck_size = main_deck_max
			card_pool = main_cards
		"Grave":
			deck_size = grave_deck_max
			card_pool = grave_cards
	card_pool = copy_array(card_pool)
	for i in range(deck_size):
		if card_pool.size() == 0:
			break
		match secret_pack_pool.size() > 0 and random_chance(2, 3, random):
			true:
				source = secret_pack_pool
			false:
				source = card_pool
		random_card = random_item(source, random)
		match decklist.has(random_card):
			true:
				decklist[random_card] += 1
			false:
				decklist[random_card] = 1
		if decklist[random_card] == MAX_COPIES or subdeck_id == "Grave":
			card_pool.erase(random_card)
			secret_pack_pool.erase(random_card)
	return convert_decklist(decklist)

func repair_decklist(decklist : Dictionary):
	force_key(decklist, "Main", [])
	force_key(decklist, "Grave", [])
	return decklist

func alphabetize_decklist(decklist : Dictionary):
	var scrutinization_mode : String = "decklist"
	return {
		"Main" : scrutinize_deck(decklist.Main, main_cards, scrutinization_mode),
		"Grave" : scrutinize_deck(decklist.Grave, grave_cards, scrutinization_mode)
	}

func build_decklist(main_deck : Array, grave_deck : Array):
	return {
		"Main" : main_deck,
		"Grave" : grave_deck
	}

func set_decklist(decklist : Dictionary, player_number : int = 1, \
slot : int = 0, game_mode : String = get_game_mode()):
	var session_log : Dictionary = get_session_log()
	slot = get_default_slot(slot, player_number)
	data_reader("write", get_deck_file_name(player_number, slot, game_mode), decklist)
	session_log = set_deck_slot(slot, player_number, game_mode, session_log)
	set_session_log(session_log)

func set_deck_slot(slot : int = 1, player_number = 1, game_mode : String = "Default", \
session_log : Dictionary = get_session_log()):
	session_log.deckslots[get_player_id(player_number, game_mode)] = slot
	return session_log

func get_game_mode():
	return get_session_log().game_mode

func get_default_slot(slot : int, player_number : int):
	if slot == 0:
		return get_session_log().deckslots[get_player_id(player_number)]
	return slot

func get_player_id(player_number : int, game_mode : String = "Default"):
	if game_mode == "Default":
		game_mode = get_session_log().game_mode
	return convert_to_string(["player_", player_number, "_", game_mode])

func get_deck_file_name(player_number : int, slot : int, game_mode : String = "Default"):
	if game_mode == "Default":
		game_mode = get_session_log().game_mode
	return convert_to_string(["decklist_player_", player_number, "_game_mode_", game_mode, "_slot_", slot])

func convert_to_string(items : Array):
	var string : String
	for item in items:
		string = string + str(item)
	return string

func data_reader(reader_type : String, file_name : String,  input : Dictionary = {}, \
	file_path : String = PATH):
	var reader : File = File.new()
	var file_ending : String = ".gd"
	if file_path == PATH:
		file_ending = ".save"
	var file = file_path + file_name + file_ending
	var status : String = "Failure"
	var return_data : Dictionary
	if file_ending == ".gd":
		return_data = load(file).info()
		status = "Success"
	elif reader_type == "read" and reader.file_exists(file):
		reader.open(file, File.READ)
		return_data = reader.get_var()
		status = "Success"
	elif reader_type == "write":
		reader.open(file, File.WRITE)
		reader.store_var(input)
	reader.close()
	return {
		"status" : status,
		"data" : return_data
	}

func mouse_state_check(card_id : int):
	if card_mouse_follows == 0 or card_mouse_follows == card_id:
		card_mouse_follows = card_id
		return true
	return false

func reset_mouse_state():
	card_mouse_follows = 0

func get_card_effects(card_name : String):
	return repair_card_effects(get_data(card_name, "res://Data/Cards/"))

func get_data(file_name : String, path : String = "res://Data/"):
	return data_reader("read", file_name, {}, path).data

func repair_card_effects(effects : Dictionary):
	if effects.has("Once"):
		force_key(effects.Once, "active", true)
	return effects

func x_axis_to_zone_number(x_axis : int):
	if x_axis < -360:
		return 1
	elif x_axis < -120:
		return 2
	elif x_axis < 120:
		return 3
	elif x_axis <= 360:
		return 4
	elif x_axis > 360:
		return 5

func get_log(log_id : String):
	var dictionary : Dictionary
	var data = data_reader("read", log_id)
	if data.status == "Success":
		dictionary = data.data
	dictionary = repair_log(log_id, dictionary)
	return dictionary

func set_log(log_id : String, dictionary : Dictionary):
	data_reader("write", log_id, dictionary)

func get_session_log():
	return get_log("session_log")

func repair_log(log_id : String, dictionary : Dictionary):
	match log_id:
		"session_log":
			dictionary = repair_session_log(dictionary)
		"roguelike_log":
			dictionary = repair_roguelike_log(dictionary)
	return dictionary

func get_roguelike_log():
	return get_log("roguelike_log")

func set_session_log(dictionary : Dictionary = {}):
	set_log("session_log", dictionary)

func set_roguelike_log(dictionary : Dictionary = {}):
	set_log("roguelike_log", dictionary)

func repair_session_log(session_log : Dictionary):
	force_key(session_log, "deckslots", {
		"player_1_Roguelike" : 1,
		"player_1_Sandbox" : 1,
		"player_2_Sandbox" : 1
	})
	force_key(session_log, "master_volume", 0)
	force_key(session_log, "display_spin_enabled", false)
	force_key(session_log, "AI_enabled", false)
	force_key(session_log, "game_speed", 40)
	force_key(session_log, "auto_play", false)
	force_key(session_log, "auto_confirm", false)
	force_key(session_log, "game_mode", "Roguelike")
	force_key(session_log, "version_number", 0.0)
	
	return session_log

func repair_roguelike_log(roguelike_log : Dictionary):
	force_key(roguelike_log, "floor_number", 0)
	force_key(roguelike_log, "final_floor", 6)
	force_key(roguelike_log, "background_sprite", "")
	force_key(roguelike_log, "background_y_position", 0)
	force_key(roguelike_log, "card_collection", empty_card_collection())
	force_key(roguelike_log, "locked_cards", get_legal_cards())
	force_key(roguelike_log, "task_pile", [])
	force_key(roguelike_log, "reveal_pile", [])
	force_key(roguelike_log, "secret_pack_cards", get_secret_packs())
	force_key(roguelike_log, "secret_packs", build_secret_packs())
	force_key(roguelike_log, "opened_secret_packs", [])
	force_key(roguelike_log, "map_icons", [])
	force_key(roguelike_log, "gameplay_winner", 0)
	force_key(roguelike_log, "current_enemy", 0)
	force_key(roguelike_log, "rewarded_amounts", [1])
	return roguelike_log

func get_secret_packs():
	return get_data("SecretPackCards")

func build_secret_packs():
	var secret_pack_cards : Dictionary = get_secret_packs()
	var secret_packs : Dictionary
	for card_name in secret_pack_cards:
		for secret_pack in secret_pack_cards[card_name]:
			match secret_packs.has(secret_pack):
				true:
					secret_packs[secret_pack].append(card_name)
				false:
					secret_packs[secret_pack] = [card_name]
	return secret_packs

func generate_icon(id : String, background_sprite : String, random : RandomNumberGenerator,
source : Dictionary = {"Default" : null}):
	var icon : Dictionary = {
		"id" : id,
		"instance_id" : random.randi(),
		"position" : Vector2(0, 0),
		"background_sprite" : background_sprite
	}
	if is_default(source):
		source = map_icon_source(id)
	icon = copy_dictionary(source, icon)
	return icon

func map_icon_source(id : String):
	var source : Dictionary
	match id:
		"Gate":
			source = {
				"name" : {
					"event" : "Gate"
				},
				"enemies_to_defeat" : max_enemies_to_defeat
			}
	return source

func generate_enemies(amount : int, floor_number : int, \
background_sprite : String, random : RandomNumberGenerator):
	var enemies : Array
	var enemy_names : Array = copy_array(get_enemy_names(floor_number))
	var enemy_name : Dictionary
	var source : Dictionary
	if floor_number == max_floors:
		amount = 1
	for i in range(amount):
		if enemy_names.size() == 0:
			break
		enemy_name = repair_icon_name(random_item(enemy_names, random))
		source = enemy_source(enemy_name, floor_number, random)
		enemies.append(generate_icon("Enemy", background_sprite, random, source))
		enemy_names.erase(enemy_name)
	return enemies

func enemy_source(enemy_name : Dictionary, floor_number : int, random : RandomNumberGenerator):
	return {
		"name" : enemy_name,
		"decklist" : generate_enemy_decklist(enemy_name.resource, floor_number, random)
	}

func repair_icon_name(enemy_name : Dictionary):
	force_key(enemy_name, "event", "Null")
	force_key(enemy_name, "resource", enemy_name.event)
	force_key(enemy_name, "highlight", enemy_name.resource)
	return enemy_name

func generate_enemy_decklist(enemy_name : String, floor_number : int, random : RandomNumberGenerator):
	var formula : Dictionary = get_enemy_formula(enemy_name)
	var main_formula = formula.Main
	var grave_formula = formula.Grave
	var deck_size = get_enemy_deck_size(floor_number)
	return {
			"Main" : generate_decklist(deck_size.Main, main_formula, random),
			"Grave" : generate_decklist(deck_size.Grave, grave_formula, random)
		}

func get_enemy_formula(enemy_name : String):
	return repair_formula(get_data(enemy_name, "res://Data/Enemies/"))

func repair_formula(formula : Dictionary):
	force_key(formula, "Main", {})
	force_key(formula, "Grave", {})
	return formula

func get_enemy_deck_size(floor_number : int):
	return {
		"Main" : get_deck_size(4, 6, floor_number, 0, main_deck_max),
		"Grave" : get_deck_size(0, 3, floor_number, 1, grave_deck_max)
	}

func get_deck_size(starting_size : int, increment : int, floor_number : int, \
skip_floors : int, max_size : int):
	return min_value(max_value(starting_size + increment * (floor_number - skip_floors), \
	max_size), starting_size)

func get_enemy_names(floor_number : int):
	return get_database("EnemyNames/Floor" + str(floor_number))

func get_database(id : String):
	return get_data(id).database

func generate_decklist(number_of_cards : int, card_pool_formula : Dictionary, \
random : RandomNumberGenerator):
	var decklist : Dictionary = raw_decklist(card_pool_formula)
	var card_pool : Array = convert_card_pool_formula(card_pool_formula)
	var card_name : String
	for card in range(number_of_cards - decklist.size()):
		if card_pool.size() == 0:
			break
		card_name = random_item(card_pool, random)
		decklist[card_name] += 1
		if decklist[card_name] == MAX_COPIES:
			for i in range(card_pool_formula[card_name]):
				card_pool.erase(card_name)
	return convert_decklist(decklist)

func convert_card_pool_formula(formula : Dictionary):
	var card_pool : Array
	for card_name in formula:
		for i in range (formula[card_name] - 1):
			card_pool.append(card_name)
	return card_pool

func raw_decklist(formula : Dictionary):
	var decklist : Dictionary
	for card_name in formula:
		decklist[card_name] = 1
	return decklist

func convert_decklist(decklist : Dictionary):
	var converted_decklist : Array
	for card_name in decklist:
		if decklist[card_name] > 0:
			converted_decklist.append([card_name, decklist[card_name]])
	return converted_decklist

func position_map_icons(original_map_icons : Array, avoided_points : Array, \
random : RandomNumberGenerator, repetitions : int = 0):
	var map_icons : Array = copy_array(original_map_icons)
	var positions : Array
	var local_repetitions : int
	for icon in map_icons:
		while position_overlaps(icon.position, positions, avoided_points, Vector2(map_icon_margin, map_icon_margin)):
			local_repetitions +=1
			if local_repetitions >= 100:
				local_repetitions = 0
				repetitions += 1
				if repetitions > 100:
					for unpositioned_icon in map_icons:
						original_map_icons.erase(icon)
						if unpositioned_icon.id != "Gate" and unpositioned_icon.position == Vector2(0, 0):
							original_map_icons.erase(unpositioned_icon)
					repetitions = 0
				return position_map_icons(original_map_icons, avoided_points, random, repetitions)
			icon.position = Vector2(
			random.randi_range(map_icon_limit(-resolution_margins.x), map_icon_limit(resolution_margins.x)),
			random.randi_range(map_icon_limit(-resolution_margins.y), map_icon_limit(resolution_margins.y)))
		positions.append(icon.position)
		local_repetitions = 0
	return map_icons

func shorten_array(array : Array, max_items : int):
	var shorten_array : Array
	for item in array:
		shorten_array.append(item)
		if shorten_array.size() >= max_items:
			break
	return shorten_array

func map_icon_limit(definite_limit : float):
	match definite_limit < 0:
		true:
			return definite_limit + map_icon_margin
		false:
			return definite_limit - map_icon_margin

func position_overlaps(position : Vector2, avoided_points : Array, \
avoided_planes : Array, margins : Vector2):
	for point in avoided_points:
		if position.distance_to(point) < margins.x + margins.y:
			return true
	for plane in avoided_planes:
		if planes_collide(position, margins, \
		plane.position, plane.margins):
			return true
	return false

func planes_collide(plane_a_position : Vector2, plane_a_margins : Vector2, \
plane_b_position : Vector2, plane_b_margins : Vector2):
	for coordinate in coordinates_2d():
		if !distance(plane_a_position[coordinate], plane_b_position[coordinate]) \
		< plane_a_margins[coordinate] + plane_b_margins[coordinate]:
			return false
	return true

func plane(element : Control):
	return {
		"position" : element.rect_position,
		"margins" : Vector2(element.max_x, element.max_y) / 2
	}

func coordinates_2d():
	return ["x", "y"]

func distance(a : float, b : float):
	return abs(a - b)

func get_roguelike_background(floor_number : int):
	match floor_number:
		1:
			return "Forest"
		2:
			return "Forest"
		3:
			return "Forest"
		4:
			return "CandyLand"
		5:
			return "CandyLand"
		6:
			return "CandyLand"

func set_roguelike_gameplay_winner(winner_player_number : int):
	var roguelike_log : Dictionary = get_roguelike_log()
	roguelike_log.gameplay_winner = winner_player_number
	set_roguelike_log(roguelike_log)

func force_key(dictionary : Dictionary, key : String, default_value):
	var has_key : bool
	for existing_key in dictionary:
		if existing_key == key:
			has_key = true
			break
	if !has_key:
		dictionary[key] = default_value

func copy_array(source : Array, array : Array = []):
	for item in source:
		array.append(item)
	return array

func scrape_array(source : Array, amount : int, array : Array = []):
	for i in range(amount):
		if source.size() <= i:
			break
		array.append(source[i])
	return array

func material_check(card : Card, source : Array, conditions : Dictionary):
	return System.get_cards_with_effect(System.get_tagged_cards(source, conditions.tag, \
	conditions.condition, card.card_name, conditions.wanted_effect, true), conditions.wanted_effect).size() \
	>= conditions.amount

func filter_duplicate_cards(source : Array, previous_targets : Array, filter_mode : bool = false):
	var filtered_array : Array
	for card in source:
		var is_duplicate : bool
		for target in previous_targets:
			if card.card_name == target.card_name:
				is_duplicate = true
				break
		if is_duplicate == filter_mode:
			filtered_array.append(card)
	return filtered_array

func filter_absolute(source : Array, tag : String, filter_mode : bool = false):
	var filtered_array : Array
	for card in source:
		if (card.card_name == tag or tag == "Null") == filter_mode :
			filtered_array.append(card)
	return filtered_array

func filter_same_instance(source : Array, original_card : Card, filter_mode : bool = false):
	var filtered_array : Array
	for card in source:
		if (card.instance_id == original_card.instance_id) == filter_mode:
			filtered_array.append(card)
	return filtered_array	
	
func filter_non_duplicate_cards(source : Array, previous_targets : String):
	var filtered_array : Array

func filter_fusion(source : Array, filter_mode : bool = false):
	var filtered_array : Array
	for card in source:
		var is_fusion : bool
		for key in card.effects:
			if key == "ContactFusion":
				is_fusion = true
				break
		if is_fusion == filter_mode:
			filtered_array.append(card)
	return filtered_array

func is_fusion(effects : Dictionary):
	return effects.has("ContactFusion")

func is_fusion_card(card : Card):
	return is_fusion(card.effects)

func is_fusion_name(card_name : String):
	return is_fusion(get_card_effects(card_name))

func get_tagged_cards(source : Array, tag : String, condition = "Null", \
original_card_name : String = "Null", wanted_effect : Dictionary = {}, \
conditions_check : bool = false):
	var tagged_cards : Array
	var local_tag : String
	for card in get_cards_with_effect(source, wanted_effect):
		if tag_check(card, tag):
			tagged_cards.append(card)
	match condition:
		"different_names":
			if conditions_check:
				tagged_cards = get_single_cards(tagged_cards)
		"different_name":
			tagged_cards = filter_absolute(tagged_cards, original_card_name)
		"absolute":
			match original_card_name == "Null":
				true:
					local_tag = tag
				false:
					local_tag = original_card_name
			tagged_cards = filter_absolute(tagged_cards, local_tag, true)
		"fusion":
			tagged_cards = filter_fusion(tagged_cards, true)
		"non_fusion":
			tagged_cards = filter_fusion(tagged_cards)
		"attacked":
			tagged_cards = filter_attacked(tagged_cards, true)
		"not_attacked":
			tagged_cards = filter_attacked(tagged_cards)
		"round_on_field":
			tagged_cards = filter_round_on_field(tagged_cards, true)
		"transformed":
			tagged_cards = filter_transformed(tagged_cards, true)
		"non_transformed":
			tagged_cards = filter_transformed(tagged_cards)
		"2_attached":
			tagged_cards = filter_by_attachment_amount(tagged_cards, 2, true)
	return tagged_cards

func get_card_names(source : Array):
	var filtered_array : Array
	for card in source:
		filtered_array.append(card.card_name)
	return filtered_array

func get_reveal_pile(source : Array):
	var filtered_array : Array
	for card in source:
		filtered_array.append([card.card_name, card.power])
	return filtered_array

func get_single_cards(source : Array):
	return find_cards_by_name(source, get_singles(source))

func find_cards_by_name(source : Array, database : Array):
	var filtered_array : Array
	for card in source:
		var card_name : String = card.card_name
		if database.has(card_name):
			filtered_array.append(card)
			database.erase(card_name)
			continue
	return filtered_array

func find_cards(source : Array, database : Array):
	var filtered_array: Array
	for card in source:
		if database.has(card):
			filtered_array.append(card)
			database.erase(card)
			continue
	return filtered_array

func get_singles(source : Array, detect_transformed : bool = false):
	var singles : Array
	var card_name : String
	for card in source:
		card_name = card.card_name
		if detect_transformed and card.second_name != "Null":
			card_name = card.second_name
		if !singles.has(card_name):
			singles.append(card_name)
	return singles

func get_pairs(source : Array, pair_size : int):
	var singles : Array
	var pairs : Array
	for card in get_singles(source):
		singles.append([card, 0])
	for card in source:
		var card_name : String = card.card_name
		for other_card in singles:
			if card.card_name == other_card[0]:
				other_card[1] += 1
				continue
	for card in singles:
		if card[1] >= pair_size:
			pairs.append(card[0])
	return pairs

func get_cards(tag : String, own_zone : Array, enemy_zone : Array, target : String, 
condition : String = "Null", absolute_name : String = "Null"):
	var cards : Array
	if absolute_name != "Null":
		tag = absolute_name
		condition = "absolute" 
	if targets_self(target):
		cards = copy_array(get_tagged_cards(own_zone, tag, condition))
	if targets_enemy(target):
		cards = copy_array(get_tagged_cards(enemy_zone, tag, condition), cards)
	return cards

func database_item(database : Array, random : RandomNumberGenerator, wanted_effect : Dictionary, \
unwanted_name : String = "Null"):
	var card_name : String = unwanted_name
	var random_card_name : String
	while card_name == unwanted_name:
		if database.size() == 0:
			return "Null"
		random_card_name = System.random_item(database, random)
		database.erase(random_card_name)
		card_name = random_card_name
		if card_name == "Null" or !System.wanted_effect_check(System.get_card_effects( \
		card_name), wanted_effect):
			card_name = unwanted_name
	return card_name

func targets_self(target : String):
	return target == "self" or target == "both"

func targets_enemy(target : String):
	return target == "enemy" or target == "both"

func targets(target : String, perspective : String, opposite : bool = false):
	if opposite:
		perspective = value_switch(perspective, ["self", "enemy"])
	match perspective:
		"self":
			return targets_self(target)
		"enemy":
			return targets_enemy(target)
				
func value_switch(value : String, source : Array):
	var index : int = source.find(value) + 1
	if index >= source.size():
		index = 0
	return source[index]
	
func get_effect_by_type(effects : Dictionary, wanted_type : String, wanted_id : String = "Null", \
wanted_spec : String = "Null", wanted_spec_value : String = "Null"):
	for effect_type in effects:
		if effect_type == wanted_type and (wanted_id == "Null" or repair_effect(effects[wanted_type]).id \
		== wanted_id) and (wanted_spec == "Null" or effects[wanted_type].has(wanted_spec)) and \
		(wanted_spec_value == "Null" or str(effects[wanted_type][wanted_spec]) == wanted_spec_value):
			return true
	return false

func has_effect(card : Card, wanted_type : String, wanted_id : String = "Null", wanted_spec : String = "Null", \
wanted_spec_value : String = "Null"):
	if card == null:
		return false
	return get_effect_by_type(card.effects, wanted_type, wanted_id, wanted_spec, wanted_spec_value)
	
func has_effect_plus_attached(original_card : Card, wanted_type : String, wanted_id : String = "Null", \
wanted_spec : String = "Null", wanted_spec_value : String = "Null"):
	for card in get_card_plus_attached(original_card):
		if has_effect(card, wanted_type, wanted_id, wanted_spec, wanted_spec_value):
			return true
	return false

func has_fusion_condition(card : Card, wanted_zone : String, wanted_spec : String, wanted_spec_value : String = "Null"):
	var effect : Dictionary
	var condition = get_fusion_condition(card, wanted_zone, wanted_spec, "Null")
	if str(condition) != "Null" and (wanted_spec_value == "Null" or condition == wanted_spec_value):
		return true
	return false

func get_fusion_condition(card : Card, wanted_zone : String, wanted_spec : String, default_value):
	var effect : Dictionary
	if card != null and has_effect(card, "ContactFusion", "Null", wanted_zone):
		effect = card.effects.ContactFusion[wanted_zone]
		if effect.has(wanted_spec):
			return effect[wanted_spec]
	return default_value

func has_fusion_zone(card : Card, wanted_zone : String):
	return is_fusion_card(card) and card.effects.ContactFusion.has(wanted_zone)

func spend_play(card : Card, plays_left : Array):
	var index : int = get_corresponding_tag(card, plays_left)
	if index == -1:
		return plays_left
	match plays_left[index].amount == 1:
		true:
			plays_left.remove(index)
		false:
			plays_left[index].amount -= 1
	return plays_left

func has_corresponding_tag(card : Card, database : Array):
	return get_corresponding_tag(card, database) > -1

func get_corresponding_tag(card : Card, database : Array):
	var index_counter : int
	var tag_found : bool
	for dictionary in database:
		if get_tagged_cards([card], dictionary.tag, dictionary.condition, \
		dictionary.absolute_name).size() > 0:
			tag_found = true
			break
		index_counter += 1
	if tag_found:
		return index_counter
	return -1

func convert_dictionaries_database(source : Array):
	var database : Array
	for dictionary in source:
		database.append(dictionary.tag)
	return database

func convert_additional_play(card : Card, effect : Dictionary):
	return {
		"tag" : effect.tag,
		"condition" : effect.condition,
		"amount" : effect.amount,
		"absolute_name" : card.card_name
	}

func tag_check(card : Card, tag : String, absolute : bool = false):
	var card_name : String
	if card == null:
		return true
	card_name = card.card_name
	if absolute:
		if card_name == tag:
			return true
		return false
	if match_tag(card_name, tag):
		return true
	return false

func match_tag(string : String, tag : String, case_sensitive : bool = true):
	if !case_sensitive:
		string = string.to_lower()
		tag = tag.to_lower()
	return tag == "Null" or string.find(tag) > -1

func card_exists(card_name : String):
	return all_cards.has(card_name)

func extract_tags(string : String):
	var start_index : int
	var end_index : int
	var tags : Array
	var tag : String
	for symbol in string:
		if symbol == " " or end_index + 1 == string.length():
			tag = copy_tag(string, start_index, end_index)
			if tag != "Null":
				tags.append(tag)
			start_index = end_index + 1
		end_index += 1
	return tags

func copy_tag(string : String, start_index : int, end_index : int):
	var tag : String
	var current_index : int = -1
	for symbol in string:
		current_index += 1
		if current_index < start_index:
			continue
		if symbol != " ":
			tag += symbol
		if current_index == end_index:
			break
	match tag.length() > 0:
		true:
			return tag
		false:
			return "Null"

func filter_search_result(text_zones : Array, filter_tags : Array):
	var matched : bool
	for tag in filter_tags:
		matched = false
		for text in text_zones:
			if System.match_tag(text, tag, false):
				matched = true
		if !matched:
			return false
	return true

func get_text_zones(card_name : String):
	var text_zones : Array = [card_name]
	var card_text : Dictionary = get_data("CardTexts/" + card_name)
	for zone in card_text:
		if zone[0] == "[":
			text_zones.append(zone)
		text_zones.append(card_text[zone])
	return text_zones

func any_tag_found(source : Array, database : Array, absolute : bool = false):
	for tag in database:
		var card : Card = first_tagged_card(source, tag, absolute)
		if card != null:
			return card
	return null

func get_cards_multiple_tags(source : Array, database : Array, absolute : bool = false):
	var tagged_cards : Array
	for card in source:
		if any_tag_found([card], database, absolute) != null:
			tagged_cards.append(card)
	return tagged_cards
			
func first_tagged_card(source : Array, tag : String, absolute : bool = false):
	for card in source:
		if tag_check(card, tag, absolute):
			return card
	return null

func random_item(array : Array, random : RandomNumberGenerator):
	return array[random.randi()%array.size()]

func random_key(dictionary : Dictionary, random : RandomNumberGenerator):
	return dictionary[random_item(get_keys(dictionary), random)]

func get_keys(dictionary : Dictionary):
	var keys : Array
	for key in dictionary:
		keys.append(key)
	return keys

func filter_target_cards_by_effects(targets : Array, filters : Array, restrictive : bool = false):
	var filtered_targets : Array
	var current_filter : Dictionary
	var filter_reader : int
	while targets.size() > 1 and filters.size() > filter_reader:
		current_filter = filters[filter_reader]
		force_key(current_filter, "type_id", "Null")
		force_key(current_filter, "boolean", true)
		for card in targets:
			if has_effect(card, current_filter.type, current_filter.type_id) == current_filter.boolean:
				filtered_targets.append(card)
		if filtered_targets.size() > 0 or restrictive:
			targets = copy_array(filtered_targets)
			filtered_targets = []
		filter_reader += 1
	return targets

func filter_once_value(source : Array, filter_mode : bool = false, restrictive : bool = true):
	var filtered_array : Array
	for card in source:
		if has_once_value(card) == filter_mode:
			filtered_array.append(card)
	match filtered_array.size() > 1 or restrictive:
		true:
			return filtered_array
		false:
			return source

func has_once_value(card : Card):
	if has_effect(card, "Once") and card.effects.Once.active:
		return true
	return false

func toggle_once(card : Card, boolean : bool = false):
	if has_effect(card, "Once"):
		card.effects.Once.active = boolean

func has_once_per_play(card : Card):
	var effects : Dictionary = card.effects
	for key in effects:
		match key:
			"Play":
				return true
			"ContactFusion":
				if has_once_per_restriction(effects.ContactFusion):
					return true
	return false

func has_once_per_restriction(effect : Dictionary):
	return effect.has("once_per_turn") or effect.has("once_per_game")

func return_filtered_targets(source : Array, filtered_array : Array):
	if filtered_array.size() > 0:
		return filtered_array
	return source

func shuffle_array(array : Array, random : RandomNumberGenerator):
	var shuffled_array : Array
	var random_index : int
	while array.size() > 0:
		random_index = random.randi()%array.size()
		shuffled_array.append(array[random_index])
		array.remove(random_index)
	return shuffled_array

func random_chance(success_range : int, total_range : int, random : RandomNumberGenerator):
	return success_range > random.randi()%total_range

func effect_has_id_in_chain(effect : Dictionary, wanted_type : String):
	var chain_layer : int
	while chain_layer == 0 or effect.has("Chain"):
		if chain_layer > 0:
			effect = effect.Chain
		if effect.id == wanted_type:
			return true
		chain_layer += 1
	return false

func filter_highest_power(source : Array, filter_mode : bool = false):
	var filtered_array : Array
	var highest_power : int = 1
	for card in source:
		if card.power > highest_power:
			highest_power = card.power
	match highest_power > 1:
		true:
			for card in source:
				if (card.power == highest_power) == filter_mode:
					filtered_array.append(card)
			return filtered_array
		false:
			return source

func filter_lowest_power(source : Array, filter_mode : bool = false):
	var filtered_array : Array
	var lowest_power : int = source[0].power
	for card in source:
		if card.power < lowest_power:
			lowest_power = card.power
	for card in source:
		if (card.power == lowest_power) == filter_mode:
			filtered_array.append(card)
	return filtered_array

func get_cards_with_effect(source : Array, wanted_effect : Dictionary):
	var filtered_array : Array
	wanted_effect = repair_wanted_effect(wanted_effect)
	if wanted_effect.type == "Null":
		return source
	for card in source:
		if wanted_effect_check(card.effects, wanted_effect):
			filtered_array.append(card)
	return filtered_array

func wanted_effect_check(effects : Dictionary, wanted_effect : Dictionary):
	var filter_mode : bool = true
	wanted_effect = repair_wanted_effect(wanted_effect)
	if is_default(wanted_effect):
		return true
	for modifier in wanted_effect.modifiers:
		match modifier:
			"non_wanted_effect":
				filter_mode = false
	return get_effect_by_type(effects, wanted_effect.type, wanted_effect.id, \
	wanted_effect.spec, wanted_effect.spec_value) == filter_mode

func repair_wanted_effect(wanted_effect : Dictionary):
	force_key(wanted_effect, "type", "Null")
	force_key(wanted_effect, "id", "Null")
	force_key(wanted_effect, "spec", "Null")
	force_key(wanted_effect, "spec_value", "Null")
	force_key(wanted_effect, "modifiers", [])
	return wanted_effect

func shorten_name(card_name : String):
	var shortened_name : String
	var characters_to_go = shorten_name_max_length
	for character in card_name:
		shortened_name = shortened_name + character
		characters_to_go -= 1
		if characters_to_go == 0:
			break
	if shortened_name[shortened_name.length() - 1] == " ":
		shortened_name.erase(shortened_name.length() - 1, 1)
	return shortened_name

func get_card_plus_attached(card : Card):
	var card_plus_attached : Array = [card]
	for attached_card in card.attached_cards:
		card_plus_attached.append(attached_card)
	return card_plus_attached

func max_variation(value : int, target_value : int, variation : int):
	if value > target_value:
		value = min_value(value - variation, target_value)
	elif value < target_value:
		value = max_value(value + variation, target_value)
	return value

func max_value(value : int, max_value : int, overflow_value : int = -1):
	if value > max_value:
		value = max_value
		if overflow_value > -1:
			value = overflow_value
	return value

func min_value(value : int, min_value : int, overflow_value : int = -1):
	if value < min_value:
		value = min_value
		if overflow_value > -1:
			value = overflow_value
	return value

func multiple_max_value(value : int, max_values : Array):
	for limit in max_values:
		value = max_value(value, limit)
	return value

func scale_value(value : int, max_value : int, min_value : int):
	value = max_value(value, max_value)
	value = min_value(value, min_value)
	return value

func scale_vector(vector : Vector2, max_vector : Vector2, min_vector : Vector2):
	vector.x = scale_value(vector.x, max_vector.x, min_vector.x)
	vector.y = scale_value(vector.y, max_vector.y, min_vector.y)
	return vector

func filter_attacked(source : Array, filter_mode : bool = false):
	var filtered_array : Array
	for card in source:
		if card.attacked == filter_mode:
			filtered_array.append(card)
	return filtered_array

func filter_tokens(source : Array, filter_mode : bool = false):
	var filtered_array : Array
	for card in source:
		if card.instance_class == "Token" == filter_mode:
			filtered_array.append(card)
	return filtered_array

func copy_dictionary(source : Dictionary, destination : Dictionary = {"Default" : null}):
	var dictionary : Dictionary
	var default : bool = is_default(destination)
	if !default:
		for key in destination:
			dictionary[key] = destination[key]
	for key in source:
		dictionary[key] = source[key]
	dictionary = de_default(dictionary)
	return dictionary

func is_default(dictionary : Dictionary):
	return dictionary.has("Default")

func de_default(dictionary : Dictionary):
	dictionary.erase("Default")
	return dictionary

func repair_effect(effect : Dictionary = {}):
	return copy_dictionary(effect, empty_effect)
	
func empty_card_collection():
	return copy_dictionary(empty_card_collection)

func node_visible(node):
	return node.modulate.a == 1	

func debug(string : String):
	print(string)

func filter_round_on_field(source : Array, filter_mode : bool = false):
	var filtered_array : Array
	for card in source:
		if card.rounds_on_the_field >= 1.0 == filter_mode:
			filtered_array.append(card)
	return filtered_array

func filter_transformed(source : Array, filter_mode : bool = false):
	var filtered_array : Array
	for card in source:
		if card.second_name != "Null" == filter_mode:
			filtered_array.append(card)
	return filtered_array

func filter_by_attachment_amount(source : Array, amount : int, filter_mode : bool = false):
	var filtered_array : Array
	for card in source:
		if card.attached_cards.size() >= amount == filter_mode:
			filtered_array.append(card)
	return filtered_array

func filter_player_number(source : Array, player_number : int, filter_mode : bool = false):
	var filtered_array : Array
	for card in source:
		if card.controlling_player == player_number == filter_mode:
			filtered_array.append(card)
	return filtered_array

func is_single_player_mode():
	return get_session_log().game_mode == "Roguelike"

func get_card_database():
	var database : Dictionary
	match is_single_player_mode():
		true:
			database = get_roguelike_log().card_collection
		false:
			database = {
				"All" : get_legal_cards(),
				"Main" : copy_array(main_cards),
				"Grave" : copy_array(grave_cards)
			}
	return database

func get_legal_cards():
	return copy_array(legal_cards)

func temporary_instance_card(card_name : String, random : RandomNumberGenerator):
	var card : Card = instance_card(card_name, random)
	card.instance_class = "Temporary"
	card.show_sprite()
	return card
	
func instance_card(card_name : String, random : RandomNumberGenerator, size_id : String = "Compressed"):
	var card : Card = load("res://System/Card.tscn").instance()
	card.instance_id = random.randi()
	card.card_name = card_name
	card.size_id = size_id
	return card

func set_to_selected(card : Card = null, free_selected : bool = false):
	if free_selected:
		set_to_selected()
	if card == null:
		unfocus_selected()
		return
	elif selected_card == card:
		unfocus_selected()
		selected_card = null
		return
	card.toggle_confirm_button(true)
	selected_card = card

func unfocus_selected():
	if selected_card != null and is_instance_valid(selected_card):
		selected_card.toggle_confirm_button(false)

func get_next_task(task_pile : Array, erase_from_task_pile : bool = true):
	var task : Dictionary
	if task_pile.size() == 0:
		return {"Default" : null}
	task = task_pile[0]
	if !erase_from_task_pile:
		return task
	elif task.amount == 1:
		task_pile.erase(task)
	task.amount -= 1
	return task

func filter_names(source : Array, restriction : String):
	var filtered_array : Array = copy_array(source)
	match restriction:
		"Main":
			filtered_array = filter_fusion_names(filtered_array)
		"Grave":
			filtered_array = filter_fusion_names(filtered_array, true)
	return filtered_array

func filter_array(source : Array, filter : Array, restrictive : bool = true):
	var filtered_array : Array
	for item in source:
		if !filter.has(item):
			filtered_array.append(item)
	if !restrictive:
		return return_filtered_targets(source, filtered_array)
	return filtered_array

func filter_fusion_names(source : Array, filter_mode : bool = false):
	var filtered_array : Array
	for card_name in source:
		if is_fusion_name(card_name) == filter_mode:
			filtered_array.append(card_name)
	return filtered_array

func get_slot_values(slots : int, x_area : float, max_margin : int, gap : int = 0):
	var layers : int = int(slots / 2)
	var middle_slot : float = slots / 2.0
	var margin : float = x_area / slots
	var starting_point : int = margin
	var exceed : float
	if margin > max_margin:
		margin = max_margin
	starting_point = margin
	if slots % 2 == 0:
		starting_point = margin / 2
		middle_slot += 0.5
	exceed = (margin - gap) / 2
	if exceed > 0:
		exceed = 0
	return {
		"layers" : layers,
		"middle_slot" : middle_slot,
		"margin" : margin,
		"starting_point" : starting_point,
		"exceed" : exceed
	}

func game_mode_switched(current_game_mode : String, game_mode : String):
	return current_game_mode != game_mode and current_game_mode != "Null"

func get_slot_position(card : Card, slot_values : Dictionary):
	var x_address : int = 0
	if card.card_slot > slot_values.middle_slot:
		x_address = (slot_values.layers - card.card_slot) * slot_values.margin + slot_values.starting_point
	elif card.card_slot < slot_values.middle_slot:
		x_address = -1 * ((card.card_slot - slot_values.layers) * slot_values.margin - slot_values.starting_point)
	return Vector2(x_address, card.local_address.y - card.card_slot)

func scrutinize_deck(deck : Array, database : Array, scrutinization_mode : String = "names"):
	var scrutinization : Array
	var item
	for card_name in database:
		for card in deck:
			if card_name == card[0]:
				match scrutinization_mode:
					"names":
						 item = card[0]
					"decklist":
						item = card
				scrutinization.append(item)
				break
	return scrutinization

func combine_subdecks(decklist : Dictionary = get_decklist()):
	return decklist.Main + decklist.Grave

func get_enemy_decklist(decklist : Dictionary):
	if decklist.Main == []:
		decklist = get_decklist()
	return decklist

func opposite_player(player_number : int):
	return abs(player_number - 3)

func mirror_slot(target_slot : int):
	return 6 - target_slot

func attached_share_check(card : Card):
	var only_share : bool = has_effect(card, "Field", "Null", "subclass", "Attached")
	match card.location == "Attached":
		true:
			return System.has_effect(card, "Field", "Null", "share_condition", "Attached") \
			or only_share
		false:
			return !only_share

func default_vector():
	return Vector2()

func is_default_vector(vector : Vector2 = default_vector()):
	return vector == default_vector()

func get_input(event : InputEvent):
	if event is InputEventKey and event.pressed and not event.echo:
		return OS.get_scancode_string(event.scancode)
	return "Null"

func value_check(value : int, reference : int):
	match reference > 0:
		true:
			if value < reference:
				return false
		false:
			if value > abs(reference):
				return false
	return true

func max_attacks(attacks_left : int, max_attacks : int):
	if attacks_left < 0 or attacks_left > max_attacks:
		return max_attacks
	return attacks_left
