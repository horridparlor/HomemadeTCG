extends Node

const effects : Dictionary = {
	"Field" : {
		"id" : "card_to_grave",
		"reference_target" : "both",
		"Chain" : {
			"id" : "mass_relocate",
			"target" : "both",
			"location" : "Graveyard",
			"relocation" : "Void"
		}
	}
}

static func info():
	return effects
