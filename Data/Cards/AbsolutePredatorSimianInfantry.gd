extends Node

const effects : Dictionary = {
	"Graveyard" : {
		"id" : "Power",
		"tag" : "AbsolutePredator"
	},
	"Void" : {
		"plus" : 2,
		"id" : "Relocation",
		"location" : "Hand",
		"once_per_turn" : "AbsolutePredatorSimianInfantry"
	}
}

static func info():
	return effects
