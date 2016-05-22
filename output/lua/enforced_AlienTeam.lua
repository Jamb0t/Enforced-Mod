local NewcheckForLostResearch =
{
	[kTechId.RegenerationShell] = { "Shell", kTechId.Regeneration },
	[kTechId.CarapaceShell] = { "Shell", kTechId.Carapace },

	[kTechId.CeleritySpur] = { "Spur", kTechId.Celerity },
	[kTechId.AdrenalineSpur] = { "Spur", kTechId.Adrenaline },

	[kTechId.AuraVeil] = { "Veil", kTechId.Aura },
	[kTechId.PhantomVeil] = { "Veil", kTechId.Phantom }
}

ReplaceLocals(AlienTeam.OnResearchComplete, { checkForGainedResearch = NewcheckForGainedResearch })

local NewcheckForGainedResearch =
{
	[kTechId.UpgradeRegenerationShell] = kTechId.Regeneration,
	[kTechId.UpgradeCarapaceShell] = kTechId.Carapace,

	[kTechId.UpgradeCeleritySpur] = kTechId.Celerity,
	[kTechId.UpgradeAdrenalineSpur] = kTechId.Adrenaline,

	[kTechId.UpgradePhantomVeil] = kTechId.Phantom,
	[kTechId.UpgradeAuraVeil] = kTechId.Aura,
}

ReplaceLocals(AlienTeam.OnUpgradeChamberDestroyed, { checkForLostResearch = NewcheckForLostResearch })
