extends Node

const card_text : Dictionary = {
	"Name" : "Unripe Okra",
	"[Discard]" : "This card becomes a random fusion. Only once per turn.",
	"[Death]" : "The top 2 cards of your opponent's deck become \"Unripe Okra\"."
}

static func info():
	return card_text
