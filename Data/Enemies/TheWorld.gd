extends Node

const deck_formula : Dictionary = {
	"Main" : {
		"DoyenOwl" : 2,
		"ElderRefrigerator" : 2,
		"HukkakeroVainamoinenTestingGrounds" : 1,
		"LividbornTusker" : 1,
		"LoosePate" : 1,
		"MeticulousHummingbird" : 2,
		"NekoSisterCherryPawsMairikoChan" : 2,
		"NekoSisterMidnightNebula" : 1,
		"NekoSisterWhiteCrescent" : 2,
		"NordicMooseRider" : 1,
		"RefrigeratorCoffin" : 2,
		"RefrigeratorMonk" : 2,
		"SoberNekoBrother" : 1,
		"VainamoinenI" : 1
	},
	"Grave" : {
		"BenevolentArchsaint" : 1,
		"DragonGodOfAbsolution" : 1,
		"GreedyHydra" : 1,
		"HappyLittleMortgageFund" : 1,
		"InvaderWarlord" : 1,
		"OlympicSwimmer" : 2,
		"SealedWrath" : 1,
		"SplatterDaemon" : 2,
		"SwimmingWithRefrigerators" : 2,
		"TheWorld" : 2,
		"VainamoinenII" : 1
	}
}

static func info():
	return deck_formula
