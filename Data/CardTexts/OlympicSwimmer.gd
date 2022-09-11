extends Node

const card_text : Dictionary = {
	"Name" : "Olympic Swimmer",
	"[ContactFusion]" : "Attach to this card; 2 \"Refrigerator\" sent to your graveyard this turn. Only once per turn.",
	"[Once]" : "This card cannot be destroyed by attack. Detach all \"Refrigerator\" attached to this card to restore this effect."
}

static func info():
	return card_text
