extends Node

const effects : Dictionary = {
	"Play" : {
		"id" : "Mill",
		"amount" : 3
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
