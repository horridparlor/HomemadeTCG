extends Node

const effects : Dictionary = {
	"Hand" : {
		"id" : "Response",
		"subclass" : "Mill",
		"tag" : "reverse"
	},
	"Void" : {
		"plus" : 2,
		"id" : "play_from_hand",
		"tag" : "AbsolutePredator"
	}
}

static func info():
	return effects
