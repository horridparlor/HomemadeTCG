extends Control

signal zone_movement(card)
signal attack_declaration(attacker, target_slot)
signal card_taken(card)
signal card_played
signal activate_effect(card, effect)
signal material_confirmed(card)
signal update_powers(update_other_player)
signal destroy_enemy(card, effect)
signal transform_target(card, effect)
signal set_active(boolean)
signal relocation_confirmerd(card, send_to)
signal update_field(source, sender)
signal update_life(card, effect)
signal close_optional_reveal_piles
signal no_targets
signal negated_check(id)

onready var zone1 = $CardSlots/CardSlot1
onready var zone2 = $CardSlots/CardSlot2
onready var zone3 = $CardSlots/CardSlot3
onready var zone4 = $CardSlots/CardSlot4
onready var zone5 = $CardSlots/CardSlot5
onready var tween = $Tween
onready var UI_buttons = $UIButtons
onready var phase_symbol = $UIButtons/PhaseButton
onready var phase_main1_symbol = $UIButtons/PhaseButton/Main1
onready var phase_attack_symbol = $UIButtons/PhaseButton/Attack
onready var phase_main2_symbol = $UIButtons/PhaseButton/Main2
onready var phase_end_symbol = $UIButtons/PhaseButton/End
onready var zone_targeting_wait = $ZoneTargetingWait

var cards_on_field : Array
var zone_vacancy : Array
var enemy_zone_vacancy : Array
var current_phase_symbol
var focused_attacker : Card
var zone_targeting_mode : String = "Null"
var card_to_take : Card
var once_per_game_effects : Array
var once_per_turn_effects : Array
var enemy_field : Array
var own_hand : Array
var enemy_hand : Array
var own_deck : Array
var enemy_deck : Array
var own_graveyard : Array
var enemy_graveyard : Array
var own_cards_sent_to_grave : Array
var enemy_cards_sent_to_grave : Array
var own_pathetic_pile : Array
var enemy_pathetic_pile : Array
var is_active : bool
var legal_targets : Array
var allow_zone_confirmation : bool
var is_attack_phase : bool
var cards_played : int
var attacks_left : int
var own_life : int
var enemy_life : int
var rounds_lasted : float
var next_play_power_gain : int
var plays_spent : int
var paid_card : Card
var target_formula : Dictionary
var negated : bool

func _ready():
	zone_vacancy = [false, false, false, false, false]
	enemy_zone_vacancy = System.copy_array(zone_vacancy)
	var zones : Array = get_zones()
	var zone_counter : int = 1
	for zone in zones:
		zone.connect("confirmed", self, "_on_zone_confirmed")
		zone.slot_number = zone_counter
		zone_counter += 1

func get_zones():
	return [zone1, zone2, zone3, zone4, zone5]

func make_AI_controlled(boolean : bool):
	for zone in get_zones():
		zone.is_AI_controlled = boolean

func add_card(card : Card):
	card.free_play = false
	card.local_address.y = rect_position.y
	append_to_field(card)
	position_cards_on_field()
	card.location = "Field"
	zone_card(card)
	card.allowed_to_highlight = true
	reset_field_instance(card)
	if is_attack_phase:
		enable_attacking(card)

func grant_play_power_gain(card : Card):
	card.passive_power = 1 + next_play_power_gain
	next_play_power_gain = 0
	update_powers()

func reset_field_instance(card : Card):
	grant_play_power_gain(card)
	card.attacked = false
	card.can_attack = true
	card.rounds_on_the_field = 0
	card.toggle_permanent_power(false)
	for attached_card in card.attached_cards:
		attached_card.card_slot = card.card_slot
	if play_pre_spent(card):
		return
	for key in card.effects:
		match key:
			"Once":
				card.effects.Once.active = true
			"Play":
				trigger_play_effect(card)
	emit_signal("card_played", card)

