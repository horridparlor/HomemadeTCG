extends Node

const effects : Dictionary = {
	"ContactFusion" : {
		"Graveyard" : {
			"location" : "Attach",
			"amount" : 2,
			"tag" : "Refrigerator",
			"reference" : "cards_sent_to_grave"
		},
		"once_per_turn" : "SwimmingWithRefrigerators1"
	},
	"Detach" : {
		"id" : "Search",
		"tag" : "Refrigerator",
		"once_per_turn" : "SwimmingWithRefrigerators2"
	}
}

static func info():
	return effects
