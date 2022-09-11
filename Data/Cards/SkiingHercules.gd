extends Node

const effects: Dictionary = {
	"ContactFusion" : {
		"Field" : {
			"wanted_effect" : {
				"type" : "Field",
				"id" : "Power",
				"spec" : "subclass",
				"spec_value" : "cards_sent_to_grave"
			},
			"amount" : 2
		}
	},
	"Play" : {
		"id" : "Mill",
		"amount" : 3,
		"target" : "enemy",
		"once_per_turn" : "SkiingHercules",
		"Chain" : {
			"id" : "Destroy",
			"subclass" : "all",
			"target" : "enemy",
			"reference" : "cards_sent_to_grave",
			"reference_target" : "enemy"
		}
	},
	"Field" : {
		"id" : "Power",
		"subclass" : "cards_sent_to_grave",
		"target" : "enemy"
	}
}

static func info():
	return effects
