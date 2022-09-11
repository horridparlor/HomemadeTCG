extends Node

const card_text : Dictionary = {
	"Name" : "Splatter Daemon",
	"[ContactFusion]" : "Restore the next 2 cards you play. Only once per game.",
	"[Detach]" : "Send the next card your opponent plays to the graveyard, but only once per game."
}

static func info():
	return card_text
