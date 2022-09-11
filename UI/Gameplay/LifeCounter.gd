extends Control

signal dead
signal update_life

onready var text_box = $TextBox
onready var lifecount = $TextBox/LifeCount
onready var count_frame = $CountFrame
onready var animations = $Animations

var life_total : int = System.starting_life
var current_life : int

func init(player_number : int):
	if System.get_session_log().game_mode == "Roguelike" and player_number == 2:
		life_total = System.max_value(8 + 2 * System.get_roguelike_log().floor_number, \
		System.starting_life)
	if life_total < 1:
		life_total = 1
	count_life()

func damage(amount : int):
	life_total += amount
	if life_total <= 0:
		life_total = 0
		emit_signal("dead")
	play_damage_animation(amount)
	count_life()

func play_damage_animation(amount : int):
	var animation_id : String = "Null"
	if amount > 0:
		animation_id = "SmallLifeGain"
	if amount < 0:
		animation_id = "SmallDamage"
		if amount < -7:
			animation_id = "HugeDamage"
		elif amount < -4:
			animation_id = "BigDamage"
		elif amount < -1:
			animation_id = "MediumDamage"
	animations.card_animation(animation_id)

func set_life(amount : int):
	life_total = amount
	count_life()

func count_life():
	emit_signal("update_life", life_total)
	count_frame.start()
	
func _on_CountFrame_timeout():
	if current_life > life_total:
		current_life -= 1
	elif current_life == life_total:
		count_frame.stop()
	elif current_life < life_total:
		current_life += 1
	lifecount.text = str(current_life)

func flip_text_box():
	text_box.rect_rotation = 180
	lifecount.rect_position = Vector2(-48, -82)
