extends Node

const effects : Dictionary = {
	"ContactFusion" : {
		"Spend_Plays" : {
			"target" : "enemy",
			"amount" : 2
		},
		"cards_played" : -2,
		"once_per_game" : "DragonGodMirai"
	},
	"Play" : {
		"id" : "end_turn"
	}
}

static func info():
	return effects
