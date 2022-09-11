extends Node

const card_text : Dictionary = {
	"Name" : "CNC Machine - Mill Cabinet",
	"[Field]" : "This card's power is equal to the number of \"CNC Machine\" in your graveyard.",
	"[Graveyard]" : "At the end phase; void this card, then mill 2 cards."
}

static func info():
	return card_text
