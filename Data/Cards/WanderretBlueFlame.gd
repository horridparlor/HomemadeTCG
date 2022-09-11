extends Node

const effects : Dictionary = {
	"Hand" : {
		"id" : "free_play",
		"subclass" : "cards_on_field",
		"target" : "self",
		"tag" : "Wanderret",
		"condition" : "different_name",
		"once_per_turn" : "WanderretBlueFlame1"
	},
	"Play" : {
		"id" : "Life",
		"multiplier" : -1.0,
		"target" : "enemy",
		"reference" : "cards_on_field",
		"reference_target" : "both",
		"tag" : "Wanderret",
		"once_per_turn" : "WanderretBlueFlame2"
	},
	"Void" : {
		"plus" : 1,
		"id" : "Life",
		"target" : "enemy",
		"constant" : -2,
		"once_per_turn" : "WanderretBlueFlame3"
	}
}

static func info():
	return effects
