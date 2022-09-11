extends Node

const effects : Dictionary = {
	"Field" : {
		"id" : "Power",
		"subclass" : "cards_sent_to_grave",
		"target" : "enemy"
	},
	"Graveyard" : {
		"id" : "friend_played",
		"tag" : "Skiing",
		"Chain" : {
			"id" : "play_to_column",
			"column" : [3],
			"once_per_turn" : "SkiingMantisSnowOrchid"
		},
	}
}

static func info():
	return effects
