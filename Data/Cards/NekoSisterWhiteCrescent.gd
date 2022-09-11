extends Node

const effects : Dictionary = {
	"Draw" : {
		"id" : "play_to_column",
		"column" : [5],
		"once_per_turn" : "NekoSisterWhiteCrescent1"
	},
	"Detach" : {
		"id" : "play_to_column",
		"column" : [1],
		"once_per_turn" : "NekoSisterWhiteCrescent2"
	}
}

static func info():
	return effects
