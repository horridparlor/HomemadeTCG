extends Node

const effects : Dictionary = {
	"Play" : {
		"id" : "search_graveyard",
		"subclass" : "Imprint",
		"target" : "enemy"
	},
	"Void" : {
		"plus" : 4,
		"id" : "play_copy",
		"subclass" : "Imprint"
	}
}

static func info():
	return effects
