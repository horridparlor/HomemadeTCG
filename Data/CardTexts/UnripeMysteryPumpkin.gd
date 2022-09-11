extends Node

const card_text : Dictionary = {
	"Name" : "Unripe Mystery Pumpkin",
	"[ContactFusion]" : "Void 2 non-fusion \"Unripe\" cards in your graveyard. Only once per turn.",
	"[Field]" : "This card's power is equal to half the number of cards sent to your graveyard this turn, rounded down.",
	"[Death]" : "Add this card to your hand. It becomes a random card with a hand-active effect."
}

static func info():
	return card_text
