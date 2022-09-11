extends Node

const deck_formula : Dictionary = {
	"Main" : {
		"OnlymaidsBlackjack" : 2,
		"OnlymaidsCatMother" : 2,
		"OnlymaidsRefinia" : 2,
		"OnlymaidsSingleMom" : 2,
		"OnlymaidsThickLassie" : 2
	},
	"Grave" : {
		"DragonGodOfDeath" : 1,
		"Octopussy" : 2,
		"TiananmenSchoolBus" : 2,
		"TwinMaidsOfDeath" : 2
	}
}

static func info():
	return deck_formula
