extends Node

const effects : Dictionary = {
	"Play" : {
		"id" : "transform",
		"subclass" : "Random",
		"wanted_effect" : {
				"type" : "Death"
		},
		"Chain" : {
			"id" : "copy_effect"
		}
	}
}

static func info():
	return effects
