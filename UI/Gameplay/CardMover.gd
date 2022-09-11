extends Control
class_name CardMover

signal deliver_card(card)
signal visual_queue(card)
signal change_zone_visibility(command, zones, reveal_pile)

onready var timer = $CardMoveFrame
onready var reveal_buttons = $RevealButtons
onready var tween = $Tween

var cards_moving : Array
var reveal_pile : Array = []
var second_reveal_pile = []
var busy_moving : bool
var default_vector : Vector2 = Vector2(0, 0)
const max_reveal_x : int = 400
const reveal_y_margin : int = System.reveal_y_margin
var cards_to_reveal : int
var cards_to_hide : int
var zones_to_hide : Array = ["Hand", "Field", "cards_moving"]
var in_reveal_mode : bool
var movement_speed : int

func move_card(card : Card):
	cards_moving.erase(card)
	card.visible = true
	if card.is_zone_locked:
		toggle_visibility(card, true)
	cards_moving.append(card)
	card.rotate_sprite(card.position.angle_to_point(card.address.position) * 180 / PI - 90)
	timer.start()

func _on_CardMoveFrame_timeout():
	for card in cards_moving:
		var local_speed : int = movement_speed
		var distance : int = card.position.distance_to(card.address.position)
		if distance > System.speed_up_distance:
			local_speed = local_speed * (distance / System.speed_up_increment)
		card.position = card.position.move_toward(card.address.position, local_speed)
		if card.position == card.address.position:
			delivere_card(card)
	if cards_moving.size() == 0:
		timer.stop()

func delivere_card(card : Card):
	var angle : int = 0
	cards_moving.erase(card)
	if card.rotation_degrees > 180:
		angle = 360
	card.rotate_sprite(angle, System.degrees_by_rotation_frame)
	if card.address.id == "Graveyard":
		card.visible = false
	if card.is_zone_locked:
		card.is_zone_locked = false
		if !in_reveal_mode:
			card_revealed()
		cards_to_hide -= 1
		if cards_to_hide == 0:
			reset_reveal_mode()
		if card.location != "Void":
			return
	emit_signal("deliver_card", card)

func reset_reveal_mode():
	busy_moving = false
	for card in reveal_pile:
		hide_card(card)
	if reveal_pile == []:
		focus_reveal_pile(true)
		toggle_reveal_button_visibility(true)
	if second_reveal_pile.size() > 0:
		return_current_task()
		return
	reveal_pile = []
	toggle_reveal_button_visibility(false)
	focus_reveal_pile(false)

func focus_reveal_pile(boolean : bool):
	emit_signal("change_zone_visibility", !boolean, zones_to_hide, reveal_pile)

func hide_card(card : Card):
	card.visible = false

func return_current_task():
	in_reveal_mode = true
	reveal_pile = second_reveal_pile
	second_reveal_pile = []
	for card in reveal_pile:
		toggle_visibility(card, true)
		card.allowed_to_highlight = true

func toggle_reveal_button_visibility(boolean : bool):
	toggle_visibility(reveal_buttons, boolean)

func toggle_visibility(target_object, boolean : bool, animation_time : float = 0):
	var tween_values : Array = System.get_tween_values(boolean, target_object)
	if animation_time <= 0:
		animation_time = tween_values[3]
	tween.interpolate_property(target_object, tween_values[0], \
	tween_values[1], tween_values[2], animation_time)
	tween.start()

func show_content(current_task : String, task_call : String,  new_reveal_pile : Array, address_id : String):
	if !busy_moving:
		busy_moving = true
		toggle_reveal_button_visibility(true)
		if reveal_pile.size() > 0:
			hide_current_task()
		reveal_pile = System.copy_array(new_reveal_pile)
		set_cards_to_reveal()
		if cards_to_reveal > 0:
			focus_reveal_pile(true)
		elif cards_to_reveal == 0:
			initialize_reveal_mode()
		if current_task == task_call:
			address_id = "Null"
			return_current_task()
			in_reveal_mode = false
		reveal_cards(address_id)
		current_task = task_call
	return current_task

func set_cards_to_reveal():
	cards_to_reveal = reveal_pile.size()

func reveal_cards(address_id : String, new_reveal_pile : Array = []):
	if new_reveal_pile.size() > 0:
		reveal_pile = System.copy_array(new_reveal_pile)
		set_cards_to_reveal()
		in_reveal_mode = false
	var x_counter : int = -max_reveal_x
	var y_counter : int = System.starting_reveal_y
	for card in reveal_pile:
		reveal_a_card(card, address_id, x_counter, y_counter)
		x_counter += System.reveal_x_margin
		if x_counter > max_reveal_x:
			x_counter = -max_reveal_x
			y_counter += reveal_y_margin

func reveal_a_card(card : Card, address_id : String, x_counter : int, y_counter : int):
	card.is_zone_locked = true
	card.reduce_touch_area(0)
	var address = {
		"id" : address_id,
		"position" : Vector2(x_counter, y_counter)
	}
	card.address = address
	emit_signal("visual_queue", card)

func hide_current_task():
	for card in reveal_pile:
		toggle_visibility(card, false)
		card.allowed_to_highlight = false
	second_reveal_pile = reveal_pile
	in_reveal_mode = false
	
func hide_content(current_task : String, updated_reveal_pile, address_id):
	if !busy_moving:
		busy_moving = true
		reveal_pile = updated_reveal_pile
		in_reveal_mode = false
		cards_to_hide = reveal_pile.size()
		for card in reveal_pile:
			card.allowed_to_highlight = false
			card.is_zone_locked = true
			var address = {
				"id" : address_id,
				"position" : default_vector
			}
			card.address = address
			emit_signal("visual_queue", card)
		current_task = "Null"
		if cards_to_hide == 0:
			reset_reveal_mode()
	return current_task
	
func card_revealed():
	cards_to_reveal -= 1
	if cards_to_reveal == 0:
		initialize_reveal_mode()

func initialize_reveal_mode():
	in_reveal_mode = true
	busy_moving = false
	for card in reveal_pile:
		card.allowed_to_highlight = true
	if reveal_pile == []:
		focus_reveal_pile(false)
		toggle_reveal_button_visibility(false)

func _on_Reveal_Up_pressed():
	reveal_down()

func _on_Reveal_Down_pressed():
	reveal_up()

func reveal_up():
	if reveal_pile.size() > 0 and reveal_pile[0].address.position.y <= \
	-(int((reveal_pile.size() + 4) / 5 - 1) * reveal_y_margin):
		return
	move_reveal_pile(-1)

func reveal_down():
	if reveal_pile.size() > 0 and reveal_pile[0].address.position.y >= System.starting_reveal_y + reveal_y_margin:
		return
	move_reveal_pile(1)

func move_reveal_pile(direction_factor : int):
	if in_reveal_mode:
		for card in reveal_pile:
			card.address.id = "Moving_Reveal_Pile"
			card.address.position.y += direction_factor * reveal_y_margin
			emit_signal("visual_queue", card)

func pull_card(card : Card):
	cards_moving.erase(card)
	reveal_pile.erase(card)
	card.allowed_to_highlight = false
	card.allowed_to_move = false

func void_card(card : Card):
	card.location = "Void"
	card.address = {
		"id" : "Void",
		"position" : System.voided_location
	}
	card.modulate.a = 1
	toggle_visibility(card, false)
	move_card(card)

func busy():
	return busy_moving or cards_moving.size() > 0

func set_movement_speed(speed : int):
	 movement_speed = int(speed / 2) + 10
