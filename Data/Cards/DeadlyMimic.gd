extends Node

const effects : Dictionary = {
	"ContactFusion" : {
		"Field" : {
			"condition" : "fusion",
			"location" : "Void"
		},
		"once_per_game" : "DeadlyMimic"
	},
	"Play" : {
		"id" : "transform",
		"reference" : "Deck",
		"subclass" : "Random"
	},
	"Graveyard" : {
		"id" : "StartGame",
		"Chain" : {
			"id" : "play_to_column",
			"column" : [3]
		}
	}
}

static func info():
	return effects
