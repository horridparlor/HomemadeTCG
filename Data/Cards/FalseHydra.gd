extends Node

const effects : Dictionary = {
	"ContactFusion" : {
		"Hand" : {
			"condition" : "different_names",
			"amount" : 2
		},
		"once_per_game" : "FalseHydra"
	},
	"Field" : {
		"id" : "cannot_be_attacked",
	},
	"Once" : {
		"id" : "death_protection",
		"condition" : "by_effect"
	}
}

static func info():
	return effects
