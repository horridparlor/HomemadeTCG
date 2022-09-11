extends Node

const deck_formula : Dictionary = {
	"Main" : {
		"ChaosFollower" : 1,
		"HydraSpawn" : 2,
		"IsekaiSummoningRitual" : 1,
		"LaxStump" : 2
	},
	"Grave" : {
		"DoomHydra" : 2,
		}
	}

static func info():
	return deck_formula
