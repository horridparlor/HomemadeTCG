extends Node

const effects : Dictionary = {
	"ContactFusion" : {
		"Field" : {
			"column" : [5]
		},
		"Hand" : {
			"tag" : "AbsolutePredator"
		}
	},
	"Play" : {
		"id" : "search_graveyard",
		"target" : "enemy",
		"once_per_turn" : "AbsolutePredatorSubmonkey"
	},
	"CardConfirmation" : {
		"id" : "Search_Enemy_Grave",
		"Chain" : {
			"id" : "Power",
			"subclass" : "becomes",
			"power_gain" : 2,
			"reference" : "cards_in_grave",
			"reference_target" : "enemy"
		}
	},
	"Death" : {
		"id" : "Mill",
		"reference" : "cards_sent_to_grave"
	}
}

static func info():
	return effects
