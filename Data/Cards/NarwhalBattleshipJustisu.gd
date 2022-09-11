extends Node

const effects : Dictionary = {
	"ContactFusion" : {
		"Field" : {
			"wanted_effect" : {
				"type" : "Void"
			},
			"amount" : 2
		},
		"once_per_turn" : "NarwhalBattleshipJustisu"
	},
	"Play" : {
		"id" : "Destroy",
		"target" : "enemy",
		"restriction" : "non_fusion",
		"source" : ["same_name", "power_gain"]
	}
}

static func info():
	return effects
