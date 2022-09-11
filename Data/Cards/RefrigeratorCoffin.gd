extends Node

const effects : Dictionary = {
	"Discard" : {
		"id" : "Search",
		"tag" : "Refrigerator",
		"condition" : "different_name",
		"location" : "Graveyard",
		"once_per_turn" : "RefrigeratorCoffin1"
	},
	"Detach" : {
		"id" : "Destroy",
		"target" : "enemy",
		"restriction" : "non_fusion",
		"once_per_turn" : "RefrigeratorCoffin2"
	}
}

static func info():
	return effects
