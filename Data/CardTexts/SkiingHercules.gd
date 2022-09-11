extends Node

const card_text : Dictionary = {
	"Name" : "Skiing Hercules",
	"[ContactFusion]" : "2 friends with power related to the number of cards sent to the graveyard.",
	"[Play]" : "Your opponent mills 3 cards, then destroy all enemies with the same name as a card sent to your opponent's graveyard this turn. Only once per turn.",
	"[Field]" : "This card's power is equal to the number of cards sent to your opponent's graveyard this turn."
}

static func info():
	return card_text
