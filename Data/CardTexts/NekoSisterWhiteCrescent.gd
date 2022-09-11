extends Node

const card_text : Dictionary = {
	"Name" : "Neko-Sister White Crescent",
	"[Draw]" : "Play this card to the rightmost column. Only once per turn.",
	"[Detach]" : "Play this card to the leftmost column, but only once per turn."
}

static func info():
	return card_text
