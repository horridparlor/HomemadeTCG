extends Node

const effects : Dictionary = {
	"Hand" : {
		"id" : "free_play",
		"subclass" : "cards_on_field",
		"target" : "both",
		"tag" : "Wanderret"
	},
	"Void" : {
		"plus" : 2,
		"id" : "Search",
		"tag" : "Wanderret",
		"once_per_turn" : "Wanderret"
	}
}

static func info():
	return effects
