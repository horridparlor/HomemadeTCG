extends Node

const effects : Dictionary = {
	"ContactFusion" : {
		"Spend_Plays" : {
			"target" : "self",
			"amount" : 3
		},
		"once_per_game" : "HappyLittleMortgageFund"
	},
	"Play" : {
		"id" : "Draw",
		"subclass" : "Until",
		"amount" : 5
	}
}

static func info():
	return effects
