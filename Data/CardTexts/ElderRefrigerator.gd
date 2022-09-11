extends Node

const card_text : Dictionary = {
	"Name" : "Elder Refrigerator",
	"[Discard]" : "Void a \"Refrigerator\" from your graveyard, then return it to your graveyard. Only once per turn.",
	"[Detach]" : "You lose 2 life, then play this card. Only once per turn."
}

static func info():
	return card_text
