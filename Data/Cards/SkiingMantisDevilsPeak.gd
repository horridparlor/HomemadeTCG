extends Node

const effects : Dictionary = {
	"Play" : {
		"id" : "Search",
		"tag" : "SkiingMantis",
		"condition" : "different_name",
		"location" : "Graveyard",
		"once_per_turn" : "SkiingMantisDevilsPeak",
		"Chain" : {
			"id" : "additional_play",
			"location" : "Graveyard",
			"tag" : "SkiingMantis"
		}
	},
	"Field" : {
		"id" : "Power",
		"subclass" : "cards_sent_to_grave",
		"target" : "enemy"
	}
}

static func info():
	return effects
