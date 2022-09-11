extends Node

const effects : Dictionary = {
	"ContactFusion" : {
		"Field" : {
			"condition" : "not_attacked",
			"amount" : 2
		}
	},
	"Play" : {
		"id" : "restriction",
		"subclass" : "max_attacks",
		"target" : "enemy",
		"amount" : 2,
		"Chain": {
			"id" : "end_turn"
		},
		"once_per_game" : "DragonGodOfPeace"
	}
}

static func info():
	return effects
