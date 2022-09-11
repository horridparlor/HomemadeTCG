extends Node2D
class_name Playmat

signal turn_end
signal attack_declaration(attacker, target_slot, reversed)
signal death(player_number, death_message)
signal destroy_enemy
signal _on_cards(call_id, player_number, number_of_cards)
signal effect_response(id, tag, number_of_cards)
signal taskbanner(message)
signal damage_opponent(amount)
signal card_sent_to_grave(card, sender)
signal session_log_update
signal opponent_close_optional_reveal_piles
signal call_opponent(message, boolean)
signal remove_from_location(card, instant_position)
signal card_to_address(card, address)
signal update_hand(source, sender)
signal update_deck(source, sender)
signal update_field(source, sender)
signal update_life(life_total, sender)
signal max_attacks(target, max_attacks)
signal update_enemy_zone_vacancy(zone_vacancy)
signal give_control(card)
signal send_enemy_graveyard(card)
signal relocation_confirmed(card, send_to, attach_to)
signal spend_plays
signal play_card(card)
signal generate_card(card_name)
signal _on_pathetic_pile(card, effect, target)
signal update_pathetic_pile(pile, target)
signal _on_shuffle(target)
signal _on_set_life(value)

onready var field = $Field
onready var hand = $Hand
onready var deck = $Deck
onready var graveyard = $Graveyard
onready var card_mover = $CardMover
onready var card_highlighter = $CardHighLighter
onready var life_counter = $LifeCounter
onready var phase_change_timer = $Timers/PhaseChangeTimer
onready var wait_timer = $Timers/WaitTimer
onready var surrender_button = $WhiteFlag/Surrender
onready var surrender_cooldown = $WhiteFlag/SurrenderCooldown
onready var surrender_sprite = $WhiteFlag/SurrenderSprite
onready var settings_tab = $CardHighLighter/SettingsTab
onready var AI_refresh_timer = $Timers/AIRefreshTimer
onready var select_fade_timer = $Timers/SelectFadeTimer

var current_task : String = "Null"
var current_focus : String = "Null"
var is_active : bool
var is_active2 : bool
var current_phase : String
var task_pile : Array
var task_pile_card : Card
var waiting_values : Array
var waiting_fors : Array
var legal_targets : Array
var task_pile_mode : String
var turn_number : int
var negate_these_effects : String
var no_targets : bool
var chain_turn_end : int
var selected_card : Card
var looking_for : String
var send_card_to : String
var previous_targets : Array
var last_task : String
var selected_location : String
var is_turn_player : bool
var is_AI_controlled : bool
var is_enemy_AI_controlled : bool
var AI_target_card : Card
var random : RandomNumberGenerator = RandomNumberGenerator.new()
var got_response : bool
var deactivated : bool
var current_message : String = "Null"
var dead : bool
var AI_default_speed : float
var AI_hastened_speed : float
var hotkey_focused_slot : int = 1
var next_max_attacks : int = -1
var extra_turn : bool
var card_confirmation_card : Card
var card_confirmation_id : String = "Null"
var imprint_to : Card
var pathetic_pile : Array
var negated : bool

func _ready():
	connect_signals()
	random.randomize()
	initialize_variables()

func init(player_data):
	set_player_number(player_data.player_number)
	instance_deck(player_data.decklist)
	instance_deck(player_data.grave_decklist)
	deck.set_decklist(player_data.decklist)
	graveyard.set_grave_decklist(player_data.grave_decklist)
	hand.random.randomize()

func initialize_variables():
	hand.zone_vacancy = field.enemy_zone_vacancy
	hand.graveyard_plane = System.plane(graveyard)
	
	deck.random = random
	
	field.own_hand = hand.cards_in_hand
	field.own_graveyard = cards_in_graveyard()
	field.own_life = life_counter.life_total

func instance_deck(decklist : Array):
	for card in decklist:
		card.show_sprite()
		card.visible = false

func set_player_number(player_number):
	hand.player_number = player_number
	life_counter.init(player_number())

func make_AI_controlled(self_boolean : bool, enemy_boolean : bool):
	is_AI_controlled = self_boolean
	is_enemy_AI_controlled = enemy_boolean
	hand.make_AI_controlled(is_AI_controlled)
	field.make_AI_controlled(is_AI_controlled)
	if player_number() != 1:
		settings_tab.make_AI_controlled(is_AI_controlled)
		settings_tab.visible = !is_AI_controlled
	induct_AI(is_AI_controlled)

func make_AI_opponent():
	life_counter.flip_text_box()
	deck.flip_text_box()

func induct_AI(boolean : bool):
	if task_pile_free():
		close_optional_reveal_piles()
	if is_turn_player:
		if boolean:
			AI_refresh_timer.start()
			return
		AI_refresh_timer.stop()

func connect_signals():
	card_mover.connect("deliver_card", self, "_on_card_delivered")
	card_mover.connect("visual_queue", self, "_on_move_call")
	card_mover.connect("change_zone_visibility", self, "_on_change_zone_visibility")
	
	hand.connect("card_focused", self, "_on_card_in_hand_focused")
	hand.connect("card_unfocused", self, "_on_card_in_hand_unfocused")
	hand.connect("card_played", field, "add_card")
	hand.connect("card_attached", self, "_on_card_attached")
	hand.connect("slide_card_in_hand", self, "_on_move_call")
	hand.connect("fill_field_zone", self, "_on_zone_vacancy")
	hand.connect("card_discarded", self, "_on_card_discarded")
	hand.connect("resolve_effect", self, "resolve_effect")
	hand.connect("free_play", self, "_on_free_play")
	hand.connect("update_hand", self, "update_hand")
	hand.connect("update_powers", self, "update_powers")
	hand.connect("allow_hand_actions", self, "allow_hand_actions")
	hand.connect("remove_from_location", self, "remove_from_location")
	
	field.connect("zone_movement", self, "_on_move_call")
	field.connect("attack_declaration", self, "_on_attack_declaration")
	field.connect("card_taken", self, "_on_card_zoned")
	field.connect("card_played", self, "_on_card_played")
	field.connect("activate_effect", self, "resolve_effect")
	field.connect("material_confirmed", self, "confirm_card")
	field.connect("destroy_enemy", self, "destroy_enemy")
	field.connect("transform_target", self, "_on_transform")
	field.connect("set_active", self, "set_is_active")
	field.connect("relocation_confirmerd", self, "relocation_confirmed")
	field.connect("update_field", self, "update_field")
	field.connect("update_life", self, "life_effect")
	field.connect("close_optional_reveal_piles", self, "close_optional_reveal_piles")
	field.connect("no_targets", self, "_on_no_targets")
	field.connect("negated_check", self, "_on_negated_check")
	
	deck.connect("move_call", self, "_on_move_call")
	deck.connect("card_milled", self, "_on_card_milled")
	deck.connect("search_mode", self, "_on_search_mode")
	deck.connect("relocation_confirmed", self, "relocation_confirmed")
	deck.connect("update_deck", self, "update_deck")
	for element in [deck, graveyard]:
		element.connect("toggle_visibility", card_mover, "toggle_visibility")
	
	life_counter.connect("dead", self, "out_of_life")
	life_counter.connect("update_life", self, "update_life")
	
	graveyard.connect("update_powers", self, "update_powers")
	graveyard.connect("card_sent_to_grave", self, "_on_card_sent_to_grave")	
	graveyard.connect("confirmation_call", self, "_on_grave_confirmation_call")
	
	settings_tab.connect("session_log_update", self, "session_log_update")

func draw_card(cards_to_draw : int = 1, location : String = "Hand"):
	var card : Card
	for i in range(cards_to_draw):
		if deck.cards_in_deck.size() == 0:
			if location == "Hand" and turn_number > 0:
				_on_death("Run out of cards, :<")
			if deck.cards_in_deck.size() == 0:
				break
		card = deck.draw_card()
		if card != null:
			card.trigger = "Draw"
			relocation_confirmed(card, location)

func shuffle_graveyard_into_deck():
	for card in get_void_targets():
		relocation_confirmed(card, "Deck")

func allow_enemy_to_toggle():
	return !is_turn_player and !is_enemy_AI_controlled

func _on_DrawButton_pressed(AI_initiated : bool = false):
	var response : String
	var deck_active_cards : Array
	if (AI_check(AI_initiated) and !(!is_turn_player and current_task == "Revealing_Attachments")) or deactivated:
		return
	if current_task == "Revealing_Attachments":
		hide_attachments()
	elif can_reveal_field_check():
		match current_task == "Null":
			true:
				if !main_phase_check():
					return
				deck_active_cards = get_deck_active_cards()
				if is_deck_active(deck_active_cards):
					set_current_task(card_mover.show_content(current_task, "Revealing_Deck", \
					deck_active_cards, "From_Deck"), false)
					if current_task == "Revealing_Deck":
						set_deck_active(deck_active_cards)
						set_overlay_message("Play a card from deck.")
						selected_location = "Play"
						current_focus = current_task
			false:
				if current_task == "Revealing_Deck":
					clear_search_mode()
					return
				response = card_mover.show_content(current_task, "Revealing_Field", [], "")
				if response == "Revealing_Field":
					taskbanner("Press deck to continue.", false)
					current_focus = response
					is_active2 = is_active
					deactivate_opponent(false, true)
					set_is_active(false)
	elif current_focus == "Revealing_Field":
		response = card_mover.hide_content(current_task, [], "")
		if response == "Null":
			taskbanner(current_message)
			current_focus = current_task
			deactivate_opponent(true, true)
			set_is_active(is_active2)

func is_deck_active(deck_active_cards : Array = get_deck_active_cards()):
	return deck_active_cards.size() > 0

func set_deck_active(deck_active_cards : Array):
	deck.current_search_pile = System.copy_array(deck_active_cards)
	legal_targets = System.copy_array(deck_active_cards)

func get_deck_active_cards():
	var deck_active_cards : Array
	var single_cards : Array
	single_cards = System.get_single_cards(deck.cards_in_deck)
	if can_field_take():
		for card in single_cards:
			if System.has_corresponding_tag(card, deck.plays_left) or \
			has_deck_play_effect(card):
				deck_active_cards.append(card)
	return deck_active_cards

func has_deck_play_effect(card : Card):
	var effect : Dictionary
	if System.has_effect(card, "Deck", "free_play"):
		effect = card.effects.Deck
		return check_free_play_conditions(card, effect)
	return false

func can_reveal_field_check():
	return current_task == current_focus and field.zone_targeting_mode == "Null"

func _on_card_delivered(card : Card):
	var address : String = card.address.id
	card_to_address(card, address)

func card_to_address(card : Card, address : String):
	if controlled_by_opponent(card):
		emit_signal("card_to_address", card, address)
		return
	match address:
		"Graveyard":
			graveyard.add_card(card)
			card.visible = false
		"Animation":
			return_from_animation(card)
		"attached":
			card.visible = false
		"Void":
			card.visible = false
		"Deck":
			card.visible = false
			deck.top_sprite.visible = true
		"AI_refresh_timer_timeout":
			_on_AIRefreshTimer_timeout()

func return_from_animation(card : Card):
	if !System.is_default_vector(card.return_address):
		card.address.position = card.return_address
		card.return_address = System.default_vector()
		_on_move_call(card)
	elif card.location == "Field":
		return_to_field_zone(card)

func return_to_field_zone(card : Card):
	card.address = {
			"id" : "return_to_field_zone",
			"position" : get_card_zone_position(card, card.card_slot)
		}
	_on_move_call(card)
	
func _on_card_in_hand_focused(card : Card):
	if main_phase_check() and is_active and empty_zone_exists() and \
	(hand_active_effect_check(card) or hand.plays_left > 0) and \
	!System.is_fusion_card(card):
		field.show_zones()

func empty_zone_exists():
	for zone in field.zone_vacancy:
		if !zone:
			return true
	return false

func hand_active_effect_check(card : Card):
	if System.has_effect(card, "Hand", "free_play"):
		if check_free_play_conditions(card, card.effects.Hand):
			induct_free_play(card)
			return true
	return false

func check_free_play_conditions(card : Card, effect : Dictionary):
	effect = System.repair_effect(effect)
	var targets_pile : Array
	var only_friends : bool = false
	var cards_found : int
	if !once_per_check(effect, false):
		return
	match effect.location:
		"Top_of_Deck":
			if card != deck.cards_in_deck[0]:
				return false
	match effect.restriction:
		"no_friends":
			if field.cards_on_field.size() > 0:
				return false
		"friends":
			only_friends = true
	match effect.subclass:
		"Default":
			return true
		"cards_on_field":
			if System.targets_self(effect.target):
				targets_pile = System.copy_array(field.get_field_plus_attached( \
				field.cards_on_field, only_friends), targets_pile)
			if System.targets_enemy(effect.target):
				targets_pile += System.copy_array(field.get_field_plus_attached( \
				field.enemy_field, only_friends), targets_pile)
			for card_on_field in System.get_tagged_cards(targets_pile, effect.tag, \
			effect.condition, card.card_name):
				cards_found += 1
				if cards_found == effect.amount:
					return true
	return false

func _on_free_play(card : Card):
	if System.has_effect(card, "Hand", "free_play"):
		once_per_check(card.effects.Hand)

func induct_free_play(card : Card):
	card.free_play = true
	return true
					
func main_phase_check():
	if current_phase == "main1" or current_phase == "main2":
		return true
	return false

func _on_card_in_hand_unfocused(card : Card):
	if current_phase != "attack" and current_task == "Null":
		field.hide_zones()

func AI_plus_attachments_check(card : Card, AI_initiated : bool):
	return AI_check(AI_initiated) and !(!is_turn_player and has_attachments_check(card))

func highlight_card(card : Card, AI_initiated : bool = false):
	if card_mover.busy():
		return
	if !is_AI_controlled:
		settings_tab.close_settings()
	if AI_plus_attachments_check(card, AI_initiated):
		return
	card_highlighter.focus_card(card)
	if graveyard_mode_check(card):
		graveyard.target_card_in_grave(card)
	elif legal_target_check(card):
		System.set_to_selected(card, true)
	elif has_attachments_check(card):
		select_fade_timer.initialize(card)

