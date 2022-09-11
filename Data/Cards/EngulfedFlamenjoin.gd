extends Node

const effects : Dictionary = {
	"Deck" : {
		"id" : "free_play",
		"location" : "Top_of_Deck",
		"subclass" : "cards_on_field",
		"target" : "both",
		"tag" : "Flamenjoin",
		"condition" : "different_name",
		"once_per_turn" : "EngulfedFlamenjoin1"
	},
	"Play" : {
		"id" : "transform",
		"target" : "target",
		"player" : "enemy",
		"tag" : "Flamenjoin",
		"once_per_turn" : "EngulfedFlamenjoin2"
	}
}

static func info():
	return effects