func play_pre_spent(card : Card):
	if card == paid_card:
		paid_card = null
	elif plays_spent > 0:
		plays_spent -= 1
		get_card_zone(card).animation("PreSpent")
		send_card_to_grave(card)
		return true
	return false

func get_zone(zone_number : int):
	return get_zones()[zone_number - 1]

func get_card_zone(card : Card):
	return get_zone(card.card_slot)

func append_to_field(card : Card):
	cards_on_field.append(card)
	card.connect("transformed", get_card_zone(card), "animation")
	cards_played += 1
	update_field()

func position_cards_on_field():
	var card_slot_counter : int
	var positioned_array : Array
	while card_slot_counter < 5:
		card_slot_counter += 1
		for card in cards_on_field:
			if card.card_slot == card_slot_counter:
				positioned_array.append(card)
				cards_on_field.erase(card)
				break
	cards_on_field = positioned_array
	
func zone_card(card : Card):
	var slot_x_axis : int
	var slot_number : int = card.card_slot
	slot_x_axis = get_zone_position(slot_number).x
	var slot_position : Vector2 = Vector2(slot_x_axis, card.local_address.y)
	var address = {
		"id" : "FieldZone",
		"position" : slot_position
	}
	card.address = address
	emit_signal("zone_movement", card)

func get_zone_position(zone_number : int):
	return get_zone(zone_number).position

func show_zones():
	toggle_zone_visibility(true)

func hide_zones():
	toggle_zone_visibility(false)

func toggle_zone_visibility(boolean : bool):
	for zone in get_zones():
		toggle_visibility(zone.play_zone, boolean)

func zone_visibility(boolean : bool):
	toggle_visibility(self, boolean)
	for card in cards_on_field:
		toggle_visibility(card, boolean)
		card.allowed_to_highlight = boolean

func toggle_visibility(zone, boolean : bool):
	var tween_values : Array = System.get_tween_values(boolean, zone)
	tween.interpolate_property(zone, tween_values[0], tween_values[1], tween_values[2], tween_values[3])
	tween.start()

func trigger_play_effect(card : Card):
	var play_effect : Dictionary = System.repair_effect(card.effects.Play)
	var effect_id : String = play_effect.id
	var number_of_cards : int = 1
	if card.negated == "Play":
		card.negated = "Null"
		return
	emit_signal("activate_effect", card, play_effect)

func toggle_active(boolean : bool):
	is_active = boolean
	toggle_visibility(UI_buttons, boolean)

func phase_symbol(symbol_id : String):
	if current_phase_symbol != null:
		toggle_visibility(current_phase_symbol, false)
		current_phase_symbol = null
	if symbol_id == "main1":
		current_phase_symbol = phase_main1_symbol
	elif symbol_id == "attack":
		current_phase_symbol = phase_attack_symbol
	elif symbol_id == "main2":
		current_phase_symbol = phase_main2_symbol
	elif symbol_id == "end":
		current_phase_symbol = phase_end_symbol
	if current_phase_symbol != null:
		toggle_visibility(current_phase_symbol, true)

func start_attack_phase():
	toggle_attack_phase(true)
	for card in cards_on_field:
		if !card.can_attack:
			card.can_attack = true
			continue
		enable_attacking(card)

func enable_attacking(card : Card):
	restore_attacks(card)
	update_powers()

func end_attack_phase():
	toggle_attack_phase(false)
	for card in cards_on_field:
		card.attacks_left = 0
		card.toggle_confirm_button(false)

func toggle_attack_phase(boolean : bool):
	is_attack_phase = boolean
	toggle_zone_visibility(boolean)

func restore_attacks(card : Card):
	if is_active:
		card.attacks_left = 1

func visualize_attacks_left(card : Card):
	var boolean : bool
	if  attacks_left != 0 and has_attacks_left(card):
		boolean = true
	card.toggle_confirm_button(boolean)

