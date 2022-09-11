extends Node

const card_text : Dictionary = {
	"Name" : "Engulfed Flamenjoin",
	"[Deck]" : "While there is a \"Flamenjoin\" with a different name on the field, you can play this card from the top of your deck. Only once per turn.",
	"[Play]" : "Target enemy transforms into \"Flamenjoin\". Only once per turn."
}

static func info():
	return card_text
