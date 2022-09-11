extends Node

const effects : Dictionary = {
	"Hand" : {
		"id" : "free_play",
		"subclass" : "cards_on_field",
		"tag" : "CNC",
		"condition" : "different_name",
		"restriction" : "friends",
		"once_per_turn" : "CNCMachine4Axis"
	},
	"Field" : {
		"id" : "Power",
		"subclass" : "cards_in_grave",
		"target" : "self",
		"tag" : "CNCMachine"
	}
}

static func info():
	return effects
