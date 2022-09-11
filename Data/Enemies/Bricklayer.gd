extends Node

const deck_formula : Dictionary = {
	"Main" : {
		"BabySharkSavaguy" : 2,
		"Bricklayer" : 2,
		"Bricks" : 2,
		"MushyFunguy" : 2
	},
	"Grave" : {
		"AngryDonutKing" : 2,
		"ChairmanGongFei" : 2,
		"SharkSummoner" : 2
	}
}

static func info():
	return deck_formula
