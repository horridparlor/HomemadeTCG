extends Node

const deck_formula : Dictionary = {
	"Main" : {
		"ChickaPrrrr" : 2,
		"LoosePate" : 2,
		"SkiingMantisBudwingHunk" : 2,
		"SkiingMantisDevilsPeak" : 2,
		"SkiingMantisHypothermiaThistle" : 2,
		"SkiingMantisSnowOrchid" : 2
	},
	"Grave" : {
		"DragonGodOfAbsolution" : 1,
		"GreedyHydra" : 1,
		"HappyLittleMortgageFund" : 1,
		"HydraMonger" : 2,
		"SealedWrath" : 1,
		"SkiingHercules" : 2,
		"SplatterDaemon" : 2
	}
}

static func info():
	return deck_formula
