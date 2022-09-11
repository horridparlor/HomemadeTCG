extends Node

const card_text : Dictionary = {
	"Name" : "Refrigerator Coffin",
	"[Discard]" : "Search a \"Refrigerator\" with a different name, and send it to your graveyard. Only once per turn.",
	"[Detach]" : "Destroy target non-fusion enemy, but only once per turn."
}

static func info():
	return card_text
