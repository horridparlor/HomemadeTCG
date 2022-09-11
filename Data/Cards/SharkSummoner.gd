extends Node

const effects : Dictionary = {
	"ContactFusion" : {
		"Field" : {
			"wanted_effect" : {
				"type" : "Discard"
			},
			"amount" : 2
		}
	},
	"Play" : {
		"id" : "Search",
		"tag" : "Shark",
		"location" : "Play",
		"Chain" : {
			"id" : "Power",
			"target" : "next_play",
			"power_gain" : 2
		},
		"once_per_turn" : "SharkSummoner"
	}
}

static func info():
	return effects
