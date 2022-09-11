extends Node

const effects : Dictionary = {
	"Play" : {
		"id" : "transform",
		"subclass" : "Random",
		"wanted_effect" : {
				"type" : "ContactFusion"
		},
		"Chain" : {
			"id" : "copy_effect"
		}
	},
	"Void" : {
		"plus" : 3,
		"id" : "transform",
		"target" : "all",
		"player" : "both",
		"subclass" : "Random"
	}
}

static func info():
	return effects
