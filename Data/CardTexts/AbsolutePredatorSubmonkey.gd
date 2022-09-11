extends Node

const card_text : Dictionary = {
	"Name" : "Absolute Predator - Submonkey",
	"[ContactFusion]" : "Friend in the rightmost column + \"Absolute Predator\" in hand.",
	"[Play]" : "Void target card in your opponent's graveyard, then this card's power becomes equal to 2 plus the number of cards with the same name as the voided card in your opponent's graveyard. Only once per turn.",
	"[Death]" : "Mill cards equal to the number of cards sent to your graveyard this turn."
}

static func info():
	return card_text
