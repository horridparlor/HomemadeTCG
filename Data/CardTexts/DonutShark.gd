extends Node

const card_text : Dictionary = {
	"Name" : "Donut Shark",
	"[Discard]" : "Search a \"Baby Shark\", but only once per turn.",
	"[Void + 2]" : "Play a \"Shark Summoner\" from your graveyard."
}

static func info():
	return card_text
