extends Node

const deck_formula : Dictionary = {
	"Main" : {
		"BabySharkCaripean" : 2,
		"BabySharkHammagal" : 2,
		"BabySharkSavaguy" : 2,
		"BabySharkTripoli" : 2,
		"DonutShark" : 2
	},
	"Grave" : {
		"EmeraldShogun" : 2,
		"NarwhalBattleshipJustisu" : 2,
		"SealedWrath" : 1,
		"SharkSummoner" : 3,
		"SkullWyvern" : 1
	}
}

static func info():
	return deck_formula
