extends Node2D
class_name Card

signal focus(card_object)
signal unfocus(card_object)
signal confirm(card_object)
signal cancel(card_object)
signal transformed

onready var overlay = $Visuals/Overlay
onready var backlight = $Visuals/Animations/Backlight
onready var animations = $Visuals/Animations

onready var touch_button = $CardSizeButton
onready var confirm_button = $Buttons/ConfirmButton/ConfirmButton
onready var confirm_sprite = $Buttons/ConfirmButton/ConfirmSprite
onready var confirm_button_highlight = $Buttons/ConfirmButtonHighlight/ConfirmButton
onready var confirm_sprite_highlight = $Buttons/ConfirmButtonHighlight/ConfirmSprite
onready var power_counter = $PowerCounter
onready var permanent_counter = $PermanentCounter
onready var power_count = $PowerCounter/PowerCount
onready var permanent_count = $PermanentCounter/Count
onready var tween = $Tween
onready var cancel_button = $Buttons/CancelButton/CancelButton
onready var cancel_sprite = $Buttons/CancelButton/CancelSprite
onready var buttons = $Buttons

onready var power_update_frame = $Control/PowerUpdateFrame
onready var rotation_frame = $Control/RotationFrame

const animation_time : float = 0.2

var card_slot : int
var address : Dictionary = {
	"id" : "Null",
	"position" : Vector2(0, 0)
}
var return_address : Vector2 = Vector2(0, 0)
var card_name : String
var second_name : String = "Null"
var is_focused : bool
var local_address : Vector2
var current_rotation : int
var rotation_speed : int
var card_starting_position : Vector2
var mouse_starting_position : Vector2
var player_number : int
var controlling_player : int
var instance_id : int
var instance_class : String = "Default"
var allowed_to_highlight : bool
var allowed_to_move : bool
var allowed_to : String = "Null"
var allowed_to_attach : String
var effects : Dictionary
var attacks_left : int
var location : String
var is_zone_locked : bool
var free_play : bool
var trigger : String
var power : int
var passive_power : int
var current_power : int
var permanent_power : int
var display_spin_enabled : bool
var negated : String
var attached_cards : Array
var attached_to : Card
var void_effect_initialized : bool
var reference_card : Card
var imprinted_card : Card
var attacked : bool
var relocation : String = "Default"
var can_attack : bool
var rounds_on_the_field : float
var size_id : String

func set_player_number(number : int):
	player_number = number
	controlling_player = player_number

func _process(delta):
	if is_focused:
		var rotation_factor : int = 1
		var card_in_hand_roof : int = System.card_in_hand_roof
		if controlling_player == 2 and !display_spin_enabled:
			rotation_factor = -1
		position = rotation_factor * get_global_mouse_position() - rotation_factor * mouse_starting_position + card_starting_position
		if position.y < card_in_hand_roof and !System.targets_enemy(allowed_to_attach):
			position.y = card_in_hand_roof

func focus():
	if allowed_to_highlight:
		emit_signal("focus", self)
	if allowed_to_move and System.mouse_state_check(instance_id):
		is_focused = true
		card_starting_position = position
		mouse_starting_position = get_global_mouse_position()

func unfocus():
	emit_signal("unfocus", self)
	if is_focused:
		is_focused = false
		System.reset_mouse_state()

func reduce_touch_area(amount : int):
	touch_button.reduce_touch_area(amount)

func _on_CardSizeButton_pressed():
	if card_sized():
		focus()

func _on_CardSizeButton_released():
	if card_sized():
		unfocus()

func _on_HighlightSizeButton_pressed():
	if highlight_sized():
		focus()

func _on_HighlightSizeButton_released():
	if highlight_sized():
		unfocus()

func is_size(id : String):
	return size_id == id

func card_sized():
	return is_size("Compressed")

func highlight_sized():
	return is_size("Highlight")

func show_sprite():
	var backlight_sprite_name : String = "Main"
	effects = System.get_card_effects(card_name)
	if instance_class == "Temporary":
		return
	if System.is_fusion_name(card_name):
		backlight_sprite_name = "Grave"
	backlight.texture = load("res://Textures/Animations/" + backlight_sprite_name + \
	"CardBacklightCompressed.png")
	overlay.texture = load("res://Textures/Card" + size_id + "/" + card_name + size_id + ".png")

func rotate_sprite(angle : float, speed : int = 1):
	current_rotation = int(angle)
	rotation_speed = speed
	rotation_frame.start()

func _on_RotationFrame_timeout():
	if rotation_degrees == current_rotation:
		rotation_frame.stop()
		if rotation_degrees == 360:
			rotation_degrees = 0
		return
	rotation_degrees = System.max_variation(rotation_degrees, current_rotation, rotation_speed)

