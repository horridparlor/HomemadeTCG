extends Node

const card_text : Dictionary = {
	"Name" : "Absolute Predator - Kamikaze",
	"[ContactFusion]" : "Friend in the leftmost column + \"Absolute Pedator\" in hand.",
	"[Play]" : "Destroy all fusion cards in the same column, but only once per turn.",
	"[Death]" : "You can play an \"Absolute Predator\" from your deck this turn."
}

static func info():
	return card_text
