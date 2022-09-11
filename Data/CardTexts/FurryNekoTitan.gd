extends Node

const card_text : Dictionary = {
	"Name" : "Furry, Neko-Titan",
	"[ContactFusion]" : "Return 2 non-fusion friends on the top of deck. Only once per turn.",
	"[Play]" : "Draw a card. Then, this card's power becomes equal to the number of cards in your hand.",
	"[Detach]" : "Destroy target fusion enemy, but only once per turn."
}

static func info():
	return card_text
