extends Control

onready var count = $Count

func show_count(number_of_copies : int):
	self.visible = true
	count.text = str(number_of_copies)

func clear():
	self.visible = false
