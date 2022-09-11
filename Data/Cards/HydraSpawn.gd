extends Node

const effects : Dictionary = {
	"Discard" : {
		"id" : "Search",
		"amount" : 2,
		"condition" : "absolute",
		"once_per_turn" : "HydraSpawn"
	}
}

static func info():
	return effects
