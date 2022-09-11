extends Node

const card_text : Dictionary = {
	"Name" : "False Hydra",
	"[ContactFusion]" : "2 cards with different names in hand, but only once per game.",
	"[Field]" : "This card cannot be attacked.",
	"[Once]" : "This card cannot be destroyed by card effect."
}

static func info():
	return card_text
