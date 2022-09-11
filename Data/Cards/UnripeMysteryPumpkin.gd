extends Node

const effects : Dictionary = {
	"ContactFusion" : {
		"Graveyard" : {
			"amount" : 2,
			"condition" : "non_fusion",
			"tag" : "Unripe"
		},
		"once_per_turn" : "UnripeMysteryPumpkin"
	},
	"Field" : {
		"id" : "Power",
		"subclass" : "cards_sent_to_grave",
		"multiplier" : 0.5
	},
	"Death" : {
		"id" : "Relocation",
		"location" : "Hand",
		"Chain" : {
			"id" : "transform",
			"superclass" : "Become",
			"subclass" : "Random",
			"wanted_effect" : {
				"type" : "Hand"
			}
		}
	}
}

static func info():
	return effects
