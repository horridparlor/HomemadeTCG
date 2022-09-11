extends Node

const effects : Dictionary = {
	"Hand" : {
		"id" : "free_play",
		"restriction" : "no_friends",
		"once_per_turn" : "OnlymaidsSingleMom"
	},
	"Field" : {
		"id" : "attacked",
		"subclass" : "life",
		"constant" : -3
	}
}

static func info():
	return effects
