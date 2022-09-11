extends Timer

signal fade_out_select_button(card)

var card : Card

func initialize(new_card : Card):
	_on_Attachments_Fade_Timer_timeout()
	card = new_card
	System.set_to_selected(card)
	start()

func _on_Attachments_Fade_Timer_timeout():
	stop()
	if card != null:
		System.set_to_selected(System.selected_card)
