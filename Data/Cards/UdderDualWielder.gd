extends Node

const effects : Dictionary = {
	"ContactFusion" : {
		"Field" : {
			"amount" : 2
		}
	},
	"Play" : {
		"id" : "Life",
		"constant" : 6,
		"once_per_game" : "UdderDualWielder"
	}
}

static func info():
	return effects
