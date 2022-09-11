extends Node

const effects : Dictionary = {
	"Field" : {
		"id" : "extra_attacks",
		"amount" : 1,
		"share_condition" : "Attached"
	},
	"Detach" : {
		"id" : "Destroy",
		"restriction" : "non_fusion",
		"target" : "enemy",
		"subclass" : "own_column"
	}
}

static func info():
	return effects
