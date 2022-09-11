extends Node

const effects : Dictionary = {
	"Play" : {
		"cards_played" : 50,
		"id" : "Life",
		"multiplier" : -0.5,
		"target" : "enemy",
		"reference" : "life",
		"reference_target" : "enemy",
		"constant" : 1,
		"subclass" : "Power"
	}
}

static func info():
	return effects
