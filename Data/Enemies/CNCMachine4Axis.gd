extends Node

const deck_formula : Dictionary = {
	"Main" : {
		"CNCMachine4Axis" : 2,
		"CNCMachineSteroidLathe" : 2
	},
	"Grave" : {
		"DarkCavalry" : 1,
	}
}

static func info():
	return deck_formula
