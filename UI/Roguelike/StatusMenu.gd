extends Control

signal open_deck
signal surrender

onready var deck_message = $EditDeck/Label
onready var death_wait_frame = $Surrender/DeathWaitFrame
onready var death_load = $Surrender/DeathLoad

const max_x : int = 440
const max_y : int = 200
const death_load_max : int = max_x
const surrendering_speed : int = 9

const update_frame : float = 0.04
var AI_controlled : bool
var surrendering : bool
var random : RandomNumberGenerator

func _on_OpenDeck_pressed():
	if AI_controlled:
		return
	toggle_deck_message()
	emit_signal("open_deck")

func toggle_deck_message():
	var new_message : Array = ["Open Deck", "Close Deck"]
	new_message.erase(deck_message.text)
	deck_message.text = new_message[0]

func make_AI_controlled(boolean : bool = true):
	AI_controlled = boolean

func _on_Die_pressed():
	surrendering = true
	death_wait_frame.start()

func _on_Die_released():
	surrendering = false

func _on_DeathWaitFrame_timeout():
	match surrendering:
		true:
			death_load.rect_size.x += surrendering_speed
			if death_load.rect_size.x >= death_load_max:
				death_load.rect_size.x = death_load_max
				death_wait_frame.stop()
				surrender()
		false:
			death_load.rect_size.x -= 2 * surrendering_speed
			if death_load.rect_size.x <= 0:
				death_load.rect_size.x = 0
				death_wait_frame.stop()

func surrender():
	emit_signal("surrender")
