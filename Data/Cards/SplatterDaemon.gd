extends Node

const effects : Dictionary = {
	"ContactFusion" : {
		"Restore_Plays" : {
			"amount" : 2
		},
		"once_per_game" : "SplatterDaemon1"
	},
	"Detach" : {
		"id" : "Spend_Plays",
		"target" : "enemy",
		"once_per_game" : "SplatterDaemon2"
	}
}

static func info():
	return effects
