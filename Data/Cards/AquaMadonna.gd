extends Node

const effects : Dictionary = {
	"Draw" : {
		"id" : "additional_play",
		"once_per_turn" : "AquaMadonna1"
	},
	"Void" : {
		"plus" : 3,
		"id" : "Relocation",
		"location" : "Top_of_Deck",
		"Chain" : {
			"id" : "Draw"
		},
		"once_per_turn" : "AquaMadonna2",
	}
}

static func info():
	return effects
