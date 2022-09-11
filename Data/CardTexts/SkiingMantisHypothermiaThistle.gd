extends Node

const card_text : Dictionary = {
	"Name" : "Skiing Mantis - Hypothermia Thistle",
	"[Field]" : "This card's power is equal to the number of cards sent to your opponent's graveyard this turn.",
	"[Graveyard]" : "If a \"Skiing\" friend dies, play this card to the same column. Only once per turn."
}

static func info():
	return card_text
