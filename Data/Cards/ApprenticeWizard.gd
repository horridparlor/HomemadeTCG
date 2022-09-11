extends Node

const effects : Dictionary = {
	"ContactFusion" : {
		"Hand" : {
			"amount" : 2
		},
		"once_per_game" : "ApprenticeWizard"
	},
	"Play" : {
		"id" : "Destroy",
		"restriction" : "non_fusion",
		"target" : "enemy",
		"Chain" : {
			"id" : "restriction",
			"subclass" : "cannot_attack"
		}
	}
}

static func info():
	return effects
