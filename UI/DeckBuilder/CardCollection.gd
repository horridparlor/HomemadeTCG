extends Node2D
class_name Card_Collection

signal collection_focused(player_number)
signal confirm(player_number)
signal session_log_update

onready var deck_slots_panel = $DeckSlots
onready var deck_slots = $DeckSlots/Slots
onready var highlight_window = $HighlightWindow
onready var control_panel = $ControlPanel
onready var settings_tab = $HighlightWindow/CardHighlighter/SettingsTab
onready var search_bar = $DeckSlots/SearchBar/LineEdit

onready var search_result1 = $CardSlots/Row1/SearchResult1
onready var search_result2 = $CardSlots/Row1/SearchResult2
onready var search_result3 = $CardSlots/Row1/SearchResult3
onready var search_result4 = $CardSlots/Row1/SearchResult4
onready var search_result5 = $CardSlots/Row1/SearchResult5
onready var search_result6 = $CardSlots/Row1/SearchResult6
onready var search_result7 = $CardSlots/Row1/SearchResult7

onready var search_result8 = $CardSlots/Row2/SearchResult8
onready var search_result9 = $CardSlots/Row2/SearchResult9
onready var search_result10 = $CardSlots/Row2/SearchResult10
onready var search_result11 = $CardSlots/Row2/SearchResult11
onready var search_result12 = $CardSlots/Row2/SearchResult12
onready var search_result13 = $CardSlots/Row2/SearchResult13
onready var search_result14 = $CardSlots/Row2/SearchResult14

var all_cards
var all_main_cards : Array
var all_grave_cards : Array
var main_deck : Array
var grave_deck : Array
var revealed_cards : Array
var current_database : Array
var confirmed : bool
var player_number
var current_menu : String
var focused_card : Array
var display_spin_enabled : bool
var search_result_page : int
var is_AI_controlled : bool
var focused : bool
var emptying_deck : bool
var game_mode : String
var search_focused : bool
var search_filters : Array

func initialize(new_player_number : int):
	var starting_slot : int
	player_number = new_player_number
	initialize_signals()
	load_card_database()
	change_current_menu("All")
	starting_slot = System.get_session_log().deckslots[System.get_player_id(player_number)]
	deck_slots.focus_deck_slot(starting_slot)
	if OS.get_name() == "Android":
		deck_slots_panel.rect_position.y = -270
		search_bar.visible = false

func initialize_signals():
	deck_slots.connect("switch_deck_slot", self, "_on_switch_deckslot")
	deck_slots.connect("deck_emptied", self, "_on_deck_emptied")
	var result_slots : Array = get_result_slots()
	for result_slot in result_slots:
		result_slot.connect("search_result_selected", self, "_on_search_result_selected")
	settings_tab.connect("menu_activated", self, "settings_tab_opened")
	settings_tab.connect("session_log_update", self, "session_log_update")

func load_card_database():
	var card_database : Dictionary = System.get_card_database()
	all_cards = card_database.All
	all_main_cards = card_database.Main
	all_grave_cards = card_database.Grave

func refresh_card_search(database : Array = []):
	search_filters = database
	revealed_cards = []
	search_result_page = 0
	match database.size() > 0:
		true:
			fill_revealed_cards(database, main_deck + grave_deck, false)
		false:
			update_revealed_cards()
	show_search_results()
	update_counts()
	
func show_search_results():
	var search_result_slots : Array = get_result_slots()
	var slot_reader : int
	var to_starting_index : int = search_result_page * 14
	for card in revealed_cards:
		if to_starting_index > 0:
			to_starting_index -= 1
			continue
		search_result_slots[slot_reader].show_result(card)
		slot_reader += 1
		if slot_reader == search_result_slots.size():
			break
	while slot_reader < search_result_slots.size():
		search_result_slots[slot_reader].clear()
		slot_reader += 1
	if focused_card.size() > 0:
		_on_search_result_selected(focused_card[0])

