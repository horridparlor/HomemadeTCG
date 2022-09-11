extends Node

const effects : Dictionary = {
	"ContactFusion" : {
		"Field" : {
			"restriction" : "Enemy",
			"condition" : "round_on_field",
			"amount" : 2
		},
		"once_per_game" : "DragonGodOfRetribution"
	},
	"Play" : {
		"id" : "end_turn"
	}
}

static func info():
	return effects
