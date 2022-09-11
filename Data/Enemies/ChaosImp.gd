extends Node

const deck_formula : Dictionary = {
	"Main" : {
		"ChaosFollower" : 2,
		"HukkakeroVainamoinenTestingGrounds" : 2,
		"IsekaiSummoningRitual" : 2,
		"SpaceTimeDistortion" : 1,
		"UnripeAsparagus" : 2,
		"UnripeOkra" : 2
	},
	"Grave" : {
		"DoomHydra" : 2,
		"DragonGodOfChaos" : 1,
		"NuclearFusionAkilleon" : 1,
		"Octopussy" : 2,
		"UnripeMysteryPumpkin" : 3
	}
}

static func info():
	return deck_formula
