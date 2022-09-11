extends Node

const effects : Dictionary = {
	"Hand" : {
		"id" : "free_play",
		"subclass" : "cards_on_field",
		"tag" : "NekoSister",
		"condition" : "different_name",
		"once_per_turn" : "NekoSisterMidnightNebula"
	},
	"Detach" : {
		"id" : "search_graveyard",
		"target" : "enemy"
	}
}

static func info():
	return effects
