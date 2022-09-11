extends Node

const effects : Dictionary = {
	"ContactFusion" : {
		"Hand" : {
			"amount" : 2
		},
		"once_per_game" : "DarkCavalry"
	},
	"Field" : {
		"id" : "extra_attacks",
		"subclass" : "Up_to",
		"amount" : 2
	}
}

static func info():
	return effects
