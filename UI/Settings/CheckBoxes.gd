extends Control

signal activity

onready var display_spin = $DisplaySpin
onready var toggle_AI = $ToggleAI
onready var autoplay = $AutoPlay
onready var auto_confirm = $AutoConfirm
onready var quit = $Quit

var is_active : bool

func _ready():
	display_spin.connect("checked", self, "_on_display_spin_checked")
	display_spin.set_description("Enable Display Spin")
	
	toggle_AI.connect("checked", self, "_on_toggle_AI_checked")
	toggle_AI.set_description("AI Opponent")
	
	autoplay.connect("checked", self, "_on_auto_play_checked")
	autoplay.set_description("Autoplay")
	
	auto_confirm.connect("checked", self, "_on_auto_confirm_checked")
	auto_confirm.set_description("Auto-Confirm")
	
	quit.connect("checked", self, "_on_quit_checked")
	quit.set_description("Quit")
	
	if System.is_single_player_mode():
		for box in [display_spin, toggle_AI, auto_confirm]:
			box.visible = false

func session_log_update():
	var session_log : Dictionary = System.get_session_log()
	display_spin.set_checked(session_log.display_spin_enabled)
	toggle_AI.set_checked(session_log.AI_enabled)
	autoplay.set_checked(session_log.auto_play)
	auto_confirm.set_checked(session_log.auto_confirm)

func _on_display_spin_checked(boolean : bool):
	on_box_checked("display_spin", boolean)

func _on_toggle_AI_checked(boolean : bool):
	on_box_checked("toggle_AI", boolean)

func _on_auto_play_checked(boolean : bool):
	on_box_checked("auto_play", boolean)

func _on_auto_confirm_checked(boolean : bool):
	on_box_checked("auto_confirm", boolean)

func _on_quit_checked(boolean : bool):
	get_tree().quit()

func on_box_checked(box_name : String, boolean : bool):
	var session_log : Dictionary = System.get_session_log()
	if box_name == "display_spin":
		session_log.display_spin_enabled = boolean
	elif box_name == "toggle_AI":
		session_log.AI_enabled = boolean
	elif box_name == "auto_play":
		session_log.auto_play = boolean
	elif box_name == "auto_confirm":
		session_log.auto_confirm = boolean
	System.set_session_log(session_log)
	activity()

func activity():
	emit_signal("activity")

func set_active(boolean : bool):
	is_active = boolean
	var checkboxes : Array = [display_spin, toggle_AI, autoplay, auto_confirm, quit]
	for box in checkboxes:
		box.set_active(boolean)

func manual_check(id : String):
	var button : Control
	match id:
		"display_spin":
			button = display_spin
		"AI_opponent":
			button = toggle_AI
		"autoplay":
			button = autoplay
		"auto_confirm":
			button = auto_confirm
		"quit":
			button = quit
	button._on_Checked_pressed()
