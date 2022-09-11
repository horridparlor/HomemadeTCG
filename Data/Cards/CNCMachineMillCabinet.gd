extends Node

const effects : Dictionary = {
	"Field" : {
		"id" : "Power",
		"subclass" : "cards_in_grave",
		"target" : "self",
		"tag" : "CNCMachine"
	},
	"Graveyard" : {
		"id" : "EndPhase",
		"Chain" : {
			"id" : "Relocation",
			"location" : "Void",
			"Chain": {
				"id" : "Mill",
				"amount" : 2
		}	
		}
	}
}

static func info():
	return effects
