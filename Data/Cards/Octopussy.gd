extends Node

const effects : Dictionary = {
	"ContactFusion" : {
		"Graveyard" : {
			"amount" : 2
		},
		"once_per_turn" : "Octopussy"
	},
	"Play" : {
		"id" : "transform",
		"superclass" : "Become",
		"subclass" : "Random",
		"wanted_effect" : {
				"type" : "Void"
		},
		"Chain" : {
			"id" : "copy_effect",
			"subclass" : "Play"
		}
	}
}

static func info():
	return effects
