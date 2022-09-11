extends Node

const deck_formula : Dictionary = {
	"Main" : {
		"AbsolutePredatorCuriousSimp" : 2,
		"AbsolutePredatorParamedic" : 2,
		"AbsolutePredatorSimianInfantry" : 2,
		"Bricklayer" : 2,
		"Bricks" : 2,
		"MushyFunguy" : 2
	},
	"Grave" : {
		"AbsolutePredatorGatlingBaboon" : 2,
		"AbsolutePredatorKamikaze" : 2,
		"AbsolutePredatorSubmonkey" : 2,
		"ChairmanGongFei" : 1,
		"DragonGodOfDeath" : 1,
		"ElderSeaMonstrosity" : 2
	}
}

static func info():
	return deck_formula
