extends Node

const effects : Dictionary = {
	"ContactFusion" : {
		"Hand" : {
			"subclass" : "Duplicates",
			"amount" : 3
		},
		"once_per_game" : "ExtinctionHydra"
	},
	"Death" : {
		"id" : "Draw",
		"subclass" : "Until",
		"amount" : 5
	}
}

static func info():
	return effects
