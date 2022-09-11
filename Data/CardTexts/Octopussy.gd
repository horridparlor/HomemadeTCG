extends Node

const card_text : Dictionary = {
	"Name" : "Octopussy",
	"[ContactFusion]" : "Void 2 cards in your graveyard, but only once per turn.",
	"[Play]" : "This card becomes a random card with a void-triggered effect, then copy its play-trigger effect."
}

static func info():
	return card_text
