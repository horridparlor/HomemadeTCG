extends Node

const effects : Dictionary = {
	"ContactFusion" : {
		"Field" : {
			"wanted_effect" : {
				"type" : "Void"
			},
			"amount" : 2
		},
		"relocation" : "Hand",
		"once_per_turn" : "NarwhalBattleshipSaiban1"
	},
	"Discard" : {
		"id" : "Search",
		"wanted_effect" : {
			"type" : "Void"
		},
		"once_per_turn" : "NarwhalBattleshipSaiban2"
	},
	"Play" : {
		"id" : "transform",
		"subclass" : "Random",
		"wanted_effect" : {
			"type" : "Void"
		},
		"reference" : "Graveyard",
		"Chain" : {
			"id" : "copy_effect",
			"subclass" : "Void"
		}
	}
}

static func info():
	return effects
