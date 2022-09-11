extends Node2D

signal search_result_selected(card_name)

onready var sprite = $Card/MinimizedSprite
onready var copy_count = $CopyCount

var number_of_copies : int
var card_name : String

func set_sprite(new_card_name : String):
	card_name = new_card_name
	sprite.texture = load("res://Textures/CardMinimized/" + card_name + "Minimized.png")

func clear_sprite():
	card_name = "Null"
	sprite.texture = null
	clear_copy_count()

func show_result(card : Array):
	set_sprite(card[0])
	set_copy_count(card[1])

func clear():
	clear_sprite()

func _on_SelectButton_pressed():
	emit_signal("search_result_selected", card_name)

func set_copy_count(new_number_of_copies : int):
	number_of_copies = new_number_of_copies
	if number_of_copies > 0:
		show_copy_count()
		return
	clear_copy_count()

func show_copy_count():
	copy_count.show_count(number_of_copies)

func clear_copy_count():
	copy_count.clear()