func confirm_card(card : Card, AI_initiated : bool = false):
	var confirmation_triggered_effects : Array
	var source : Array
	if card_mover.busy() or AI_plus_attachments_check(card, AI_initiated):
		return
	if imprint_to != null:
		imprint_to.imprinted_card = card
		imprint_to = null
	System.set_to_selected(System.selected_card)
	if current_task != "Null" and System.has_effect(task_pile_card, "CardConfirmation", current_task):
		task_pile_card.reference_card = card
		confirmation_triggered_effects.append({
			"card" : task_pile_card,
			"effect" : task_pile_card.effects.CardConfirmation
		})
	if task_pile_free() and System.node_visible(field.phase_attack_symbol) and current_phase == "attack" \
	and card.controlling_player == player_number():
		set_is_active(false)
		field.attack(card)
		taskbanner("Which column to attack?")
	elif card == graveyard.target_in_graveyard and current_task == "Revealing_Grave":
		confirm_graveyard(card)
	elif legal_target_check(card):
		card.pull_from_action()
		match current_task:
			"Revealing_Hand":
				close_reveal_pile(card, "Hand")
			"Revealing_Deck":
				spend_play(card, deck, "Deck")
				confirm_search_deck(card)
			"Searching_Deck":
				confirm_search_deck(card)
			"Revealing_Field":
				relocation_confirmed(card)
				match card.controlling_player == player_number():
					true:
						source = field.cards_on_field
					false:
						source = field.enemy_field
						close_optional_reveal_piles(true)
				close_reveal_pile(card, "Field")
			"Search_Graveyard":
				confirm_search_graveyard(card)
			"Search_Enemy_Grave":
				confirm_search_graveyard(card)
			"Playing_Hand":
				close_catalogue_view(card, "Hand")
			"Playing_Grave":
				close_catalogue_view(card, "Graveyard")
			"Revealing_Attachments":
				activate_detach_effect(card)
	elif has_attachments_check(card):
		select_fade_timer.stop()
		card.toggle_confirm_button(false)
		reveal_attachments(card)
	for effect in confirmation_triggered_effects:
		resolve_effect(effect.card, effect.effect)

func player_number():
	return hand.player_number

func confirm_graveyard(card : Card):
	graveyard.pull_card(card)
	_on_GraveButton_pressed(true)
	if System.has_corresponding_tag(card, graveyard.plays_left):
		spend_play(card, graveyard)
		task_play(card, true)
		return
	set_is_active(false)
	activate_from_graveyard(card)

func confirm_search_deck(card : Card):
	is_active = false
	legal_targets = []
	deck.confirm_search_target(card, selected_location)

func confirm_search_graveyard(card : Card):
	relocation_confirmed(card)
	if has_next_task_key("search_graveyard") and ((current_task == "Search_Graveyard" and \
	get_next_task_key("target") == "self") or (current_task == "Search_Enemy_Grave" \
	and get_next_task_key("target") == "enemy")):
		start_task_pile()
		return
	hide_graveyard_void_targets()	

func cancel_card(card : Card):
	if card == null:
		return
	if card == field.focused_attacker:
		field.clear_attack_targeting()
		full_state_clean(true)

func full_state_clean(boolean : bool):
	clear_current_task()
	set_is_active(boolean)
	is_turn_player = boolean

func legal_target_check(card : Card):
	if overleaping_task():
		pass
	elif current_task == "Revealing_Attachments" and !card.allowed_to == "Detach":
		pass
	elif legal_targets.has(card):
		return true
	return false

func overleaping_task():
	return (current_task != current_focus) or (current_phase == "attack" and \
	current_task == "Revealing_Grave")
	
func graveyard_mode_check(card : Card):
	if card.location == "Graveyard" and current_task == "Revealing_Grave" and \
	is_active and main_phase_check():
		return true
	return false

func has_attachments_check(card : Card):
	return card.location == "Field" and current_task == "Null" and \
	card.attached_cards.size() > 0 and card.player_number == player_number() \
	and (main_phase_check() or allow_enemy_to_toggle())

func move_card(card : Card, address : Dictionary):
	card.address = address
	card_mover.move_card(card)

func _on_move_call(card : Card):
	if convert_address(card):
		card_mover.move_card(card)

func convert_address(card : Card):
	var id : String = card.address.id
	if id == "From_Graveyard" or str(card.address.position) == "From_Graveyard":
		card.position = graveyard.rect_position
	elif id == "From_Deck" or str(card.address.position) == "From_Deck":
		card.position = deck.rect_position
	elif id == "From_Attached":
		card.position = task_pile_card.position
	if id == "Hand":
		if card.location != "Hand":
			hand.add_card(card)
			return false
		card.address.position = hand.rect_position
	elif id == "Graveyard":
		card.address.position = graveyard.rect_position
	elif id == "Deck":
		card.address.position = deck.rect_position
	elif id == "attached" and current_task == "Revealing_Attachments":
		card.address.position = task_pile_card.position
	return true
	
func _on_GraveButton_pressed(AI_initiated : bool = false):
	if (AI_check(AI_initiated) and (is_turn_player or is_enemy_AI_controlled)) or \
	deactivated:
		return
	elif current_focus == "Revealing_Grave":
		hide_grave()
	elif current_task == "Revealing_Attachments":
		hide_attachments()
	elif graveyard_inactive_check() and cards_in_graveyard().size() > 0:
		show_grave()

func graveyard_inactive_check():
	if current_task == "Revealing_Deck":
		clear_search_mode()
		return false
	return (is_active or !is_turn_player) and current_focus != "Search_Graveyard" and \
	current_focus != "Playing_Grave"
	
func show_grave():
	if field.zone_targeting_mode == "attack_target":
		cancel_card(field.focused_attacker)
	if current_task == current_focus:
		var response : String = card_mover.show_content(current_task, "Revealing_Grave", cards_in_graveyard(), "From_Graveyard")
		if response == "Revealing_Grave":
			if is_active:
				System.copy_array(cards_in_graveyard(), legal_targets)
				activate_graveyard()
			current_focus = response
			if current_task == "Null":
				set_current_task(response, false)

func activate_graveyard(activate : bool = true):
	var source : Array = cards_in_graveyard()
	for card in System.filter_fusion(source, true):
		if check_fusion_conditions(card):
			match activate:
				true:
					card.allow_to("ContactFusion")
				false:
					return true
	if negated_check("void_graveyard"):
		return false
	for card in System.get_cards_with_effect(source, {"type" : "Void"}):
		if graveyard.check_void_conditions(card) and resolve_check(card, card.effects.Void, false):
			match activate:
				true:
					card.allow_to("Void")
				false:
					return true
	return false

func hide_grave():
	var response : String = card_mover.hide_content(current_task, cards_in_graveyard(), "Graveyard")
	if response == "Null":
		if current_task == "Revealing_Grave":
			for card in legal_targets:
				card.pull_from_action()
			legal_targets = []
			graveyard.forget_target_in_graveyard()
			clear_current_task()
			return
		current_focus = current_task
	
func _on_change_zone_visibility(command : bool, zones : Array, reveal_pile : Array):
	hand.reveal_pile = System.copy_array(reveal_pile)
	for zone in zones:
		convert_zone_to_hide(command, zone)

func convert_zone_to_hide(command : bool, zone : String):
	if zone == "Hand":
		hand.zone_visibility(command)
	elif zone == "Field":
		field.zone_visibility(command)
	elif zone == "cards_moving":
		for card in card_mover.cards_moving:
			card_mover.toggle_visibility(card, command)

func start_turn():
	close_optional_reveal_piles()
	is_turn_player = true
	manual_phase_change("draw")
	new_turn_values_update()
	if is_AI_controlled:
		AI_default_speed()
		AI_refresh_timer.start()

func close_optional_reveal_piles(call_enemy : bool = false):
	if call_enemy:
		emit_signal("opponent_close_optional_reveal_piles")
		return
	if card_mover.busy():
		waiting_fors.append("Close_Optional_Reveal_Piles")
		wait_timer.start()
		return
	AI_target_card = null
	if current_task == "Revealing_Grave" or current_task == "Revealing_Attachments":
		_on_GraveButton_pressed(true)

func new_turn_values_update():
	hand.zone_vacancy = field.zone_vacancy
	hand.enemy_zone_vacancy = field.enemy_zone_vacancy
	hand.plays_left = 1
	for zone in [deck, graveyard]:
		zone.plays_left = []
	field.next_play_power_gain = 0
	initialize_max_attacks()
	update_powers()
	if not_first_turn():
		draw_card()

func update_powers():
	field.update_powers()
	toggle_backlights()
	release_hotkey_focus()

func update_turn_number(new_turn_number : int, rounds_lasted : float):
	turn_number = new_turn_number
	field.update_rounds(rounds_lasted)
	field.once_per_turn_effects = []
	hand.allow_hand_actions()
	field.cards_played = 0
	field.own_cards_sent_to_grave = []
	field.enemy_cards_sent_to_grave = []
	for card in field.cards_on_field:
		card.attacked = false

func set_is_active(boolean : bool, message : String = "Default"):
	is_active = boolean
	var elements : Array = [hand, field, graveyard]
	for element in elements:
		element.toggle_active(is_active)
	if !boolean:
		hide_surrender_button()
	toggle_backlights()
	if message != "Default":
		taskbanner(message)

func toggle_backlights():
	var boolean : bool = task_pile_free()
	allow_hand_actions(boolean)
	toggle_deck_backlight(boolean)
	toggle_graveyard_backlight(boolean)
	toggle_field_backlights(boolean)

func toggle_deck_backlight(boolean : bool):
	deck.toggle_backlight(boolean and is_deck_active())

func toggle_graveyard_backlight(boolean : bool):
	var graveyard_active : bool = stack_free() and activate_graveyard(false)
	graveyard.toggle_backlight(boolean and graveyard_active)

func toggle_field_backlights(boolean : bool):
	for card in field.cards_on_field:
		if card == field.focused_attacker:
			return
		match boolean and has_detachable_attached(card):
			true:
				card.allow_to("Detach")
			false:
				card.toggle_backlight()

func has_detachable_attached(card : Card):
	for attached_card in card.attached_cards:
		if System.has_effect(attached_card, "Detach") and \
		resolve_check(attached_card, attached_card.effects.Detach, false):
			return true
	return false

func _on_card_search(card : Card, subclass : String, tag : String, amount : int, \
constant : int, condition : String, wanted_effect : Dictionary, location : String):
	var search_pile : Array = deck.card_search(card, tag, amount, condition, wanted_effect, \
	location)
	if search_pile.size() == 0 or (location == "Play" and !can_field_take()):
		return false
	match subclass:
		"Instant":
			instant_search(search_pile, amount, location)
			return true
		"Random":
			search_pile = get_random_search_choices(search_pile, constant)
	deck.confirm_search_pile(search_pile)
	set_is_active(false)
	_on_search_mode(true, search_pile, location)
	return true

func get_random_search_choices(search_pile : Array, choices : int):
	var filtered_pile : Array
	var singles_pile : Array
	var source : Array
	var random_card : Card
	singles_pile = System.get_single_cards(search_pile)
	for i in range (choices):
		if search_pile.size() == 0:
			break
		match singles_pile.size() == 0:
			true:
				source = search_pile
			false:
				source = singles_pile
		random_card = System.random_item(source, random)
		filtered_pile.append(random_card)
		search_pile.erase(random_card)
		singles_pile.erase(random_card)
	return System.shuffle_array(filtered_pile, random)

func instant_search(source : Array, amount : int, location : String):
	var random_card : Card
	while amount != 0 and source.size() > 0:
		random_card = System.random_item(source, random)
		relocation_confirmed(random_card, location)
		source.erase(random_card)
		amount -= 1
	deck.shuffle_deck()

func _on_search_mode(boolean : bool, search_pile : Array, send_to : String = "Hand"):
	if boolean:
		set_current_task(card_mover.show_content(current_task, "Searching_Deck", \
		search_pile, "From_Deck"), false)
		if current_task == "Searching_Deck":
			legal_targets = System.copy_array(search_pile)
			set_overlay_message("Select search target.")
			selected_location = send_to
			current_focus = current_task
			return
		waiting_search_mode(boolean, search_pile, send_to)
		return
	clear_search_mode(send_to)

func clear_search_mode(send_to : String = "Hand"):
	if card_mover.busy():
		waiting_search_mode()
		return
	clear_overlay_message()
	legal_targets = []
	selected_location = "Null"
	if deck.current_search_amount > 0:
		_on_search_mode(true, deck.current_search_pile, send_to)
		return
	set_current_task(card_mover.hide_content(current_task, deck.current_search_pile, "Deck"))
	set_is_active(true)

func waiting_search_mode(boolean : bool = false, search_pile : Array = [], send_to : String = "Default"):
	waiting_values = [boolean, search_pile, send_to]
	waiting_fors.append("Searching_Deck")
	wait_timer.start()

func set_current_task(new_task : String, copy_current_focus : bool = true):
	current_task = new_task
	if copy_current_focus:
		current_focus = current_task
	release_hotkey_focus()

func release_hotkey_focus():
	hotkey_focused_slot = 1

func clear_current_task():
	set_current_task("Null")
	taskbanner()

func set_overlay_message(message : String):
	taskbanner(message)

func clear_overlay_message():
	taskbanner()

func _on_PhaseButton_pressed(AI_initiated : bool = false):
	if AI_check(AI_initiated):
		return
	if task_pile_free() and !card_mover.busy() and System.node_visible(field.phase_symbol):
		phase_procedure()

func task_pile_free():
	return is_active and current_task == "Null"

func phase_procedure():
	if card_mover.busy():
		waiting_fors.append("Phase_Procedure")
		wait_timer.start()
		return
	if current_phase == "draw":
		if !dead:
			set_is_active(true)
			manual_phase_change("main1")
	elif current_phase == "main1":
		if turn_number == 1:
			manual_phase_change("end")
			return
		manual_phase_change("attack")
	elif current_phase == "attack":
		if card_mover.cards_moving.size() > 0 or attack_animations_playing():
			phase_procedure()
			return
		manual_phase_change("main2")
	elif current_phase == "main2":
		manual_phase_change("end")
	elif current_phase == "end":
		end_turn()

func attack_animations_playing():
	for card in field.cards_on_field:
		if card.address.id == "Animation":
			return_to_field_zone(card)
			return true
	return false

func manual_phase_change(phase : String):
	current_phase = phase
	field.phase_symbol(phase)
	if current_phase == "draw":
		phase_change_timer.start()
	elif current_phase == "attack":
		close_optional_reveal_piles(true)
		hand.toggle_active(false)
		field.start_attack_phase()
		if field.has_any_attacks():
			taskbanner("Choose an attacker.")
	elif current_phase == "main2":
		hand.toggle_active(true)
		field.end_attack_phase()
		taskbanner()
	elif current_phase == "end":
		is_active = false
		phase_change_timer.start()
	update_powers()

func end_turn():
	var next_turn_player_number : int = System.opposite_player(player_number())
	if extra_turn:
		next_turn_player_number = player_number()
		extra_turn = false
	full_state_clean(false)
	AI_refresh_timer.stop()
	emit_signal("turn_end", next_turn_player_number)

func trigger_start_game_effects():
	trigger_graveyard_effects("StartGame")

func trigger_end_phase_effects():
	trigger_graveyard_effects("EndPhase")

func trigger_graveyard_effects(id : String):
	var source : Array
	for card in cards_in_graveyard():
		if System.has_effect(card, "Graveyard", id):
			source.append({
				"card" : card,
				"Chain" : card.effects.Graveyard.Chain
			})
	for effect in source:
		resolve_effect(effect.card, effect.Chain)

