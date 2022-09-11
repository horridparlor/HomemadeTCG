extends Node

const deck_formula : Dictionary = {
	"Main" : {
		"BeginnerMilker" : 2,
		"IsekaiSummoningRitual" : 2,
		"MushyFunguy" : 2,
		"OnlymaidsRefinia" : 2,
		"UnripeAsparagus" : 2,
		"UnripeOkra" : 2,
	},
	"Grave" : {
		"AngryDonutKing" : 1,
		"DeadlyMimic" : 1,
		"DragonGodOfDeath" : 1,
		"ExtinctionHydra" : 1,
		"TwinMaidsOfDeath" : 2,
		"UdderDualWielder" : 2,
		"UnripeMysteryPumpkin" : 2
	}
}

static func info():
	return deck_formula
