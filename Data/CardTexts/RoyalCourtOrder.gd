extends Node

const card_text : Dictionary = {
	"Name" : "Royal Court Order",
	"[ContactFusion]" : "2 cards in hand, but only once per turn.",
	"[Play]" : "Your opponent gains 2 life, but they lose 4 life when they realize how pathetic they are."
}

static func info():
	return card_text
