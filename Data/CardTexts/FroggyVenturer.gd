extends Node

const card_text : Dictionary = {
	"Name" : "Froggy-Venturer",
	"[Play]" : "If this is your first card played this turn, play a copy of a random differently named card in your deck.",
	"[Field]" : "This card's power is equal to 1 plus the number of tokens on the field."
}

static func info():
	return card_text