func _on_zone_vacancy(slot_numbers : Array, boolean : bool):
	for slot_number in slot_numbers:
		hand.zone_vacancy[slot_number] = boolean
		field.zone_vacancy[slot_number] = boolean
	emit_signal("update_enemy_zone_vacancy", field.zone_vacancy)
	
func update_enemy_zone_vacancy(zone_vacancy : Array):
	field.set_enemy_zone_vacancy(zone_vacancy)
	hand.enemy_zone_vacancy = field.enemy_zone_vacancy

func _on_attack_declaration(attacker : Card, target_slot : int, reversed : bool = false):
	new_animation(attacker, get_card_zone_position(attacker, target_slot, \
	reversed) + Vector2(0, -300))
	if !reversed:
		is_active = true
		target_slot = mirror_target_slot(target_slot)
	emit_signal("attack_declaration", attacker, target_slot, reversed)
	if is_turn_player:
		set_is_active(true)
	taskbanner()

func new_animation(card : Card, position : Vector2):
	card.address = {
		"id" : "Animation",
		"position" : position
	}
	_on_move_call(card)

func mirror_target_slot(target_slot : int):
	return 6 - target_slot

func get_card_zone_position(card : Card, zone_number : int, reversed : bool = false):
	if reversed:
		zone_number = mirror_target_slot(zone_number)
	var vector2 : Vector2 = field.get_zone_position(zone_number)
	vector2.y = card.local_address.y
	return vector2

func attacked(attacker : Card, slot_number : int, reversed : bool):
	var damage_amount : int
	if field.attacked(attacker, slot_number, reversed):
		damage_amount = attacker.power
		if damage_amount < 1:
			damage_amount = 1
		take_damage(damage_amount, -1)

func take_damage(amount : int, modifier : int = 1):
	amount = try_modify_damage(modifier * amount)
	if amount == 0:
		return
	life_counter.damage(amount)

func try_modify_damage(amount : int):
	var effect : Dictionary
	var once_spent : bool
	for card in field.cards_on_field:
		if System.has_once_value(card):
			effect = System.repair_effect(card.effects.Once)
			match effect.id:
				"modify_damage":
					if amount < 0:
						once_spent = true
						amount = effect.multiplier * amount + effect.constant
			if once_spent:
				System.toggle_once(card)
				trigger_chained_effects(card, effect, ["Instant"])
				break
	return amount

func _on_death(death_message : String):
	emit_signal("death", player_number(), death_message)

func out_of_life():
	var death_message : String = "Run out of life, :("
	var value : int
	var response_effect : Dictionary
	for card in hand.cards_in_hand:
		if System.has_effect(card, "Hand", "Response", "subclass", "out_of_life"):
			response_effect = System.repair_effect(card.effects.Hand)
			value = response_effect.amount
			if resolve_check(card, response_effect):
				_on_set_life(value)
				pay_response_effect(card)
				return
	_on_death(death_message)

func die():
	set_is_active(false)
	dead = true
	AI_refresh_timer.stop()

func _on_PhaseChangeTimer_timeout():
	phase_change_timer.stop()
	phase_procedure()

func _on_grave_confirmation_call(id : String, card : Card):
	if id == "Void" and !once_per_check(card.effects.Void, false):
			return
	elif id == "Play" and !can_field_take():
			return
	graveyard.confirm_graveyard_conditions(card)	
		
func check_fusion_conditions(card : Card, AI_initiated : bool = false):
	var met_fusion_conditions : bool = true
	var fusion_conditions : Dictionary = card.effects.ContactFusion
	var materials_from_field : bool
	if !resolve_check(card, fusion_conditions, false):
		return false
	for zone in fusion_conditions:
		match zone:
			"Field":
				met_fusion_conditions = check_field_conditions(card, fusion_conditions, \
				met_fusion_conditions, AI_initiated)				
				materials_from_field = true	
			"Hand":
				met_fusion_conditions = check_hand_conditions(card, fusion_conditions, \
				met_fusion_conditions)
			"Graveyard":
				met_fusion_conditions = check_graveyard_conditions(card, fusion_conditions, \
				met_fusion_conditions)
			"Top_of_Deck":
				met_fusion_conditions = check_top_of_deck_conditions(card, fusion_conditions, \
				met_fusion_conditions)
			"Restore_Plays":
				met_fusion_conditions = check_restore_plays_conditions(fusion_conditions, \
				met_fusion_conditions)
		
	if !materials_from_field and !empty_zone_exists():
		met_fusion_conditions = false
	return met_fusion_conditions

func check_field_conditions(card : Card, fusion_conditions : Dictionary, \
met_fusion_conditions : bool, AI_initiated : bool):
	var conditions : Dictionary = System.repair_effect(fusion_conditions.Field)
	var subclass : String = conditions.subclass
	var source : Array
	var cards_to_find : int
	match conditions.restriction:
		"Null":
			source = field.cards_on_field
			if AI_initiated:
				source = System.filter_target_cards_by_effects( \
				System.filter_once_value(source), \
				System.AI_field_material_restrictions, true)
		"Enemy":
			source = field.enemy_field
	if conditions.column[0] > 0:
		subclass = "column"
	elif subclass == "Default":
		subclass = "friends"
	match subclass:
		"column":
			cards_to_find = conditions.column.size()
			for column in conditions.column:
				for card in source:
					if card.card_slot == column:
						cards_to_find -= 1
						break
			if cards_to_find > 0:
				met_fusion_conditions = false
		"friends":
			if !System.material_check(card, source, conditions):
				met_fusion_conditions = false
	return met_fusion_conditions

func check_hand_conditions(card : Card, fusion_conditions : Dictionary, met_fusion_conditions : bool):
	var conditions : Dictionary = System.repair_effect(fusion_conditions.Hand)
	var subclass : String = conditions.subclass
	var cards_to_find : int
	var duplicates_found : bool
	var source : Array = System.get_tagged_cards(hand.cards_in_hand, conditions.tag, \
	conditions.condition, card.card_name, conditions.wanted_effect)
	match subclass:
		"Default":
			if !System.material_check(card, source, conditions):
				met_fusion_conditions = false
		"Duplicates":
			for card in source:
				cards_to_find = conditions.amount
				for other_card in source:
					if card.card_name == other_card.card_name:
						cards_to_find -= 1
						if cards_to_find == 0:
							duplicates_found = true
							break
				if duplicates_found:
					return met_fusion_conditions
			met_fusion_conditions = false
	return met_fusion_conditions

func check_graveyard_conditions(card : Card, fusion_conditions : Dictionary, \
met_fusion_conditions : bool):
	var conditions : Dictionary = System.repair_effect(fusion_conditions.Graveyard)
	if (conditions.location == "Default" and negated_check("void_graveyard")) or \
	!has_void_material_targets(card, conditions):
		met_fusion_conditions = false
	return met_fusion_conditions

func has_void_material_targets(original_card : Card, effect : Dictionary):
	var void_targets : Array = get_void_targets(effect.condition, effect.tag, effect.target, \
	effect.reference, effect.reference_target)
	void_targets.erase(original_card)
	return void_targets.size() >= effect.amount

func check_top_of_deck_conditions(card : Card, fusion_conditions : Dictionary, met_fusion_conditions : bool):
	var conditions : Dictionary = System.repair_effect(fusion_conditions.Top_of_Deck)
	var source : Array = System.scrape_array(deck.cards_in_deck, conditions.amount)
	if !System.material_check(card, source, conditions):
		met_fusion_conditions = false
	return met_fusion_conditions

func check_restore_plays_conditions(fusion_conditions : Dictionary, \
met_fusion_conditions : bool):
	var conditions : Dictionary = System.repair_effect(fusion_conditions.Restore_Plays)
	if System.targets_self(conditions.target):
		if field.plays_spent < conditions.amount:
			met_fusion_conditions = false
	return met_fusion_conditions

func _on_card_played(card_played : Card):
	var effect : Dictionary
	var source : Array = System.copy_array(cards_in_graveyard())
	for card in source:
		if System.has_effect(card, "Graveyard", "friend_played"):
			effect = card.effects.Graveyard
			if System.tag_check(card_played, effect.tag) and resolve_check(card, effect, false):
				card.reference_card = card_played
				resolve_effect(card, effect)
	update_powers()

func cards_in_graveyard():
	return graveyard.cards_in_graveyard

func _on_card_zoned(card : Card):
	_on_zone_vacancy([card.card_slot - 1], true)
	card.location = "Field"
	set_is_active(true)
	if current_task == "Placing_Card":
		clear_current_task()
		check_turn_end()
	field.add_card(card)

func check_turn_end():
	chain_turn_end -= 1
	if chain_turn_end == 0:
		manual_phase_change("end")
	
func activate_from_graveyard(card : Card):
	card.allowed_to_highlight = false
	card_mover.toggle_visibility(card, false)
	var effects : Dictionary = card.effects
	for key in effects:
		if key == "ContactFusion":
			activate_contact_fusion(card, effects)
		elif key == "Void":
			activate_void_effect(card)
	task_card(card)
	start_task_pile()

func activate_contact_fusion(card : Card, effects : Dictionary):
	var fusion_conditions : Dictionary = effects.ContactFusion
	var relocation : String = "Default"
	once_per_check(fusion_conditions)
	task_pile_mode = "Play"
	
	for zone in fusion_conditions:
		match zone:
			"Hand":
				task_hand_materials(card, fusion_conditions)
			"Field":
				task_field_materials(card, fusion_conditions)
			"Graveyard":
				task_graveyard_materials(fusion_conditions)
			"Top_of_Deck":
				task_top_of_deck_materials(fusion_conditions)
			"Spend_Plays":
				spend_plays_materials(card, fusion_conditions)
			"Restore_Plays":
				restore_plays_materials(card, fusion_conditions)
			"relocation":
				relocation = fusion_conditions.relocation
		card.relocation = relocation

func task_hand_materials(card : Card, fusion_conditions : Dictionary):
	var conditions : Dictionary = System.repair_effect(fusion_conditions.Hand)
	var task : Dictionary
	var source : Array = hand.cards_in_hand
	var targets : Array
	var pairs : Array
	var subclass : String = conditions.subclass
	var send_to : String = conditions.location
	var original_name : String = card.card_name
	if send_to == "Default":
		send_to = "Graveyard"
	match subclass:
		"Default":
			targets = System.get_tagged_cards(source, conditions.tag, conditions.condition, \
			original_name, conditions.wanted_effect)
			if materials_choice_locked(targets, conditions.amount, send_to):
				for card in targets:
					task = {
						"id" : "Discard",
						"tag" : card.card_name,
						"send_to" : send_to
					}
					new_task(task)
				return
			elif System.get_single_cards(targets).size() == 1:
				task = {
					"id" : "Discard",
					"tag" : targets[0].card_name,
					"amount" : conditions.amount,
					"send_to" : send_to
				}
				new_task(task)
				return
			task = {
				"id" : "Hand",
				"subclass" : "tag",
				"tag" : conditions.tag,
				"amount" : conditions.amount,
				"send_to" : send_to,
				"condition" : conditions.condition,
				"original_name" : original_name,
				"wanted_effect" :  conditions.wanted_effect
			}
			new_task(task)
		"Duplicates":
			pairs = System.get_pairs(source, conditions.amount)
			if pairs.size() == 1:
				task = {
					"id" : "Discard",
					"tag" : pairs[0],
					"amount" : conditions.amount
				}
				new_task(task)
			elif pairs.size() > 1:
				task = {
					"id" : "Hand",
					"subclass" : "Duplicates",
					"tag" : conditions.tag,
					"amount" : conditions.amount,
					"send_to" : send_to
				}
				new_task(task)

func task_field_materials(card : Card, fusion_conditions : Dictionary):
	var conditions : Dictionary = System.repair_effect(fusion_conditions.Field)
	var source : Array = field.cards_on_field
	var task : Dictionary
	var targets : Array
	var subclass : String = "friends"
	var send_to : String = conditions.location
	if conditions.column[0] > 0:
		subclass = "column"
	if send_to == "Default":
		send_to = "Graveyard"
	match conditions.restriction:
		"Enemy":
			source = field.enemy_field
	match subclass:
		"column":
			for column in conditions.column:
				task = {
					"id" : "Field",
					"subclass" : "column",
					"column" : column,
					"send_to" : send_to
				}
				new_task(task)
		"friends":
			targets = System.get_tagged_cards(source, conditions.tag, \
			conditions.condition, card.card_name, conditions.wanted_effect)
			if materials_choice_locked(targets, conditions.amount, send_to):
				for target in targets:
					task = {
						"id" : "Field",
						"subclass" : "column",
						"column" : target.card_slot,
						"send_to" : send_to,
						"source" : source
					}
					new_task(task)
				return
			task = {
				"id" : "Field",
				"subclass" : "tag",
				"tag" : conditions.tag,
				"amount" : conditions.amount,
				"condition" : conditions.condition,
				"wanted_effect" : conditions.wanted_effect,
				"send_to" : send_to,
				"source" : source
			}
			new_task(task)

func materials_choice_locked(targets : Array, number_of_cards : int, send_to : String):
	return targets.size() == number_of_cards and  \
	(send_to != "Top_of_Deck" or System.get_singles(targets, true).size() == 1)

func task_graveyard_materials(fusion_conditions : Dictionary):
	var conditions : Dictionary = System.repair_effect(fusion_conditions.Graveyard)
	var targets : Array
	var send_to : String = conditions.location
	if send_to == "Default":
		send_to = "Void"
	targets = get_void_targets(conditions.condition, conditions.tag, conditions.target, \
	conditions.reference, conditions.reference_target)
	task_void_cost(targets, conditions.amount, conditions.tag, conditions.condition, \
	send_to, conditions.reference, conditions.reference_target)

func task_top_of_deck_materials(fusion_conditions : Dictionary):
	var conditions : Dictionary = System.repair_effect(fusion_conditions.Top_of_Deck)
	var send_to : String = conditions.location
	if send_to == "Default":
		send_to = "Graveyard"
	for i in range(conditions.amount):
		if deck.cards_in_deck.size() == 0:
			break
		relocation_confirmed(deck.cards_in_deck[0], send_to)

func spend_plays_materials(card : Card, fusion_conditions : Dictionary):
	var conditions : Dictionary = System.repair_effect(fusion_conditions.Spend_Plays)
	spend_plays(conditions.amount, conditions.target, card)

func restore_plays_materials(card : Card, fusion_conditions : Dictionary):
	var conditions : Dictionary = System.repair_effect(fusion_conditions.Restore_Plays)
	spend_plays(-conditions.amount, conditions.target, card)

func spend_plays(amount : int, target : String = "self", card : Card = null):
	if System.targets_self(target):
		field.plays_spent += amount
		if field.plays_spent < 0:
			field.plays_spent = 0
	if System.targets_enemy(target):
		emit_signal("spend_plays", amount)
	if card != null:
		field.paid_card = card

