extends Node2D

signal focus(data)

onready var background_sprite = $Sprites/Background
onready var icon_sprite = $Sprites/Icon

var data : Dictionary
var instance_id : int

func _ready():
	update_sprites()

func _on_TouchScreenButton_pressed():
	emit_signal("focus", data)

func build(build_data : Dictionary):
	data = build_data
	instance_id = data.instance_id
	position = data.position
	
func update_sprites():
	var id : String = data.id
	var sprite_name : String
	background_sprite.texture = load("res://Textures/MapIcons/Background/" + data.background_sprite + ".png")
	match id:
		"Gate":
			match data.enemies_to_defeat == 0:
				true:
					sprite_name = "Open"
				false:
					sprite_name = "Locked"
		"Enemy":
			sprite_name = data.name.resource
	icon_sprite.texture = load("res://Textures/MapIcons/" + id + "/" + sprite_name + ".png")
