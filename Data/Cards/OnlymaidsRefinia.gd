extends Node

const effects : Dictionary = {
	"Field" : {
		"id" : "attacked",
		"subclass" : "life",
		"constant" : -1
	},
	"Death" : {
		"id" : "restriction",
		"subclass" : "max_attacks",
		"timing" : "Now",
		"target" : "enemy",
	}
}

static func info():
	return effects