func toggle_backlight(boolean : bool = false):
	match boolean and allowed_to != "Null":
		true:
			animations.play("Backlight")
		false:
			animations.stop()
			toggle_visibility(backlight, false)
			allowed_to = "Null"
			
func pull_from_action():
	toggle_confirm_button(false)
	toggle_backlight(false)

func allow_to(id : String):
	allowed_to = id
	toggle_backlight(true)

func toggle_button(button : TouchScreenButton, sprite : Sprite, boolean : bool):
	button.visible = boolean
	toggle_visibility(sprite, boolean)

func toggle_confirm_button(boolean : bool):
	var button : TouchScreenButton = confirm_button
	var sprite : Sprite = confirm_sprite
	if highlight_sized():
		button = confirm_button_highlight
		sprite = confirm_sprite_highlight
	toggle_button(button, sprite, boolean)

func toggle_cancel_button(boolean : bool):
	var button : TouchScreenButton = cancel_button
	var sprite : Sprite = cancel_sprite
	toggle_button(button, sprite, boolean)

func _on_ConfirmButton_pressed():
	emit_signal("confirm", self)

func _on_CancelButton_pressed():
	emit_signal("cancel", self)

func set_power(new_power : int):
	power = new_power
	toggle_power()
	power_update_frame.start()

func toggle_power():
	if power <= 1:
		clear_power()
		return
	toggle_visibility(power_counter, true)
	toggle_faded(false, buttons)

func toggle_permanent_power(boolean : bool = true):
	permanent_count.text = str(permanent_power)
	toggle_visibility(permanent_counter, boolean and permanent_power > 0)

func set_count(count : int):
	power = count
	toggle_power()
	set_current_power(count)

func _on_PowerUpdateFrame_timeout():
	if current_power > power:
		current_power -= 1
	elif current_power == power:
		power_update_frame.stop()
	elif current_power < power:
		current_power += 1
	set_current_power()

func set_current_power(count : int = current_power):
	if count < 1:
		count = 1
	power_count.text = str(count)

func clear_power():
	power = 0
	toggle_visibility(power_counter, false)
	toggle_faded(true, buttons)

func toggle_visibility(sprite : Node, boolean : bool):
	var tween_values : Array = System.get_tween_values(boolean, sprite)
	tween.interpolate_property(sprite, tween_values[0], tween_values[1], tween_values[2], animation_time)
	tween.start()

func toggle_faded(boolean : bool, sprite):
	var tween_values : Array = System.get_tween_values_faded(boolean, sprite)
	tween.interpolate_property(sprite, tween_values[0], tween_values[1], tween_values[2], animation_time)
	tween.start()

func attach_card(original_card : Card):
	for card in System.get_card_plus_attached(original_card):
		_on_attach(card)
		card.location = "Attached"
		card.address = {
			"id" : "attached",
			"position" : position
		}

func _on_attach(card : Card):
	attached_cards.append(card)
	card.attached_to = self
	if card.controlling_player == card.player_number:
		return
	for modification in get_attached_modifications(card):
			match modification:
				"no_effects":
					effects = {}

func get_attached_modifications(card : Card):
	var modifications : Array
	if System.has_effect(card, "Field", "Attached"):
		modifications = System.copy_array(card.effects.Field.source)
	return modifications

func transform(superclass : String, subclass : String, tag : String, database : Array, \
wanted_effect : Dictionary, random : RandomNumberGenerator):
	var random_card_name : String
	random.randomize()
	if tag == card_name:
		return
	match subclass:
		"Random":
			tag = System.database_item(database, random, wanted_effect, card_name)
	transform_effects(tag, superclass)

func transform_name(tag : String):
	if second_name == "Null":
		set_second_name(tag)
	card_name = tag

func change_name(tag : String):
	card_name = tag
	second_name = "Null"

func set_second_name(tag : String):
	if tag == second_name:
		second_name = "Null"
		return
	second_name = card_name

func transform_effects(tag : String, superclass : String = "Default"):
	if tag == "Null":
		return
	match superclass:
		"Default":
			transform_name(tag)
		"Become":
			change_name(tag)
	show_sprite()
	emit_signal("transformed", "Transformation")

func clear_transformation():
	if second_name != "Null":
		card_name = second_name
		second_name = "Null"
		show_sprite()

func clear_attached():
	for card in attached_cards:
		for modification in get_attached_modifications(card):
			match modification:
				"no_effects":
					show_sprite()

func allowed_to_confirm():
	return confirm_button.visible or confirm_button_highlight.visible
