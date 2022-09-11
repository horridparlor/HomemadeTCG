extends Node

const enemy_names : Array = [
	{
		"event" : "Donut King",
		"resource" : "AngryDonutKing"
	},
	{
		"event" : "The World",
		"resource" : "TheWorld"
	},
	{
		"event" : "Deadly Twins",
		"resource" : "TwinMaidsOfDeath"
	}
]

static func info():
	return {
		"database" : enemy_names
	}