func can_attack(card : Card = null):
	if card != null:
		for attached_card in card.attached_cards:
			if System.has_effect(attached_card, "Field", "Attached") and \
			attached_card.effects.Field.source.has("no_attacks") and \
			attached_card.controlling_player != attached_card.player_number:
				return false
	if enemy_field.size() == 0:
		return true
	for card in enemy_field:
		if can_pay_attacked_cost(card):
			return true
	return false

func has_any_attacks():
	for card in cards_on_field:
		if has_attacks_left(card):
			return true
	return false

func has_attacks_left(card : Card):
	return can_attack(card) and card.attacks_left + \
	get_extra_attacks_plus_attached(card) > 0

func get_extra_attacks_plus_attached(original_card : Card):
	var extra_attacks : int
	var field_effect_active : bool
	for card in System.get_card_plus_attached(original_card):
		if System.has_effect(card, "Field", "extra_attacks"):
			field_effect_active = false
			match card == original_card:
				true:
					field_effect_active = !System.has_effect(card, "Field", "Null", \
					"subclass", "Attached")
				false:
					field_effect_active = System.attached_share_check(card)
			if field_effect_active:
				extra_attacks += get_extra_attacks(card)
	return extra_attacks

func get_extra_attacks(card : Card):
	var effect : Dictionary = System.repair_effect(card.effects.Field)
	var extra_attacks : int = effect.amount
	var reference_material : Dictionary = {"Default" : null}
	var additional : bool = true
	match effect.subclass:
		"Up_to":
			additional = false
	match effect.reference:
		"cards_on_field":
			match effect.restriction:
					"Null":
						reference_material = {
							"own" : own_field_plus_attached(),
							"enemy" : enemy_field_plus_attached()
						}
					"friends":
						reference_material = {
							"own" : cards_on_field,
							"enemy" : enemy_field
						}
	if !System.is_default(reference_material):
		extra_attacks = System.get_cards(effect.tag, reference_material.own, \
		reference_material.enemy, effect.reference_target, effect.condition).size()
	if !additional and extra_attacks > 0:
		extra_attacks -= 1
	return extra_attacks

func attack(card : Card):
	card.toggle_confirm_button(false)
	card.toggle_cancel_button(true)
	card.allow_to("Attack")
	focused_attacker = card
	initialize_zone_targeting("attack_target")

func initialize_zone_targeting(mode : String):
	toggle_zone_targeting_UI(true)
	zone_targeting_mode = mode

func once_per_check(effect : Dictionary, add_to_list : bool = true):
	for key in effect:
		if key == "once_per_game":
			var restricted_name : String = effect.once_per_game
			if once_per_game_effects.has(restricted_name):
				return false
			if add_to_list:
				once_per_game_effects.append(restricted_name)
		elif key == "once_per_turn":
			var restricted_name : String = effect.once_per_turn
			if once_per_turn_effects.has(restricted_name):
				return false
			if add_to_list:
				once_per_turn_effects.append(restricted_name)
	return true

func modify_target(id : String, source_tags : Array, target : String, amount : int, \
restriction : String, tag : String = "Null", reference_card : Card = null):
	var subclass : String = source_tags[0]
	legal_targets = []
	if System.targets_self(target):
		legal_targets = System.copy_array(cards_on_field, legal_targets)
	if System.targets_enemy(target):
		legal_targets = System.copy_array(enemy_field, legal_targets)
		
	if restriction == "fusion":
		legal_targets = System.filter_fusion(legal_targets, true)
	elif restriction == "non_fusion":
		legal_targets = System.filter_fusion(legal_targets)
		
	match legal_targets.size() > 0:
		true:
			target_formula = {
				"id" : id,
				"subclass" : subclass,
				"source_tags" : source_tags,
				"tag" : tag,
				"amount" : amount,
				"restriction" : restriction,
				"reference_card" : reference_card
			}
			initialize_zone_targeting("modify_target")
			emit_signal("set_active", false, "Select target by column.")
		false:
			emit_signal("no_targets")

