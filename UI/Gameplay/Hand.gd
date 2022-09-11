extends Control

signal card_focused(card)
signal card_unfocused(card)
signal card_played(card)
signal card_attached(card)
signal slide_card_in_hand()
signal fill_field_zone(slot_numbers, boolean)
signal card_discarded(card)
signal resolve_effect(card, effect)
signal free_play(card)
signal update_hand
signal update_powers
signal allow_hand_actions
signal remove_from_location(card)

onready var tween = $Tween

const x_area : float = 1150.0
const max_margin : int = 300
const card_gap : int = 180

const hand_max_x : int = 525
const hand_min_x : int = -525
const hand_max_y : int = 40
const hand_min_y : int = -190

var cards_in_hand : Array
var player_number : int
var is_active : bool
var is_revealed : bool = true
var plays_left : int
var zone_vacancy : Array
var enemy_zone_vacancy : Array
var filled_zone : int
var is_AI_controlled : int
var random : RandomNumberGenerator = RandomNumberGenerator.new()
var reveal_pile : Array
var graveyard_plane : Dictionary

func add_card(card : Card):
	card.location = "Hand"
	card.is_zone_locked = true
	var relative_y : int = System.hand_position.y
	card.local_address.y = relative_y
	card.connect("focus", self, "_on_card_focused")
	card.connect("unfocus", self, "_on_card_unfocused")
	card.allowed_to_move = is_hand_active()
	card.allowed_to_highlight = true
	allow_hand_actions([card])
	cards_in_hand.append(card)
	update_hand()
	card.card_slot = cram_card()
	position_cards_in_hand()
	activate_effect(card, "Draw")
	if !is_revealed and card.location == "Hand":
		convert_visibility(false, card)
	emit_signal("update_powers")

func allow_hand_actions(source : Array = cards_in_hand):
	emit_signal("allow_hand_actions", true, source)

func position_cards_in_hand():
	var slots : int = cards_in_hand.size()
	var slot_values : Dictionary
	if slots <= 0:
		return
	slot_values = System.get_slot_values(slots, x_area, max_margin, card_gap)
	for card in cards_in_hand:
		card.reduce_touch_area(slot_values.exceed)
		if card.card_slot == 1:
			card.reduce_touch_area(0)
		card.address = {
			"id" : "Slide_Card_In_Hand",
			"position" : System.get_slot_position(card, slot_values)
		}
		emit_signal("slide_card_in_hand", card)
	position_hand_array()

func position_hand_array():
	var updated_array : Array
	var current_slot : int = cards_in_hand.size()
	while current_slot > 0:
		for card in cards_in_hand:
			if card.card_slot == current_slot:
				updated_array.append(card)
				break
		current_slot -= 1
	cards_in_hand = updated_array

func cram_card():
	var card_slot : int = (cards_in_hand.size() / 2) + 1
	for card in cards_in_hand:
		if card.card_slot >= card_slot:
			card.card_slot += 1
	return card_slot

func _on_card_focused(card : Card):
	if is_AI_controlled:
		return
	if is_revealed:
		emit_signal("card_focused", card)

func _on_card_unfocused(card : Card):
	if is_AI_controlled:
		return
	if is_active:
		emit_signal("card_unfocused", card)
		if can_play(card):
			play_card(card)
			return
		elif can_attach(card):
			attach_card(card)
			return
		elif can_discard(card):
			activate_discard_effect(card)
		card.free_play = false
		slide_card(card)

func play_card(card : Card):
	relocation(card)
	emit_signal("card_played", card)

func attach_card(card : Card):
	relocation(card)
	emit_signal("card_attached", card, "Hand")
	allow_hand_actions()

func activate_discard_effect(card : Card):
	if card.allowed_to != "Discard":
		return
	card.trigger = "Discard"
	discard_card(card)

func discard_card(card : Card):
	pull_card(card)
	emit_signal("card_discarded", card)
	activate_effect(card, "Discard")
	allow_hand_actions()

func relocation(card : Card):
	emit_signal("remove_from_location", card)
	position_cards_in_hand()
	card.card_slot = filled_zone

func can_play(card : Card):
	var position : Vector2 = card.position
	if card.is_zone_locked:
		return false
	elif (plays_left > 0 or card.free_play) and !System.is_fusion_card(card) \
	and card_over_field(position) and vacancy_check(position):
		free_play_check(card)
		return true
	return false

func can_attach(card : Card):
	var position : Vector2 = card.position
	if card.is_zone_locked:
		return false
	elif System.targets_self(card.allowed_to_attach) and \
	card_over_field(position) and !vacancy_check(position):
		return true
	elif System.targets_enemy(card.allowed_to_attach) and \
	card_over_enemy_field(position) and enemy_vacant_check(position):
		card.controlling_player = System.opposite_player(card.controlling_player)
		return true
	return false

