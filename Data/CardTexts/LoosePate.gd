extends Node

const card_text : Dictionary = {
	"Name" : "Loose Pate",
	"[Field]" : "The card this card is attached gains 1 power and can attack an additional time each turn.",
	"[Graveyard]" : "If you play a \"Hydra\", attach this card to it. Void this card when it leaves the field. Only once per turn"
}

static func info():
	return card_text
