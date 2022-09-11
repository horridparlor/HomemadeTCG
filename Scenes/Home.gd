extends Node2D

const DECK_BUILDER_PATH : String = "res://Scenes/DeckBuilder.tscn"
const GAMEPLAY_PATH : String = "res://Scenes/Gameplay.tscn"
const ROGUELIKE_PATH : String = "res://Scenes/RoguelikeMode.tscn"
const SCENE_SWITCH_SIGNALS : Array = [
	"open_deck_builder",
	"close_deck_builder",
	"open_gameplay",
	"close_gameplay"
]

var current_scene
var scene_to_clear
var current_game_mode : String

func _ready():
	var session_log : Dictionary = System.get_session_log()
	OS.set_current_screen(1)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), session_log.master_volume)
	current_game_mode = session_log.game_mode
	restart_current_scene()

func restart_current_scene():
	if current_scene != null:
		current_scene.music.stop()
		current_scene.queue_free()
		current_scene = null
	match current_game_mode:
		"Roguelike":
			open_roguelike()
		"Sandbox":
			open_deck_builder()

func open_deck_builder():
	set_current_scene("DeckBuilder")
	load_scene(DECK_BUILDER_PATH)

func close_deck_builder():
	open_gameplay()

func open_gameplay():
	set_current_scene("Gameplay")
	load_scene(GAMEPLAY_PATH)

func close_gameplay(winner_player_number : int):
	match current_game_mode:
		"Roguelike":
			System.set_roguelike_gameplay_winner(winner_player_number)
			open_roguelike()
		"Sandbox":
			open_deck_builder()

func open_roguelike():
	set_current_scene("Roguelike")
	load_scene(ROGUELIKE_PATH)

func set_current_scene(id : String):
	System.current_scene = id

func load_scene(path : String):
	System.selected_card = null
	var scene = load(path).instance()
	var auto_initialize : bool
	add_child(scene)
	for switch_signal in SCENE_SWITCH_SIGNALS:
		scene.connect(switch_signal, self, switch_signal)
	scene.connect("clear_scene", self, "_on_clear_scene")
	scene.connect("refresh_scene", self, "refresh_scene")
	scene.visible = false
	if current_scene == null:
		auto_initialize = true
	current_scene = scene
	if auto_initialize:
		initialize_scene(scene)

func initialize_scene(scene : Node2D):
	scene.initialize_scene()

func refresh_scene():
	current_game_mode = System.get_session_log().game_mode
	restart_current_scene()

func _on_clear_scene(scene):
	scene.queue_free()
	initialize_scene(current_scene)
