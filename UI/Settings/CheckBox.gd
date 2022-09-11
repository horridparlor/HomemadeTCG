extends Control

signal checked(boolean)

onready var checked_sprite = $Button/CheckedSprite
onready var unchecked_sprite = $Button/UncheckedSprite
onready var description = $Description

var is_checked : bool
var is_active : bool

func _on_Checked_pressed():
	if !is_active:
		return
	is_checked = !is_checked
	toggle_sprites()
	emit_signal("checked", is_checked)

func toggle_sprites():
	checked_sprite.visible = is_checked
	unchecked_sprite.visible = !is_checked

func set_checked(boolean : bool):
	is_checked = boolean
	toggle_sprites()

func set_active(boolean : bool):
	is_active = boolean
	
func set_description(string : String):
	description.text = string
