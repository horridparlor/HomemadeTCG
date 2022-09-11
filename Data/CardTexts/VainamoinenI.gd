extends Node

const card_text : Dictionary = {
	"Name" : "Vainamoinen - I",
	"[Hand]" : "You can attach this card to a friend. Only once per turn.",
	"[Detach]" : "Void target fusion card in your opponent's graveyard. Only once per turn."
}

static func info():
	return card_text