func get_result_slots():
	return [search_result1, search_result2,
	search_result3, search_result4, search_result5, search_result6,
	search_result7, search_result8, search_result9, search_result10,
	search_result11, search_result12, search_result13, search_result14]

func update_revealed_cards():
	current_database = []
	if current_menu == "All":
		fill_revealed_cards(all_cards, main_deck + grave_deck)
	elif current_menu == "Main":
		fill_revealed_cards(all_main_cards, main_deck)
	elif current_menu == "Grave":
		fill_revealed_cards(all_grave_cards, grave_deck)
	elif current_menu == "Deck":
		fill_revealed_cards(System.scrutinize_deck(main_deck, all_main_cards), main_deck)
		fill_revealed_cards(System.scrutinize_deck(grave_deck, all_grave_cards), grave_deck)

func fill_revealed_cards(database : Array, copies_reference : Array, \
update_current_database : bool = true):
	var card : Array
	for card_name in database:
		card = [card_name, 0]
		revealed_cards.append(card)
		for reference_card in copies_reference:
			if card[0] == reference_card[0]:
				card[1] = reference_card[1]
	if update_current_database:
		current_database = current_database + database

func _on_ConfirmSwitch_pressed():
	if AI_controlled_check():
		return
	if confirmed:
		set_confirmed(false)
		return
	set_confirmed(true)
	save_decklist()
	emit_signal("confirm", player_number)

func set_confirmed(boolean : bool):
	confirmed = boolean
	control_panel.set_confirm_sprite(boolean)

func _on_switch_deckslot(deck_slot : int = deck_slots.current_slot):
	var decklist : Dictionary
	if is_AI_controlled:
		return
	save_decklist()
	deck_slots.current_slot = deck_slot
	decklist = System.get_decklist(player_number, deck_slot)
	main_deck = decklist.Main
	grave_deck = decklist.Grave
	refresh_card_search()

func copy_decklist(decklist : Array, source : Array):
	decklist = []
	System.copy_array(source, decklist)

func _on_MenuSwitch_pressed():
	var id : String = System.value_switch(current_menu, \
	["All", "Main", "Grave", "Deck"])
	if AI_controlled_check():
		return
	change_current_menu(id)
	_on_LineEdit_text_changed()

func change_current_menu(new_menu : String):
	current_menu = new_menu
	control_panel.set_menu_filter_sprite(current_menu)
	refresh_card_search()

func save_decklist():
	if deck_slots.current_slot > 0:
		var decklist : Dictionary = System.alphabetize_decklist( \
		System.build_decklist(main_deck, grave_deck))
		System.set_decklist(decklist, player_number, deck_slots.current_slot, game_mode)

func _on_search_result_selected(card_name : String):
	if AI_controlled_check():
		return
	focus_collection()
	var copy_count : int
	for card in revealed_cards:
		if card[0] == card_name:
			copy_count = card[1]
			focused_card = card
			highlight_window.highlight_card(card)
			break

func _on_DecreaseBy1_pressed():
	update_focused_card(-1)

func _on_IncreaseBy1_pressed():
	update_focused_card(1)

func _on_DecreaseBy10_pressed():
	update_focused_card(-3)

func _on_IncreaseBy10_pressed():
	update_focused_card(3)

func _on_ToZero_pressed():
	if AI_controlled_check():
		return
	clear_focused()

func clear_focused():
	if focused_card.size() == 0:
		return
	focused_card[1] = 0
	update_focused_card()

func update_focused_card(copy_change : int = 0):
	if AI_controlled_check():
		return
	set_confirmed(false)
	if focused_card.size() == 0:
		return
	focused_card[1] += copy_change
	focused_card[1] = System.max_value(focused_card[1], System.MAX_COPIES)
	if focused_card[1] < 0:
		focused_card[1] = 0
	if all_main_cards.has(focused_card[0]):
		append_to_decklist(focused_card, main_deck, System.main_deck_max)
	elif all_grave_cards.has(focused_card[0]):
		append_to_decklist(focused_card, grave_deck, System.grave_deck_max)
	highlight_window.highlight_card(focused_card)
	update_counts(focused_card)

