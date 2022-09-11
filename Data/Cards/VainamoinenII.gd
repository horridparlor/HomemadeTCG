extends Node

const effects : Dictionary = {
	"ContactFusion" : {
		"Field" : {
			"condition" : "2_attached"
		}
	},
	"Play" : {
		"id" : "Destroy",
		"subclass" : "own_column",
		"target" : "both",
	},
	"Field" : {
		"subclass" : "Attached",
		"power_gain" : 2
	}
}

static func info():
	return effects
