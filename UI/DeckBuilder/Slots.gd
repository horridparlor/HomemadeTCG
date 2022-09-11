extends Control

signal switch_deck_slot(slot_number)
signal deck_emptied(initialize, induct)

onready var slot_1 = $Slot1
onready var slot_2 = $Slot2
onready var slot_3 = $Slot3
onready var slot_4 = $Slot4

onready var slot_1_focus = $Slot1/FocusSprite
onready var slot_2_focus = $Slot2/FocusSprite
onready var slot_3_focus = $Slot3/FocusSprite
onready var slot_4_focus = $Slot4/FocusSprite

onready var empty_slot = $EmptySlot
onready var empty_slot_button = $EmptySlot/EmptyDeck
onready var empty_slot_sprite = $EmptySlot/EmptySprite
onready var emptying_deck_timer = $EmptySlot/EmptyingDeckTimer
onready var tween = $Tween

const slot_x_margin : float = 124.5
var current_slot : int

func focus_deck_slot(slot_number : int):
	var slot_focuses = get_slot_sprites()
	if slot_number != current_slot:
		slot_focuses[current_slot - 1].visible = false
		slot_focuses[slot_number - 1].visible = true
		emit_signal("switch_deck_slot", slot_number)
		toggle_empty_slot_visibility(false)
		return
	toggle_empty_slot_visibility(!empty_slot_button.visible)
	emit_signal("deck_emptied", empty_slot_button.visible, false)
	empty_slot.rect_position.x = get_slots()[slot_number - 1].rect_position.x

func get_slots():
	return [slot_1, slot_2, slot_3, slot_4]

func get_slot_sprites():
	return [slot_1_focus, slot_2_focus, slot_3_focus, slot_4_focus]

func focus_current_slot():
	focus_deck_slot(current_slot)

func _on_DeckSlot1_pressed():
	focus_deck_slot(1)

func _on_DeckSlot2_pressed():
	focus_deck_slot(2)

func _on_DeckSlot3_pressed():
	focus_deck_slot(3)

func _on_DeckSlot4_pressed():
	focus_deck_slot(4)

func _on_EmptyDeck_pressed():
	emptying_deck_timer.start()

func _on_EmptyingDeckTimer_timeout():
	emptying_deck_timer.stop()
	toggle_empty_slot_visibility(false)
	emit_signal("deck_emptied", false, true)

func toggle_empty_slot_visibility(boolean : bool):
	empty_slot_button.visible = boolean
	toggle_visibility(empty_slot_sprite, boolean)

func toggle_visibility(sprite, boolean : bool):
	var tween_values : Array = System.get_tween_values(boolean, sprite)
	tween.interpolate_property(sprite, tween_values[0], tween_values[1], tween_values[2], tween_values[3])
	tween.start()
