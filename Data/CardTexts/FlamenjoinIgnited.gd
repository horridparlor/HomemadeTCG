extends Node

const card_text : Dictionary = {
	"Name" : "Flamenjoin Ignited",
	"[ContactFusion]" : "2 friends with different names, but only once per turn.",
	"[Play]" : "Search a \"Flamenjoin\", and place it on the top of your deck.",
	"[Field]" : "This card's power is equal to the number of cards with the same name on the top of your deck."
}

static func info():
	return card_text
