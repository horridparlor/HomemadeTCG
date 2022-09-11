extends Node

const effects : Dictionary = {
	"ContactFusion" : {
		"Graveyard" : {
			"location" : "Attach",
			"amount" : 2,
			"tag" : "Refrigerator",
			"reference" : "cards_sent_to_grave"
		},
		"once_per_turn" : "OlympicSwimmer"
	},
	"Once" : {
		"id" : "death_protection",
		"condition" : "by_attack",
		"restore_condition" : {
			"id" : "Detach",
			"subclass" : "All",
			"tag" : "Refrigerator"
		}
	}
}

static func info():
	return effects
