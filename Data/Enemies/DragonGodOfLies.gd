extends Node

const deck_formula : Dictionary = {
	"Main" : {
		"ChaosFollower" : 2,
		"CNCMachine4Axis" : 3,
		"CNCMachineMillCabinet" : 3,
		"CNCMachineSteroidLathe" : 3,
		"IsekaiSummoningRitual" : 2,
		"MushyFunguy" : 2,
		"SpaceTimeDistortion" : 2,
	},
	"Grave" : {
		"ChairmanGongFei" : 2,
		"DarkCavalry" : 1,
		"DeadlyMimic" : 1,
		"DoomHydra" : 2,
		"DragonGodOfLies" : 1,
		"ElderSeaMonstrosity" : 1,
		"Octopussy" : 3
	}
}

static func info():
	return deck_formula
