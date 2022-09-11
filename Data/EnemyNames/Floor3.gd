extends Node

const enemy_names : Array = [
	{
		"event" : "Doyen Owl",
		"resource" : "DoyenOwl"
	},
	{
		"event" : "Paramedic",
		"resource" : "AbsolutePredatorParamedic"
	},
	{
		"event" : "Bricklayer"
	},
	{
		"event" : "Bunny Champ",
		"resource" : "BunnyGirlChampion"
	},
	{
		"event" : "Mill Cabinet",
		"resource" : "CNCMachineMillCabinet"
	},
	{
		"event" : "Female Dile",
		"resource" : "FemaleDile",
		"highlight" : "EmeraldShogun"
	},
	{
		"event" : "Many the Cat",
		"resource" : "ManyCat",
		"highlight" : "OnlymaidsCatMother"
	},
	{
		"event" : "Shark Summoner",
		"resource" : "SharkSummoner"
	},
	{
		"event" : "Ice Swimmer",
		"resource" : "SwimmingWithRefrigerators"
	},
	{
		"event" : "Wanderrets",
		"resource" : "WanderretInfestation"
	}
]

static func info():
	return {
		"database" : enemy_names
	}
