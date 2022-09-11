extends Node

const deck_formula : Dictionary = {
	"Main" : {
		"SiljaVaakkumanner" : 2,
		"VainamoinenI" : 2
	},
	"Grave" : {
		"ApprenticeWizard" : 1,
	}
}

static func info():
	return deck_formula
