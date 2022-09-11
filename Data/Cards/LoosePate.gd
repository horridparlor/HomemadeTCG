extends Node

const effects : Dictionary = {
	"Field" : {
		"id" : "extra_attacks",
		"subclass" : "Attached",
		"amount" : 1,
		"power_gain" : 1
	},
	"Graveyard" : {
		"id" : "friend_played",
		"tag" : "Hydra",
		"Chain" : {
			"id" : "Relocation",
			"location" : "Attach",
			"relocation" : "Void"
		},
		"once_per_turn" : "LoosePate"
	}
}

static func info():
	return effects
