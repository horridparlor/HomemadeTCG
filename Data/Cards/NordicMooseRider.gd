extends Node

const effects : Dictionary = {
	"Play" : {
		"id" : "search_graveyard",
		"location" : "Attach"
	},
	"Field" : {
		"id" : "irreversible",
		"share_condition" : "Attached"
	}
}

static func info():
	return effects
