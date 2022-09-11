extends Node

const deck_formula : Dictionary = {
	"Main" : {
		"CNCMachine4Axis" : 3,
		"CNCMachineMillCabinet" : 3,
		"CNCMachineSteroidLathe" : 3,
		"IsekaiSummoningRitual" : 2
	},
	"Grave" : {
		"ApprenticeWizard" : 2,
		"DarkCavalry" : 2,
		"DragonGodOfLies" : 2
	}
}

static func info():
	return deck_formula
