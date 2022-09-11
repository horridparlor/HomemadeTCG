extends Node

const effects : Dictionary = {
	"ContactFusion" : {
		"Graveyard" : {
			"tag" : "Wanderret",
			"reference" : "cards_sent_to_grave",
			"amount" : 3,
			"location" : "Attach"
		},
		"once_per_turn" : "Slenderret"
	},
	"Play" : {
		"id" : "transform",
		"target" : "all",
		"player" : "enemy",
		"tag" : "Wanderret"
	}
}

static func info():
	return effects
