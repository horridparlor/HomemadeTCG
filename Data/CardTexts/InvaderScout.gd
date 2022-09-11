extends Node

const card_text : Dictionary = {
	"Name" : "Invader Scout",
	"[Hand]" : "While only your opponent has any cards on the field, you can additionally play this card.",
	"[Play]" : "Search an \"Invader\" with a different name. Only once per turn."
}

static func info():
	return card_text
