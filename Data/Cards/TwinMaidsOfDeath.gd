extends Node

const effects : Dictionary = {
	"ContactFusion" : {
		"Field" : {
			"tag" : "Onlymaids",
			"amount" : 2
		},
		"once_per_turn" : "TwinMaidsOfDeath"
	},
	"Field" : {
		"id" : "attacked",
		"subclass" : "life",
		"constant" : -3
	},
	"Once" : {
		"id" : "death_protection",
		"condition" : "by_attack"
	},
}

static func info():
	return effects
