extends Node

const effects : Dictionary = {
	"Play" : {
		"id" : "Life",
		"constant" : 2,
		"Chain" : {
			"id" : "play_copy",
			"life" : -9
		},
		"once_per_turn" : "NatsuToyKnight"
	}
}

static func info():
	return effects