func can_discard(card : Card):
	var position : Vector2 = card.position
	if !card.allowed_to == "Discard" or card.is_zone_locked:
		return false
	elif card_over_graveyard(position):
		return true
	return false

func card_over_field(position : Vector2):
	return position.x <= hand_max_x and position.x >= hand_min_x and \
	position.y <= hand_max_y and position.y >= hand_min_y

func card_over_enemy_field(position : Vector2):
	position.y += System.gain_control_margin
	return card_over_field(position)

func card_over_graveyard(position : Vector2):
	return System.planes_collide(position, System.card_rect / 2, \
	graveyard_plane.position, graveyard_plane.margins)

func free_play_check(card : Card):
	if !card.free_play:
		plays_left -= 1
	elif card.free_play:
		emit_signal("free_play", card)

func vacancy_check(position : Vector2):
	var slot_number : int = position_to_slot_number(position)
	if !zone_vacancy[slot_number]:
		emit_signal("fill_field_zone", [slot_number], true)
		return true
	return false

func enemy_vacant_check(position : Vector2):
	var slot_number : int = position_to_slot_number(position)
	if enemy_zone_vacancy[slot_number]:
		return true
	return false

func position_to_slot_number(position : Vector2):
	var slot_number : int = System.x_axis_to_zone_number(position.x) - 1
	filled_zone = slot_number + 1
	return slot_number

func pull_card(card : Card):
	card.location = "Null"
	card.address.id = "Null"
	var slot : int = card.card_slot
	for card in cards_in_hand:
		if card.card_slot > slot:
			card.card_slot -= 1
	cards_in_hand.erase(card)
	update_hand()
	card.allowed_to_highlight = false
	card.allowed_to_move = false
	card.toggle_backlight(false)
	card.reduce_touch_area(0)
	card.disconnect("focus", self, "_on_card_focused")
	card.disconnect("unfocus", self, "_on_card_unfocused")

func slide_card(card : Card):
	var relative_position : float = card.position.x
	var slot_counter : int = 0
	var vacant_slots : Array
	for other_card in cards_in_hand:
		vacant_slots.append(other_card.card_slot)
		if other_card.position.x >= relative_position:
			slot_counter += 1
	card.card_slot = slot_counter
	var stuffed_slot : int = 0
	for other_card in cards_in_hand:
		var card_slot : int = other_card.card_slot
		var slot_found : bool = false
		for slot in vacant_slots:
			if slot == card_slot:
				vacant_slots.erase(slot)
				slot_found = true
		if !slot_found:
			stuffed_slot = card_slot
	
	if stuffed_slot > 0:
		var vacant_slot : int = vacant_slots[0]
		var direction_factor : int = 1
		if vacant_slot < stuffed_slot:
			direction_factor = -1
		for other_card in cards_in_hand:
			if other_card.card_slot == stuffed_slot and other_card.instance_id != card.instance_id:
				other_card.card_slot += direction_factor
			elif vacant_slot > stuffed_slot and other_card.card_slot > stuffed_slot and other_card.card_slot < vacant_slot:
				other_card.card_slot += direction_factor
			elif vacant_slot < stuffed_slot and other_card.card_slot < stuffed_slot and other_card.card_slot > vacant_slot:
				other_card.card_slot += direction_factor
	position_cards_in_hand()
	
func zone_visibility(boolean : bool):
	convert_visibility(boolean, self)
	for card in cards_in_hand:
		if !reveal_pile.has(card):
			convert_visibility(boolean, card)
	tween.start()

func convert_visibility(boolean : bool, zone):
	self.visible = boolean
	var tween_values : Array = System.get_tween_values(boolean, zone)
	tween.interpolate_property(zone, tween_values[0], tween_values[1], tween_values[2], tween_values[3])
	is_revealed = false
	if boolean:
		is_revealed = true
	for card in cards_in_hand:
		card.allowed_to_highlight = is_revealed
		if is_active:
			card.allowed_to_move = is_revealed
	
func toggle_active(boolean : bool = is_active):
	is_active = boolean
	for card in cards_in_hand:
		card.allowed_to_move = boolean and !is_AI_controlled
	if boolean:
		position_cards_in_hand()
	allow_hand_actions()

func activate_effect(card : Card, wanted_key : String):
	if card.trigger != wanted_key:
		return
	card.trigger = "Null"
	for key in card.effects:
		if key == wanted_key:
			emit_signal("resolve_effect", card, card.effects[wanted_key])

func shuffle_hand():
	var card_slots : Array
	for card in cards_in_hand:
		card_slots.append(card.card_slot)
	card_slots = System.shuffle_array(card_slots, random)
	for card in cards_in_hand:
		card.card_slot = card_slots[0]
		card_slots.remove(0)
	position_cards_in_hand()

func is_hand_active():
	return is_active and is_revealed

func make_AI_controlled(boolean : bool):
	is_AI_controlled = boolean
	toggle_active()

func update_hand():
	emit_signal("update_hand", cards_in_hand)
