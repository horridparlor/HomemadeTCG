extends Node

const card_text : Dictionary = {
	"Name" : "Greedy Hydra",
	"[ContactFusion]" : "2 cards with the same name in hand, but only once per game.",
	"[Play]" : "Draw cards until you have 3 in hand."
}

static func info():
	return card_text
