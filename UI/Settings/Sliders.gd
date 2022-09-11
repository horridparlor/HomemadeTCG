extends Control

signal activity

onready var game_speed = $GameSpeed
onready var master_volume = $MasterVolume

var is_active : bool
var forced_active : bool
var increase_volume : bool

func _ready():
	increase_volume = System.current_scene == "Roguelike"
	game_speed.set_description("Game Speed")
	master_volume.set_description("Master Volume")

func session_log_update():
	var session_log : Dictionary = System.get_session_log()
	forced_active = true
	game_speed.value = session_log.game_speed
	master_volume.value = session_log.master_volume
	forced_active = false

func slider_active_check(slider, value : int):
	if is_active or forced_active:
		slider.current_value = value
		return true
	slider.value = slider.current_value
	return false

func _on_GameSpeed_value_changed(value):
	if !slider_active_check(game_speed, value):
		return
	update_session_log("game_speed", value)

func _on_MasterVolume_value_changed(value):
	if !slider_active_check(master_volume, value):
		return
	if value == System.minumum_volume:
		value = System.zero_volume
	update_session_log("master_volume", value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), value)

func update_session_log(key : String, value : int):
	var session_log : Dictionary = System.get_session_log()
	session_log[key] = value
	System.set_session_log(session_log)
	emit_signal("activity")

func set_active(boolean : bool):
	is_active = boolean

func manual_slide(id : String, amount : int):
	var slider : HSlider
	match id:
		"game_speed":
			slider = game_speed
		"master_volume":
			slider = master_volume
	slider.value += amount
