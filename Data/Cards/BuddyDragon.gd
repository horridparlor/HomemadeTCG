extends Node

const effects : Dictionary = {
	"Deck" : {
		"id" : "Shuffled",
		"subclass" : "Top"
	},
	"Draw" : {
		"id" : "Power",
		"subclass" : "permanent",
		"power_gain" : 2,
	},
	"Void" : {
		"id" : "Relocation",
		"location" : "Deck"
	}
}

static func info():
	return effects
