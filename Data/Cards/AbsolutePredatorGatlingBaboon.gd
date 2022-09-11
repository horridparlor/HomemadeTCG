extends Node

const effects : Dictionary = {
	"ContactFusion" : {
		"Field" : {
			"column" : [3]
		},
		"Hand" : {
			"tag" : "AbsolutePredator"
		}
	},
	"Play" : {
		"id" : "Destroy",
		"subclass" : "own_column",
		"target" : "both",
		"restriction" : "non_fusion",
		"once_per_turn" : "AbsolutePredatorGatlingBaboon"
	},
	"Once" : {
		"id" : "reverse_attack"
	}
}

static func info():
	return effects
