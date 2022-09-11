extends Node

const effects : Dictionary = {
	"ContactFusion" : {
		"Field" : {
			"condition" : "different_names",
			"amount" : 2
		}
	},
	"Play" : {
		"id" : "Destroy",
		"target" : "enemy",
		"Chain" : {
			"id" : "restriction",
			"subclass" : "cannot_attack"
		},
		"once_per_game" : "AngryDonutKing"
	}
}

static func info():
	return effects
