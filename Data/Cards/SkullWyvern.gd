extends Node

const effects : Dictionary = {
	"ContactFusion" : {
		"Graveyard" : {
			"reference" : "cards_sent_to_grave",
			"amount" : 2,
			"location" : "Attach"
		},
		"once_per_game" : "SkullWyvern"
	},
	"Detach" : {
		"id" : "Mill",
		"amount" : 2
	}
}

static func info():
	return effects
