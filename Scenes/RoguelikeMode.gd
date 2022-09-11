extends Node2D
class_name RoguelikeScene

signal refresh_scene
signal open_deck_builder
signal clear_scene(scene)
signal open_gameplay

onready var background_layer = $Background
onready var background = $Background/Background
onready var camera = $Background/CenteredCamera
onready var music = $Background/BackgroundMusic
onready var event_window = $EventWindow

onready var settings_tab = $UI/CardHighlighter/SettingsTab
onready var status_menu = $UI/StatusMenu
onready var cards_layer = $Animations/Cards
onready var card_mover = $Animations/CardMover
onready var card_highlighter = $UI/CardHighlighter
onready var taskbanner = $UI/TaskBanner
onready var discord_link = $UI/DiscordLink

onready var close_timer = $Timers/CloseTimer
onready var task_pile_refresh_timer = $Timers/TaskPileRefreshTimer

const cards_spawning_point : Vector2 = Vector2(0, System.resolution.y / 2.0 + System.highlight_card_rect.y)
const x_area : float = System.resolution.x
const max_margin_highlight : int = int(System.highlight_card_rect.x * 1.5)
const max_margin_compressed : int = max_margin_highlight / 2
const reveal_pile_y : int = (-int(System.resolution.y) + 2 * System.reveal_y_margin) / 2
const animation_time : float = 1.2
const background_starting_position : int = -810

var random : RandomNumberGenerator = RandomNumberGenerator.new()
var reveal_pile : Array
var task_pile : Array
var task_tags : Array
var is_active : bool
var map_icons : Array
var legal_targets : Array
var amount_offered : int

func _ready():
	camera.current = true
	connect_signals()
	settings_tab.session_log_update()
	random.randomize()
	initialize_floor()

func connect_signals():
	event_window.connect("toggle_visibility", card_mover, "toggle_visibility")
	event_window.connect("event_cleared", self, "task_pile_ready")
	event_window.connect("enter_gameplay", self, "enter_gameplay")
	event_window.connect("reveal_pile", self, "show_reveal_pile")
	event_window.connect("close_reveal_pile", self, "close_reveal_pile")
	event_window.connect("death", self, "death")
	event_window.connect("ascend_next_floor", self, "ascend_next_floor")
	
	settings_tab.connect("session_log_update", self, "session_log_update")
	status_menu.random = random
	status_menu.connect("open_deck", self, "open_deck")
	status_menu.connect("surrender", self, "death")
	card_mover.connect("deliver_card", self, "deliver_card")
	discord_link.connect("get_active", self, "make_active")

func _on_death():
	event(icon("Death", "You died!"))

func _on_victory():
	event(icon("Victory", "You won!", "Yeeeeh ;O"))

func death():
	System.set_roguelike_log()
	empty_decklists()
	refresh_scene()

func empty_decklists():
	var empty_decklist : Dictionary = {
		"Main" : [],
		"Grave" : []
	}
	var player_number : int = 1
	var slots : Array = [1, 2, 3, 4]
	var game_mode : String = "Roguelike"
	for slot in slots:
		System.set_decklist(empty_decklist, player_number, slot, game_mode)

func refresh_scene():
	emit_signal("refresh_scene")

func initialize_scene():
	var roguelike_log : Dictionary = System.get_roguelike_log()
	music.play()
	visible = true
	place_map_icons(roguelike_log)
	start_unfinished_tasks(roguelike_log)

