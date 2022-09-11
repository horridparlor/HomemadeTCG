extends Node

const effects : Dictionary = {
	"Discard" : {
		"id" : "Mill"
	},
	"Detach" : {
		"id" : "transform",
		"target" : "target",
		"player" : "enemy",
		"tag" : "RefrigeratorMonk",
		"once_per_turn" : "RefrigeratorMonk"
	}
}

static func info():
	return effects
