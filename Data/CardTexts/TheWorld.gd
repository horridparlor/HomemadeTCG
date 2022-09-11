extends Node

const card_text : Dictionary = {
	"Name" : "The World",
	"[ContactFusion]" : "2 friends with different names.",
	"[Play]" : "Attach your deck to this card, then shuffle all non-fusion cards in your graveyard into a new deck. Only once per game.",
	"[Field]" : "This card's power is equal to the number of cards attached to it."
}

static func info():
	return card_text
