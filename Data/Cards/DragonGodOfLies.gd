extends Node

const effects : Dictionary = {
	"ContactFusion" : {
		"Field" : {
			"condition" : "transformed",
			"amount" : 2
		}
	},
	"Play" : {
		"id" : "transform",
		"player" : "enemy",
		"target" : "top_of_deck",
		"amount" : -1,
		"subclass" : "Random",
		"wanted_effect" : {
				"type" : "ContactFusion",
				"modifiers" : ["non_wanted_effect"]
		},
		"Chain": {
			"id" : "end_turn"
		},
		"once_per_game" : "DragonGodOfLies"
	}
}

static func info():
	return effects
