extends Node

const effects : Dictionary = {
	"Draw" : {
		"id" : "play_to_column",
		"tag" : "leftmost",
		"once_per_turn" : "DoyenOwl",
		"Chain" : {
			"id" : "Draw",
			"turn_number" : 0
		}
	}
}

static func info():
	return effects
