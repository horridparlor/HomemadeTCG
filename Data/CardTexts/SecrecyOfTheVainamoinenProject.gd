extends Node

const card_text : Dictionary = {
	"Name" : "Secrecy of the Vainamoinen Project",
	"[Hand]" : "You can attach this card to a card on the field. Only once per turn.",
	"[Field]" : "The enemy this card is attached has no effects.",
	"[Detach]" : "Draw 2 cards. Only while this card is attached to a \"Vaakkumanner\" friend, and only once per turn."
}

static func info():
	return card_text
