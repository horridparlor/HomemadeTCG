extends Node

const effects : Dictionary = {
	"Draw" : {
		"id" : "transform",
		"player" : "enemy",
		"target" : "top_of_deck",
		"amount" : -1,
		"subclass" : "Random",
		"reference" : "Deck",
		"reference_target" : "enemy"
	}
}

static func info():
	return effects
