extends HSlider

onready var description = $Description

var current_value : int

func set_description(string : String):
	description.text = string
