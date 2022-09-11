extends Node

const effects : Dictionary = {
	"Discard" : {
		"id" : "search_graveyard",
		"tag" : "Refrigerator",
		"location" : "Graveyard",
		"once_per_turn" : "ElderRefrigerator1"
	},
	"Detach" : {
		"id" : "Life",
		"constant" : -2,
		"Chain" : {
			"id" : "Relocation",
			"location" : "Play",	
		},
		"once_per_turn" : "ElderRefrigerator2"
	}
}

static func info():
	return effects
