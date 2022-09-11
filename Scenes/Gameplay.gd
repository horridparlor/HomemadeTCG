extends Node2D
class_name GameplayScene

signal close_gameplay(winner_player_number)
signal clear_scene(scene)
signal refresh_scene

onready var camera = $Background/CenteredCamera
onready var music = $Background/BackgroundMusic
onready var player1 = $GameArea/Players/Playmat1
onready var player2 = $GameArea/Players/Playmat2
onready var start_game_timer = $Timers/StartGameTimer
onready var ending_cooldown = $Timers/EndingCooldown
onready var player_1_cards = $GameArea/Cards/Player1Cards
onready var player_2_cards = $GameArea/Cards/Player2Cards
onready var player_1_taskbanner = $GameArea/Taskbanners/TaskBanner1
onready var player_2_taskbanner = $GameArea/Taskbanners/TaskBanner2
onready var rotation_frame = $Timers/RotationFrame
onready var game_area = $GameArea
onready var display_spin_enabled : bool

const singed_songs : Array = [
]

const gameplay_jukebox : Array = singed_songs + [
	"CatGirlManifestation",
	"NecrophiliaFilmhouse",
	"StaticWorld"
]

var random : RandomNumberGenerator = RandomNumberGenerator.new()
var game_over : bool
var turn_number : int
var degrees : int = 0
var cards_in_game : Array
var turn_player_number : int = 1
var rounds_lasted : float
var current_game_mode : String = "Null"
var winner_player_number : int

func _ready():
	camera.current = true
	random.randomize()
	play_music()
	initialize_player(1)
	initialize_player(2)

func play_music():
	var random_song : String = System.random_item( \
	gameplay_jukebox, random)
	var file_extension : String = ".ogg"
	if singed_songs.has(random_song):
		file_extension = ".wav"
	music.stream = load("res://Textures/Audio/" + random_song + file_extension)

func initialize_scene():
	music.play()
	visible = true
	start_game_timer.start()
	session_log_update()

func get_player_data(player_number):
	var decklist : Array = generate_deck(player_number)
	var player_data : Dictionary = {
		"player_number" : player_number,
		"decklist" : decklist[0],
		"grave_decklist" : decklist[1]
	}
	return player_data

func initialize_player(player_number : int):
	var player = get_player(player_number)
	var opponent = get_player(player_number, true)
	var chain_calls : Array = ["_on_pathetic_pile", "_on_shuffle", "update_pathetic_pile", \
	"spend_plays", "relocation_confirmed", "update_enemy_zone_vacancy", "max_attacks", \
	"update_life", "update_field", "update_deck", "update_hand", "card_to_address", \
	"remove_from_location", "_on_set_life"]
	
	player.connect("turn_end", self, "_on_turn_end")
	player.connect("attack_declaration", self, "_on_attack_declaration")
	player.connect("death", self, "_on_player_dies")
	player.connect("destroy_enemy", self, "_on_destroy_enemy")
	player.connect("_on_cards", self, "_on_cards")
	player.connect("effect_response", self, "_on_effect_response")
	player.connect("taskbanner", self, "_on_taskbanner")
	player.connect("session_log_update", self, "session_log_update")
	player.connect("give_control", self, "give_control")
	player.connect("generate_card", self, "generate_card")
	
	player.connect("damage_opponent", opponent.life_counter, "damage")
	player.connect("send_enemy_graveyard", opponent.graveyard, "add_card")
	player.connect("card_sent_to_grave", opponent, "_on_card_sent_to_grave")
	player.connect("opponent_close_optional_reveal_piles", opponent, "close_optional_reveal_piles")
	player.connect("call_opponent", opponent, "listen_opponent")
	for call in chain_calls:
		player.connect(call, opponent, call)
	
	player.field.connect("update_powers", opponent.field, "update_powers")
	player.field.enemy_graveyard = opponent.graveyard.cards_in_graveyard
	player.field.enemy_cards_sent_to_grave = opponent.field.own_cards_sent_to_grave
	
	player.init(get_player_data(player_number))

func draw_card(player_number):
	get_player(player_number).draw_card()

func get_player(player_number : int, get_opposite : bool = false):
	if get_opposite:
		player_number = System.opposite_player(player_number)
	if player_number == 1:
		return player1
	return player2

func generate_deck(player_number):
	var source_decklist : Dictionary = System.gameplay_decklist(player_number, random)
	var generated_decklist : Array = [[], []]
	fill_deck(player_number, generated_decklist, source_decklist)
	return generated_decklist

