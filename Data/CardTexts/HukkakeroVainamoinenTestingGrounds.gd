extends Node

const card_text : Dictionary = {
	"Name" : "Hukkakero - Vainamoinen Testing Grounds",
	"[Hand]" : "You can attach this card to a friend. Only once per turn.",
	"[Detach]" : "Destroy random enemy. Only while there are 3 or more enemies, and only once per turn. "
}

static func info():
	return card_text
