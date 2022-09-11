extends Node

const effects : Dictionary = {
	"Play" : {
		"id" : "transform",
		"subclass" : "Copy",
		"target" : "target",
		"player" : "enemy",
		"tag" : "MushyFunguy"
	},
	"Void" : {
		"plus" : 6,
		"id" : "additional_play",
		"location" : "Deck"
	}
}

static func info():
	return effects
