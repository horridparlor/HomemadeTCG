extends Control

signal get_active

onready var animations = $Animations

const max_x : int = 200
const max_y : int = 200
const server_url : String = "https://discord.gg/hybmm4Wb"

var is_active : bool

func _ready():
	animations.set_backlight("DiscordLink")

func _on_Button_pressed():
	emit_signal("get_active", "DiscordLink")
	if is_active:
		OS.shell_open(server_url)
