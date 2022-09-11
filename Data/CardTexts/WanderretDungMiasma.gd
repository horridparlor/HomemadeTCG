extends Node

const card_text : Dictionary = {
	"Name" : "Wanderret - Dung Miasma",
	"[ContactFusion]" : "Attach 2 non-fusion friends to this card. Only once per turn.",
	"[Play]" : "Play a \"Wanderret\" token.",
	"[Field]" : "This card's power is equal to the  number of \"Wanderret\" on your field."
}

static func info():
	return card_text
