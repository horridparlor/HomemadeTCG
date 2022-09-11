extends Node

const effects : Dictionary = {
	"ContactFusion" : {
		"Hand" : {
			"subclass" : "Duplicates",
			"amount" : 2
		},
		"once_per_game" : "GreedyHydra"
	},
	"Play" : {
		"id" : "Draw",
		"subclass" : "Until",
		"amount" : 3
	}
}

static func info():
	return effects
