extends Node

const effects : Dictionary = {
	"ContactFusion" : {
		"Field" : {
			"wanted_effect" : {
				"type" : "Draw"
			},
			"location" : "Void"
		},
		"once_per_game" : "BenevolentArchsaint"
	},
	"Once" : {
		"id" : "death_protection",
		"condition" : "by_attack"
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
