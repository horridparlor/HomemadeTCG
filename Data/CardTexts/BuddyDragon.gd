extends Node

const card_text : Dictionary = {
	"Name" : "Buddy Dragon",
	"[Deck]" : "This card is always shuffled on the top.",
	"[Draw]" : "This card permanently gains 2 power.",
	"[Void]" : "Shuffle this card into the deck."
}

static func info():
	return card_text
