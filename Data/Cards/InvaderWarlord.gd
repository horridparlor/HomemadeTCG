extends Node

const effects : Dictionary = {
	"ContactFusion" : {
		"Field" : {
			"condition" : "non_fusion",
			"location" : "Attach"
		},
		"once_per_turn" : "InvaderWarlord"
	},
	"Field" : {
		"id" : "Power",
		"subclass" : "cards_on_field",
		"tag" : "Invader"
	}
}

static func info():
	return effects