func place_map_icons(roguelike_log : Dictionary):
	var map_icon : Resource = load("res://UI/Roguelike/MapIcon.tscn")
	var instance : Node2D
	var enemies_to_defeat : int
	var label : String
	background.texture = load("res://Textures/UI/Roguelike/Background/" + \
	roguelike_log.background_sprite + ".png")
	background.position.y = background_starting_position + roguelike_log.background_y_position
	for icon in roguelike_log.map_icons:
		match icon.id:
			"Gate":
				icon.enemies_to_defeat = repair_enemies_to_defeat(icon.enemies_to_defeat, \
				roguelike_log)
				enemies_to_defeat = icon.enemies_to_defeat
				match enemies_to_defeat == 0:
					true:
						label = System.gate_open_label
						roguelike_log.map_icons = []
					false:
						label = "Kill " + str(enemies_to_defeat) + " "
						match enemies_to_defeat == 1:
							true:
								label += "enemy."
							false:
								label += "enemies."
				icon.name["description"] = label
		instance = map_icon.instance()
		instance.build(icon)
		instance.connect("focus", self, "highlight_map_icon")
		background_layer.add_child(instance)
		map_icons.append(instance)
		if enemies_to_defeat == 0:
			break

func repair_enemies_to_defeat(enemies_to_defeat : int, roguelike_log : Dictionary):
	return System.max_value(enemies_to_defeat, count_enemy_icons(roguelike_log))

func start_unfinished_tasks(roguelike_log : Dictionary):
	task_pile = System.copy_array(roguelike_log.task_pile)
	set_is_active(false)
	start_task_pile()

func task_gameplay_results(roguelike_log : Dictionary):
	var resulting_tasks : Array
	var updated_icons : Array
	if System.always_win and roguelike_log.gameplay_winner > 0:
		roguelike_log.gameplay_winner = 1
	match roguelike_log.gameplay_winner:
		1:
			for icon in roguelike_log.map_icons:
				if icon.id == "Gate":
					icon.enemies_to_defeat = repair_enemies_to_defeat( \
					icon.enemies_to_defeat, roguelike_log) - 1
				updated_icons.append(icon)
			roguelike_log.map_icons = updated_icons
			resulting_tasks = [card_to_add(roguelike_log, "Main", roguelike_log.rewarded_amounts[0]), 
			card_to_add(roguelike_log, "Grave", 1)]
			roguelike_log = pull_rewarded_amount(roguelike_log)
			for icon in roguelike_log.map_icons:
				if icon.id == "Enemy" and (icon.instance_id == \
				roguelike_log.current_enemy):
					roguelike_log.map_icons.erase(icon)
			if roguelike_log.map_icons.size() == 0:
				roguelike_log.task_pile.append(build_task("victory"))
		2:
			resulting_tasks = [build_task("death")]
	for task in resulting_tasks:
		roguelike_log.task_pile.append(task)
		roguelike_log.gameplay_winner = 0
	System.set_roguelike_log(roguelike_log)
	return roguelike_log

func pull_rewarded_amount(roguelike_log : Dictionary):
	if roguelike_log.rewarded_amounts.size() > 1:
		roguelike_log.rewarded_amounts.remove(0)
	return roguelike_log

func count_enemy_icons(roguelike_log : Dictionary):
	var count : int
	for icon in roguelike_log.map_icons:
		if icon.id == "Enemy":
			count += 1
	return count

func new_task(id : String, amount : int = 1, subclass : String = "Null"):
	task_pile.append(build_task(id, amount, subclass))

func build_task(id : String = "Null", amount : int = 1, subclass : String = "Null"):
	return {
		"id" : id,
		"amount" : amount,
		"subclass" : subclass
	}

func session_log_update():
	var session_log : Dictionary = System.get_session_log()
	card_mover.set_movement_speed(session_log.game_speed)
	if session_log.game_mode != "Roguelike":
		emit_signal("refresh_scene")

func initialize_floor():
	var roguelike_log : Dictionary = System.get_roguelike_log()
	roguelike_log = task_gameplay_results(roguelike_log)
	if roguelike_log.floor_number == 0:
		generate_floor(roguelike_log, true)

