extends Node

const effects : Dictionary = {
	"ContactFusion" : {
		"Field" : {
			"column" : [2, 4]
		}
	},
	"Field" : {
		"id" : "cannot_be_attacked",
		"column" : [3],
	},
	"Once" : {
		"id" : "modify_damage",
		"multiplier" : -2
	}
}

static func info():
	return effects
