extends Node

const effects : Dictionary = {
	"Hand" : {
		"id" : "Attach",
		"target" : "enemy",
		"once_per_turn" : "PossessiveInvader"
	},
	"Field" : {
		"id" : "Attached",
		"source" : ["no_effects", "no_attacks"]
	}
}

static func info():
	return effects
