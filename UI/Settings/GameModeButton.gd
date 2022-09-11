extends Control

signal activity

onready var roguelike_sprite = $RoguelikeSprite
onready var sandbox_sprite = $SandboxSprite

var game_mode : String
var game_mode_sprite : Sprite
var is_active : bool

func _ready():
	session_log_update()

func session_log_update():
	game_mode = System.get_session_log().game_mode
	update_game_mode_sprite()

func _on_ChangeGameMode_pressed():
	var session_log : Dictionary = System.get_session_log()
	if !is_active:
		return
	if game_mode == "Roguelike":
		game_mode = "Sandbox"
	elif game_mode == "Sandbox":
		game_mode = "Roguelike"
	update_game_mode_sprite()
	session_log.game_mode = game_mode
	System.set_session_log(session_log)
	emit_signal("activity")

func update_game_mode_sprite():
	if game_mode_sprite != null:
		game_mode_sprite.visible = false
	if game_mode == "Roguelike":
		focus_game_mode_sprite(roguelike_sprite)
	elif game_mode == "Sandbox":
		focus_game_mode_sprite(sandbox_sprite)

func focus_game_mode_sprite(sprite : Sprite):
	sprite.visible = true
	game_mode_sprite = sprite

func set_active(boolean : bool):
	is_active = boolean
