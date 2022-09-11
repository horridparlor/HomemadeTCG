extends Node

const effects : Dictionary = {
	"Hand" : {
		"id" : "free_play",
		"subclass" : "cards_on_field",
		"tag" : "Onlymaids",
		"condition" : "different_name",
		"restriction" : "friends",
		"once_per_turn" : "OnlymaidsCatMother"
	},
	"Field" : {
		"id" : "attacked",
		"subclass" : "life",
		"constant" : -2
	}
}

static func info():
	return effects
