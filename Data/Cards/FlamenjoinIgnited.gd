extends Node

const effects : Dictionary = {
	"ContactFusion" : {
		"Field" : {
			"condition" : "different_names",
			"amount" : 2
		},
		"once_per_turn" : "FlamenjoinIgnited"
	},
	"Play" : {
		"id" : "Search",
		"tag" : "Flamenjoin",
		"location" : "Top_of_Deck",
	},
	"Field" : {
		"id" : "Power",
		"subclass" : "cards_top_of_deck",
	}
}

static func info():
	return effects
