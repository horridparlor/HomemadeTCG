extends Node

const enemy_names : Array = [
	{
		"event" : "Gatling Baboon",
		"resource" : "AbsolutePredatorGatlingBaboon"
	},
	{
		"event" : "Doom Hydra",
		"resource" : "DoomHydra"
	},
	{
		"event" : "God of Future",
		"resource" : "DragonGodMirai"
	},
	{
		"event" : "Absolution",
		"resource" : "DragonGodOfAbsolution"
	},
	{
		"event" : "God of Chaos",
		"resource" : "DragonGodOfChaos"
	},
	{
		"event" : "God of Death",
		"resource" : "DragonGodOfDeath"
	},
	{
		"event" : "God of Lies",
		"resource" : "DragonGodOfLies"
	},
	{
		"event" : "Retribution",
		"resource" : "DragonGodOfRetribution"
	},
	{
		"event" : "Alpha Flamenjoin",
		"resource" : "FlamenjoinIgnited"
	},
	{
		"event" : "Miss Latosse",
		"resource" : "OnlymaidsRefinia"
	}
]

static func info():
	return {
		"database" : enemy_names
	}
