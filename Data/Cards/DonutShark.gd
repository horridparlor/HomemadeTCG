extends Node

const effects : Dictionary = {
	"Discard" : {
		"id" : "Search",
		"tag" : "BabyShark",
		"once_per_turn" : "DonutShark"
	},
	"Void" : {
		"plus" : 2,
		"id" : "play_from_graveyard",
		"tag" : "SharkSummoner"
	}
}

static func info():
	return effects
