extends Node

const effects : Dictionary = {
	"ContactFusion" : {
		"Field" : {
			"amount" : 2,
			"location" : "Attach"
		},
		"once_per_turn" : "ElderlyNekoSlayer"
	},
	"Field" : {
		"id" : "extra_attacks",
		"subclass" : "Up_to",
		"tag" : "Neko",
		"reference" : "cards_on_field",
		"reference_target" : "both"
	},
	"Detach" : {
		"id" : "Destroy",
		"target" : "enemy",
		"restriction" : "non_fusion"
	}
}

static func info():
	return effects