func generate_floor(roguelike_log : Dictionary = System.get_roguelike_log(), \
reset_collection : bool = false):
	var floor_number : int = roguelike_log.floor_number + 1
	if floor_number == 1:
		floor_number = System.starting_floor
	var background_sprite : String = System.get_roguelike_background(floor_number)
	for icon in map_icons:
		background_layer.remove_child(icon)
		icon.queue_free()
	map_icons = []
	
	roguelike_log.floor_number = floor_number
	roguelike_log.background_sprite = background_sprite
	roguelike_log.background_y_position = random.randi_range(0, 1600)
	roguelike_log.rewarded_amounts = generate_card_amounts(6, 3)
	roguelike_log = generate_map_icons(background_sprite, roguelike_log)
	match reset_collection:
		true:
			roguelike_log.card_collection = System.empty_card_collection()
			roguelike_log.locked_cards = System.get_legal_cards()
			roguelike_log = build_starter_deck(roguelike_log)
		false:
			place_map_icons(roguelike_log)

	System.set_roguelike_log(roguelike_log)

func generate_map_icons(background_sprite : String, roguelike_log : Dictionary):
	var icons : Array = generate_icons(icons_to_generate(roguelike_log), background_sprite, \
	roguelike_log)
	var avoided_planes : Array
	for element in UI_elements():
		avoided_planes.append(System.plane(element))
	icons = System.position_map_icons(icons, avoided_planes, random)
	roguelike_log.map_icons = System.copy_array(icons)
	return roguelike_log

func icons_to_generate(roguelike_log : Dictionary):
	var icons : Array = ["Gate", "Enemy"]
	if roguelike_log.floor_number == roguelike_log.final_floor:
		icons.erase("Gate")
	return icons

func generate_icons(id_s : Array, background_sprite : String, \
roguelike_log : Dictionary = System.get_roguelike_log()):
	var icons : Array
	for id in id_s:
		match id:
			"Enemy":
				icons += System.generate_enemies(System.max_value( \
				System.max_enemies_to_defeat + 1, System.max_map_icons - icons.size()), \
				roguelike_log.floor_number, background_sprite, random)
			_:
				icons.append(System.generate_icon(id, background_sprite, random))
	return icons

func UI_elements():
	return [card_highlighter, status_menu, taskbanner, discord_link]

func _input(event : InputEvent):
	var key : String = System.get_input(event)
	if !is_active:
		return
	if key != "Null":
		if key == System.toggle_settings_key:
			settings_tab._on_OpenSettings_pressed()
		elif settings_tab.is_menu_active:
			settings_tab.setting_shortcuts(key)

func open_deck():
	var decklist : Array = System.combine_subdecks()
	var do_open_deck : bool = !task_tags.has("your_decklist")
	var second_reveal_pile : Array = System.get_reveal_pile(reveal_pile)
	if decklist.size() == 0:
		status_menu.toggle_deck_message()
		return
	if task_tags.has("add_card") or !do_open_deck:
		second_reveal_pile = []
	match reveal_pile.size() > 0:
		true:
			task_tags.append("task_incompleted")
			event_window.close_reveal_pile(second_reveal_pile)
			match do_open_deck:
				true:
					open_deck()
				false:
					start_task_pile()
		false:
			task_tags.append("your_decklist")
			set_is_active(false)
			event_window.show_reveal_pile(decklist, "Your decklist.", false)

func _on_CloseTimer_timeout():
	emit_signal("clear_scene", self)

func make_AI_controlled(boolean : bool):
	for element in get_UI_elements():
		element.make_AI_controlled(boolean)

func get_UI_elements():
	return [settings_tab, status_menu]

func build_starter_deck(roguelike_log : Dictionary):
	var card_amounts : Array = generate_card_amounts(10, 4)
	for amount in card_amounts:
		roguelike_log.task_pile.append(card_to_add(roguelike_log, "Main", amount))
	return roguelike_log

func generate_card_amounts(amount : int, divided_by : int):
	var card_amounts : Array
	var random_amount : int
	var portions_left : int = divided_by
	for i in range(divided_by):
		portions_left -= 1
		match portions_left == 0:
			true:
				random_amount = amount
			false:
				random_amount = random.randi_range(1, System.max_value( \
				amount - portions_left, 6))
		amount -= random_amount
		card_amounts.append(random_amount)
		pass
	card_amounts = System.shuffle_array(card_amounts, random)
	return card_amounts

