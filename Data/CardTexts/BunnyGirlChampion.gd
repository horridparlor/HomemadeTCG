extends Node

const card_text : Dictionary = {
	"Name" : "Bunny Girl Champion",
	"[Field]" : "This card's power is equal to half the number of cards with different names in your deck, rounded down."
}

static func info():
	return card_text
