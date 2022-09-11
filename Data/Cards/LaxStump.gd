extends Node

const effects : Dictionary = {
	"Field" : {
		"id" : "irreversible",
		"subclass" : "Attached",
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
		"once_per_turn" : "LaxStump"
	}
}

static func info():
	return effects
