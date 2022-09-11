extends Control

signal session_log_update
signal menu_activated

onready var settings_menu = $SettingsMenu
onready var tween = $Tween
onready var sliders = $SettingsMenu/SettingsContainer/Sliders
onready var check_boxes = $SettingsMenu/SettingsContainer/CheckBoxes
onready var game_mode_button = $SettingsMenu/GameModeButton

var is_menu_active : bool
var is_AI_controlled : bool

func _ready():
	settings_menu.modulate.a = 0
	for menu in get_submenus():
		menu.connect("activity", self, "activity")

func get_submenus():
	return [sliders, check_boxes, game_mode_button]

func _on_OpenSettings_pressed():
	if is_AI_controlled:
		return
	is_menu_active = !is_menu_active
	if is_menu_active:
		emit_signal("menu_activated")
	toggle_visibility(is_menu_active, settings_menu)
	for menu in get_submenus():
		menu.set_active(is_menu_active)

func toggle_visibility(boolean : bool, zone):
	var tween_values : Array = System.get_tween_values(boolean, zone)
	tween.interpolate_property(zone, tween_values[0], tween_values[1], tween_values[2], tween_values[3])
	tween.start()

func close_settings():
	if is_menu_active:
		_on_OpenSettings_pressed()

func activity():
	emit_signal("session_log_update")

func make_AI_controlled(boolean : bool):
	if boolean:
		close_settings()
	is_AI_controlled = boolean

func session_log_update():
	for menu in get_submenus():
		menu.session_log_update()

func setting_shortcuts(key : String):
	var shortcuts : Dictionary = System.setting_shortcuts
	var slider_id : String = "Null"
	var checkbox_id : String = "Null"
	var amount : int
	match key:
		shortcuts.speed_up:
			slider_id = "game_speed"
			amount = 8
		shortcuts.speed_down:
			slider_id = "game_speed"
			amount = -8
		shortcuts.volume_up:
			slider_id = "master_volume"
			amount = 3
		shortcuts.volume_down:
			slider_id = "master_volume"
			amount = -3
		shortcuts.enable_display_spin:
			checkbox_id = "display_spin"
		shortcuts.AI_opponent:
			checkbox_id = "AI_opponent"
		shortcuts.autoplay:
			checkbox_id = "autoplay"
		shortcuts.auto_confirm:
			checkbox_id = "auto_confirm"
		shortcuts.quit:
			checkbox_id = "quit"
	if slider_id != "Null":
		manual_slide(slider_id, amount)
	if checkbox_id != "Null":
		manual_check(checkbox_id)

func manual_check(id : String):
	check_boxes.manual_check(id)

func manual_slide(id : String, amount : int):
	sliders.manual_slide(id, amount)
