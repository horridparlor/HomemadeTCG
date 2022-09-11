extends Node

const card_text : Dictionary = {
	"Name" : "Lohjaburger Restaurant Manager",
	"[Hand]" : "Reverse any attack targeting a non-fusion friend. Then, discard this card. Only once per turn.",
	"[Graveyard]" : "At the end phase, if you played 5 or more cards this turn; add this card to your hand. Only once per turn."
}

static func info():
	return card_text
