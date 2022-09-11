extends Node

const effects : Dictionary = {
	"Play" : {
		"id" : "Life",
		"constant" : 3
	},
	"Death" : {
		"id" : "play_from_graveyard",
		"tag" : "UdderDualWielder",
		"instant_position" : "same_column"
	}
}

static func info():
	return effects