func fill_deck(player_number : int, decklist : Array, source_list : Dictionary):
	var section_index : int = 1
	var source_sections = [source_list.Main, source_list.Grave]
	while section_index >= 0:
		for card in source_sections[section_index]:
			var number_of_cards : int = card[1]
			for i in range(number_of_cards):
				decklist[section_index].insert(0, generate_card(card[0], player_number))
		section_index -= 1

func generate_card(card_name : String, player_number : int, card_confirmation : bool = false):
	var card : Card
	match System.card_exists(card_name):
		true:
			card = System.instance_card(card_name, random)
		false:
			get_player(player_number).negated = true
			return
	set_player_number(card, player_number)
	card.connect("focus", self, "_on_highlight_card")
	card.connect("confirm", self, "_on_confirm_card")
	card.connect("cancel", self, "_on_cancel_card")
	if card_confirmation:
		get_player(player_number).card_confirmation_card = card
	return card

func set_player_number(card : Card, player_number : int):
	card.set_player_number(player_number)
	if player_number == 1:
		player_1_cards.add_child(card)
		return
	player_2_cards.add_child(card)
	cards_in_game.append(card)

func _on_highlight_card(card : Card):
	for player in get_players():
		player.highlight_card(card)

func _on_confirm_card(card : Card):
	for player in get_players():
		player.confirm_card(card)

func _on_cancel_card(card : Card):
	for player in get_players():
		player.cancel_card(card)

func get_players():
	return [player1, player2]

func start_turn(player):
	player.start_turn()

func _on_turn_end(next_turn_player_number):
	var players : Array = [get_player(turn_player_number), get_player(turn_player_number, \
	true)]
	turn_number += 1
	for player in players:
		player.trigger_end_phase_effects()
	if next_turn_player_number != turn_player_number and turn_player_number > 0:
		rounds_lasted += 0.5
	turn_player_number = next_turn_player_number
	for player in players:
		player.update_turn_number(turn_number, rounds_lasted)
	start_turn(get_player(turn_player_number))
	film_player()

func mirror_target_slot(target_slot : int):
	return 6 - target_slot

func mirror_all_slots(all_slots : Array):
	var filtered_array : Array
	for slot in all_slots:
		filtered_array.append(mirror_target_slot(slot))
	return filtered_array

func _on_attack_declaration(attacker : Card, target_slot : int, reversed : bool):
	var target_player = get_player(attacker.player_number, true)
	target_player.attacked(attacker, target_slot, reversed)

func _on_player_dies(player_number : int, death_message : String):
	var dead_player : Playmat
	var alive_player : Playmat
	var players : Array
	winner_player_number = System.opposite_player(player_number)
	if game_over:
		return
	game_over = true
	_on_taskbanner(player_number, death_message, true)
	_on_taskbanner(winner_player_number, "You Won!", true)
	dead_player = get_player(player_number)
	alive_player = get_player(winner_player_number)
	players = [dead_player, alive_player]
	for player in players:
		player.die()
	ending_cooldown.start()

func _on_destroy_enemy(card : Card, subclass : String, target : String, restriction : String, \
reference : String, reference_target : String, source_tags : Array, reference_card : Card, \
 amount : int):
	var attacking_player = get_player(card.player_number)
	var attacked_player = get_player(card.player_number, true)
	var own_target_columns : Array
	var enemy_target_columns : Array
	var possible_targets : Array
	var source : Array
	var random_card : Card
	if subclass == "Default":
		subclass = "target"
	match subclass:
		"Null":
			attacking_player.field.card_destroyed(card)
			return
		"same_name":
			target = "both"
			possible_targets = System.get_tagged_cards(get_zoned_cards(), card.card_name, \
			"absolute")
		"own_column":
			own_target_columns.append(card.card_slot)
			enemy_target_columns.append(card.card_slot)
		"all":
			possible_targets = get_zoned_cards(target, attacking_player, attacked_player)
			match reference:
				"cards_sent_to_grave":
					source = System.copy_array(attacking_player.field.get_names_sent_to_grave(target), source)
			if source.size() > 0:
				possible_targets = System.get_cards_multiple_tags(possible_targets, source, true)
			elif reference != "Null":
				possible_targets = []
		"target":
			if source_tags.has("power_gain"):
				reference_card = card
			attacking_player.field.modify_target("Destroy", source_tags, target, \
			amount, restriction, "Null", reference_card)
			return
		"random":
			source = get_zoned_cards(target, attacking_player)
			while possible_targets.size() < amount and source.size() > 0:
				random_card = System.random_item(source, random)
				possible_targets.append(random_card)
				source.erase(random_card)
	own_target_columns = add_to_target_columns(possible_targets, attacking_player)
	enemy_target_columns = add_to_target_columns(possible_targets, attacked_player)
	if System.targets_self(target):
		attacking_player.destroy_zoned_cards(own_target_columns, restriction, reference_card)
	if System.targets_enemy(target):
		if subclass == "own_column":
			enemy_target_columns = mirror_all_slots(enemy_target_columns)
		attacked_player.destroy_zoned_cards(enemy_target_columns, restriction, reference_card)

