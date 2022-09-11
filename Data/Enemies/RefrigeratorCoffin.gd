extends Node

const deck_formula : Dictionary = {
	"Main" : {
		"NordicMooseRider" : 2,
		"RefrigeratorCoffin" : 2,
		"RefrigeratorMonk" : 2
	},
	"Grave" : {
		"OlympicSwimmer" : 2,
		"SplatterDaemon" : 1
	}
}

static func info():
	return deck_formula
