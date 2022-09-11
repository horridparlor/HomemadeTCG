extends Node

const effects : Dictionary = {
	"ContactFusion" : {
		"Field" : {
			"wanted_effect" : {
				"type" : "Draw"
			},
			"amount" : 2
		}
	},
	"Play" : {
		"id" : "Draw",
		"amount" : 2,
		"once_per_turn" : "MercuryEagle"
	},
	"Field" : {
		"id" : "Power",
		"subclass" : "cards_in_hand"
	}
}

static func info():
	return effects
