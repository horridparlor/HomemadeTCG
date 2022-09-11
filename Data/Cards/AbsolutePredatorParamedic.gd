extends Node

const effects : Dictionary = {
	"Hand" : {
		"id" : "Response",
		"subclass" : "out_of_life",
		"once_per_turn" : "AbsolutePredatorParamedic1"
	},
	"Graveyard" : {
		"id" : "death_protection",
		"restriction" : "fusion",
		"condition" : "by_attack",
		"once_per_turn" : "AbsolutePredatorParamedic2"
	}
}

static func info():
	return effects
