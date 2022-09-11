extends Node

const effects : Dictionary = {
	"Hand" : {
		"id" : "Attach",
		"target" : "both",
		"once_per_turn" : "SecrecyOfTheVainamoinenProject1"
	},
	"Field" : {
		"id" : "Attached",
		"source" : ["no_effects"]
	},
	"Detach" : {
		"id" : "Draw",
		"amount" : 2,
		"attached" : "Vaakkumanner",
		"once_per_turn" : "SecrecyOfTheVainamoinenProject2"
	}
}

static func info():
	return effects
