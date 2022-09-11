extends Node

const effects : Dictionary = {
	"Field" : {
		"id" : "Negate",
		"subclass" : "void_graveyard",
		"target" : "both"
	}
}

static func info():
	return effects
