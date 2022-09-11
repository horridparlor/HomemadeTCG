extends Node

const effects : Dictionary = {
	"Hand" : {
		"id" : "Response",
		"subclass" : "reverse_attack",
		"restriction" : "non_fusion",
		"once_per_turn" : "LohjaburgerRestaurantManager1"
	},
	"Graveyard" : {
		"id" : "EndPhase",
		"Chain" : {
			"id" : "Relocation",
			"location" : "Hand",
			"cards_played" : 5,
			"once_per_turn" : "LohjaburgerRestaurantManager2",
		}
	}
}

static func info():
	return effects
