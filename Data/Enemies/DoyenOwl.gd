extends Node

const deck_formula : Dictionary = {
	"Main" : {
		"AquaMadonna" : 2,
		"BuddyDragon" : 2,
		"DoyenOwl" : 2,
		"LoosePate" : 2
	},
	"Grave" : {
		"GreedyHydra" : 1,
		"MercuryEagle" : 2,
		"WanderretDungMiasma" : 2
	}
}

static func info():
	return deck_formula