func task_void_cost(targets : Array, cost_amount : int, tag : String = "Null", \
condition : String = "non_fusion", send_to : String = "Void", \
reference : String = "Null", reference_target : String = "self"):
	var task : Dictionary
	if targets.size() == cost_amount:
		task = {
			"id" : "search_graveyard",
			"subclass" : "prechosen",
			"cards" : targets,
			"send_to" : send_to
		}
		new_task(task)
	elif cost_amount > 0:
		task = {
			"id" : "search_graveyard",
			"amount" : cost_amount,
			"tag" : tag,
			"condition" : condition,
			"send_to" : send_to,
			"reference" : reference,
			"reference_target" : reference_target
		}
		new_task(task)

func activate_void_effect(card : Card):
	var effect : Dictionary = card.effects.Void
	var plus : int = 0
	var targets : Array = get_void_targets()
	card.void_effect_initialized = true
	task_pile_mode = "Void"
	for condition in effect:
		if condition == "plus":
			plus = effect.plus
	task_void_cost(targets, plus)

func start_task_pile():
	var task : Dictionary = System.get_next_task(task_pile)
	if !System.is_default(task):
		send_card_to = task.send_to
		got_response = false
		if task.id != last_task:
			last_task = task.id
			previous_targets = []
		if task.id == "Hand":
			reveal_hand(task.tag, task.amount, task.subclass, task.condition, \
			task.original_name, task.wanted_effect)
		elif task.id == "Field":
			if task.source == field.enemy_field:
				close_optional_reveal_piles(true)
			if task.subclass == "column":
				for card in task.source:
					if card.card_slot == task.column:
						relocation_confirmed(card)
						start_task_pile()
						break
			elif task.subclass == "tag":
				reveal_field(task.source, task.tag, task.amount, task.subclass, task.condition, task.wanted_effect)
		elif task.id == "search_graveyard":
			if task.subclass == "prechosen":
				task_void_card(task.cards, task.send_to)
				return
			search_graveyard(task.target, task.tag, task.condition, task.reference, task.reference_target)
		elif task.id == "Discard":
			relocation_confirmed(System.get_tagged_cards(hand.cards_in_hand, task.tag, "absolute")[0])
			start_task_pile()
		return
	task_pile_ready()

func relocation_confirmed(original_card : Card, send_to : String = "Default", attach_to : Card = null, \
relocation : String = "Default"):
	if attach_to == null:
		attach_to = task_pile_card
	if send_to == "Default":
		send_to = send_card_to
	if relocation != "Default":
		original_card.relocation = relocation
	if controlled_by_opponent(original_card):
		emit_signal("relocation_confirmed", original_card, send_to, attach_to)
		return
	remove_from_location(original_card)
	original_card.show_sprite()
	for card in System.get_card_plus_attached(original_card):
		card.attached_cards = []
		relocation(card, attach_to, send_to)
	update_powers()

func relocation(card : Card, attach_to : Card, send_to : String):
	if (card.relocation != "Default" or card.instance_class != "Default") \
	and send_to != "Attach":
		send_to = card.relocation
		match card.instance_class:
			"Token":
				send_to = "Void"
		card.relocation = "Default"
	match send_to:
		"Graveyard":
			send_to_grave(card)
		"Void":
			void_card(card)
		"Attach":
			attach_to.attach_card(card)
			_on_move_call(card)
		"Hand":
			hand.add_card(card)
		"Deck":
			deck.shuffle_card(card)
		"Top_of_Deck":
			deck.add_card(card)
		"Play":
			match can_field_take():
				true:
					task_play(card, true)
				false:
					send_to_grave(card)

func send_to_grave(card : Card):
	match card.player_number == player_number():
		true:
			graveyard.add_card(card)
		false:
			card.controlling_player = card.player_number
			card.position.y -= System.resolution.y / 2
			emit_signal("give_control", card)
			emit_signal("send_enemy_graveyard", card)
	card.address.id = "Graveyard"
	_on_move_call(card)
	trigger_card_to_grave_effects(card)

func task_pile_ready():
	legal_targets = []
	selected_card = null
	imprint_to = null
	previous_targets = []
	deactivate_opponent(false)
	if task_pile_mode == "Null":
		pass
	elif task_pile_mode == "Play":
		set_is_active(false)
		task_pile_card.allowed_to_highlight = true
		card_mover.toggle_visibility(task_pile_card, true)
		taskbanner("Select zone to play.")
		set_current_task("Placing_Card")
		field.take_card(task_pile_card)
		task_pile_card = null
		waiting_fors.append("Show_Zones")
		wait_timer.start()
		return
	elif task_pile_mode == "Void":
		resolve_void_effect(task_pile_card)
		return
	task_pile_card = null
	if is_turn_player:
		set_is_active(true)

func deactivate_opponent(boolean : bool = true, force_deactivation : bool = false):
	var message : String = "deactivate"
	if force_deactivation:
		message = "force_deactivation"
	emit_signal("call_opponent", message, boolean)

func hide_graveyard():
	hide_reveal_pile(cards_in_graveyard(), "Graveyard")

func show_reveal_pile(source : Array, task_name : String, address_id : String,
message : String, tag : String = "Null", amount : int = 1, subclass : String = "Default", \
condition : String = "Null", original_card_name : String = "Null", wanted_effect : Dictionary = {}):
	var target_options : Array = legal_targets
	if legal_targets.size() == 0:
		target_options = get_target_options(source, tag, amount, subclass, condition, \
		original_card_name, wanted_effect)
	taskbanner(message)
	set_current_task(card_mover.show_content(current_task, task_name, target_options, address_id), false)
	if current_task == task_name:
		current_focus = current_task
		legal_targets = System.copy_array(target_options)
		return
	waiting_values = [source, task_name, address_id, message, tag, amount, subclass, \
	condition, original_card_name, wanted_effect]
	waiting_fors.append("Show_Reveal_Pile")
	wait_timer.start()

func hide_reveal_pile(reveal_pile : Array = [], address : String = "Null"):
	taskbanner()
	if address != "Null":
		current_task = card_mover.hide_content(current_task, reveal_pile, address)
	if current_task == "Null":
		current_focus = current_task
	start_task_pile()

func reveal_hand(tag : String, amount : int, subclass : String, condition : String, \
original_name : String, wanted_effect : Dictionary):
	var source : Array = hand.cards_in_hand
	var message : String = "Choose material from hand."
	if choice_locked_check("Hand", tag, condition, original_name, wanted_effect):
		return
	show_reveal_pile(source, "Revealing_Hand", "From_Hand", message, tag, amount, subclass, \
	condition, original_name, wanted_effect)

func hide_hand():
	hide_reveal_pile(hand.cards_in_hand, "Hand")

func reveal_field(source : Array, tag : String, amount : int, subclass : String, \
condition : String, wanted_effect : Dictionary):
	taskbanner("Choose material from field.")
	if choice_locked_check("Field", tag, condition, "Null", wanted_effect):
		return
	set_current_task("Revealing_Field")
	if legal_targets.size() == 0:
		legal_targets = System.copy_array(get_target_options(source, tag, amount, \
		subclass, condition, "Null", wanted_effect))
	field.material_target(legal_targets)

func hide_field():
	hide_reveal_pile()

func reveal_attachments(card : Card):
	var source : Array = card.attached_cards
	var message : String = "Attached to " + System.shorten_name(card.card_name)
	task_pile_card = card
	task_pile_mode = "Null"
	allow_detach(source)
	show_reveal_pile(source, "Revealing_Attachments", "From_Attached", message)
	
func allow_detach(source : Array):
	for card in source:
		if System.has_effect(card, "Detach") and resolve_check(card, card.effects.Detach, false) \
		and is_turn_player:
			card.allow_to("Detach")

func hide_attachments():
	var source : Array = task_pile_card.attached_cards
	for card in source:
		card.pull_from_action()
	hide_reveal_pile(source, "attached")

func get_target_options(source : Array, tag : String, amount : int, subclass : String, condition, \
original_card_name : String, wanted_effect : Dictionary):
	var target_options : Array
	looking_for = "Null"
	target_options = System.copy_array(System.get_tagged_cards(source, tag, condition, \
	original_card_name), target_options)
	if subclass == "Duplicates":
		looking_for = "duplicates"
		target_options = legal_targets
		if legal_targets == []:
			for card in source:
				if tag != "Null" and card.card_name.find(tag) == -1:
					break
				var cards_to_find : int = amount + 1
				for other_card in source:
					if card.card_name == other_card.card_name:
						cards_to_find -= 1
						if cards_to_find == 0:
							target_options.append(card)
							break
	elif condition == "different_names":
		looking_for = "different_names"
	wanted_effect = System.repair_wanted_effect(wanted_effect)
	if wanted_effect.type != "Null":
		target_options = System.get_cards_with_effect(target_options, wanted_effect)
	return target_options

func _on_WaitTimer_timeout():
	var waiting_for : String = waiting_fors[0]
	waiting_fors.erase(waiting_for)
	if waiting_fors.size() == 0:
		wait_timer.stop()
	if waiting_for == "Show_Reveal_Pile":
		show_reveal_pile(waiting_values[0], waiting_values[1], waiting_values[2],
		waiting_values[3], waiting_values[4], waiting_values[5], waiting_values[6],
		waiting_values[7], waiting_values[8], waiting_values[9])
	elif waiting_for == "Show_Zones":
		field.show_zones()
	elif waiting_for == "Search_Graveyard":
		search_graveyard(waiting_values[0], waiting_values[1], waiting_values[2], waiting_values[3], waiting_values[4])
	elif waiting_for == "Playing_Hand":
		play_from_hand(waiting_values[0])
	elif waiting_for == "Playing_Grave":
		play_from_graveyard(waiting_values[0], waiting_values[1], waiting_values[2], waiting_values[3], waiting_values[4])
	elif waiting_for == "Searching_Deck":
		_on_search_mode(waiting_values[0], waiting_values[1], waiting_values[2])
	elif waiting_for == "Void_Card":
		task_void_card(waiting_values[0], waiting_values[1])
	elif waiting_for == "Send_Call_Response":
		send_call_response()
	elif waiting_for == "Phase_Procedure":
		phase_procedure()
	elif waiting_for == "Close_Optional_Reveal_Piles":
		close_optional_reveal_piles()

func _on_card_discarded(card : Card):
	relocation_confirmed(card, "Graveyard")

func destroy_zoned_cards(zone_numbers : Array, restriction : String, power_gain_card : Card):
	var destroyed_cards = get_destroyed_cards(zone_numbers, restriction)
	var cards_destroyed : int
	for card in destroyed_cards:
		if field.card_destroyed(card):
			cards_destroyed += 1
	if power_gain_card != null:
		power_gain_card.passive_power += cards_destroyed
		update_powers()

func get_destroyed_cards(zone_numbers : Array, restriction : String):
	var destroyed_cards : Array
	var restricted : bool
	for card in System.get_tagged_cards(field.cards_on_field, "Null", restriction):
		if zone_numbers.has(card.card_slot):
			destroyed_cards.append(card)
	return destroyed_cards

func _on_mill_effect(target : String, number_of_cards : int, reference : String, \
reference_target : String, tag : String):
	var player_number : int = player_number()
	if reference == "Null":
		pass
	elif reference == "cards_sent_to_grave":
		number_of_cards = field.count_cards_sent_to_grave(reference_target, tag)
	if target == "enemy":
		player_number = System.opposite_player(player_number)
	emit_signal("_on_cards", "Mill", player_number, number_of_cards)
	
func _on_card_milled(card : Card):
	relocation_confirmed(card, "Graveyard")

func _on_draw_effect(target : String, number_of_cards : int, subclass : String):
	var player_number : int = player_number()
	match subclass:
		"Until":
			number_of_cards = number_of_cards - hand.cards_in_hand.size()
	if number_of_cards < 1:
		return
	if System.targets_enemy(target):
		player_number = System.opposite_player(player_number())
	emit_signal("_on_cards", "Draw", player_number(), number_of_cards)

func response_call(id : String, player_number : int, number_of_cards : int):
	var effect : Dictionary
	var response_card : Card
	if turn_number < 1:
		pass
	for card in hand.cards_in_hand:
		if System.has_effect(card, "Hand", "Response", "subclass", id):
			effect = System.repair_effect(card.effects.Hand)
			if !resolve_check(card, effect):
				continue
			match effect.tag:
				"reverse":
					player_number = System.opposite_player(player_number)
			response_card = card
			break
	emit_signal("effect_response", id, player_number, number_of_cards)
	pay_response_effect(response_card)

func pay_response_effect(card : Card):
	if card != null:
		hand.discard_card(card)
		hand.position_cards_in_hand()

func search_graveyard(target : String, tag : String, condition : String, \
reference : String, reference_target : String):
	var target_options : Array = get_void_targets(condition, tag, target, reference, reference_target)
	if target_options.size() == 0:
		start_task_pile()
		return
	var message : String = "Select void target."
	if send_card_to == "Attach":
		message = "Select card to attach."
	var task_call : String = "Search_Graveyard"
	is_active = false
	if target == "enemy":
		message = "Select enemy void target."
		task_call = "Search_Enemy_Grave"
		deactivate_opponent()
	if target == "self" or got_response:
		set_current_task(card_mover.show_content(current_task, task_call,  target_options, "From_Graveyard"), false)
	if current_task == "Search_Graveyard" or current_task == "Search_Enemy_Grave":
		taskbanner(message)
		current_focus = current_task
		legal_targets = System.copy_array(target_options)
		return
	waiting_values = [target, tag, condition, reference, reference_target]
	waiting_fors.append("Search_Graveyard")
	wait_timer.start()

func get_void_targets(condition : String = "non_fusion", tag : String = "Null",  \
target : String = "self", reference : String = "Null", reference_target : String = "self"):
	var void_targets : Array
	var source : Array = cards_in_graveyard()
	if target == "enemy":
		source = field.enemy_graveyard
	void_targets = System.get_tagged_cards(source, tag, condition)
	if reference == "Null":
		pass
	elif reference == "cards_sent_to_grave":
		void_targets = System.find_cards(void_targets, field.get_cards_sent_to_grave(reference_target))
	return void_targets

func hide_graveyard_void_targets():
	var source : Array = cards_in_graveyard()
	taskbanner()
	if current_task == "Search_Enemy_Grave":
		source = field.enemy_graveyard
	set_current_task(card_mover.hide_content(current_task, source, "Graveyard"))
	if System.has_effect(task_pile_card, "Void"):
		task_pile_mode = "Void"
	start_task_pile()

func void_card(card : Card):
	card_mover.void_card(card)

func task_void_card(source : Array, send_to : String):
	if !card_mover.busy():
		for card in source:
			relocation_confirmed(card, send_to)
		start_task_pile()
		return
	waiting_fors.append("Void_Card")
	waiting_values = [source, send_to]
	wait_timer.start()

