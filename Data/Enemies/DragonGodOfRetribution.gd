extends Node

const deck_formula : Dictionary = {
	"Main" : {
		"HukkakeroVainamoinenTestingGrounds" : 2,
		"InvaderScout" : 2,
		"PossessiveInvader" : 2,
		"SecrecyOfTheVainamoinenProject" : 2,
		"SiljaVaakkumanner" : 2,
		"VainamoinenI" : 2
	},
	"Grave" : {
		"BenevolentArchsaint" : 1,
		"DragonGodOfRetribution" : 1,
		"EternalKing" : 2,
		"GreedyHydra" : 1,
		"Hivemind" : 2,
		"InvaderWarlord" : 2,
		"VainamoinenII" : 2
	}
}

static func info():
	return deck_formula
