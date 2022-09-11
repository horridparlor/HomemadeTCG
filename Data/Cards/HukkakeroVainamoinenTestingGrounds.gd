extends Node

const effects : Dictionary = {
	"Hand" : {
		"id" : "Attach",
		"once_per_turn" : "HukkakeroVainamoinenTestingGrounds1"
	},
	"Detach" : {
		"id" : "Destroy",
		"subclass" : "random",
		"target" : "enemy",
		"zone_conditions" : {
			"subclass" : "cards_on_field",
			"restriction" : "friends",
			"target" : "enemy",
			"amount" : 3
		},
		"once_per_turn" : "HukkakeroVainamoinenTestingGrounds2"
	}
}

static func info():
	return effects