func remove_from_location(card : Card, instant_position : bool = false):
	card_mover.pull_card(card)
	card.clear_transformation()
	match card.location:
		"Graveyard":
			match card.player_number == player_number():
				true:
					graveyard.pull_card(card)
				false:
					emit_signal("remove_from_location", card, instant_position)
			if instant_position:
				card.position = graveyard.rect_position
		"Hand":
			hand.pull_card(card)
			hand.position_cards_in_hand()
		"Field":
			field.remove_from_field(card)
		"Deck":
			deck.pull_card(card)
		"Attached":
			if card.attached_to != null:
				card.attached_to.attached_cards.erase(card)
				card.location = card.attached_to.location
				card.position = card.attached_to.position
				card.attached_to = null

func resolve_void_effect(card : Card):
	var void_effect : Dictionary
	if card.void_effect_initialized:
		card.void_effect_initialized = false
		void_effect = card.effects.Void
		relocation_confirmed(card, "Void")
		resolve_effect(card, void_effect)
		return
	set_is_active(true)
	
func resolve_effect(card : Card, effect : Dictionary, resolve_tags : Array = []):
	var id : String
	if !resolve_check(card, effect, true, resolve_tags):
		return
	if !resolve_tags.has("Instant"):
		if is_turn_player:
			set_is_active(true)
		task_pile_card = card
	effect = System.repair_effect(effect)
	id = effect.id
	match id:
		"play_from_hand":
			play_from_hand(effect.tag)
		"play_from_graveyard":
			_on_play_from_graveyard(card, effect, effect.instant_position, effect.subclass, effect.tag, \
			effect.condition, effect.wanted_effect, effect.negate_effects, effect.relocation)
		"Search":
			if !_on_card_search(card, effect.subclass, effect.tag, effect.amount, effect.constant, \
			effect.condition, effect.wanted_effect, effect.location):
				return
		"Mill":
			_on_mill_effect(effect.target, effect.amount, effect.reference, effect.reference_target, effect.tag)
		"Destroy":
			no_targets = false
			destroy_enemy(card, effect)
			if no_targets:
				return
		"Draw":
			_on_draw_effect(effect.target, effect.amount, effect.subclass)
		"play_to_column":
			_on_play_to_column(card, effect, effect.tag, effect.subclass, effect.column[0], effect.relocation)
		"Power":
			_on_power_effect(card, effect.subclass, effect.target, effect.condition, \
			effect.power_gain, effect.reduction, effect.reference, effect.reference_target, \
			effect.tag, effect.reference_tag)
		"end_turn":
			chain_turn_end = effect.amount
			check_turn_end()
		"Life":
			life_effect(card, effect)
		"additional_play":
			_on_additional_play(card, effect, effect.location, effect.amount)
		"search_graveyard":
			_on_search_graveyard(card, effect.target, effect.tag, effect.amount, effect.condition, \
			effect.location, effect.reference, effect.reference_target, effect.subclass)
		"Relocation":
			if card.location == "Graveyard" and effect.location == "Void" and negated_check("void_graveyard"):
				return
			relocation_confirmed(card, effect.location, card.reference_card, effect.relocation)
		"restriction":
			_on_restriction(card, effect.subclass, effect.timing, effect.target, effect.amount)
		"extra_turn":
			extra_turn = true
		"transform":
			_on_transform(card, effect)
		"mass_relocate":
			if card.reference_card != null:
				effect.tag = card.reference_card.card_name
				effect.restriction = "absolute"
			_on_mass_relocate(effect.location, effect.relocation, effect.target, effect.tag, effect.restriction)
		"copy_effect":
			copy_effect(card, effect.subclass)
		"Spend_Plays":
			spend_plays(effect.amount, effect.target)
		"play_copy":
			_on_play_copy(card, effect.subclass, effect.tag, effect.wanted_effect, \
			effect.reference, effect.reference_target, effect.reference_tag, effect.source)
		"pathetic_pile":
			_on_pathetic_pile(card, effect, effect.target)
		"Shuffle":
			_on_shuffle(effect.target)
	trigger_chained_effects(card, effect, resolve_tags)
	card.reference_card = null
	chain_turn_end = 0

func trigger_chained_effects(card : Card, effect : Dictionary, resolve_tags : Array):
	match effect.has("Chain"):
		true:
			resolve_effect(card, effect.Chain, resolve_tags)
		false:
			toggle_backlights()

func resolve_check(card : Card, effect : Dictionary, add_to_list : bool = true, resolve_tags : Array = []):
	effect = System.repair_effect(effect)
	var ignore_only : bool = resolve_tags.has("ignore_only")
	if !resolution_conditions(card, effect, ignore_only) or effect_negated(card, effect) or \
	(!ignore_only and !once_per_check(effect, add_to_list) or \
	imprint_failure(card, effect)):
		return false
	return true

func once_per_check(effect : Dictionary, add_to_list : bool = true):
	return field.once_per_check(effect, add_to_list)

func restore_once_pers(effect : Dictionary):
	for key in effect:
		if key == "once_per_game":
			field.once_per_game_effects.erase(effect.once_per_game)
		elif key == "once_per_turn":
			field.once_per_turn_effects.erase(effect.once_per_turn)

func imprint_failure(card : Card, effect : Dictionary):
	if effect.subclass == "Imprint" and imprint_failure_prone_id_s().has(effect.id) \
	and card.imprinted_card == null:
		return true
	return false

func imprint_failure_prone_id_s():
	return ["play_copy"]

func resolution_conditions(card : Card, effect : Dictionary, ignore_only : bool):
	var resolving : bool = true
	var value : int
	var reference : int
	for key in effect:
		match key:
			"turn_number":
				if !System.value_check(turn_number, effect.turn_number):
					resolving = false
			"cards_played":
				value = effect.cards_played
				reference = field.cards_played
				match value >= 20:
					true:
						if ! value / 10 == reference:
							resolving = false
					false:
						if !System.value_check(reference, value):
							resolving = false
			"life":
				if !System.value_check(life_counter.life_total, effect.life):
					resolving = false
			"attached":
				if !ignore_only and (!System.tag_check(card.attached_to, effect.attached) or \
				card.player_number != card.controlling_player):
					resolving = false
			"zone_conditions":
				if !check_free_play_conditions(card, effect.zone_conditions):
					resolving = false
	return resolving

func effect_negated(card : Card, effect : Dictionary):
	var id : String = "Null"
	var effects : Dictionary = card.effects
	for key in effects:
		if effects[key] == effect:
			id = key
	return negated_check(id)

func negated_check(id : String, target : String = "self"):
	if id != "Null":
		for card in field.own_field_plus_attached():
			if has_negation_effect(card, id) and System.targets(get_negation_target(card), target):
				return true
		for card in field.enemy_field_plus_attached():
			if has_negation_effect(card, id) and System.targets(get_negation_target(card), target, true):
				return true
	return false

func _on_negated_check(id : String):
	field.negated = negated_check(id)

func has_negation_effect(card : Card, subclass : String):
	return System.has_effect(card, "Field", "Negate", "subclass", subclass)

func get_negation_target(card : Card):
	var target : String = "self"
	var field_effect : Dictionary = card.effects.Field
	if field_effect.has("target"):
		target = field_effect.target
	return target

func play_from_hand(tag : String):
	var target_options : Array
	if !can_field_take():
		return
	for card in hand.cards_in_hand:
		if System.tag_check(card, tag):
			target_options.append(card)
	if target_options.size() == 0:
		return
	set_current_task(card_mover.show_content(current_task, "Playing_Hand", target_options, "From_Hand"), false)
	if current_task == "Playing_Hand":
		taskbanner("Card from hand to play.")
		set_is_active(false)
		current_focus = current_task
		legal_targets = System.copy_array(target_options)
		return
	waiting_values = [tag]
	waiting_fors.append("Playing_Hand")
	wait_timer.start()

func play_from_graveyard(original_card_name : String, tag : String, condition : String, \
wanted_effect : Dictionary, negate_effects : String):
	var target_options : Array = get_target_options(cards_in_graveyard(), tag, 1, "tag", \
	condition, original_card_name, wanted_effect)
	if target_options.size() == 0 or !can_field_take():
		return
	set_current_task(card_mover.show_content(current_task, "Playing_Grave", target_options, "From_Graveyard"), false)
	if current_task == "Playing_Grave":
		taskbanner("Card from grave to play.")
		set_is_active(false)
		current_focus = current_task
		legal_targets = System.copy_array(target_options)
		negate_these_effects = negate_effects
		return
	waiting_values = [original_card_name, tag, condition, wanted_effect, negate_effects]
	waiting_fors.append("Playing_Grave")
	wait_timer.start()

func _on_play_copy(card : Card, subclass : String, tag : String, wanted_effect, \
reference : String, reference_target : String, reference_tag : String, source : Array):
	var card_name : String = card.card_name
	var imprinted_card = card.imprinted_card
	var unwanted_name : String = "Null"
	negated = false
	if source.has("different_name"):
		unwanted_name = card.card_name
	match subclass:
		"Default":
			if tag != "Null":
				card_name = tag
		"Imprint":
			card_name = imprinted_card.card_name
		"Random":
			card_name = System.database_item(field.get_database(reference, \
			reference_target, reference_tag), random, wanted_effect, unwanted_name)
	if can_field_take():
		emit_signal("generate_card", card_name, player_number(), true)
		if negated:
			return
		relocation_confirmed(card_confirmation_card, "Play")
		card_confirmation_card.instance_class = "Token"
		card_confirmation_card = null
		if can_field_take():
			graveyard.play_animation("PlayCopy")

func _on_WhiteFlag_pressed():
	if AI_check():
		return
	if !is_active:
		return
	if surrender_button.visible:
		hide_surrender_button()
		return
	surrender_button.visible = true
	card_mover.toggle_visibility(surrender_sprite, true)
	surrender_cooldown.start()

func hide_surrender_button():
	surrender_button.visible = false
	card_mover.toggle_visibility(surrender_sprite, false)
	surrender_cooldown.stop()

func _on_SurrenderCooldown_timeout():
	hide_surrender_button()

func _on_Surrender_pressed():
	if AI_check():
		return
	if is_active:
		_on_death("You surrendered, :(")

func _on_play_to_column(card : Card, effect : Dictionary, instant_position : String, \
subclass : String, column : int, relocation : String, original_card : Card = null):
	if card == null or card.location == "Field":
		return
	if original_card == null:
		original_card = card
	match instant_position:
		"rightmost":
			var zone_counter : int = 5
			while zone_counter >= 0:
				if field.column_empty(zone_counter):
					column = zone_counter
					break
				zone_counter -= 1
		"leftmost":	
			var zone_counter : int = 1
			for zone in field.zone_vacancy:
				if !zone:
					column = zone_counter
					break
				zone_counter += 1
		"same_column":
			column = original_card.card_slot
	if column > 0 and field.column_empty(column):
		remove_from_location(card, true)
		card.card_slot = column
		_on_zone_vacancy([column - 1], true)
		card.relocation = relocation
		card_mover.toggle_visibility(card, field.is_active or !is_turn_player)
		field.add_card(card)
		match subclass:
			"Attach":
				relocation_confirmed(find_from_graveyard(original_card.reference_card.card_name, \
				"Null", card), "Attach", card)
		return
	restore_once_pers(effect)

func taskbanner(message : String = "Null", set_current_message : bool = true):
	emit_signal("taskbanner", player_number(), message)
	if set_current_message:
		current_message = message

func close_catalogue_view(card : Card, catalogue_zone : String):
	task_play(card)
	if catalogue_zone == "Hand":
		hand.pull_card(card)
		hide_hand()
	elif catalogue_zone == "Graveyard":
		graveyard.pull_card(card)
		card.negated = negate_these_effects
		negate_these_effects = "Null"
		hide_graveyard()

func task_play(card : Card, start_task_pile : bool = false):
	task_card(card, "Play")
	if start_task_pile:
		start_task_pile()

func task_card(card : Card, mode : String = "Null"):
	task_pile_card = card
	task_pile_card.position = graveyard.rect_position
	if mode != "Null":
		task_pile_mode = mode

func life_effect(card : Card, effect : Dictionary):
	effect = System.repair_effect(effect)
	match effect.subclass:
		"SetLife":
			_on_set_life(effect.constant, effect.target)
			return
	_on_life_effect(card, effect.target, effect.constant, effect.reduction, \
	effect.multiplier, effect.reference, effect.reference_target, effect.tag, \
	effect.subclass)

func _on_life_effect(card : Card, target : String, gain : int, reduction : int,
multiplier : float, reference : String, reference_target : String, tag : String, \
subclass : String):
	var amount : int = (field.count_reference(reference, reference_target, tag) \
	+ gain - reduction) * multiplier
	if System.targets_self(target):
		take_damage(amount)
	if System.targets_enemy(target):
		emit_signal("damage_opponent", amount)
	match subclass:
		"Power":
			resolve_effect(card, {"id" : "Power", "power_gain" : abs(amount)})

func _on_set_life(value : int, target : String = "self"):
	if System.targets_self(target):
		set_life(value)
	if System.targets_enemy(target):
		emit_signal("_on_set_life", value)

func set_life(value : int):
	life_effect(null, {"constant" : value - life_counter.life_total})
	

func find_from_graveyard(tag : String, condition : String = "Null", original_card : Card = null):
	for card in System.get_tagged_cards(cards_in_graveyard(), tag, condition):
		if card != original_card:
			return card
	return null

func new_task(task : Dictionary):
	var id : String = task.id
	System.force_key(task, "amount", 1)
	match id:
		"Discard":
			System.force_key(task, "condition", "Null")
			System.force_key(task, "send_to", "Graveyard")
		"search_graveyard":
			System.force_key(task, "target", "self")
			System.force_key(task, "send_to", "Void")
			System.force_key(task, "subclass", "manual")
		"Hand":
			System.force_key(task, "condition", "Null")
			System.force_key(task, "original_name", "Null")
			System.force_key(task, "wanted_effect", {})
		"Field":
			System.force_key(task, "source", field.cards_on_field)
	task_pile.append(task)	

func close_reveal_pile(card : Card, source : String):
	var filtered_array : Array
	previous_targets.append(card)
	for other_card in legal_targets:
		if remaining_targets_check(other_card):
			filtered_array.append(other_card)
	legal_targets = filtered_array
	if source == "Hand":
		relocation_confirmed(card)
		hide_hand()
	elif source == "Field":
		hide_field()

func remaining_targets_check(card : Card):
	if previous_targets.has(card):
		return false
	if looking_for == "Null":
		pass
	elif looking_for == "duplicates" and System.filter_duplicate_cards(System.get_tagged_cards( \
	previous_targets, card.card_name, "absolute"), previous_targets, true).size() == 0:
		return false
	elif looking_for == "different_names" and System.get_singles( \
	System.get_tagged_cards(previous_targets, card.card_name, "absolute")).size() > 0:
		return false
	return true

