extends Node

const card_text : Dictionary = {
	"Name" : "Invader Warlord",
	"[ContactFusion]" : "Attach a non-fusion friend to this card, but only once per turn.",
	"[Field]" : "This card's power is equal to the number of \"Invader\" on your field."
}

static func info():
	return card_text
