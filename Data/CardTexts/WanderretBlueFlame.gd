extends Node

const card_text : Dictionary = {
	"Name" : "Wanderret - Blue Flame",
	"[Hand]" : "While there is a \"Wanderret\" with a different name on your field, you can additionally play this card. Only once per turn.",
	"[Play]" : "Your opponent loses life equal to the number of \"Wanderret\" on the field. Only once per turn.",
	"[Void + 1]" : "Your opponent loses 2 life, but only once per turn."
}

static func info():
	return card_text
