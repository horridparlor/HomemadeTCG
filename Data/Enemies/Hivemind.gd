extends Node

const deck_formula : Dictionary = {
	"Main" : {
		"2500BCInvader" : 2,
		"InvaderBugInTheSimulation" : 2,
		"InvaderScout" : 2,
		"NekoSisterWhiteCrescent" : 2,
		"PossessiveInvader" : 2
	},
	"Grave" : {
		"HappyLittleMortgageFund" : 1,
		"Hivemind" : 2,
		"InvaderWarlord" : 2,
		"SplatterDaemon" : 2
	}
}

static func info():
	return deck_formula
