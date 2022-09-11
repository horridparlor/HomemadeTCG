extends Node

const effects : Dictionary = {
	"ContactFusion" : {
		"Field" : {
			"wanted_effect" : {
				"type" : "Play",
				"modifiers" : ["non_wanted_effect"]
			}
		},
		"once_per_turn" : "DragonGodOfChaos"
	},
	"Play" : {
		"id" : "transform",
		"subclass" : "Random",
		"wanted_effect" : {
			"type" : "Play"
		},
		"Chain" : {
			"id" : "copy_effect"
		}
	}
}

static func info():
	return effects
