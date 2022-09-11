extends Node

const effects : Dictionary = {
	"Play" : {
		"id" : "play_from_graveyard",
		"tag" : "Wanderret",
		"condition" : "non_fusion",
		"once_per_turn" : "HollowedWanderret1"
	},
	"Void" : {
		"id" : "Mill",
		"amount" : 2,
		"once_per_turn" : "HollowedWanderret2"
	}
}

static func info():
	return effects
