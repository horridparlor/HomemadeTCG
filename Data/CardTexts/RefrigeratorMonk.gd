extends Node

const card_text : Dictionary = {
	"Name" : "Refrigerator Monk",
	"[Discard]" : "Mill a card.",
	"[Detach]" : "Target enemy transforms into \"Refrigerator Monk\", but only once per turn."
}

static func info():
	return card_text
