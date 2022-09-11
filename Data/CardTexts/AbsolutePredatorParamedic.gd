extends Node

const card_text : Dictionary = {
	"Name" : "Absolute Predator - Paramedic",
	"[Hand]" : "If you would run out of life, your life becomes 1 instead. Then, discard this card. Only once per turn.",
	"[Graveyard]" : "If a fusion friend would die by attack, void this card instead, but only once per turn."
}

static func info():
	return card_text
