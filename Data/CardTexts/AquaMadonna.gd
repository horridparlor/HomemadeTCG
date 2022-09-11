extends Node

const card_text : Dictionary = {
	"Name" : "Aqua Madonna",
	"[Draw]" : "You can play an additional card this turn. Only once per turn.",
	"[Void + 3]" : "Place this card on the top of your deck, then draw a card. Only once per turn."
}

static func info():
	return card_text
