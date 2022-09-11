extends Node

const effects : Dictionary = {
	"ContactFusion" : {
		"Field" : {
			"condition" : "round_on_field",
			"amount" : 2
		}
	},
	"Play" : {
		"id" : "extra_turn",
		"Chain" : {
			"id" : "restriction",
			"subclass" : "max_attacks",
			"amount" : 1,
			"Chain": {
				"id" : "end_turn"
			},
		},
		"once_per_game" : "DragonGodOfAbsolution"
	},
	"Field" : {
		"id" : "Power",
		"subclass" : "full_rounds"
	}
}

static func info():
	return effects
