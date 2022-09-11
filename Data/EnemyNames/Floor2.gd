extends Node

const enemy_names : Array = [
	{
		"event" : "Apeshit",
		"resource" : "AbsolutePredatorApeshit"
	},
	{
		"event" : "Hammagal",
		"resource" : "BabySharkHammagal"
	},
	{
		"event" : "Bunny-Saurus",
		"resource" : "BunnySaurus",
		"highlight" : "BunnyGirlChampion"
	},
	{
		"event" : "Flamenjoin"
	},
	{
		"event" : "Hydra Spawn",
		"resource" : "HydraSpawn"
	},
	{
		"event" : "Moderator",
		"resource" : "InvaderModerator",
		"highlight" : "InvaderWarlord"
	},
	{
		"event" : "Mairiko-chan",
		"resource" : "NekoSisterCherryPawsMairikoChan"
	},
	{
		"event" : "Brazen Bulk",
		"resource" : "RefrigeratorCoffin"
	},
	{
		"event" : "Skiier-Skippy",
		"resource" : "SkippyTheSkiier",
		"highlight" : "SkiingMantisBudwingHunk"
	},
	{
		"event" : "Wanderret",
	}
]

static func info():
	return {
		"database" : enemy_names
	}
