extends Node

const effects : Dictionary = {
	"Deck" : {
		"id" : "free_play",
		"subclass" : "cards_on_field",
		"location" : "Top_of_Deck",
		"target" : "both",
		"tag" : "Flamenjoin"
	}
}

static func info():
	return effects
