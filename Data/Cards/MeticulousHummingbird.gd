extends Node

const effects : Dictionary = {
	"Draw" : {
		"id" : "play_to_column",
		"tag" : "rightmost",
		"once_per_turn" : "MeticulousHummingbird",
		"Chain" : {
			"id" : "Power",
			"subclass" : "becomes",
			"power_gain" : 3,
			"turn_number" : 0
		}
	}
}

static func info():
	return effects
