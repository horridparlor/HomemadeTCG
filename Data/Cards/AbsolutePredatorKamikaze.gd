extends Node

const effects : Dictionary = {
	"ContactFusion" : {
		"Field" : {
			"column" : [1]
		},
		"Hand" : {
			"tag" : "AbsolutePredator"
		}
	},
	"Play" : {
		"id" : "Destroy",
		"subclass" : "own_column",
		"target" : "both",
		"restriction" : "fusion",
		"once_per_turn" : "AbsolutePredatorKamikaze"
	},
	"Death" : {
		"id" : "additional_play",
		"tag" : "AbsolutePredator",
		"location" : "Deck"
	}
}

static func info():
	return effects
