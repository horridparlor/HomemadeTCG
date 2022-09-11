extends Node

const deck_formula : Dictionary = {
	"Main" : {
		"FroggyVenturer" : 2,
		"SkiingMantisBudwingHunk" : 2,
		"SkiingMantisDevilsPeak" : 2,
		"SkiingMantisHypothermiaThistle" : 2,
		"SkiingMantisSnowOrchid" : 2
	},
	"Grave" : {
		"DragonGodOfPeace" : 1,
		"EternalKing" : 2,
		"FalseHydra" : 1,
		"NuclearFusionAkilleon" : 1,
		"SkiingHercules" : 2
	}
}

static func info():
	return deck_formula
