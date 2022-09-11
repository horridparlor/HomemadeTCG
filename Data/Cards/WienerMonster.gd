extends Node

const effects : Dictionary = {
	"ContactFusion" : {
		"Field" : {
			"amount" : 2
		}
	},
	"Field" : {
		"id" : "extra_attacks",
		"subclass" : "Up_to",
		"reference" : "cards_on_field",
		"condition" : "fusion",
		"restriction" : "friends"
	}
}

static func info():
	return effects
