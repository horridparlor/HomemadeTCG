extends Node

const effects : Dictionary = {
	"ContactFusion" : {
		"Field" : {
			"amount" : 2,
			"location" : "Attach"
		},
		"once_per_turn" : "EmeraldShogun"
	},
	"Death" : {
		"id" : "bounce_attached"
	}
}

static func info():
	return effects
