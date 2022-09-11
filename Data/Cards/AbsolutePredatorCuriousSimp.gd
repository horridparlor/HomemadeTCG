extends Node

const effects : Dictionary = {
	"Play" : {
		"id" : "Search",
		"tag" : "AbsolutePredator",
		"condition" : "different_name",
		"once_per_turn" : "AbsolutePredatorCuriousSimp"
	}
}

static func info():
	return effects
