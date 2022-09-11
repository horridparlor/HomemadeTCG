extends Node

const effects : Dictionary = {
	"ContactFusion" : {
		"Field" : {
			"amount" : 2,
			"condition" : "non_fusion",
			"location" : "Attach"
		},
		"once_per_turn" : "WanderretDungMiasma"
	},
	"Play" : {
		"id" : "play_copy",
		"tag" : "Wanderret"
	},
	"Field" : {
		"id" : "Power",
		"subclass" : "cards_on_field",
		"tag" : "Wanderret"
	}
}

static func info():
	return effects
