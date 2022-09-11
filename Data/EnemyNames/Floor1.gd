extends Node

const enemy_names : Array = [
	{
		"event" : "Infantry",
		"resource" : "AbsolutePredatorSimianInfantry"
	},
	{
		"event" : "4-Axis",
		"resource" : "CNCMachine4Axis"
	},
	{
		"event" : "Donut Shark",
		"resource" : "DonutShark"
	},
	{
		"event" : "PC - Bug",
		"resource" : "InvaderBugInTheSimulation"
	},
	{
		"event" : "Neko Sister",
		"resource" : "NekoSisterWhiteCrescent"
	},
	{
		"event" : "Thick Lassie",
		"resource" : "OnlymaidsThickLassie"
	},
	{
		"event" : "Steelen Monk",
		"resource" : "RefrigeratorMonk"
	},
	{
		"event" : "Supo Mobile",
		"resource" : "SupoMobile",
		"highlight" : "VainamoinenI"
	},
	{
		"event" : "Vampire Boy",
		"resource" : "VampireBoy",
		"highlight" : "MushyFunguy"
	},
	{
		"event" : "White Husk",
		"resource" : "WanderretWhiteHusk"
	}
]

static func info():
	return {
		"database" : enemy_names
	}
