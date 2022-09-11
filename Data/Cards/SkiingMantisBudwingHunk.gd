extends Node

const effects : Dictionary = {
	"Play" : {
		"id" : "Mill",
		"amount" : 2,
		"target" : "enemy",
		"Chain" : {
			"id" : "search_graveyard",
			"target" : "enemy",
			"amount" : 2,
			"condition" : "non_fusion",
		},
		"once_per_turn" : "SkiingMantisBudwingHunk"
	},
	"Field" : {
		"id" : "Power",
		"subclass" : "cards_sent_to_grave",
		"target" : "enemy"
	}
}

static func info():
	return effects
