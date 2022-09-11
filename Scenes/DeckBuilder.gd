extends Node2D
class_name DeckBuilder

signal close_deck_builder
signal clear_scene(scene)
signal refresh_scene

onready var camera = $Background/CenteredCamera
onready var music = $Background/BackgroundMusic
onready var player1 = $GameArea/Player1/CardCollection
onready var player2 = $GameArea/Player2/CardCollection
onready var rotation_frame = $Timers/RotationFrame
onready var game_area = $GameArea
onready var enter_gameplay_timer = $Timers/EnterGameplayTimer

var players : Array
var degrees : int
var initialized : bool
var current_game_mode : String = "Null"

func _ready():
	camera.current = true
	initialize_players()

func initialize_scene():
	initialized = true
	visible = true
	if System.get_session_log().auto_confirm:
		auto_confirm()
		return
	music.play()

func auto_confirm():
	if !initialized:
		return
	for player in get_players():
		if !player.confirmed:
			player._on_ConfirmSwitch_pressed()	

func initialize_players():
	var session_log : Dictionary = System.get_session_log()
	var display_spin_enabled : bool = session_log.display_spin_enabled
	initialize_player(player1, 1)
	initialize_player(player2, 2)
	for player in get_players():
		player.connect("collection_focused", self, "_on_collection_focused")
		player.connect("confirm", self, "_on_confirm")
		player.connect("session_log_update", self, "session_log_update")
	player1.focused = true
	session_log_update()

func initialize_player(player : Card_Collection, player_number : int):
	player.visible = true
	players.append(player)
	player.initialize(player_number)

func get_player(player_number : int, opposite : bool = false):
	if opposite:
		player_number = abs(player_number - 3)
	if player_number == 1:
		return player1
	return player2

func get_players():
	return players

func _on_confirm(player_number : int):
	if get_player(player_number, true).confirmed:
		for player in get_players():
			player.make_AI_controlled(true)
		music.stop()
		emit_signal("close_deck_builder")
		enter_gameplay_timer.start()
		
func _on_EnterGameplayTimer_timeout():
	enter_gameplay_timer.stop()
	emit_signal("clear_scene", self)

func _on_collection_focused(player_number : int):
	film_player(player_number)
	get_player(player_number).focused = true
	get_player(player_number, true).unfocus_collection()
	
func film_player(player_number : int):
	degrees = 0
	if player_number == 2:
		degrees = 180
	rotation_frame.start()

func _on_RotationFrame_timeout():
	if int(game_area.rect_rotation) != degrees:
		game_area.rect_rotation += System.degrees_by_rotation_frame
		if game_area.rect_rotation >= 360:
			game_area.rect_rotation = 0
		return
	rotation_frame.stop()

func session_log_update():
	var session_log : Dictionary = System.get_session_log()
	var game_mode : String = session_log.game_mode
	var game_mode_switched = System.game_mode_switched(current_game_mode, game_mode)
	var display_spin_enabled : bool = session_log.display_spin_enabled
	for player in get_players():
		player.display_spin_enabled = display_spin_enabled
		player.settings_tab.session_log_update()
		if game_mode_switched:
			player._on_switch_deckslot()
		player.game_mode = game_mode
	if game_mode_switched:
		emit_signal("refresh_scene")
	current_game_mode = game_mode
	if session_log.auto_confirm:
		auto_confirm()
