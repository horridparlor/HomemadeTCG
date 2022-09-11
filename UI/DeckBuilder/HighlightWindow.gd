extends Control

onready var card_highlighter = $CardHighlighter
onready var copy_count = $UI/CopyCount/Count

func highlight_card(card : Array):
	var card_name : String = card[0]
	var number_of_copies : int = card[1]
	card_highlighter.focus(card_name)
	copy_count.text = str(number_of_copies)

func clear():
	highlight_card(["CardBack", 0])
