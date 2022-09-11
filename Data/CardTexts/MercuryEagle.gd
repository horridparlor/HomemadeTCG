extends Node

const card_text : Dictionary = {
	"Name" : "Mercury Eagle",
	"[ContactFusion]" : "2 friends with a draw-trigger effect.",
	"[Play]" : "Draw 2 cards, but only once per turn.",
	"[Field]" : "This card's power is equal to the number of cards in your hand."
}

static func info():
	return card_text
