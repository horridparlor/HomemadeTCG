extends Node

const enemy_names : Array = [
	{
		"event" : "Kamikaze",
		"resource" : "AbsolutePredatorKamikaze"
	},
	{
		"event" : "Caripean",
		"resource" : "BabySharkCaripean"
	},
	{
		"event" : "Chaos Imp",
		"resource" : "ChaosImp",
		"highlight" : "ChaosFollower"
	},
	{
		"event" : "Dark Cavalry",
		"resource" : "DarkCavalry"
	},
	{
		"event" : "Deadly Mimic",
		"resource" : "DeadlyMimic"
	},
	{
		"event" : "Hivemind"
	},
	{
		"event" : "Olympic Swimmer",
		"resource" : "OlympicSwimmer"
	},
	{
		"event" : "10 out of 10",
		"resource" : "OnlymaidsSingleMom"
	},
	{
		"event" : "Snow Orchid",
		"resource" : "SkiingMantisSnowOrchid"
	},
	{
		"event" : "Dung Miasma",
		"resource" : "WanderretDungMiasma"
	}
]

static func info():
	return {
		"database" : enemy_names
	}