func toggle_zone_targeting_UI(boolean : bool):
	var zones : Array = get_zones()
	for zone in zones:
		toggle_visibility(zone.confirm_button, boolean)
	toggle_zone_visibility(boolean)
	toggle_visibility(phase_symbol, !boolean)
	allow_zone_confirmation = false
	if boolean:
		zone_targeting_wait.start()

func attack_phase_symbol_visible():
	return phase_attack_symbol.modulate.a == 1 and phase_symbol.modulate.a == 1

func _on_ZoneTargetingWait_timeout():
	allow_zone_confirmation = true

func attack_declaration(zone_number : int, attack_target : Card):
	if attack_target != null:
		pay_attacked_cost(attack_target)
	attacks_left -= 1
	focused_attacker.attacks_left -= 1
	emit_signal("attack_declaration", focused_attacker, zone_number)
	clear_attack_targeting()
	
func clear_attack_targeting():
	toggle_zone_targeting_UI(false)
	focused_attacker.toggle_cancel_button(false)
	update_powers()
	focused_attacker.toggle_backlight()
	focused_attacker = null
	zone_targeting_mode = "Null"

func _on_zone_confirmed(zone_number : int):
	var is_legal_column : bool
	var attack_target : Card
	var attackable_cards : Array = get_attackable()
	if !allow_zone_confirmation:
		return
	match zone_targeting_mode:
		"attack_target":
			for card in attackable_cards:
				if zone_number == System.mirror_slot(card.card_slot) and \
				can_pay_attacked_cost(card):
					is_legal_column = true
					attack_target = card
			if attackable_cards.size() == 0:
				is_legal_column = true
			if is_legal_column:
				zone_targeting_mode = "Null"
				attack_declaration(zone_number, attack_target)
		"material_target":
			for card in cards_on_field + enemy_field:
				if zone_number == card.card_slot and legal_targets.has(card):
					zone_targeting_mode = "Null"
					emit_signal("material_confirmed", card)
		"taking_card":
			if zone_vacancy[zone_number - 1]:
				return
			clear_zone_targeting()
			card_to_take.card_slot = zone_number
			emit_signal("card_taken", card_to_take)
		"modify_target":
			_on_modify_target(zone_number)

func get_attackable(source : Array = enemy_field, was_reversed : bool = false):
	var filtered_array : Array
	for card in source:
		if can_be_attacked(card) or was_reversed:
			filtered_array.append(card)
	return filtered_array

func can_be_attacked(card : Card):
	var effect : Dictionary
	if System.has_effect(card, "Field", "cannot_be_attacked"):
		effect = System.repair_effect(card.effects.Field)
		if check_field_conditions(card, effect):
			return false
	return true

func _on_modify_target(zone_number : int):
	for card in legal_targets:
		if cards_on_field.has(card) and card.card_slot == zone_number:
			card_destroyed(card)
		elif enemy_field.has(card) and System.mirror_slot(card.card_slot) == zone_number:
			match target_formula.id:
				"Destroy":
					emit_signal("destroy_enemy", card, {"subclass" : target_formula.subclass, \
					"reference_card" : target_formula.reference_card})
				"Transform":
					emit_signal("transform_target", card, {"tag" : target_formula.tag})
			clear_zone_targeting()
			emit_signal("set_active", true, "Null")

func can_pay_attacked_cost(attack_target : Card, do_pay : bool = false):
	if System.has_effect(attack_target, "Field", "attacked") and \
	!get_attacked_cost(attack_target, attack_target.effects.Field, do_pay):
		return false
	for card in enemy_field_plus_attached():
		if System.has_effect(card, "Field", "friend_attacked") and \
		(!card.effects.Field.has("tag") or System.tag_check(attack_target, card.effects.Field.tag)) and \
		!get_attacked_cost(card, card.effects.Field, do_pay):
			return false
	return true

