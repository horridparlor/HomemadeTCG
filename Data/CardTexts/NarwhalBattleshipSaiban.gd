extends Node

const card_text : Dictionary = {
	"Name" : "Narwhal Battleship - Saiban",
	"[ContactFusion]" : "2 friends with a void-triggered effect, but add this card to your hand when it leaves the field. Only once per turn.",
	"[Discard]" : "Search a card with a void-triggered effect. Only once per turn.",
	"[Play]" : "This card transforms into a random card with a void-triggered effect in your graveyard, then copy its void-triggered effect."
}

static func info():
	return card_text