func card_to_add(roguelike_log : Dictionary, restriction : String = "Any", \
amount : int = 1):
	var card_to_add : Dictionary = {
		"id" : "add_card",
		"subclass" : restriction,
		"amount" : amount
	}
	return card_to_add

func _on_add_card(restriction : String, amount : int):
	var choices : int = 3
	if restriction == "Grave" or amount > 2:
		choices = 4
	generate_cards(generate_card_names(choices, restriction))
	if reveal_pile.size() > 0:
		task_tags.append("add_card")
		amount_offered = amount
		offer_card_choice()
		return
	update_task_pile()

func offer_card_choice():
	var slots : int = reveal_pile.size()
	var slot_values : Dictionary = System.get_slot_values(slots, x_area, max_margin_highlight)
	var message : String = "Choose a card"
	var message_ending : String = "."
	if amount_offered > 1:
		message_ending = " X(" + str(amount_offered) + ")" + message_ending
	message += message_ending
	for card in reveal_pile:
		induct_card(card)
		legal_targets.append(card)
		card.address.position = System.get_slot_position(card, slot_values)
		_on_move_call(card)
	taskbanner(message)

func deliver_card(card : Card):
	match card.address.id:
		"reveal":
			card.allowed_to_highlight = true
		"clear":
			card.queue_free()

func taskbanner(message : String = "Null"):
	taskbanner.set_message(message)

func induct_card(card : Card):
	card.show_sprite()
	card.address.id = "reveal"
	toggle_visibility(card, true, animation_time)
	card.local_address.y = reveal_pile_y

func toggle_visibility(object, boolean : bool, animation_time : float = 0):
	card_mover.toggle_visibility(object, boolean, animation_time)

func generate_cards(card_names : Array, instance_size : String = "Highlight", \
remember_reveal_pile : bool = true):
	var roguelike_log : Dictionary = System.get_roguelike_log()
	var card : Card
	for card_name in card_names:
		card = instance_card(card_name, instance_size)
		reveal_pile.append(card)
		card.card_slot = reveal_pile.size()
	if remember_reveal_pile:
		roguelike_log.reveal_pile = System.copy_array(card_names)
		System.set_roguelike_log(roguelike_log)

func generate_card_names(amount : int, restriction : String):
	var roguelike_log : Dictionary = System.get_roguelike_log()
	var secret_packs : Dictionary = roguelike_log.secret_packs
	var opened_secret_packs : Array = System.shuffle_array(roguelike_log.opened_secret_packs, random)
	var card_names : Array
	var locked_cards : Array = get_locked_cards(restriction)
	var card_name : String
	var source : Array
	var random_secret_pack : String
	if roguelike_log.reveal_pile.size() > 0:
		return System.copy_array(roguelike_log.reveal_pile)
	for secret_pack in opened_secret_packs:
		secret_packs[secret_pack] = System.filter_names(secret_packs[secret_pack], 
		restriction)
	while amount > 0 and locked_cards.size() > 0:
		random_secret_pack = secret_pack_source(secret_packs, opened_secret_packs)
		match random_secret_pack == "Null":
			true:
				source = locked_cards
			false:
				source = secret_packs[random_secret_pack]
				opened_secret_packs.erase(random_secret_pack)
				
		card_name = System.random_item(source, random)
		card_names.append(card_name)
		locked_cards.erase(card_name)
		for secret_pack in opened_secret_packs:
			if secret_packs[secret_pack].has(card_name):
				secret_packs[secret_pack].erase(card_name)
				opened_secret_packs.erase(secret_pack)
		amount -= 1
	return System.shuffle_array(card_names, random)

func secret_pack_source(secret_packs : Dictionary, opened_secret_packs : Array):
	for secret_pack in opened_secret_packs:
		if System.random_chance(System.max_value(3, secret_packs[secret_pack].size()), \
		8, random):
			return secret_pack
	return "Null"

