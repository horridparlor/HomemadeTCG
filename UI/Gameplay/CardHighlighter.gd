extends Control
class_name CardHighlighter

onready var highlight_sprite = $HighlightSprite
onready var settings_tab = $SettingsTab
onready var clear_highlight_timeout = $ClearHighlighTimeout

const max_x : int = 400
const max_y : int = 600
const scale_up : int = 3
const scale_up_vector : Vector2 = Vector2(scale_up, scale_up)
const scale_multiplier : float = 1.0 / scale_up

var is_focused : bool
var relative_mouse_position : Vector2
var is_active : bool = true

func _ready():
	settings_tab.connect("menu_activated", self, "clear_highlight")

func focus(card_name : String):
	if System.card_exists(card_name):
		highlight_sprite.texture = load("res://Textures/CardHighlight/" + card_name + "Highlight.png")

func focus_card(card : Card):
	focus(card.card_name)

func _on_HighlighterButton_pressed():
	if settings_tab.is_menu_active or !is_active:
		return
	highlight_sprite.scale = scale_up_vector
	relative_mouse_position = get_global_mouse_position()
	is_focused = true
	highlight_sprite.region_rect = Rect2(200, 200, 100, 150)

func _process(delta):
	if is_focused:
		var relative_position : Vector2
		relative_position = (get_global_mouse_position() - relative_mouse_position) * (scale_up - 1)
		relative_position = System.scale_vector(relative_position, \
		Vector2(max_x - scale_multiplier * max_x, max_y - scale_multiplier * max_y), \
		Vector2(-scale_multiplier * max_x, -scale_multiplier * max_y))
		highlight_sprite.region_rect = Rect2( \
		System.scale_value(relative_position.x, max_x - scale_multiplier * max_x, 0), \
		System.scale_value(relative_position.y, max_y - scale_multiplier * max_y, 0), \
		System.scale_value(max_x - relative_position.x, scale_multiplier * max_x, scale_multiplier / scale_up * max_x), \
		System.scale_value(max_y - relative_position.y, scale_multiplier * max_y, scale_multiplier / scale_up * max_y))

func _on_HighlighterButton_released():
	is_focused = false
	highlight_sprite.scale = Vector2(1, 1)
	highlight_sprite.region_rect = Rect2(0, 0, max_x, max_y)
	highlight_sprite.position = Vector2(0, 0)

func clear_highlight():
	_on_HighlighterButton_released()
	is_active = false
	clear_highlight_timeout.start()

func _on_ClearHighlighTimeout_timeout():
	is_active = true
	clear_highlight_timeout.stop()
