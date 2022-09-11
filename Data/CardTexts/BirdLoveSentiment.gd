extends Node

const card_text : Dictionary = {
	"Name" : "Bird-Love Sentiment",
	"[Play]" : "Void target card in your opponent's graveyard.",
	"[Void + 4]" : "Play a copy of the voided card."
}

static func info():
	return card_text