func choice_locked_check(zone : String, tag : String, condition : String, \
original_name : String, wanted_effect : Dictionary):
	var options : Array
	var task : Dictionary
	if looking_for == "duplicates":
		options = System.get_singles(System.get_tagged_cards(legal_targets, tag,
		condition, original_name, wanted_effect))
		if options.size() == 1:
			if zone == "Hand":
				task = {
					"id" : "Discard",
					"tag" : options[0],
					"send_to" : send_card_to
				}
			new_task(task)
			start_task_pile()
			return true
	elif looking_for == "different_names":
		options = System.filter_duplicate_cards(legal_targets, previous_targets)
		if options.size() == 1:
			if zone == "Hand":
				task = {
				"id" : "Discard",
				"tag" : options[0].card_name,
				"send_to" : send_card_to
			}
			if zone == "Field":
				task = {
				"id" : "Field",
				"subclass" : "column",
				"column" : options[0].card_slot,
				"send_to" : send_card_to
			}
			new_task(task)
			start_task_pile()
			return true
	return false

func _on_play_from_graveyard(card : Card, effect : Dictionary, instant_position : String, subclass : String, \
tag : String, condition : String, wanted_effect : Dictionary, negate_effects : String, relocation : String):
	if instant_position == "Null":
		play_from_graveyard(card.card_name, tag, condition, wanted_effect, negate_effects)
	elif instant_position != "Null":
		_on_play_to_column(find_from_graveyard(tag, condition), effect, instant_position, \
		subclass, 0, relocation, card)

func _on_additional_play(card : Card, effect : Dictionary, location : String, amount : int):
	var active_zone : Control
	if location == "Default":
		location = "Hand"
	match location:
		"Hand":
			hand.plays_left += amount
			return
		"Deck":
			active_zone = deck
		"Graveyard":
			active_zone = graveyard
	active_zone.plays_left.insert(0, System.convert_additional_play(card, effect))

func spend_play(card : Card, active_zone : Control, effect_type : String = "Null"):
	if System.has_effect(card, effect_type):
		once_per_check(card.effects[effect_type])
	System.spend_play(card, active_zone.plays_left)

func _on_card_sent_to_grave(card : Card, sender : String):
	var card_name : String = card.card_name
	if sender == "self":
		card.address.id == "Graveyard"
		_on_move_call(card)
		field.own_cards_sent_to_grave.append(card)
		emit_signal("card_sent_to_grave", card, "enemy")
		return
	field.enemy_cards_sent_to_grave.append(card)

func session_log_update():
	emit_signal("session_log_update")

func _on_session_log_update():
	var session_log : Dictionary = System.get_session_log()
	var speed : int = session_log.game_speed
	settings_tab.session_log_update()
	card_mover.set_movement_speed(speed)
	AI_default_speed = (85.0 - speed) / 100
	AI_hastened_speed = AI_default_speed / 3
	phase_change_timer.wait_time = (100.0 - speed) / 100

func AI_check(AI_initiated : bool = false):
	return is_AI_controlled and !AI_initiated

func _on_AIRefreshTimer_timeout():
	if card_mover.busy():
		return
	elif AI_clear_task():
		return
	elif AI_try_attack():
		return
	elif AI_try_play():
		return
	elif AI_try_activate_effects():
		return
	AI_turn_procedure()

func AI_turn_procedure():
	if hand.cards_in_hand.size() >= 1 and System.random_chance(3, 10, random):
		hand.shuffle_hand()
		return
	_on_PhaseButton_pressed(true)

func AI_try_play(initialize : bool = true):
	if stack_free():
		return AI_try_restore_plays(initialize) or AI_try_play_from_hand(initialize) or \
		AI_try_play_from_deck(initialize) or AI_try_play_from_graveyard(initialize)
	return false

func AI_try_restore_plays(initialize : bool):
	var possible_targets : Array
	if field.plays_spent == 0:
		return false
	for card in cards_in_graveyard():
		if System.has_fusion_zone(card, "Restore_Plays") and \
		check_fusion_conditions(card, true):
			possible_targets.append(card)
	if possible_targets.size() > 0:
		if initialize:
			AI_target_card = System.random_item(possible_targets, random)
			_on_GraveButton_pressed(true)
		return true
	return false

func AI_try_play_from_hand(initialize : bool):
	var targeted_zone : int
	var targeted_card : Card
	var source : Array = System.filter_fusion(hand.cards_in_hand)
	if source.size() > 0 and can_field_take():
		if get_free_play_cards().size() > 0:
			targeted_card = AI_get_card_from_hand_to_play(get_free_play_cards())
		elif hand.plays_left > 0:
			targeted_card = AI_get_card_from_hand_to_play(source)
		if targeted_card == null:
			return false
		if initialize:
			targeted_zone = AI_get_zone_to_play(targeted_card)
			AI_play_from_hand(targeted_card, targeted_zone)
		return true
	return false

func AI_try_play_from_deck(initialize : bool):
	if !deck.backlight_on:
		return false
	if is_deck_active():
		if initialize:
			_on_DrawButton_pressed(true)
		return true
	return false

func AI_get_zone_to_play(card : Card):
	var vacant_zones : Array
	var zone_number : int = 1
	for zone in field.zone_vacancy:
		if !zone:
			vacant_zones.append(zone_number)
		zone_number += 1
	if System.has_effect(card, "Play", "Destroy", "subclass", "own_column"):
		vacant_zones = get_same_column_destroyable_zones(card, vacant_zones)
	elif System.has_effect_plus_attached(card, "Field", "Null", "column"):
		vacant_zones = filter_column_active_zones(card, vacant_zones)
	elif System.has_effect_plus_attached(card, "Detach", "Null", "column"):
		vacant_zones = filter_column_restrictive_zones(card, vacant_zones)
	if !System.has_effect(card, "Once"):
		vacant_zones = get_zones_to_meet_fusion_conditions(vacant_zones)
	return System.random_item(vacant_zones, random)

func filter_column_active_zones(original_card : Card, vacant_zones : Array):
	var filtered_array : Array
	var card_plus_attached : Array = System.get_card_plus_attached(original_card)
	var column : int
	for card in card_plus_attached:
		if System.has_effect(card, "Field", "Null", "column"):
			column = card.effects.Field.column[0]
			if vacant_zones.has(column):
				filtered_array.append(column)
	return System.return_filtered_targets(vacant_zones, filtered_array)

func filter_column_restrictive_zones(original_card : Card, vacant_zones : Array):
	var filtered_array : Array
	filtered_array = System.copy_array(vacant_zones, filtered_array)
	for card in original_card.attached_cards:
		if System.has_effect(card, "Detach", "Null", "column"):
			filtered_array.erase(card.effects.Detach.column)
	return System.return_filtered_targets(vacant_zones, filtered_array)

func get_zones_to_meet_fusion_conditions(vacant_zones : Array):
	var filtered_array : Array
	var fusion_conditions : Dictionary
	var field_conditions : Dictionary
	for fusion in AI_get_fusion_plans(true):
		fusion_conditions = fusion.effects.ContactFusion
		if fusion_conditions.has("Field"):
			field_conditions = fusion_conditions.Field
			if field_conditions.has("column"):
				for column in field_conditions.column:
					if vacant_zones.has(column):
						filtered_array.append(column)
	return System.return_filtered_targets(vacant_zones, filtered_array)

func get_same_column_destroyable_zones(card : Card, vacant_zones : Array):
	var filtered_array : Array
	var destroy_effect : Dictionary = card.effects.Play
	var card_slot : int
	System.force_key(destroy_effect, "restriction", "Null")
	for enemy in get_destroy_effect_targets(destroy_effect.restriction):
		card_slot = mirror_target_slot(enemy.card_slot)
		if vacant_zones.has(card_slot):
			filtered_array.append(card_slot)
	return System.return_filtered_targets(vacant_zones, filtered_array)

func can_field_take():
	return field.first_vacant_zone() > 0

func get_free_play_cards():
	var free_cards : Array
	for card in hand.cards_in_hand:
		hand_active_effect_check(card)
		if card.free_play:
			free_cards.append(card)
			card.free_play = false
	free_cards = filter_by_no_friends_condition(free_cards)
	return free_cards

func filter_by_no_friends_condition(source : Array):
	var filtered_array : Array
	for card in source:
		if System.has_effect(card, "Hand", "free_play", "restriction", "no_friends"):
			filtered_array.append(card)
	return System.return_filtered_targets(source, filtered_array)

func AI_get_card_from_hand_to_play(possible_targets : Array = hand.cards_in_hand):
	possible_targets = AI_filter_play_targets(possible_targets)
	possible_targets = System.filter_fusion(possible_targets)
	return System.random_item(possible_targets, random)

func AI_filter_play_targets(possible_targets : Array, filter_mode : bool = false):
	var filtered_targets : Array
	filtered_targets = filter_play_value(possible_targets, true)
	possible_targets = System.return_filtered_targets(possible_targets, filtered_targets)
	filtered_targets = System.filter_target_cards_by_effects(possible_targets, System.AI_play_filters)
	return filtered_targets

func filter_play_value(source : Array, filter_mode : bool = false):
	var filtered_array : Array
	for card in source:
		if has_play_value(card) == filter_mode:
			filtered_array.append(card)
	return filtered_array

func AI_play_from_hand(targeted_card : Card, targeted_zone : int, AI_initalized : bool = true):
	hand.filled_zone = targeted_zone
	_on_zone_vacancy([targeted_zone - 1], true)
	hand_active_effect_check(targeted_card)
	hand.free_play_check(targeted_card)
	hand.play_card(targeted_card)

func AI_try_play_from_graveyard(initialize : bool):
	var possible_targets : Array = AI_get_fusions_to_play()
	if get_additional_play_choices_in_graveyard().size() > 0:
		if initialize:
			_on_GraveButton_pressed(true)
		return true
	elif possible_targets.size() > 0:
		if initialize:
			AI_target_card = System.random_item(possible_targets, random)
			_on_GraveButton_pressed(true)
		return true
	return false

func get_additional_play_choices_in_graveyard():
	var source : Array = cards_in_graveyard()
	var database : Array = System.convert_dictionaries_database(graveyard.plays_left)
	var possible_targets : Array
	if database.size() > 0 and System.any_tag_found(source, \
	database) != null and can_field_take():
		possible_targets = System.get_cards_multiple_tags(source, database)
		possible_targets = AI_filter_play_targets(possible_targets)
	return possible_targets

func AI_get_fusions_to_play():
	var targets : Array
	for card in AI_get_fusion_plans():
		if check_fusion_conditions(card, true):
			targets.append(card)
	return targets

func AI_get_fusion_plans(include_valueless : bool = false):
	var targets : Array
	for card in cards_in_graveyard():
		card.card_slot = 0
		if System.has_effect(card, "ContactFusion") and resolve_check(card, \
		card.effects.ContactFusion, false) and (has_once_per_value(card) or \
		has_attaching_value(card) or has_hand_advance_value(card) or \
		card_advantage_free_materials(card) or has_once_value(card) \
		or include_valueless):
			targets.append(card)
	return targets

func card_advantage_free_materials(card : Card):
	return (System.has_fusion_zone(card, "Top_of_Deck") or \
	System.has_fusion_condition(card, "Spend_Plays", "target", "enemy")) \
	and (!System.has_effect(card, "Play") or !effect_ends_turn(card.effects.Play))

func has_hand_advance_value(card : Card):
	if would_skip_attack() and System.has_fusion_condition(card, \
	"Hand", "amount") and !System.has_effect(card, "ContactFusion", "Null", "once_per_game") \
	and card.effects.ContactFusion.Hand.amount <= hand.cards_in_hand.size() - 2:
		return true
	return false

func has_once_per_value(card : Card):
	return System.has_once_per_play(card) and has_play_value(card)

func has_once_value(card : Card):
	var effect : Dictionary
	var column : int
	if !would_skip_attack() and System.has_effect(card, "Once") and \
	System.has_effect(card, "Field"):
		effect = System.repair_effect(card.effects.Field)
		column = effect.column[0]
		if column > 0:
			if field.zone_vacancy[column - 1]:
				return false
		return true
	return false
	
func has_attaching_value(card : Card):
	var zoned_cards_with_attach_value : int = get_attach_valuable_cards(field.cards_on_field).size()
	var handed_cards_with_attach_value : int = get_attach_valuable_cards(hand.cards_in_hand).size()
	var number_of_cards : int
	if System.has_fusion_condition(card, "Field", "location", "Attach"):
		number_of_cards = 1
		if !would_skip_attack():
			return false
		if System.has_fusion_condition(card, "Field", "amount"):
			number_of_cards = card.effects.ContactFusion.Field.amount
		if number_of_cards <= zoned_cards_with_attach_value:
			return true
	elif System.has_fusion_condition(card, "Hand", "send_to", "Attach"):
		number_of_cards = 1
		if System.has_fusion_condition(card, "Hand", "amount"):
			number_of_cards = card.effects.ContactFusion.Hand.amount 
		if number_of_cards <= handed_cards_with_attach_value:
			return true
	return false

func get_attach_valuable_cards(source : Array):
	var valuable_cards : Array
	for card in source:
		if has_attach_value(card):
			valuable_cards.append(card)
	return valuable_cards

func has_attach_value(original_card : Card):
	var boolean : bool
	var card : Card
	var card_name : String = original_card.card_name
	if original_card.second_name != "Null":
		card_name = original_card.second_name
	card = System.temporary_instance_card(card_name, random)
	boolean = ((System.has_effect(card, "Detach") and has_effect_value( \
	card, card.effects.Detach, "Detach")) or System.attached_share_check(card) or \
	System.has_effect(card, "Field", "Negate") or System.has_effect(card, "Field", "card_to_grave") \
	or original_card.attached_cards.size() > 0) and original_card.attached_cards.size() < 3
	card.queue_free()
	return boolean

func filter_attach_value(source : Array, filter_mode : bool = false):
	var filtered_array : Array
	for card in source:
		if has_attach_value(card) == filter_mode:
			filtered_array.append(card)
	return System.return_filtered_targets(source, filtered_array)

func has_play_value(card : Card):
	var effect : Dictionary
	if System.has_effect(card, "Play"):
		effect = card.effects.Play
		return has_effect_value(card, effect) and !play_effect_depleted(card) and \
		!effect_negated(card, effect)
	elif System.is_fusion_card(card) and System.has_once_per_restriction(card.effects.ContactFusion) \
	and System.has_effect(card, "Death", "bounce_attached"):
		return true
	elif System.has_effect(card, "Once") and !would_skip_attack():
		return true
	return false

