extends Node

const deck_formula : Dictionary = {
	"Main" : {
		"LohjaburgerRestaurantManager" : 1,
		"SkiingMantisBudwingHunk" : 2,
		"SkiingMantisDevilsPeak" : 1,
		"SkiingMantisHypothermiaThistle" : 2,
	},
	"Grave" : {
		"SkiingHercules" : 2
	}
}

static func info():
	return deck_formula
