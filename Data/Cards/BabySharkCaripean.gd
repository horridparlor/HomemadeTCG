extends Node

const effects : Dictionary = {
	"Discard" : {
		"id" : "additional_play",
		"location" : "Deck",
		"tag" : "BabyShark",
		"condition" : "different_name",
		"once_per_turn" : "BabySharkCaripean"
	},
	"Void" : {
		"plus" : 2,
		"id" : "Power",
		"target" : "friends",
		"tag" : "Shark",
		"power_gain" : 2
	}
}

static func info():
	return effects
