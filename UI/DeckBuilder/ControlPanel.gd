extends Control

onready var main_count = $CardCounts/MainBacklight/MainCount
onready var grave_count = $CardCounts/Grave_Backlight/GraveCount
onready var confirm_sprite = $Switches/ConfirmSprite
onready var confirmed_sprite = $Switches/ConfirmedSprite

onready var menu_all = $Switches/MenuAllSprite
onready var menu_main = $Switches/MenuMainSprite
onready var menu_grave = $Switches/MenuGraveSprite
onready var menu_deck = $Switches/MenuDeckSprite

var current_menu_filter_sprite : Sprite

func set_counts(main_deck : Array, grave_deck : Array):
	recalc_deck_count(main_count, main_deck)
	recalc_deck_count(grave_count, grave_deck)

func recalc_deck_count(count, source_deck : Array):
	var new_count : int
	for card in source_deck:
		new_count += card[1]
	count.text = str(new_count)

func set_confirm_sprite(boolean):
	confirm_sprite.visible = !boolean
	confirmed_sprite.visible = boolean

func set_menu_filter_sprite(current_menu : String):
	if current_menu_filter_sprite != null:
		current_menu_filter_sprite.visible = false
	if current_menu == "All":
		current_menu_filter_sprite = menu_all
	elif current_menu == "Main":
		current_menu_filter_sprite = menu_main
	elif current_menu == "Grave":
		current_menu_filter_sprite = menu_grave
	elif current_menu == "Deck":
		current_menu_filter_sprite = menu_deck
	current_menu_filter_sprite.visible = true
