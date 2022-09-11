extends Node

const effects : Dictionary = {
	"Play" : {
		"cards_played" : -1,
		"id" : "play_copy",
		"subclass" : "Random",
		"source" : ["different_name"],
		"reference" : "Deck",
	},
	"Field" : {
		"id" : "Power",
		"constant" : 1,
		"subclass" : "tokens_on_field",
		"target" : "both"
	}
}

static func info():
	return effects
