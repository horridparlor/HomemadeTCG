extends Control

onready var text_box = $TextBox
onready var task_message = $TextBox/TaskMessage
onready var tween = $Tween

const max_x : int = 1600
const max_y : int = 200
var is_permanent : bool

func set_message(message : String, make_permanent : bool = false):
	if message == "Null":
		clear_message()
		return
	toggle_visibility(true)
	task_message.text = message
	if make_permanent:
		is_permanent = true
	
func clear_message():
	if !is_permanent:
		toggle_visibility(false)

func toggle_visibility(boolean : bool):
	var tween_values : Array = System.get_tween_values(boolean, self)
	tween.interpolate_property(self, tween_values[0], tween_values[1], tween_values[2], tween_values[3])
	tween.start()

func flip_text_box():
	text_box.rect_rotation = 180
	task_message.rect_position = Vector2(-640, -110)
