extends Node

const effects : Dictionary = {
	"Hand" : {
		"id" : "Response",
		"subclass" : "Draw",
		"tag" : "reverse",
		"once_per_turn" : "LittleMissKatarina"
	},
	"Play" : {
		"id" : "pathetic_pile",
		"subclass" : "Realize",
		"target" : "enemy"
	}
}

static func info():
	return effects