func get_attacked_cost(card : Card, effect : Dictionary, do_pay : bool):
	effect = System.repair_effect(effect)
	match effect.subclass:
		"Null":
			pass
		"life":
			if do_pay:
				emit_signal("update_life", card, {"target" : effect.target, "constant" : effect.constant})
				return true
			if System.targets_self(effect.target) and own_life < effect.constant or \
			System.targets_enemy(effect.target) and enemy_life < effect.constant:
				return false
	return true

func pay_attacked_cost(attack_target : Card):
	can_pay_attacked_cost(attack_target, true)

func clear_zone_targeting():
	toggle_zone_targeting_UI(false)
	zone_targeting_mode = "Null"

func attacked(attacker : Card, slot_number : int, was_reversed : bool):
	var effect : Dictionary
	var card : Card = get_zoned_card(slot_number, get_attackable(cards_on_field, was_reversed))
	var reversed : bool
	if card != null:
		if can_be_reversed(attacker):
			reversed = try_response_to_reverse(card)
			if !reversed and System.has_effect(card, "Once", "reverse_attack"):
				effect = card.effects.Once
				if effect.active and is_effect_active(card, effect):
					effect.active = false
					reversed = true
		if reversed:
			emit_signal("attack_declaration", card, attacker.card_slot, true)
			return false
		card_destroyed_by_battle(card)
		attacker.attacked = true
		return false
	attacker.attacked = true
	return true

func try_response_to_reverse(defender : Card):
	var restriction : String = "Null"
	var effect : Dictionary
	for card in own_hand:
		if System.has_effect(card, "Hand", "Response", "subclass", "reverse_attack"):
			effect = card.effects.Hand
			if effect.has("restriction"):
				restriction = effect.restriction
			if check_restriction(defender, restriction) and once_per_check(effect):
				send_card_to_grave(card)
				return true
	return false

func check_restriction(card : Card, restriction : String):
	if restriction == "Null":
		pass
	elif restriction == "fusion" and !System.has_effect(card, "ContactFusion"):
		return false
	elif restriction == "non_fusion" and System.has_effect(card, "ContactFusion"):
		return false
	return true

func get_zoned_card(card_slot : int, source : Array = cards_on_field):
	if source == enemy_field:
		card_slot = System.mirror_slot(card_slot)
	for card in source:
		if card.card_slot == card_slot:
			return card
	return null

func is_effect_active(card : Card, effect : Dictionary):
	var condition : String
	if effect.has("condition"):
		condition = effect.condition
		if condition == "enemy_turn" and is_attack_phase:
			return false
	return true

func can_be_reversed(attacker : Card):
	for card in System.get_card_plus_attached(attacker):
		if System.has_effect(card, "Field", "irreversible") and \
		System.attached_share_check(card):
			return false
	return true

func card_destroyed_by_battle(card : Card):
	card_destroyed(card, "by_attack")

func card_destroyed(card : Card, destroyed_by : String = "by_effect"):
	var death_effect : Dictionary = {"Default" : null}
	var card_name : String = card.card_name
	if try_death_protection(card, destroyed_by):
		play_card_animation(card, "DeathProtection")
		return false
	if System.has_effect(card, "Death"):
		death_effect = card.effects.Death
	trigger_bounce_effects(card)
	send_card_to_grave(card)
	play_card_animation(card, "CardDestroyed")
	resolve_death_triggered(card, card_name, death_effect)
	return true
	
func resolve_death_triggered(card : Card, card_name : String, death_effect : Dictionary):
	var graveyard_effect : Dictionary
	var tag : String
	if card.location != "Graveyard":
		return
	if !System.is_default(death_effect):
		emit_signal("activate_effect", card, death_effect)
	for card_in_grave in own_graveyard:
		if System.has_effect(card_in_grave, "Graveyard", "friend_dies") and card_in_grave != card:
			graveyard_effect = card_in_grave.effects.Graveyard
			tag = "Null"
			if graveyard_effect.has("tag"):
				tag = graveyard_effect.tag
			if !System.match_tag(card_name, tag):
				continue
			card_in_grave.card_slot = card.card_slot
			card_in_grave.reference_card = card
			emit_signal("activate_effect", card_in_grave, card_in_grave.effects.Graveyard)

