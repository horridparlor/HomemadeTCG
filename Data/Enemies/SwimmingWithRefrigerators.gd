extends Node

const deck_formula : Dictionary = {
	"Main" : {
		"CNCMachineSteroidLathe" : 2,
		"ElderRefrigerator" : 3,
		"HollowedWanderret" : 2,
		"RefrigeratorMonk" : 3
	},
	"Grave" : {
		"ExtinctionHydra" : 1,
		"NarwhalBattleshipJustisu" : 1,
		"SwimmingWithRefrigerators" : 2
	}
}

static func info():
	return deck_formula
