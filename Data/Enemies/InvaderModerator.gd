extends Node

const deck_formula : Dictionary = {
	"Main" : {
		"2500BCInvader" : 2,
		"InvaderBugInTheSimulation" : 2,
		"InvaderScout" : 2
	},
	"Grave" : {
		"InvaderWarlord" : 2
	}
}

static func info():
	return deck_formula
