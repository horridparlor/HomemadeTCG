extends Node

const effects : Dictionary = {
	"Discard" : {
		"id" : "transform",
		"superclass" : "Become",
		"subclass" : "Random",
		"wanted_effect" : {
			"type" : "ContactFusion"
		},
		"once_per_turn" : "UnripeOkra"
	},
	"Death" : {
		"id" : "transform",
		"superclass" : "Become",
		"tag" : "UnripeOkra",
		"amount" : 2,
		"player" : "enemy",
		"target" : "top_of_deck"
	}
}

static func info():
	return effects
