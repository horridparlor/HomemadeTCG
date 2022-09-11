extends Node

const effects : Dictionary = {
	"Field" : {
		"id" : "Power",
		"subclass" : "cards_sent_to_grave",
		"target" : "enemy"
	},
	"Graveyard" : {
		"id" : "friend_dies",
		"tag" : "Skiing",
		"Chain" : {
			"id" : "play_from_graveyard",
			"tag" : "SkiingMantisHypothermiaThistle",
			"instant_position" : "same_column"
		},
		"once_per_turn" : "SkiingMantisHypothermiaThistle",
	}
}

static func info():
	return effects
