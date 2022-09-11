extends Node

const effects : Dictionary = {
	"Discard" : {
		"id" : "play_copy",
		"zone_conditions" : {
			"subclass" : "cards_on_field",
			"amount" : 2,
			"tag" : "Shark",
			"restriction" : "friends",
		},
		"once_per_turn" : "BabySharkTripoli1"
	},
	"Void" : {
		"plus" : 2,
		"id" : "Search",
		"amount" : 2,
		"condition" : "absolute",
		"once_per_game" : "BabySharkTripoli2"
	}
}

static func info():
	return effects
