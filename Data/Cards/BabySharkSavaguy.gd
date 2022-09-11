extends Node

const effects : Dictionary = {
	"Discard" : {
		"id" : "Destroy",
		"restriction" : "non_fusion",
		"target" : "enemy",
		"once_per_turn" : "BabySharkSavaguy1"
	},
	"Void" : {
		"plus" : 2,
		"id" : "search_graveyard",
		"target" : "enemy",
		"condition" : "non_fusion",
		"once_per_turn" : "BabySharkSavaguy2"
	}
}

static func info():
	return effects
