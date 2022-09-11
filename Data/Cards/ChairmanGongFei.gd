extends Node

const effects : Dictionary = {
	"ContactFusion" : {
		"Field" : {
			"condition" : "non_fusion",
			"amount" : 2
		}
	},
	"Play" : {
		"id" : "additional_play",
		"once_per_turn" : "ChairmanGongFei"
	}
}

static func info():
	return effects
