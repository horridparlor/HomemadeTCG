extends Control

signal toggle_visibility(event_button, boolean)
signal event_cleared
signal enter_gameplay
signal reveal_pile
signal close_reveal_pile
signal death
signal ascend_next_floor

onready var background = $Background
onready var event_name = $EventButtons/EventName
onready var fight = $EventButtons/Fight
onready var decklist = $EventButtons/Decklist
onready var death = $EventButtons/Death
onready var ascend = $EventButtons/Ascend
onready var back = $EventButtons/Back
onready var reveal_pile_back = $RevealPileBack

const empty_data : Dictionary = {
	"id" : "Null",
	"name" : {"event" : "Null"}
}
var data : Dictionary
var second_reveal_pile : Array

func _ready():
	fight.set_label("Fight")
	decklist.set_label("Spy decklist")
	death.set_label("Okay :<")
	ascend.set_label("Ascend")
	back.set_label("Back")
	reveal_pile_back.hide(true)
	
	for button in event_buttons() + [reveal_pile_back]:
		for cue in button_cues():
			button.connect(cue, self, cue)
			
	fight.connect("pressed", self, "enter_gameplay")
	decklist.connect("pressed", self, "show_reveal_pile")
	death.connect("pressed", self, "_on_death")
	ascend.connect("pressed", self, "ascend_next_floor")
	back.connect("pressed", self, "close_window")
	reveal_pile_back.connect("pressed", self, "close_reveal_pile")
	
	reset_window(false, true)

func reset_window(update_name : bool = true, instant : bool = false):
	hide_buttons(instant)
	set_data(empty_data, update_name)

func button_cues():
	return ["toggle_visibility"]

func event(icon : Dictionary):
	var revealed_buttons : Array = [background, back]
	var append_buttons : Array
	var roguelike_log : Dictionary = System.get_roguelike_log()
	hide_buttons(true)
	set_data(icon)
	match data.id:
		"Null":
			reset_window(false)
			return
		"Death":
			append_buttons = [event_name, death]
			revealed_buttons.erase(back)
		"Gate":
			append_buttons = [event_name]
			if icon.name.description == System.gate_open_label:
				append_buttons.append(ascend)
		"Enemy":
			append_buttons = [event_name, fight, decklist]
		"Victory":
			append_buttons = [event_name, death]
			death.set_label(icon.death_message)
			revealed_buttons.erase(back)
						
	for button in append_buttons:
		revealed_buttons.append(button)
	for button in revealed_buttons:
		button.reveal()

func set_data(icon : Dictionary, update_name : bool = true):
	data = System.copy_dictionary(icon, data)
	if update_name:
		set_event_name(data.name.event)

func set_event_name(string : String):
	event_name.set_label(string)

func close_window():
	reset_window(false)
	emit_signal("event_cleared")

func hide_buttons(instant : bool = false):
	for button in event_buttons():
		button.hide(instant)

func event_buttons():
	return [background, event_name, fight, decklist, death, ascend, back]

func enter_gameplay():
	System.set_decklist(System.get_enemy_decklist(data.decklist), 2, 1)
	close_window()
	emit_signal("enter_gameplay")

func show_reveal_pile(source : Array = System.combine_subdecks(System.get_enemy_decklist( \
data.decklist)), message : String = "Enemy decklist.", init_back_button : bool = true):
	hide_buttons()
	emit_signal("reveal_pile", source, message)
	if init_back_button:
		reveal_pile_back.reveal()

func toggle_visibility(event_button : Control, boolean : bool):
	emit_signal("toggle_visibility", event_button, boolean)

func close_reveal_pile(reveal_pile : Array = []):
	reveal_pile_back.hide()
	emit_signal("close_reveal_pile")
	event(data)
	if second_reveal_pile.size() > 0:
		show_reveal_pile(second_reveal_pile)
		second_reveal_pile = []
	elif data.id != "Null":
		second_reveal_pile = reveal_pile

func _on_death():
	close_window()
	emit_signal("death")

func ascend_next_floor():
	close_window()
	emit_signal("ascend_next_floor")
