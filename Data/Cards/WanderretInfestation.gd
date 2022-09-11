extends Node

const effects : Dictionary = {
	"ContactFusion" : {
		"Field" : {
			"condition" : "different_names",
			"amount" : 2
		}
	},
	"Play" : {
		"id" : "Search",
		"tag" : "Wanderret",
		"location" : "Graveyard",
		"once_per_turn" : "WanderretInfestation"
	},
	"Field" : {
		"id" : "Power",
		"subclass" : "cards_on_field",
		"target" : "both",
		"tag" : "Wanderret"
	}
}

static func info():
	return effects