func has_effect_value(card : Card, effect : Dictionary, trigger_type : String = "Default"):
	var id : String
	var location : String
	var source : Array
	var local_source : Array
	var value : int
	var life : int = life_counter.life_total
	effect = System.repair_effect(effect)
	id = effect.id
	if !resolve_check(card, effect, false):
		return false
	match id:
		"Null":
			return false
		"Draw":
			match effect.subclass:
				"Until":
					value = hand.cards_in_hand.size()
					if value >= effect.amount or value > 2:
						return false
			if would_get_milled(effect.target, effect.amount):
				return false
		"Mill":
			if would_get_milled(effect.target, effect.amount) or !would_skip_attack() or \
			(trigger_type == "Discard" and hand.cards_in_hand.size() < 4):
				return false
		"Search":
			if deck.card_search(card, effect.tag, effect.amount, effect.condition, \
			effect.wanted_effect).size() == 0:
				return false
		"Life":
			match System.targets_self(effect.target):
				true:
					match effect.constant * effect.multiplier > 0:
						true:
							if would_skip_attack() or (life > System.critical_life_total and \
							trigger_type != "Detach"):
								return false
						false:
							if effect.has("Chain") and life > abs(System.repair_effect( \
							effect.Chain).constant):
								return has_effect_value(card, effect.Chain)
							return false
				false:
					if (effect.reference != "Null" and field.count_reference(effect.reference, \
					effect.reference_target) < 2):
						return false
		"play_from_hand":
			if !play_effect_has_targets(card, effect, hand.cards_in_hand) or attack_locked():
				return false
		"play_from_graveyard":
			if !play_effect_has_targets(card, effect, cards_in_graveyard()) or attack_locked():
				return false
		"Destroy":
			if !destroy_effect_has_targets(card, effect.subclass, effect.restriction, card.card_slot):
				return false
		"play_to_column":
			if !can_play_to_column(effect) or attack_locked():
				return false
		"search_graveyard":
			match effect.location:
				"Graveyard":
					if !has_void_material_value(card):
						return false
				_:
					if would_skip_attack():
						return false
			if field.count_grave(effect.target, effect.tag, effect.condition) < effect.amount:
				return false
		"additional_play":
			if !would_skip_attack() or !can_field_take() or attack_locked():
				return
			location = effect.location
			if location == "Default":
				location = "Hand"
			match location:
				"Hand":
					source = hand.cards_in_hand
					if filter_play_value(System.filter_fusion(hand.cards_in_hand), true).size() \
					< effect.amount:
						return false
				"Deck":
					source = deck.cards_in_deck
				"Graveyard":
					source = cards_in_graveyard()
			if System.get_tagged_cards(source, effect.tag, effect.condition, \
			card.card_name).size() == 0:
				return false
		"transform":
			source = field.enemy_field
			if effect.player != "self":
				match effect.target:
					"top_of_deck":
						local_source = field.enemy_deck
						if would_skip_attack() or System.get_tagged_cards(local_source, effect.tag, \
						"non_transformed").size() < local_source.size() / 2 + 5 or System.get_singles( \
						local_source).size() < 4:
							return false
						return true
				if System.filter_once_value(source, true).size() + System.filter_target_cards_by_effects( \
				source, System.AI_field_material_filters).size() == 0:
					return false
		"Power":
			if !would_skip_attack() or !has_field_advance(effect.target == "next_play") or \
			attack_locked() or (effect.target == "friends" and System.get_tagged_cards(field.cards_on_field, \
			effect.tag).size() == 0):
				return false
		"Relocation":
			if !can_field_take() or attack_locked():
				return false
		"play_copy":
			if !can_field_take():
				return false
			match effect.subclass:
				"Random":
					if System.database_item(field.get_database(effect.reference, \
					effect.reference_target, effect.reference_tag), random, \
					effect.wanted_effect, card.card_name) == "Null":
						return false
		"pathetic_pile":
			if effect.subclass == "Realize" and field.enemy_pathetic_pile.size() < 2:
				return false
	if effect_ends_turn(effect):
		return false
	return true

func effect_ends_turn(effect : Dictionary):
	 return System.effect_has_id_in_chain(effect, "end_turn") and would_skip_attack()

func has_field_advance(needs_plays_left : bool = false):
	var cards_on_field : int = field.cards_on_field.size()
	var boolean : bool
	if needs_plays_left:
		if !AI_try_play(false):
			return false
		cards_on_field += 1
	boolean = cards_on_field > field.enemy_field.size()
	return boolean

func has_void_material_value(card : Card):
	var effect : Dictionary
	for fusion in AI_get_fusion_plans(true):
		if System.has_fusion_condition(fusion, "Graveyard", "reference", "cards_sent_to_grave"):
			effect = System.repair_effect(fusion.effects.ContactFusion.Graveyard)
			if System.tag_check(card, effect.tag) and !has_void_material_targets(card, effect):
				return true
	return false

func destroy_effect_has_targets(card : Card, subclass : String, restriction : String, column : int):
	var targets : Array = get_destroy_effect_targets(restriction)
	match subclass:
		"own_column":
			match column == 0:
				true:
					targets = filter_by_vacant(targets, true, card)
				false:
					targets = filter_by_column(targets, mirror_target_slot(column))
	return targets.size() > 0

func filter_by_column(source : Array, column : int):
	var filtered_array : Array
	for card in source:
		if card.card_slot == column:
			filtered_array.append(card)
	return filtered_array

func filter_by_vacant(source : Array, filter_mode : bool = false, card : Card = null):
	var filtered_array : Array
	var card_slot : int
	var slots_to_open : Array
	for column in System.get_fusion_condition(card, "Field", "column", []):
		slots_to_open.append(column)
	for card in source:
		card_slot = System.mirror_slot(card.card_slot)
		if (!field.zone_vacancy[card_slot - 1] \
		or slots_to_open.has(card_slot)) == filter_mode:
			filtered_array.append(card)
	return filtered_array

func get_destroy_effect_targets(restriction : String):
	var possible_targets : Array
	possible_targets = System.copy_array(field.enemy_field, possible_targets)
	possible_targets = System.get_tagged_cards(possible_targets, "Null", restriction)
	return possible_targets

func play_effect_has_targets(card : Card, effect : Dictionary, source : Array):
	return (System.filter_same_instance(System.get_tagged_cards( \
	source, effect.tag, effect.condition), card).size() > 0) and can_field_take()

func would_skip_attack():
	return current_phase == "main1" and not_first_turn()

func attack_locked():
	var cards_on_field : int = field.count_field()
	var attacks_left : int = field.attacks_left
	return attacks_left >= 0 and attacks_left <= cards_on_field

func not_first_turn():
	return turn_number > 1

func would_get_milled(target : String, number_of_cards : int):
	return System.targets_self(target) and (number_of_cards > deck.cards_in_deck.size())

func can_play_to_column(effect : Dictionary):
	if !can_field_take():
		return false
	if effect.has("column") and field.zone_vacancy[effect.column[0] - 1]:
		return false
	return true

func play_effect_depleted(card : Card):
	if !card.effects.has("Play"):
		return false
	return !once_per_check(card.effects.Play, false)

func filter_play_depleted(source : Array, filter_mode : bool = false):
	var filtered_array : Array
	for card in source:
		if play_effect_depleted(card) == filter_mode:
			filtered_array.append(card)
	return System.return_filtered_targets(source, filtered_array)

func AI_try_attack():
	var possible_attackers : Array = AI_get_attackers()
	if current_phase != "attack":
		return false
	if field.zone_targeting_mode == "attack_target":
		AI_attack()
		return true
	elif possible_attackers.size() > 0 and AI_can_attack():
		possible_attackers = System.return_filtered_targets(possible_attackers, \
		AI_filter_attackers_by_power(possible_attackers))
		AI_initialize_attack(System.random_item(possible_attackers, random))
		return true
	return false

func AI_filter_attackers_by_power(possible_attackers : Array):
	if field.enemy_field.size() == 0:
		return System.filter_highest_power(possible_attackers, true)
	return System.filter_lowest_power(possible_attackers, true)

func AI_can_attack():
	var enemy_field : Array = field.enemy_field
	return enemy_field.size() == 0 or filter_impossible_attack_targets(enemy_field).size() > 0

func AI_get_attackers():
	var attackers : Array
	if field.attacks_left == 0:
		return attackers
	for card in field.cards_on_field:
		if field.has_attacks_left(card):
			attackers.append(card)
	return attackers

func AI_initialize_attack(card : Card):
	AI_confirm_card(card)
	field.allow_zone_confirmation = true

func AI_attack():
	var zone_number : int = AI_get_attack_target()
	if zone_number == 0:
		zone_number = 3
	field._on_zone_confirmed(zone_number)

func AI_get_attack_target():
	var zone_number : int
	var possible_targets : Array
	var filtered_targets : Array
	possible_targets = System.copy_array(field.get_attackable(), possible_targets)
	possible_targets = filter_impossible_attack_targets(possible_targets)
	if !field.can_be_reversed(field.focused_attacker):
		possible_targets = System.filter_target_cards_by_effects(possible_targets, System.AI_attacker_reverser_filters)
	possible_targets = System.filter_target_cards_by_effects(possible_targets, System.AI_attack_target_filters)
	if possible_targets.size() > 0:
		zone_number = mirror_target_slot(System.random_item(possible_targets, random).card_slot)
	return zone_number

func filter_impossible_attack_targets(source : Array):
	var filtered_array : Array
	var effect : Dictionary
	var constant : int
	for card in source:
		if System.has_effect(card, "Field", "attacked", "subclass", "life"):
			effect = card.effects.Field
			constant = 1
			if effect.has("constant"):
				constant = effect.constant
			if life_counter.life_total + constant <= 0:
				continue
		filtered_array.append(card)
	return filtered_array

func AI_clear_task():
	var target : Card
	var source : Array = legal_targets
	var zone_targeting : String = field.zone_targeting_mode
	var possible_targets : Array
	var strings : String
	var filters : Array = System.AI_destroy_target_filters
	if zone_targeting != "Null":
		match zone_targeting:
			"taking_card":
				AI_take_card()
				return true
			"material_target":
				target = AI_get_material_from_field()
				AI_confirm_card(target)
				return true
			"modify_target":
				possible_targets = System.copy_array(field.legal_targets, possible_targets)
				if field.target_formula.subclass == "Transform":
					filters = System.AI_field_material_filters
				possible_targets = System.filter_target_cards_by_effects( \
				System.filter_once_value(possible_targets, true, false), filters)
				field._on_zone_confirmed(mirror_target_slot(System.random_item(possible_targets, random).card_slot))
				return true
	elif current_focus == "Revealing_Field":
		_on_DrawButton_pressed(true)
		close_optional_reveal_piles()
		return true
	elif source.size() > 0:
		if source.has(AI_target_card):
			if AI_target_card.position.y > System.starting_reveal_y:
				card_mover.reveal_up()
				AI_hastened_speed()
				return true
			target = AI_target_card
			AI_target_card = null
		elif target != null:
			AI_target_card = null
		elif target == null:
			possible_targets = System.copy_array(source, possible_targets)
			if current_task == "Playing_Grave":
				possible_targets = filter_play_depleted(possible_targets)
				possible_targets = filter_powerful_fusions(possible_targets, true)
			elif current_task == "Revealing_Grave" and get_additional_play_choices_in_graveyard().size() > 0:
				possible_targets = get_additional_play_choices_in_graveyard()
			elif current_task == "Revealing_Hand":
				possible_targets = System.filter_target_cards_by_effects(source, System.AI_hand_material_filters)
				possible_targets = filter_play_depleted(possible_targets, true)
			elif current_task == "Search_Enemy_Grave":
				possible_targets = System.filter_target_cards_by_effects(source, System.AI_void_enemy_grave_filters)
			elif current_task == "Search_Graveyard":
				match send_card_to:
					"Attach":
						possible_targets = filter_attach_value(source, true)
					"Graveyard":
						possible_targets = System.filter_array(source, field.own_cards_sent_to_grave, false)
			elif current_task == "Revealing_Grave":
				_on_GraveButton_pressed(true)
				return true
			AI_target_card = System.random_item(possible_targets, random)
			return true
		AI_default_speed()
		AI_confirm_card(target)
		return true
	return false

func AI_get_material_from_field():
	var possible_targets : Array
	var card : Card = task_pile_card
	System.copy_array(legal_targets, possible_targets)
	if System.has_fusion_condition(card, "Field", "send_to", "Attach"):
		possible_targets = filter_attach_value(possible_targets, true)
	possible_targets = System.filter_target_cards_by_effects(possible_targets, System.AI_field_material_filters)
	return System.random_item(possible_targets, random)

func AI_default_speed():
	AI_refresh_timer.wait_time = AI_default_speed

func AI_hastened_speed():
	AI_refresh_timer.wait_time = AI_hastened_speed

func AI_take_card():
	if can_field_take():
		field.allow_zone_confirmation = true
		field._on_zone_confirmed(AI_get_zone_to_play(field.card_to_take))

func AI_confirm_card(card : Card):
	highlight_card(card, true)
	confirm_card(card, true)

func get_next_task_key(key : String):
	if task_pile.size() > 0:
		if task_pile[0].has(key):
			return task_pile[0][key]
	return "Null"

func has_next_task_key(id : String):
	if get_next_task_key("id") == id:
		return true
	return false

func AI_try_activate_effects():
	if stack_free():
		return AI_try_activate_hand_effect() or AI_try_activate_detach_effect() or \
		AI_try_activate_void_effect()
	return false

func stack_free():
	return main_phase_check() and task_pile_free()

func AI_try_activate_hand_effect():
	var own_source : Array = field.cards_on_field
	var enemy_source : Array = System.filter_once_value(field.enemy_field, true)
	for card in hand.cards_in_hand:
		if System.targets_enemy(card.allowed_to_attach) and enemy_source.size() > 0:
			match card.position.y <= -System.gain_control_margin:
				true:
					AI_attach_from_hand(card)
				false:
					card.reference_card = System.random_item(enemy_source, random)
					card.address = {
						"id" : "AI_refresh_timer_timeout",
						"position" : Vector2(-card.reference_card.position.x, -System.gain_control_margin)
					}
					card_mover.move_card(card)
			return true
		elif System.targets_self(card.allowed_to_attach):
			if System.has_effect(card, "Detach", "Null", "attached"):
				own_source = System.get_tagged_cards(own_source, card.effects.Detach.attached)
			if own_source.size() == 0:
				return false
			card.reference_card = System.random_item(own_source, random)
			AI_attach_from_hand(card)
			return true
		elif card.allowed_to == "Discard" and has_effect_value(card, card.effects["Discard"], "Discard"):
			hand.activate_discard_effect(card)
			return true
	return false

func AI_attach_from_hand(card : Card):
	var attached_to : Card = card.reference_card
	var card_slot : int = attached_to.card_slot
	card.reference_card = null
	if controlled_by_opponent(attached_to):
		card_slot = mirror_target_slot(card_slot)
		card.controlling_player = System.opposite_player(card.controlling_player)
	hand.filled_zone = card_slot
	hand.attach_card(card)

func controlled_by_opponent(card : Card):
	return card.player_number != player_number()

