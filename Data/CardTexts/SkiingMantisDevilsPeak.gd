extends Node

const card_text : Dictionary = {
	"Name" : "Skiing Mantis - Devil's Peak",
	"[Play]" : "Search a \"Skiing Mantis\" with a different name, and send it to your graveyard. You can play a \"Skiing Mantis\" from your graveyard this turn. Only once per turn.",
	"[Field]" : "This card's power is equal to the number of cards sent to your opponent's graveyard this turn."
}

static func info():
	return card_text