func append_to_decklist(new_card : Array, decklist : Array, max_deck_size : int):
	for card in decklist:
		if card[0] == new_card[0]:
			if new_card[1] == 0:
				decklist.erase(card)
				return
			var space_in_deck : int = get_space_in_deck(decklist, max_deck_size)
			if new_card[1] - card[1] > space_in_deck:
				new_card[1] = card[1] + space_in_deck
			card[1] = new_card[1]
			return
	if new_card[1] > 0:
		var space_in_deck : int = get_space_in_deck(decklist, max_deck_size)
		if new_card[1] > space_in_deck:
			new_card[1] = space_in_deck
		decklist.append(new_card)

func get_space_in_deck(decklist : Array, max_deck_size : int):
	return max_deck_size - get_number_of_cards_in_deck(decklist)

func get_number_of_cards_in_deck(decklist : Array):
	var card_count : int
	for card in decklist:
		card_count += card[1]
	return card_count

func update_counts(card : Array = []):
	control_panel.set_counts(main_deck, grave_deck)
	if card.size() > 0:
		for result_slot in get_result_slots():
			if result_slot.card_name == card[0]:
				result_slot.set_copy_count(card[1])

func focus_collection():
	if display_spin_enabled:
		emit_signal("collection_focused", player_number)

func unfocus_collection():
	deck_slots.toggle_empty_slot_visibility(false)
	focused_card = []
	focused = false
	highlight_window.clear()
	settings_tab.close_settings()

func _on_SearchPileUP_pressed():
	if AI_controlled_check():
		return
	if search_result_page > 0:
		search_result_page -= 1
	show_search_results()

func _on_SearchPileDown_pressed():
	if AI_controlled_check():
		return
	if int((revealed_cards.size() - 1) / 14) > search_result_page:
		search_result_page += 1
	show_search_results()

func session_log_update():
	emit_signal("session_log_update")

func make_AI_controlled(boolean : bool):
	is_AI_controlled = boolean
	settings_tab.make_AI_controlled(boolean)

func _on_deck_emptied(initialize : bool, inducted : bool):
	emptying_deck = initialize
	if inducted:
		clear_focused()
		main_deck = []
		grave_deck = []
		refresh_card_search(search_filters)

func AI_controlled_check():
	settings_tab.close_settings()
	if emptying_deck:
		deck_slots.focus_current_slot()
		return true
	return is_AI_controlled

func _input(event : InputEvent):
	var key : String = System.get_input(event)
	var shortcuts : Dictionary = System.card_collection_shortcuts
	if is_AI_controlled or !focused:
		return
	if key != "Null":
		if key == System.toggle_settings_key:
			settings_tab._on_OpenSettings_pressed()
		elif settings_tab.is_menu_active:
			settings_tab.setting_shortcuts(key)
		elif shortcuts.has(key):
			card_collection_shortcuts(shortcuts[key])

func card_collection_shortcuts(id : String):
	match id:
		"search":
			match search_focused:
				true:
					close_search_bar()
				false:
					open_search_bar()
					_on_LineEdit_mouse_entered()

func _on_LineEdit_text_changed(new_text : String = search_bar.text):
	var filtered_database : Array
	var filter_tags : Array = System.extract_tags(new_text)
	for card_name in current_database:
		if System.filter_search_result(System.get_text_zones(card_name), filter_tags):
			filtered_database.append(card_name)
	refresh_card_search(filtered_database)

func _on_LineEdit_mouse_entered():
	open_search_bar()

func _on_LineEdit_mouse_exited():
	close_search_bar()

func open_search_bar():
	search_focused = true
	settings_tab.close_settings()
	search_bar.grab_focus()

func close_search_bar():
	search_focused = false
	search_bar.release_focus()

func settings_tab_opened():
	close_search_bar()
