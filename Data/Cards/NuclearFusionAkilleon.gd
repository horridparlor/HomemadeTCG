extends Node

const effects : Dictionary = {
	"ContactFusion" : {
		"Field" : {
			"condition" : "fusion",
			"amount" : 2
		},
		"once_per_game" : "NuclearFusionAkilleon"
	},
	"Play" : {
		"id" : "Life",
		"reference" : "highest_power",
		"reference_target" : "enemy",
		"subclass" : "Power"
	}
}

static func info():
	return effects
