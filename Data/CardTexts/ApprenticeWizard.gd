extends Node

const card_text : Dictionary = {
	"Name" : "Apprentice Wizard",
	"[ContactFusion]" : "2 cards in hand, but only once per game.",
	"[Play]" : "Destroy target non-fusion enemy, but this card cannot attack this turn."
}

static func info():
	return card_text
