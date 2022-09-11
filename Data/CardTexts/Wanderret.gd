extends Node

const card_text : Dictionary = {
	"Name" : "Wanderret",
	"[Hand]" : "While there is a \"Wanderret\" on the field, you can additionally play this card.",
	"[Void + 2]" : "Search a \"Wanderret\", but only once per turn."
}

static func info():
	return card_text
