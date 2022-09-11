extends Control

signal pressed
signal toggle_visibility(event_button)

onready var label = $Label
onready var button = $Button

var value : int
var label_prefix : String
var label_suffix : String

func _ready():
	if button != null:
		button.connect("pressed", self, "_on_Button_pressed")

func set_label(string : String, suffix : String = "Null"):
	if suffix != "Null":
		label_prefix = string
		label_suffix = suffix
		return
	label.text = label_prefix + string + label_suffix

func _on_Button_pressed():
	match value == 0:
		true:
			emit_signal("pressed")
		false:
			emit_signal("pressed", value)

func reveal():
	visible = true
	toggle_visibility(true)

func hide(force : bool = false):
	if force:
		visible = false
		modulate.a = 0
	toggle_visibility(false)

func toggle_visibility(boolean : bool):
	if button != null:
		button.visible = boolean
	emit_signal("toggle_visibility", self, boolean)

func set_value(new_value : int):
	value = new_value
	set_label(str(value))
