local NewcheckForLostResearch =
{
	[kTechId.RegenerationShell] = { "Shell", kTechId.Regeneration },
	[kTechId.CarapaceShell] = { "Shell", kTechId.Carapace },
	[kTechId.CrushShell] = { "Shell", kTechId.Crush },
	
	[kTechId.CeleritySpur] = { "Spur", kTechId.Celerity },
	[kTechId.AdrenalineSpur] = { "Spur", kTechId.Adrenaline },
	[kTechId.SilenceSpur] = { "Spur", kTechId.Silence },
	
	[kTechId.AuraVeil] = { "Veil", kTechId.Aura },
	[kTechId.VampirismVeil] = { "Veil", kTechId.Vampirism }
}

ReplaceLocals(AlienTeam.OnResearchComplete, { checkForGainedResearch = NewcheckForGainedResearch })

local NewcheckForGainedResearch =
{
	[kTechId.UpgradeCrushShell] = kTechId.Crush,
	[kTechId.UpgradeRegenerationShell] = kTechId.Regeneration,
	[kTechId.UpgradeCarapaceShell] = kTechId.Carapace,
	
	[kTechId.UpgradeCeleritySpur] = kTechId.Celerity,
	[kTechId.UpgradeAdrenalineSpur] = kTechId.Adrenaline,
	[kTechId.UpgradeSilenceSpur] = kTechId.Silence,
	
	[kTechId.UpgradeVampirismVeil] = kTechId.Vampirism,
	[kTechId.UpgradeAuraVeil] = kTechId.Aura,
}

ReplaceLocals(AlienTeam.OnUpgradeChamberDestroyed, { checkForLostResearch = NewcheckForLostResearch })