func play_card_animation(card : Card, id : String):
	get_card_zone(card).animation(id)

func send_card_to_grave(card : Card):
	emit_signal("relocation_confirmerd", card, "Graveyard")

func trigger_bounce_effects(card : Card):
	var location : String
	var source : Array
	if System.has_effect(card, "Death", "bounce_attached"):
		location = System.repair_effect(card.effects.Death).location
		if location == "Default":
			location = "Hand"
		source = System.copy_array(card.attached_cards)
		for attached_card in source:
			emit_signal("relocation_confirmerd", attached_card, location)
		emit_signal("close_optional_reveal_piles")

func try_death_protection(card : Card, destroyed_by : String):
	return try_graveyard_death_protection(card, destroyed_by) \
	or try_own_death_protection(card, destroyed_by)

func try_graveyard_death_protection(original_card : Card, destroyed_by : String):
	var effect : Dictionary
	var restriction : String = "Null"
	var condition : String = "Null"
	negated = false
	emit_signal("negated_check", "void_graveyard")
	if negated:
		return false
	for card in own_graveyard:
		if System.has_effect(card, "Graveyard", "death_protection"):
			effect = card.effects.Graveyard
			for key in effect:
				match key:
					"restriction":
						restriction = effect.restriction
					"condition":
						condition = effect.condition
			if check_restriction(original_card, restriction) and can_protect_source(condition, destroyed_by) and\
			once_per_check(effect):
				emit_signal("relocation_confirmerd", card, "Void")
				return true
	return false

func try_own_death_protection(card : Card, destroyed_by : String):
	var effect : Dictionary
	var condition : String = "Null"
	if System.has_effect(card, "Once", "death_protection"):
		effect = card.effects.Once
		if effect.has("condition"):
			condition = effect.condition
		if effect.active and can_protect_source(condition, destroyed_by):
			effect.active = false
			try_restore_once_effect(card, effect)
			return true
	return false

func try_restore_once_effect(card : Card, effect : Dictionary):
	var restore_condition : Dictionary
	var cards_to_detach : Array
	if effect.has("restore_condition"):
		restore_condition = System.repair_effect(effect.restore_condition)
		match restore_condition.id:
			"Detach":
				for attached_card in card.attached_cards:
					if System.tag_check(attached_card, restore_condition.tag):
						cards_to_detach.append(attached_card)
				
				if cards_to_detach.size() > 0:
					match restore_condition.subclass:
						"Default":
							cards_to_detach = cards_to_detach[0]
					for attached_card in cards_to_detach:
						send_card_to_grave(attached_card)
					effect.active = true
					return

func can_protect_source(condition : String, destroyed_by : String):
	return condition == "Null" or condition == destroyed_by

func remove_from_field(card : Card):
	cards_on_field.erase(card)
	update_field()
	zone_vacancy[card.card_slot - 1] = false
	clear_field_instance(card)

func clear_field_instance(card : Card):
	card.disconnect("transformed", get_card_zone(card), "animation")
	card.allowed_to_highlight = false
	card.clear_power()
	card.toggle_permanent_power()
	card.clear_attached()

func take_card(card : Card):
	card_to_take = card
	initialize_zone_targeting("taking_card")
	if count_vacant_zones() == 1:
		allow_zone_confirmation = true
		_on_zone_confirmed(first_vacant_zone())

func count_vacant_zones():
	var count : int
	for zone in zone_vacancy:
		if !zone:
			count += 1
	return count

func first_vacant_zone():
	var zone_number : int = 1
	for zone in zone_vacancy:
		if !zone:
			return zone_number
		zone_number += 1
	return 0

