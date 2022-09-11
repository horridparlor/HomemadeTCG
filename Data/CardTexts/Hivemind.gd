extends Node

const card_text : Dictionary = {
	"Name" : "Hivemind",
	"[ContactFusion]" : "Attach 2 \"Invader\" in your hand to this card, but only once per turn.",
	"[Field]" : "This card's power is equal to twice the number of \"Invader\" on your field.",
	"[Once]" : "Reverse any attack targeting this card during your opponent's turn."
}

static func info():
	return card_text
