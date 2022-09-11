extends Node

const effects : Dictionary = {
	"ContactFusion" : {
		"Field" : {
			"condition" : "different_names",
			"amount" : 5
		}
	},
	"Play" : {
		"id" : "Search",
		"subclass" : "Instant",
		"amount" : -1,
		"location" : "Attach",
		"Chain" : {
			"id" : "mass_relocate",
			"restriction" : "non_fusion",
			"location" : "Graveyard",
			"relocation" : "Top_of_Deck",
			"Chain" : {
				"id" : "Shuffle"
			}
		},
		"once_per_game" : "TheWorld"
	},
	"Field" : {
		"id" : "Power",
		"subclass" : "cards_attached"
	}
}

static func info():
	return effects
