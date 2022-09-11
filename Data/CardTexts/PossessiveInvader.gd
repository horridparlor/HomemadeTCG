extends Node

const card_text : Dictionary = {
	"Name" : "Possessive Invader",
	"[Hand]" : "You can attach this card to an enemy. Only once per turn.",
	"[Field]" : "The enemy this card is attached to; has no effects and cannot attack."
}

static func info():
	return card_text
