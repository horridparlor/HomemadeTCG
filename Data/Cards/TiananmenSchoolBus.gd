extends Node

const effects : Dictionary = {
	"ContactFusion" : {
		"Hand" : {
			"amount" : 2
		},
		"once_per_turn" : "TiananmenSchoolBus"
	},
	"Once" : {
		"id" : "reverse_attack"
	}
}

static func info():
	return effects
