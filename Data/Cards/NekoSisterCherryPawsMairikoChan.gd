extends Node

const effects : Dictionary = {
	"Draw" : {
		"id" : "play_to_column",
		"column" : [3],
		"once_per_turn" : "NekoSisterCherryPawsMairikoChan"
	},
	"Field" : {
		"id" : "Power",
		"power_gain" : 3,
		"column" : [3],
		"share_condition" : "Attached"
	}
}

static func info():
	return effects
