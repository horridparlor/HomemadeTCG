extends Node

const effects : Dictionary = {
	"ContactFusion" : {
		"Top_of_Deck" : {
			"amount" : 6,
			"location" : "Void"
		},
		"once_per_game" : "SealedWrath"
	},
	"Play" : {
		"id" : "Power",
		"subclass" : "becomes",
		"reference" : "full_rounds"
	}
}

static func info():
	return effects
