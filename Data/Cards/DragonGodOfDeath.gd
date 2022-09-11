extends Node

const effects : Dictionary = {
	"ContactFusion" : {
		"Field" : {
			"column" : [1, 5]
		}
	},
	"Play" : {
		"id" : "play_from_graveyard",
		"negate_effects" : "Play",
		"once_per_game" : "DragonGodOfDeath",
		"Chain": {
			"id" : "end_turn",
			"amount" : 2
		}
	}
}

static func info():
	return effects
