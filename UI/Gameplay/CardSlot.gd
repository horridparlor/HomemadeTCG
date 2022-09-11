extends Node2D

signal confirmed(zone_number)

onready var play_zone = $PlayZone
onready var confirm_button = $ConfirmButton
onready var animations = $Animations

var slot_number : int
var is_AI_controlled : bool

func _on_Button_pressed():
	if !is_AI_controlled:
		emit_signal("confirmed", slot_number)

func animation(id : String):
	animations.card_animation(id)
