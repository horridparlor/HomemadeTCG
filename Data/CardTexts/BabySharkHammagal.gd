extends Node

const card_text : Dictionary = {
	"Name" : "Baby Shark - Hammagal",
	"[Discard]" : "The next card you play this turn gains 2 power.",
	"[Void + 2]" : "Draw cards until you have 2 in hand. Only once per game."
}

static func info():
	return card_text
