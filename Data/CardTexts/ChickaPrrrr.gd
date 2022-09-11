extends Node

const card_text : Dictionary = {
	"Name" : "Chicka Prrrr",
	"[Discard]" : "Your opponent mills 3 cards, but only once per turn.",
	"[Play]" : "This card's power becomes equal to the number of cards sent to your opponent's graveyard this turn."
}

static func info():
	return card_text
