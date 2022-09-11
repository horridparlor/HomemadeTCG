extends Node

const effects : Dictionary = {
	"Death" : {
		"id" : "transform",
		"target" : "all",
		"restriction" : "fusion",
		"player" : "enemy",
		"subclass" : "Random",
		"wanted_effect" : {
				"type" : "ContactFusion",
				"modifiers" : ["non_wanted_effect"]
		}
	}
}

static func info():
	return effects
