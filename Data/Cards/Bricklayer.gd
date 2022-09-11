extends Node

const effects : Dictionary = {
	"Play" : {
		"id" : "additional_play",
		"location" : "Deck",
		"amount" : 2,
		"tag" : "Bricks",
		"once_per_turn" : "Bricklayer"
	}
}

static func info():
	return effects
