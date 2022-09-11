extends Node

const effects : Dictionary = {
	"Field" : {
		"id" : "Negate",
		"subclass" : "Play",
		"target" : "both"
	}
}

static func info():
	return effects
