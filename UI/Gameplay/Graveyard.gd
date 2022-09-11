extends Control

signal update_powers()
signal card_sent_to_grave(card)
signal confirmation_call(id, card, confirm_card)
signal toggle_visibility(object, boolean)

onready var tween = $Tween
onready var background_animations = $BackgroundAnimations
onready var foreground_animations = $ForegroundAnimations
onready var backlight = $BackgroundAnimations/Backlight

const max_x : int = 300
const max_y : int = 200

var cards_in_graveyard : Array
var is_active : bool
var target_in_graveyard : Card
var plays_left : Array

func _ready():
	background_animations.set_backlight("Graveyard")

func set_grave_decklist(decklist):
	for card in decklist:
		add_card(card)
		card.visible = false

func add_card(card : Card):
	card.location = "Graveyard"
	if !cards_in_graveyard.has(card):
		cards_in_graveyard.insert(0, card)
		card.connect("transformed", self, "play_animation")
		emit_signal("card_sent_to_grave", card, "self")

func pull_card(card : Card):
	cards_in_graveyard.erase(card)
	card.disconnect("transformed", self, "play_animation")
	emit_signal("update_powers")

func toggle_active(boolean : bool):
	is_active = boolean

func target_card_in_grave(card : Card):
	if target_in_graveyard != null:
		forget_target_in_graveyard()
	match card.allowed_to:
		"ContactFusion":
			confirm_graveyard_conditions(card)
		"Void":
			if check_void_conditions(card):
				confirm_graveyard_conditions(card, "Void")
			return
	if System.has_corresponding_tag(card, plays_left):
		confirm_graveyard_conditions(card, "Play")

func check_void_conditions(card : Card):
	var void_targets_to_find : int = 1
	var void_effect : Dictionary
	match System.has_effect(card, "Void"):
		true:
			void_effect = card.effects.Void
		false:
			return false
	for key in void_effect:
		if key == "plus":
			void_targets_to_find += void_effect.plus
	for other_card in cards_in_graveyard:
		var is_fusion : bool
		for key in other_card.effects:
			if key == "ContactFusion":
				is_fusion = true
		if is_fusion:
			continue
		void_targets_to_find -= 1
		if void_targets_to_find == 0:
			return true
	return false
	
func confirm_graveyard_conditions(card : Card, confirmation_id : String = "Null"):
	if confirmation_id == "Null":
		target_in_graveyard = card
		System.set_to_selected(target_in_graveyard)
		return
	emit_signal("confirmation_call", confirmation_id, card)

func forget_target_in_graveyard():
	if target_in_graveyard != null:
		System.set_to_selected()

func toggle_backlight(boolean : bool):
	match boolean:
		true:
			background_animations.play("Backlight")
		false:
			background_animations.stop()
			emit_signal("toggle_visibility", backlight, false)

func play_animation(id : String):
	foreground_animations.card_animation(id)