func update_powers(update_other_player : bool = true):
	if update_other_player:
		emit_signal("update_powers", !update_other_player)
	for card in cards_on_field:
		card.set_power(get_power(card))
		if is_attack_phase:
			visualize_attacks_left(card)

func get_power(card : Card, attached_to : Card = null):
	var passive_power : int = card.passive_power
	var power_modifier : Dictionary = {
		"power" : 0,
		"addition" : 0,
		"multiplier" : 1,
	}
	power_modifier = get_power_modifier(card, power_modifier, attached_to)
	if attached_to != null:
		return power_modifier.addition
	for attached_card in card.attached_cards:
		if System.attached_share_check(attached_card):
			power_modifier.addition += get_power(attached_card, card)
	power_modifier.addition += get_grave_power_addition(card)
	if power_modifier.power > 0:
		passive_power -= 1
	elif power_modifier.power + passive_power < 1:
		power_modifier.power = 1
	power_modifier.power = power_modifier.power * power_modifier.multiplier \
	+ passive_power + card.permanent_power + power_modifier.addition
	return power_modifier.power

func get_power_modifier(card : Card, power_modifier : Dictionary, attached_to : Card):
	var effect : Dictionary
	var field_instance : Card = card
	if attached_to != null:
		field_instance = attached_to
	if System.has_effect(card, "Field"):
		effect = System.repair_effect(card.effects.Field)
		if !System.attached_share_check(card):
			return power_modifier
		power_modifier.addition = effect.power_gain
		match effect.id:
			"Power":
				match check_field_conditions(field_instance, effect):
					true:
						power_modifier.power = count_reference( \
						effect.subclass, effect.target, effect.tag, "Null", "Null", card)
						power_modifier.multiplier = effect.multiplier
					false:
						power_modifier.addition -= effect.power_gain
	return power_modifier

func check_field_conditions(card : Card, effect : Dictionary):
	var column : int = effect.column[0]
	return column == 0 or card.card_slot == column

func count_reference(subclass : String, target : String, tag : String = "Null", \
condition : String = "Null", absolute_card_name : String = "Null", card : Card = null):
		var count : int
		match subclass:
			"cards_in_hand":
				count = count_hand(target, tag, \
				condition, absolute_card_name)
			"cards_in_grave":
				count = count_grave(target, tag, \
				condition, absolute_card_name)
			"cards_on_field":
				count = count_field(target, tag)
			"tokens_on_field":
				count = count_tokens(target, tag)
			"cards_sent_to_grave":
				count = count_cards_sent_to_grave(target, tag)
			"full_rounds":
				count = int(rounds_lasted)
			"cards_top_of_deck":
				count = count_deck(target, tag)
			"names_in_deck":
				count = System.get_singles(get_decked_cards(target, tag)).size()
			"life":
				count = count_life(target)
			"highest_power":
				count = count_highest_power(target, tag)
			"cards_attached":
				count = card.attached_cards.size()
		return count

func get_grave_power_addition(original_card : Card):
	var power_addition : int
	var tag : String
	var addition : int
	var effect : Dictionary
	for card in own_graveyard:
		if System.has_effect(card, "Graveyard", "Power"):
			tag = "Null"
			addition = 1
			effect = card.effects.Graveyard
			for key in effect:
				if key == "tag":
					tag = effect.tag
				elif key == "addition":
					addition = effect.addition
			if System.tag_check(original_card, tag):
				power_addition += addition
	return power_addition

func count_hand(target : String, tag : String, condition : String, \
absolute_name : String = "Null"):
	return System.get_cards(tag, own_hand, enemy_hand, target, condition, \
	absolute_name).size()

func count_deck(target : String, tag : String):
	var source : Array = get_decks(target)
	var count : int
	var local_tag : String
	for deck in source:
		count += count_tag_top_of_deck(deck, tag)
	return count

func get_decks(target : String):
	var source : Array
	if System.targets_self(target):
		source.append(own_deck)
	if System.targets_enemy(target):
		source.append(enemy_deck)
	return source

