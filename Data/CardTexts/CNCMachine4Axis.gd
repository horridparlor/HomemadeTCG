extends Node

const card_text : Dictionary = {
	"Name" : "CNC Machine - 4-Axis",
	"[Hand]" : "While there is a \"CNC\" friend with a different name, you can additionally play this card. Only once per turn.",
	"[Field]" : "This card's power is equal to the number of \"CNC Machine\" in your graveyard."
}

static func info():
	return card_text