func add_to_target_columns(source : Array, player : Playmat):
	var target_columns : Array
	for target in System.filter_player_number(source, \
	player.player_number(), true):
		target_columns.append(target.card_slot)
	return target_columns

func get_zoned_cards(target : String = "both", attacking_player : Playmat = get_player(1), \
attacked_player : Playmat = get_player(2)):
	var cards : Array
	if System.targets_self(target):
		cards = System.copy_array(get_cards_on_players_field(attacking_player))
	if System.targets_enemy(target):
		cards = System.copy_array(get_cards_on_players_field(attacked_player), cards)
	return cards

func get_cards_on_players_field(player : Playmat):
	var cards : Array
	for card in player.field.cards_on_field:
		cards.append(card)
	return cards

func _on_cards(call_id : String, player_number : int, number_of_cards : int):
	get_player(player_number, true).response_call(call_id, player_number, number_of_cards)

func _on_effect_response(id : String, player_number : int, number_of_cards : int):
	match id:
		"Draw":
			get_player(player_number).draw_card(number_of_cards)
		"Mill":
			get_player(player_number).draw_card(number_of_cards, "Graveyard")

func _on_StartGameTimer_timeout():
	start_game_timer.stop()
	for player in get_players():
		player.trigger_start_game_effects()
		player.draw_card(System.starting_hand_size)
	var starting_player : int = random.randi_range(1, 2)
	if System.starting_player > 0:
		starting_player = System.starting_player
	_on_turn_end(starting_player)

func _on_EndingCooldown_timeout():
	ending_cooldown.stop()
	if game_over:
		emit_signal("close_gameplay", winner_player_number)
		emit_signal("clear_scene", self)

func _on_taskbanner(player_number : int, message : String, make_permanent : bool = false):
	if player_number == 1:
		player_1_taskbanner.set_message(message, make_permanent)
		return
	player_2_taskbanner.set_message(message, make_permanent)

func film_player(boolean : bool = true):
	if !display_spin_enabled and boolean:
		return
	degrees = 0
	if turn_player_number == 2 and boolean:
		degrees = 180
	rotation_frame.start()

func _on_RotationFrame_timeout():
	if int(game_area.rect_rotation) != degrees:
		spin_frame()
		if game_area.rect_rotation >= 360:
			game_area.rect_rotation = 0
		return
	rotation_frame.stop()

func spin_frame():
	game_area.rect_rotation += System.degrees_by_rotation_frame

func session_log_update():
	var session_log : Dictionary = System.get_session_log()
	var game_mode : String = session_log.game_mode
	var single_player_mode = System.is_single_player_mode()
	var player1_AI_controlled : bool = session_log.auto_play
	var player2_AI_controlled : bool = session_log.AI_enabled or single_player_mode
	if single_player_mode:
		player2.make_AI_opponent()
		player_2_taskbanner.flip_text_box()
	display_spin_enabled = session_log.display_spin_enabled and !single_player_mode
	cards_update_display_spin()
	film_player(display_spin_enabled)
	player1.make_AI_controlled(player1_AI_controlled, player2_AI_controlled)
	player2.make_AI_controlled(player2_AI_controlled, player1_AI_controlled)
	for player in get_players():
		player._on_session_log_update()
	if System.game_mode_switched(current_game_mode, game_mode):
		emit_signal("refresh_scene")
	current_game_mode = session_log.game_mode

func cards_update_display_spin():
	for card in cards_in_game:
		card.display_spin_enabled = display_spin_enabled

func give_control(card : Card):
	card.position.x = -card.position.x
	card.position.y += System.card_rect.y
	for layer in card_layers():
		layer.remove_child(card)
	card_layers()[card.controlling_player - 1].add_child(card)
	
func card_layers():
	return[player_1_cards, player_2_cards]
