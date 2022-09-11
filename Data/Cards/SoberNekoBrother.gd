extends Node

const effects : Dictionary = {
	"Play" : {
		"id" : "search_graveyard",
		"tag" : "NekoSister",
		"location" : "Top_of_Deck",
		"once_per_turn" : "NekoSisterSoberBrother1"
	},
	"CardConfirmation" : {
		"id" : "Search_Graveyard",
		"Chain" : {
			"id" : "Draw"
		}
	},
	"Detach" : {
		"id" : "Life",
		"constant" : 2
	}
}

static func info():
	return effects