func instance_card(card_name : String, instance_size : String):
	var card : Card = System.instance_card(card_name, random, instance_size)
	card.position = cards_spawning_point
	card.modulate.a = 0
	cards_layer.add_child(card)
	card.connect("focus", self, "highlight_card")
	card.connect("confirm", self, "confirm_card")
	return card

func get_locked_cards(restriction : String = "Null"):
	return System.filter_names(System.get_roguelike_log().locked_cards, restriction)

func highlight_card(card : Card):
	card_highlighter.focus_card(card)
	card_highlighter.clear_highlight()
	if legal_targets.has(card):
		System.set_to_selected(card, true)
	move_to_view(card)

func move_to_view(card : Card):
	var y_value : int = card.position.y
	var starting_reveal_y : int = reveal_pile_y + System.starting_reveal_y
	var reveal_y_margin : int = card_mover.reveal_y_margin
	if y_value > starting_reveal_y + 2 * reveal_y_margin:
		reveal_pile_up()
	elif y_value < starting_reveal_y:
		reveal_pile_down()

func reveal_pile_up():
	move_reveal_pile(-1)

func reveal_pile_down():
	move_reveal_pile(1)

func move_reveal_pile(multiplier : int):
	for card in reveal_pile:
		card.address.position.y += multiplier * card_mover.reveal_y_margin
		_on_move_call(card)

func _on_move_call(card : Card):
	card_mover.move_card(card)
	
func confirm_card(card : Card):
	add_to_decklist(card)
	close_reveal_pile(card)

func close_reveal_pile(confirmed_card : Card = null):
	match confirmed_card == null:
		true:
			System.set_to_selected()
		false:
			confirmed_card.toggle_confirm_button(false)
	legal_targets = []
	card_mover.reveal_pile = []
	for card in reveal_pile:
		card.allowed_to_highlight = false
		card.address = {
			"id" : "clear",
			"position" : cards_spawning_point
		}
		toggle_visibility(card, false, animation_time)
		_on_move_call(card)
	update_task_pile(!task_tags.has("task_incompleted"))

func update_task_pile(task_completed : bool = false):
	var roguelike_log : Dictionary = System.get_roguelike_log()
	clear_current_task()
	if task_completed:
		complete_task(roguelike_log)

func clear_current_task():
	taskbanner()
	reveal_pile = []
	task_tags = []

func complete_task(roguelike_log : Dictionary):
	clear_completed_task()
	roguelike_log.task_pile = System.copy_array(task_pile)
	roguelike_log.reveal_pile = reveal_pile
	System.set_roguelike_log(roguelike_log)
	start_task_pile()

func clear_completed_task():
	task_pile.remove(0)

func add_to_decklist(card : Card):
	var roguelike_log : Dictionary = System.get_roguelike_log()
	var card_name : String = card.card_name
	var decklist : Dictionary = System.get_decklist()
	var subdeck_id : String
	match System.is_fusion_name(card_name):
		true:
			subdeck_id = "Grave"
		false:
			subdeck_id = "Main"
	decklist = add_to_subdeck(card_name, decklist, subdeck_id)
	if subdeck_id == "Grave":
		decklist["overflow"] = 0
	roguelike_log = remove_from_locked(card_name, roguelike_log, \
	decklist, subdeck_id)
	decklist.erase("overflow")
	System.set_roguelike_log(roguelike_log)
	System.set_decklist(decklist)

func add_to_subdeck(card_name : String, decklist : Dictionary, subdeck_id : String):
	for card in decklist[subdeck_id]:
		if card[0] == card_name:
			card[1] += amount_offered
			if card[1] >= System.MAX_COPIES:
				decklist["overflow"] = card[1] - System.MAX_COPIES
				card[1] = System.MAX_COPIES
			return decklist
	decklist[subdeck_id].append([card_name, amount_offered])
	return System.alphabetize_decklist(decklist)
	
