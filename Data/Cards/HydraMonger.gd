extends Node

const effects : Dictionary = {
	"ContactFusion" : {
		"Hand" : {
			"subclass" : "Duplicates",
			"amount" : 2
		}
	},
	"Play" : {
		"id" : "Search",
		"subclass" : "Random",
		"constant" : 3,
		"once_per_game" : "HydraMonger"
	}
}

static func info():
	return effects
