extends Node

const effects : Dictionary = {
	"Hand" : {
		"id" : "Attach",
		"once_per_turn" : "VainamoinenI1"
	},
	"Detach" : {
		"id" : "search_graveyard",
		"condition" : "fusion",
		"target" : "enemy",
		"once_per_turn" : "VainamoinenI2"
	}
}

static func info():
	return effects
