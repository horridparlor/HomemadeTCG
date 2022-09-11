extends Node

const effects : Dictionary = {
	"ContactFusion" : {
		"Hand" : {
			"subclass" : "Duplicates",
			"amount" : 2
		}
	},
	"Play" : {
		"id" : "Draw",
		"amount" : 2,
		"once_per_game" : "DoomHydra"
	}
}

static func info():
	return effects
