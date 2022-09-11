extends Node

const deck_formula : Dictionary = {
	"Main" : {
		"AbsolutePredatorCuriousSimp" : 2,
		"AbsolutePredatorParamedic" : 2,
		"AbsolutePredatorSimianInfantry" : 2,
		"BeginnerMilker" : 2,
		"BirdLoveSentiment" : 2
	},
	"Grave" : {
		"AbsolutePredatorGatlingBaboon" : 2,
		"AbsolutePredatorSubmonkey" : 2,
		"UdderDualWielder" : 2
	}
}

static func info():
	return deck_formula
