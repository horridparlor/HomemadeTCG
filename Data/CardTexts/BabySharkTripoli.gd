extends Node

const card_text : Dictionary = {
	"Name" : "Baby Shark - Tripoli",
	"[Discard]" : "Play a copy of this card. Only while there are 2 or more \"Shark\" friends, and only once per turn.",
	"[Void + 2]" : "Search 2 copies of this card, but only once per game."
}

static func info():
	return card_text
