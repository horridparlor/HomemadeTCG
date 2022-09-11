extends Node

const effects : Dictionary = {
	"Once" : {
		"id" : "modify_damage",
		"multiplier" : 0,
		"Chain" : {
			"id" : "Life",
			"subclass" : "SetLife",
			"constant" : 1,
			"target" : "both"
		}
	}
}

static func info():
	return effects
