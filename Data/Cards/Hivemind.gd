extends Node

const effects : Dictionary = {
	"ContactFusion" : {
		"Hand" : {
			"tag" : "Invader",
			"amount" : 2,
			"location" : "Attach",
		},
		"once_per_turn" : "Hivemind"
	},
	"Field" : {
		"id" : "Power",
		"subclass" : "cards_on_field",
		"tag" : "Invader",
		"multiplier" : 2.0
	},
	"Once" : {
		"id" : "reverse_attack",
		"condition" : "enemy_turn"
	}
}

static func info():
	return effects
