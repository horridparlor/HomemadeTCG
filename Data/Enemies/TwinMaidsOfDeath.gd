extends Node

const deck_formula : Dictionary = {
	"Main" : {
		"HollowedWanderret" : 2,
		"OnlymaidsBlackjack" : 2,
		"OnlymaidsCatMother" : 2,
		"OnlymaidsSingleMom" : 2,
		"Wanderret" : 2,
		"WanderretBlueFlame" : 2,
		"WanderretWhiteHusk" : 2
	},
	"Grave" : {
		"ApprenticeWizard" : 1,
		"DeadlyMimic" : 1,
		"DragonGodMirai" : 1,
		"DragonGodOfDeath" : 1,
		"DragonGodOfPeace" : 1,
		"ExtinctionHydra" : 1,
		"NarwhalBattleshipJustisu" : 2,
		"NarwhalBattleshipSaiban" : 2,
		"Slenderret" : 2,
		"TwinMaidsOfDeath" : 2,
		"WanderretDungMiasma" : 2,
		"WanderretInfestation" : 2
	}
}

static func info():
	return deck_formula
