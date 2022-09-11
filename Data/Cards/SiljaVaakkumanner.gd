extends Node

const effects : Dictionary = {
	"Graveyard" : {
		"id" : "friend_dies",
		"tag" : "Vainamoinen",
		"Chain" : {
			"id" : "play_from_graveyard",
			"tag" : "SiljaVaakkumanner",
			"instant_position" : "same_column",
			"subclass" : "Attach"
		},
		"once_per_turn" : "SiljaVaakkumanner",
	}
}

static func info():
	return effects
