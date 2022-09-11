extends Node

const effects : Dictionary = {
	"Deck" : {
		"id" : "free_play",
		"subclass" : "cards_on_field",
		"target" : "self",
		"tag" : "Wanderret",
		"condition" : "different_name",
		"restriction" : "friends",
		"once_per_turn" : "WanderretWhiteHusk"
	},
	"Void" : {
		"plus" : 3,
		"id" : "Destroy",
		"target" : "enemy"
	}
}

static func info():
	return effects
