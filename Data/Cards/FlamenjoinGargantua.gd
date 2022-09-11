extends Node

const effects : Dictionary = {
	"Deck" : {
		"id" : "free_play",
		"location" : "Top_of_Deck",
		"subclass" : "cards_on_field",
		"target" : "self",
		"tag" : "Flamenjoin",
		"condition" : "different_name",
		"restriction" : "friends",
		"once_per_turn" : "FlamenjoinGargantua"
	},
	"Play" : {
		"id" : "transform",
		"target" : "top_of_deck",
		"tag" : "Flamenjoin",
		"cards_played" : -1,
	}
}

static func info():
	return effects
