extends Node

const card_text : Dictionary = {
	"Name" : "Doyen Owl",
	"[Draw]" : "Play this card to the leftmost free column, but only once per turn. If the game has not started, draw a card. "
}

static func info():
	return card_text