func remove_from_locked(card_name : String, roguelike_log : Dictionary, \
decklist : Dictionary, subdeck_id : String):
	var erase_from_card_pool : bool
	var secret_packs : Dictionary = roguelike_log.secret_packs
	var secret_pack_cards : Dictionary = roguelike_log.secret_pack_cards
	var overflow : int
	if decklist.has("overflow"):
		overflow = decklist.overflow
		erase_from_card_pool = true
		if overflow > 0:
			roguelike_log = cram_task(card_to_add(roguelike_log, subdeck_id, \
			overflow), roguelike_log, 1)
	if erase_from_card_pool:
		roguelike_log.locked_cards.erase(card_name)
	if secret_pack_cards.has(card_name):
		for secret_pack in secret_pack_cards[card_name]:
			match erase_from_card_pool:
				true:
					roguelike_log.secret_packs[secret_pack].erase(card_name)
				false:
					roguelike_log = open_secret_pack(roguelike_log, secret_pack)
		if erase_from_card_pool:
			roguelike_log.secret_pack_cards.erase(card_name)
	return roguelike_log

func cram_task(task : Dictionary, roguelike_log : Dictionary, index : int = 0):
	roguelike_log.task_pile.insert(index, task)
	task_pile.insert(index, task)
	return roguelike_log

func open_secret_pack(roguelike_log : Dictionary, secret_pack : String):
	if roguelike_log.secret_packs[secret_pack].size() > 0 and \
	!roguelike_log.opened_secret_packs.has(secret_pack):
		roguelike_log.opened_secret_packs.append(secret_pack)
	return roguelike_log
	
func start_task_pile():
	var task : Dictionary = System.get_next_task(task_pile, false)
	if !System.is_default(task):
		match task.id:
			"add_card":
				_on_add_card(task.subclass, task.amount)
			"death":
				_on_death()
			"victory":
				_on_victory()
		return
	if event_window.data.id == "Null":
		task_pile_ready()

func task_pile_ready():
	task_pile_refresh_timer.start()

func set_roguelike_log_key(key : String, value):
	var roguelike_log : Dictionary = System.get_roguelike_log()
	roguelike_log[key] = value
	System.set_roguelike_log(roguelike_log)

func _on_TaskPileRefreshTimer_timeout():
	task_pile_refresh_timer.stop()
	set_is_active()

func highlight_map_icon(icon : Dictionary):
	if !is_active:
		return
	match icon.id:
		"Enemy":
			set_roguelike_log_key("current_enemy", icon.instance_id)
			card_highlighter.focus(icon.name.highlight)
	event(icon)

func icon(id : String, icon_name : String = "Null", death_message : String = "Default"):
	return {"id" : id, "name" : {"event" : icon_name}, "death_message" : death_message}

func event(icon : Dictionary):
	set_is_active(false)
	event_window.event(icon)
	
func enter_gameplay():
	set_is_active(false)
	emit_signal("open_gameplay")
	emit_signal("clear_scene", self)

func set_is_active(boolean : bool = true):
	is_active = boolean
	toggle_backlights()

func make_active(element_id : String):
	var target_element : Control
	match element_id:
		"DiscordLink":
			target_element = discord_link
	if target_element != null:
		target_element.is_active = is_active

func toggle_backlights(boolean : bool = is_active):
	for element in [discord_link]:
		match boolean:
			true:
				element.animations.play("Backlight")
			false:
				element.animations.stop()
		toggle_visibility(element, boolean)

func show_reveal_pile(source : Array, message : String):
	var cards_to_reveal : Array
	var card_name : String
	var card_counts : Dictionary
	for card in source:
		card_name = card[0]
		cards_to_reveal.append(card_name)
		card_counts[card_name] = card[1]
	generate_cards(cards_to_reveal, "Compressed", false)
	card_mover.reveal_cards("catalogue", reveal_pile)
	for card in reveal_pile:
		card.show_sprite()
		card.set_count(card_counts[card.card_name])
		card.address.position.y += reveal_pile_y
		_on_move_call(card)
	if reveal_pile.size() <= 15:
		taskbanner(message)

func ascend_next_floor():
	generate_floor()
