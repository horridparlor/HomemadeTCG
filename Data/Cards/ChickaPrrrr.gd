extends Node

const effects: Dictionary = {
	"Discard" : {
		"id" : "Mill",
		"amount" : 3,
		"target" : "enemy",
		"once_per_turn" : "ChickaPrrrr"
	},
	"Play" : {
		"id" : "Power",
		"subclass" : "becomes",
		"reference" : "cards_sent_to_grave",
		"reference_target" : "enemy"
	}
}

static func info():
	return effects
