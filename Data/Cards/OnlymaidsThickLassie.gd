extends Node

const effects : Dictionary = {
	"Field" : {
		"id" : "attacked",
		"subclass" : "life",
		"constant" : -1
	},
	"Graveyard" : {
		"id" : "EndPhase",
		"Chain" : {
			"id" : "play_to_column",
			"column" : [3],
			"relocation" : "Void"	
		}
	}
}

static func info():
	return effects
