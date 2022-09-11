extends Node

const effects : Dictionary = {
	"Discard" : {
		"id" : "Power",
		"target" : "next_play",
		"power_gain" : 2
	},
	"Void" : {
		"plus" : 2,
		"id" : "Draw",
		"subclass" : "Until",
		"amount" : 2,
		"once_per_game" : "BabySharkHammagal"
	}
}

static func info():
	return effects
