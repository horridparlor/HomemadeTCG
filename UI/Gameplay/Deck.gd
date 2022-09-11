extends Control

signal search_mode(boolean, search_pile, send_to)
signal move_call(card)
signal card_milled(card)
signal relocation_confirmed(card, send_to)
signal update_deck
signal toggle_visibility(object, boolean)

onready var text_box = $TopSprite/TextBox
onready var card_count = $TopSprite/TextBox/CardCount
onready var backlight = $BackgroundAnimations/Backlight
onready var top_sprite = $TopSprite
onready var background_animations = $BackgroundAnimations
onready var foreground_animations = $ForegroundAnimations

var cards_in_deck : Array
var current_search_pile : Array
var current_search_amount : int
var random : RandomNumberGenerator
var plays_left : Array
var backlight_on : bool

func _ready():
	background_animations.set_backlight("CardBack")

func set_decklist(decklist):
	for card in decklist:
		card.position = rect_position
		add_card(card, false)
	random.randomize()
	shuffle_deck()
	update_count()

func add_card(card : Card, do_update_count : bool = true):
	cards_in_deck.insert(0, card)
	card.location = "Deck"
	card.address.id = "Deck"
	card.connect("transformed", self, "card_in_deck_transformed")
	if do_update_count:
		update_count()
	emit_signal("move_call", card)

func shuffle_card(card : Card):
	add_card(card)
	shuffle_deck(card)

func pull_card(card : Card):
	cards_in_deck.erase(card)
	card.disconnect("transformed", self, "card_in_deck_transformed")
	update_count()
	
func update_deck():
	emit_signal("update_deck", cards_in_deck)
	
func draw_card(index : int = 0):
	if cards_in_deck.size() > index:
		return cards_in_deck[index]
	return null

func update_count():
	card_count.text = str(cards_in_deck.size())
	if cards_in_deck.size() == 0:
		top_sprite.visible = false
	update_deck()

func card_search(original_card : Card, tag : String, amount : int, \
condition : String, wanted_effect : Dictionary, send_to : String = "Hand"):
	var search_pile : Array
	for card in System.get_tagged_cards(cards_in_deck, tag, condition, \
	original_card.card_name, wanted_effect):
		search_pile.append(card)
	if search_pile.size() >= amount:
		shuffle_deck()
		current_search_amount = amount
		return search_pile
	return []

func confirm_search_pile(search_pile : Array):
	current_search_pile = System.copy_array(search_pile)

func tag_check(card_name : String, tag : String):
	if tag == "Null":
		return true
	elif card_name.find(tag) > -1:
		return true
	return false

func confirm_search_target(card : Card, send_to : String):
	if send_to == "Default":
		send_to = "Hand"
	System.set_to_selected()
	cards_in_deck.erase(card)
	current_search_pile.erase(card)
	current_search_amount -= 1
	update_count()
	emit_signal("search_mode", false, current_search_pile)
	emit_signal("relocation_confirmed", card, send_to)
	if current_search_amount > 0:
		emit_signal("toggle_visibility", card, false)

func shuffle_deck(shuffled_card : Card = null):
	var source : Array = System.copy_array(cards_in_deck)
	var top_card : Card
	var top_shuffled : Array
	var bottom_card : Card
	var bottom_shuffled : Array
	var shuffled_to : Array
	var deck_portions : Array = [top_shuffled, source, bottom_shuffled]
	for card in cards_in_deck:
		if System.has_effect(card, "Deck", "Shuffled"):
			shuffled_to = ["Null"]
			source.erase(card)
			match card.effects.Deck.subclass:
				"Top":
					match card == shuffled_card:
						true:
							top_card = card
						false:
							shuffled_to = top_shuffled
				"Bottom":
					match card == shuffled_card:
						true:
							bottom_card = card
						false:
							shuffled_to = bottom_shuffled
			if shuffled_to != ["Null"]:
				shuffled_to.append(card)
	cards_in_deck = []
	match top_card == null:
		true:
			cards_in_deck = []
		false:
			cards_in_deck = [top_card]
	for portion in deck_portions:
		portion = System.shuffle_array(portion, random)
		cards_in_deck += portion
	if bottom_card != null:
		cards_in_deck.append(bottom_card)

func toggle_backlight(boolean : bool):
	match boolean:
		true:
			background_animations.play("Backlight")
		false:
			background_animations.stop()
			emit_signal("toggle_visibility", backlight, false)
	backlight_on = boolean

func card_in_deck_transformed(id : String):
	foreground_animations.card_animation(id)
	foreground_animations.wait()

func flip_text_box():
	text_box.rect_rotation = 180
	card_count.rect_position = Vector2(-149, -99)