func AI_try_activate_detach_effect():
	for card in field.cards_on_field:
		for attached_card in card.attached_cards:
			if System.has_effect(attached_card, "Detach") and \
			has_effect_value(attached_card, attached_card.effects.Detach, "Detach"):
				AI_target_card = attached_card
				AI_confirm_card(card)
				return true
	return false

func AI_try_activate_void_effect():
	var possible_targets : Array
	if negated_check("void_graveyard"):
		return false
	for card in cards_in_graveyard():
		if System.has_effect(card, "Void") and graveyard.check_void_conditions(card) \
		and has_effect_value(card, card.effects.Void):
			possible_targets.append(card)
	if possible_targets.size() > 0:
		AI_target_card = System.random_item(possible_targets, random)
		_on_GraveButton_pressed(true)
		return true
	return false

func filter_powerful_fusions(source : Array, filter_mode : bool = false):
	var filtered_array : Array
	for card in source:
		if System.has_effect(card, "ContactFusion") and System.has_effect(card, "Once") \
		 == filter_mode:
			filtered_array.append(card)
	return System.return_filtered_targets(source, filtered_array)

func activate_detach_effect(card : Card):
	relocation_confirmed(card, "Graveyard")
	hide_attachments()
	resolve_effect(card, card.effects.Detach)

func destroy_enemy(card : Card, effect : Dictionary):
	effect = System.repair_effect(effect)
	emit_signal("destroy_enemy", card, effect.subclass, effect.target, effect.restriction, \
	effect.reference, effect.reference_target, effect.source, effect.reference_card, \
	effect.amount)

func _on_search_graveyard(card : Card, target : String, tag : String, number_of_cards : int, \
condition : String, location : String, reference : String, reference_target : String, \
subclass : String):
	if location == "Default":
		location = "Void"
	var task : Dictionary = {
		"id" : "search_graveyard",
		"amount" : number_of_cards,
		"tag" : tag,
		"condition" : condition,
		"send_to" : location,
		"reference" : reference,
		"reference_target" : reference_target
	}
	if System.targets_self(target):
		task["target"] = "self"
		task_search_graveyard(task)
	if System.targets_enemy(target):
		task["target"] = "enemy"
		task_search_graveyard(task)
	match subclass:
		"Imprint":
			imprint_to = card
	task_pile_mode = "Null"
	start_task_pile()

func task_search_graveyard(task : Dictionary):
	if get_void_targets(task.condition, task.tag, task.target, \
	task.reference, task.reference_target).size() >= task.amount and \
	(task.send_to != "Void" or !negated_check("void_graveyard", task.target)):
		set_is_active(false)
		new_task(task)

func listen_opponent(message : String, boolean : bool):
	if message == "deactivate":
		deactivated = boolean
		deactivate(boolean)
	elif message == "force_deactivation":
		if deactivated:
			deactivate(boolean)
	elif message == "response":
		got_response = boolean
		return
	send_call_response()

func deactivate(boolean : bool):
	card_mover.focus_reveal_pile(boolean)
	if !boolean:
		close_optional_reveal_piles()

func send_call_response():
	if card_mover.busy():
		waiting_fors.append("Send_Call_Response")
		wait_timer.start()
		return
	emit_signal("call_opponent", "response", true)

func _input(event : InputEvent):
	var key : String = System.get_input(event)
	var card_slot : int
	var gameplay_shortcuts : Dictionary = System.gameplay_shortcuts
	if !is_turn_player or is_AI_controlled:
		return
	if key != "Null":
		if settings_tab.is_menu_active and key != System.toggle_settings_key:
			settings_tab.setting_shortcuts(key)
		elif gameplay_shortcuts.has(key):
			gameplay_shortcuts(gameplay_shortcuts[key])
		elif System.number_shortcuts.has(key):
			number_shortcuts(int(key))
		elif System.arrow_shortcuts.has(key):
			arrow_shortcuts(key)

func arrow_shortcuts(key : String):
	var source : Array = hand.cards_in_hand
	if current_task != "Null":
		source = legal_targets
	if System.left_keys.has(key):
		hotkey_focused_slot -= 1
		if hotkey_focused_slot < 1:
			hotkey_focused_slot = source.size()
	elif System.right_keys.has(key):
		hotkey_focused_slot += 1
	hotkey_focus_card()

func gameplay_shortcuts(id : String):
	match id:
		"activate":
			hotkey_focus_card(true)
		"cancel":
			cancel_card(field.focused_attacker)
		"deck":
			_on_DrawButton_pressed()
		"graveyard":
			_on_GraveButton_pressed()
		"phase_procedure":
			_on_PhaseButton_pressed()
		"settings":
			settings_tab._on_OpenSettings_pressed()
		"white_flag":
			_on_WhiteFlag_pressed()
		"surrender":
			if surrender_button.visible:
				_on_Surrender_pressed()

func number_shortcuts(card_slot : int):
	var card : Card
	if field.zone_targeting_mode != "Null":
		field._on_zone_confirmed(card_slot)
		return
	card = field.get_zoned_card(card_slot)
	if card != null:
		manual_confirm_card(card)
	if main_phase_check() and task_pile_free() and hand.cards_in_hand.size() > 0 and \
	field.column_empty(card_slot) and (hand.plays_left > 0 or get_free_play_cards().has(card)):
		AI_play_from_hand(hand.cards_in_hand[hotkey_focused_slot - 1], card_slot, false)
		hotkey_focused_slot = 1

func hotkey_focus_card(activate : bool = false):
	var source : Array = hand.cards_in_hand
	var card : Card
	if current_task != "Null":
		source = legal_targets
	elif !is_active:
		source = []
	if source.size() == 0:
		return
	hotkey_focused_slot = System.max_value(hotkey_focused_slot, source.size(), 1)
	card = source[hotkey_focused_slot - 1]
	match activate:
		true:
			match card.allowed_to == "Discard":
				true:
					hand.activate_discard_effect(card)
				false:
					match card.allowed_to_confirm():
						true:
							confirm_card(card)
						false:
							highlight_card(card)
		false:
			flicker_card(card)

func flicker_card(card : Card):
	if card_mover.cards_moving.has(card):
		return
	card.return_address = card.position
	new_animation(card, Vector2(card.position.x, 100))

func manual_confirm_card(card : Card):
	if card.allowed_to_confirm():
		confirm_card(card)
		return
	highlight_card(card)

func update_hand(source : Array, sender : String = "self"):
	match sender:
		"self":
			field.own_hand = source
			emit_signal("update_hand", source, "enemy")
			return
		"enemy":
			field.enemy_hand = System.copy_array(source)

func update_deck(source : Array, sender : String = "self"):
	match sender:
		"self":
			field.own_deck = source
			emit_signal("update_deck", source, "enemy")
		"enemy":
			field.enemy_deck = System.copy_array(source)

func update_field(source : Array, sender : String):
	if sender == "self":
		emit_signal("update_field", source, "enemy")
		return
	field.enemy_field = System.copy_array(source)

func _on_power_effect(card : Card, subclass : String, target : String, condition : String, \
addition : int, reduction : int, reference : String, reference_target : String, tag : String,  \
reference_tag : String):
	var power_gain_targets : Array = [card]
	var power_gain : int
	var absolute_card_name : String = "Null"
	if card.reference_card != null:
		absolute_card_name = card.reference_card.card_name
	power_gain = addition - reduction + field.count_reference(reference, reference_target, \
	reference_tag, condition, absolute_card_name)
	match subclass:
		"becomes":
			power_gain -= 1
		"permanent":
			card.permanent_power += power_gain
			card.toggle_permanent_power()
	match target:
		"next_play":
			field.next_play_power_gain += power_gain
			return
		"all":
			power_gain_targets = field.cards_on_field + field.enemy_field
		"friends":
			power_gain_targets = field.cards_on_field
		"enemies":
			power_gain_targets = field.enemy_field
	grant_passive_power(power_gain_targets, power_gain, tag)

func grant_passive_power(power_gain_targets : Array, power_gain : int, tag : String):
	for card in power_gain_targets:
		if System.tag_check(card, tag):
			card.passive_power += power_gain
	update_powers()

func _on_restriction(card : Card, subclass : String, timing : String, target : String, amount : int):
	if subclass == "max_attacks":
		max_attacks(timing, target, amount)
	elif subclass == "cannot_attack":
		card.attacks_left = 0
		card.can_attack = false

func max_attacks(timing : String, target : String, max_attacks : int):
	if System.targets_self(target):
		match timing:
			"next_turn":
				next_max_attacks = System.max_attacks(next_max_attacks, max_attacks)
			"Now":
				field.attacks_left = System.max_attacks(field.attacks_left, max_attacks)
	elif System.targets_enemy(target):
		emit_signal("max_attacks", timing, "self", max_attacks)

func initialize_max_attacks():
	field.attacks_left = next_max_attacks
	next_max_attacks = -1

func update_life(life_total : int, sender : String = "self"):
	match sender:
		"self":
			field.own_life = life_total
			emit_signal("update_life", life_total, "enemy")
		"enemy":
			field.enemy_life = life_total

func _on_transform(card : Card, effect : Dictionary):
	effect = System.repair_effect(effect)
	if card_confirmation_id == "copy_transform":
		card_confirmation_card.transform_effects(card.card_name)
		card_confirmation_id = "Null"
	transform(card, effect.target, effect.player, effect.reference, \
	effect.reference_target, effect.reference_tag, effect.source, \
	effect.superclass, effect.subclass, effect.tag, effect.wanted_effect, \
	effect.amount, effect.restriction)

func _on_no_targets():
	card_confirmation_id = "Null"
	no_targets = true

func transform(original_card : Card, target : String, player : String, reference : String, \
reference_target : String, reference_tag : String, source_tags : Array, superclass : String,  \
subclass : String, tag : String, wanted_effect : Dictionary, amount : int, restriction : String):
	var source : Array
	var transform_targets : Array
	var database : Array
	match subclass:
		"Copy":
			card_confirmation_card = original_card
			card_confirmation_id = "copy_transform"
	if System.targets_self(player):
		source = System.copy_array(field.cards_on_field)
	if System.targets_enemy(player):
		source = System.copy_array(field.enemy_field, source)
	source = System.get_tagged_cards(source, "Null", restriction)
	match target:
		"self":
			transform_targets.append(original_card)
		"all":
			transform_targets = System.copy_array(source)
		"target":
			field.modify_target("Transform", source_tags, player, amount, restriction, tag)
			return
		"top_of_deck":
			transform_targets = field.get_top_of_deck(player, amount)
	database = field.get_database(reference, reference_target, reference_tag)
	for card in transform_targets:
		card.transform(superclass, subclass, tag, database, wanted_effect, random)
	update_powers()

func allow_hand_actions(boolean : bool, source : Array = hand.cards_in_hand):
	if !boolean:
		return
	for card in source:
		if !(allow_attach(card) or allow_discard(card)):
			card.toggle_backlight(false)

func hand_active():
	return task_pile_cleared() and current_phase != "attack"

func allow_attach(card : Card):
	var effect : Dictionary
	var target : String
	if System.has_effect(card, "Hand", "Attach") and hand_active():
		effect = System.repair_effect(card.effects.Hand)
		if once_per_check(effect, false):
			target = effect.target
			if field.count_field(target) > 0 and stack_free():
				card.allowed_to_attach = target
				card.allow_to("Attach")
				return true
	card.allowed_to_attach = "Null"
	return false

func allow_discard(card : Card):
	var effect : Dictionary
	if System.has_effect(card, "Discard") and hand_active():
		effect = System.repair_effect(card.effects.Discard)
		if resolve_check(card, effect, false):
			card.allow_to("Discard")
			return true
	return false

func task_pile_cleared():
	return task_pile_free() and field.zone_targeting_mode == "Null"

func _on_card_attached(card : Card, caller : String = "Playmat"):
	var attach_to : Card
	if caller == "Hand":
		once_per_check(card.effects.Hand)
	match card.player_number == card.controlling_player:
		true:
			attach_to = field.get_zoned_card(card.card_slot)
		false:
			attach_to = field.get_zoned_card(card.card_slot, field.enemy_field)
			emit_signal("give_control", card)
	relocation_confirmed(card, "Attach", attach_to)
	update_powers()

func trigger_card_to_grave_effects(card_sent_to_grave : Card):
	activate_card_to_grave_effects(field.own_field_plus_attached(), card_sent_to_grave)
	activate_card_to_grave_effects(field.enemy_field_plus_attached(), card_sent_to_grave, false)

func activate_card_to_grave_effects(source : Array, card_sent_to_grave : Card, \
target_self : bool = true):
	var target : String
	var effect : Dictionary
	for card in source:
		target = "self"
		if System.has_effect(card, "Field", "card_to_grave"):
			effect = card.effects.Field
			if effect.has("reference_target"):
				target = effect.reference_target
			match target_self:
				true:
					if !System.targets_self(target):
						continue
				false:
					if !System.targets_enemy(target):
						continue
			card.reference_card = card_sent_to_grave
			resolve_effect(card, effect, ["Instant"])

func _on_shuffle(target : String):
	if System.targets_self(target):
		deck.shuffle_deck()
	if System.targets_enemy(target):
		emit_signal("_on_shuffle", "self")

func _on_mass_relocate(location : String, relocation : String, target : String, \
tag : String, restriction : String):
	var card_mass : Array
	match location:
		"Graveyard":
			card_mass = get_graveyard_mass(target, relocation, tag, restriction)
	for card in card_mass:
		relocation_confirmed(card, relocation)

func get_graveyard_mass(target : String, relocation : String, tag : String, \
restriction : String):
	var void_targets : Array
	if System.targets_self(target) and (!relocation == "Void" or !negated_check( \
	"void_graveyard")):
		void_targets = System.get_tagged_cards(field.own_graveyard, tag, restriction)
	if System.targets_enemy(target) and (!relocation == "Void" or !negated_check( \
	"void_graveyard", "enemy")):
		void_targets += System.get_tagged_cards(field.enemy_graveyard, tag, restriction)
	return void_targets

func copy_effect(card : Card, subclass : String):
	var effects : Dictionary = card.effects
	if subclass == "Default":
		subclass = "Play"
	if effects.has(subclass):
		resolve_effect(card, effects[subclass], ["ignore_only"])

func _on_pathetic_pile(card : Card, effect : Dictionary, target : String):
	if System.targets_enemy(target):
		emit_signal("_on_pathetic_pile", card, effect, "self")
	if System.targets_self(target):
		match effect.subclass:
			"Default":
				if effect.has("Stack"):
					pathetic_pile.append({"card" : card, "effect" : effect.Stack})
				update_pathetic_pile()
			"Realize":
				if System.targets_self(target):
					for realization in pathetic_pile:
						resolve_effect(realization.card, realization.effect)
					pathetic_pile = []

func update_pathetic_pile(pile : Array = pathetic_pile, target : String = "self"):
	match target:
		"self":
			field.own_pathetic_pile = pile
			emit_signal("update_pathetic_pile", pile, "enemy")
		"enemy":
			field.enemy_pathetic_pile = pile
