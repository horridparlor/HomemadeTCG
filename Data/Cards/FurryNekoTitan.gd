extends Node

const effects : Dictionary = {
	"ContactFusion" : {
		"Field" : {
			"condition" : "non_fusion",
			"amount" : 2,
			"location" : "Top_of_Deck"
		},
		"once_per_turn" : "FurryNekoTitan1"
	},
	"Play" : {
		"id" : "Draw",
		"Chain" : {
			"id" : "Power",
			"subclass" : "becomes",
			"reference" : "cards_in_hand"
		}
	},
	"Detach" : {
		"id" : "Destroy",
		"target" : "enemy",
		"restriction" : "fusion",
		"once_per_turn" : "FurryNekoTitan2"
	}
}

static func info():
	return effects
