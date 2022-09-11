extends Node

const effects : Dictionary = {
	"ContactFusion" : {
		"Hand" : {
			"amount" : 2
		},
		"once_per_turn" : "RoyalCourtOrder"
	},
	"Play" : {
		"id" : "Life",
		"target" : "enemy",
		"constant" : 2,
		"Chain" : {
			"id" : "pathetic_pile",
			"target" : "enemy",
			"Stack" : {
				"id" : "Life",
				"constant" : -4,
			}
		}
	}
}

static func info():
	return effects
