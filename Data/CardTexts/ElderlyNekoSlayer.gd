extends Node

const card_text : Dictionary = {
	"Name" : "Elderly Neko-Slayer",
	"[ContactFusion]" : "Attach 2 friends to this card, but only once per turn.",
	"[Field]" : "This card can attack up to the number of times there are \"Neko\" on the field per turn.",
	"[Detach]" : "Destroy target non-fusion enemy."
}

static func info():
	return card_text
