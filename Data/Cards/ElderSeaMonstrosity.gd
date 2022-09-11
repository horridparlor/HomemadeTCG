extends Node

const effects : Dictionary = {
	"ContactFusion" : {
		"Top_of_Deck" : {
			"amount" : 2,
			"wanted_effect" : {
				"type" : "Void"
			}
		},
		"relocation" : "Void",
		"once_per_turn" : "ElderSeaMonstrosity"
	}
}

static func info():
	return effects
