extends Node

const effects : Dictionary = {
	"Play" : {
		"id" : "Search",
		"tag" : "Onlymaids",
		"condition" : "different_name",
		"once_per_turn" : "OnlymaidsBlackjack"
	},
	"Field" : {
		"id" : "friend_attacked",
		"subclass" : "life",
		"constant" : -1
	}
}

static func info():
	return effects
