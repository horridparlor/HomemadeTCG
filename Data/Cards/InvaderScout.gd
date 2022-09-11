extends Node

const effects : Dictionary = {
	"Hand" : {
		"id" : "free_play",
		"subclass" : "cards_on_field",
		"target" : "enemy",
		"restriction" : "no_friends"
	},
	"Play" : {
		"id" : "Search",
		"tag" : "Invader",
		"condition" : "different_name",
		"once_per_turn" : "InvaderScout"
	}
}

static func info():
	return effects