func get_decked_cards(target : String, tag : String):
	var source : Array
	for deck in get_decks(target):
		source = source + deck
	return System.get_tagged_cards(source, tag)

func get_top_of_deck(target : String, amount : int):
	var cards : Array
	var index : int
	for deck in get_decks(target):
		index = 0
		while index < deck.size() and (amount == -1 or index < amount):
			cards.append(deck[index])
			index += 1
	return cards

func count_tag_top_of_deck(source : Array, tag : String):
	var count : int
	for card in source:
		if System.tag_check(card, tag):
			count += 1
			if tag == "Null":
				tag = card.card_name
			continue
		break
	return count

func count_grave(target : String, tag : String, condition : String = "Null", \
absolute_name : String = "Null"):
	return get_graved_cards(target, tag, condition, absolute_name).size()

func get_graved_cards(target : String, tag : String, condition : String = "Null", \
absolute_name : String = "Null"):
	return System.get_cards(tag, own_graveyard, enemy_graveyard, target, condition, absolute_name)

func count_cards_sent_to_grave(target : String, tag : String):
	return get_cards_sent_to_grave(target, tag).size()

func get_cards_sent_to_grave(target : String, tag : String = "Null"):
	return System.get_cards(tag, own_cards_sent_to_grave, enemy_cards_sent_to_grave, target)

func get_names_sent_to_grave(target : String):
	var names : Array
	for card in get_cards_sent_to_grave(target):
		names.append(card.card_name)
	return names

func get_database(reference : String, target : String, tag : String):
	var database : Array
	match reference:
		"Null":
			return System.get_all_cards()
		"Deck":
			database = get_decked_cards(target, tag)
		"Graveyard":
			database = get_graved_cards(target, tag)
	database = System.get_card_names(database)
	return database

func get_zoned_cards(target : String, tag : String):
	return System.get_cards(tag, own_field_plus_attached(), enemy_field_plus_attached(), target)

func count_field(target : String = "self", tag : String = "Null"):
	return get_zoned_cards(target, tag).size()

func count_tokens(target : String, tag : String):
	return System.filter_tokens(get_zoned_cards(target, tag), true).size()

func count_highest_power(target : String, tag : String):
	var highest_power_cards : Array = System.filter_highest_power( \
	get_zoned_cards(target, tag), true)
	if highest_power_cards.size() > 0:
		return System.min_value(highest_power_cards[0].power, 1)
	return 0

func count_life(target : String):
	var life_count : int
	if System.targets_self(target):
		life_count += own_life
	if System.targets_enemy(target):
		life_count += enemy_life
	return life_count

func get_field_plus_attached(source : Array, skip_attached : bool = false):
	var expanded_array : Array
	for card in source:
		expanded_array.append(card)
		if !skip_attached:
			for attached_card in card.attached_cards:
				expanded_array.append(attached_card)
	return expanded_array

func own_field_plus_attached():
	return get_field_plus_attached(cards_on_field)

func enemy_field_plus_attached():
	return get_field_plus_attached(enemy_field)

func material_target(targets : Array):
	legal_targets = targets
	zone_targeting_mode = "material_target"

func column_empty(var column : int):
	if column < 1 or column > 5:
		return false
	if !zone_vacancy[column - 1]:
		return true
	return false

func update_field():
	emit_signal("update_field", cards_on_field, "self")

func update_rounds(new_rounds_lasted : float):
	if new_rounds_lasted > rounds_lasted:
		update_rounds_on_field(new_rounds_lasted - rounds_lasted)
		rounds_lasted = new_rounds_lasted
		update_powers()

func update_rounds_on_field(round_progression : float):
	for card in cards_on_field:
		card.rounds_on_the_field += round_progression

func set_enemy_zone_vacancy(new_vacancy : Array):
	var index : int = 4
	for slot in new_vacancy:
		enemy_zone_vacancy[index] = slot
		index -= 1
